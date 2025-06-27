local PlayerReputation = {} -- [playerId] = {points = int, lastSale = timestamp}
local SavePath = 'data/reputation_data.json'

-- Helpers
local function GetIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then
            return id
        end
    end
    return nil
end

local function LoadReputationFile()
    local content = LoadResourceFile(GetCurrentResourceName(), SavePath)
    if content then
        local data = json.decode(content)
        if type(data) == "table" then
            return data
        end
    end
    return {}
end

local function SaveReputationFile(data)
    SaveResourceFile(GetCurrentResourceName(), SavePath, json.encode(data, { indent = true }))
end

-- Load on resource start (optional if you want global rep memory)
local SavedReputation = LoadReputationFile()

-- Get tier from points
local function GetReputationTier(points)
    for tierIndex, tierData in pairs(Config.Reputation.tiers) do
        if points >= tierData.minRep and points <= tierData.maxRep then
            return tierIndex, tierData.name
        end
    end
    local maxTierIndex = #Config.Reputation.tiers
    return maxTierIndex, Config.Reputation.tiers[maxTierIndex].name
end

-- Add reputation points
local function AddReputationPoints(playerId, drugName, amount)
    local identifier = GetIdentifier(playerId)
    if not identifier then return end

    local rep = PlayerReputation[playerId] or {points = 0, lastSale = 0}
    local drug = Config.Drugs[drugName]
    if not drug or not drug.sell or not drug.sell.repGain then
        print(("[snake-drugs] No repGain configured for drug: %s"):format(drugName))
        return
    end

    local gain = drug.sell.repGain * amount
    rep.points = rep.points + gain
    rep.lastSale = os.time()
    PlayerReputation[playerId] = rep

    local tierIndex, tierName = GetReputationTier(rep.points)
    print(("[snake-drugs] Player %d sold %d %s, gained %d rep points, total %d (%s)"):format(playerId, amount, drugName, gain, rep.points, tierName))

    -- Save to file
    SavedReputation[identifier] = rep
    SaveReputationFile(SavedReputation)

    -- Sync to client
    TriggerClientEvent("snake-drugs:updateReputation", playerId, tierIndex, rep.points)
end

-- Reputation decay system
local function DecayReputation(playerId)
    local rep = PlayerReputation[playerId]
    if not rep then return end

    local now = os.time()
    local secondsInactive = now - rep.lastSale
    local decayThreshold = Config.Reputation.decayDays * 86400

    if secondsInactive >= decayThreshold then
        rep.points = math.max(0, rep.points - Config.Reputation.decayAmount)
        rep.lastSale = now
        PlayerReputation[playerId] = rep

        local tierIndex, tierName = GetReputationTier(rep.points)
        print(("[snake-drugs] Player %d reputation decayed by %d points to %d (%s) due to inactivity"):format(playerId, Config.Reputation.decayAmount, rep.points, tierName))

        -- Save decay
        local identifier = GetIdentifier(playerId)
        if identifier then
            SavedReputation[identifier] = rep
            SaveReputationFile(SavedReputation)
        end

        -- Sync
        TriggerClientEvent("snake-drugs:updateReputation", playerId, tierIndex, rep.points)
    end
end

-- Decay thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- 1 hour
        for _, playerId in ipairs(GetPlayers()) do
            DecayReputation(tonumber(playerId))
        end
    end
end)

-- Load rep on connect
AddEventHandler('playerConnecting', function(_, _, deferrals)
    local src = source
    local identifier = GetIdentifier(src)
    if identifier and SavedReputation[identifier] then
        PlayerReputation[src] = SavedReputation[identifier]
    else
        PlayerReputation[src] = { points = 0, lastSale = 0 }
    end
end)

-- Save rep on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    local identifier = GetIdentifier(src)
    if identifier and PlayerReputation[src] then
        SavedReputation[identifier] = PlayerReputation[src]
        SaveReputationFile(SavedReputation)
        PlayerReputation[src] = nil
    end
end)

-- Event to manually request rep from client (/rep or on spawn)
RegisterNetEvent("snake-drugs:getReputation")
AddEventHandler("snake-drugs:getReputation", function()
    local src = source
    local rep = PlayerReputation[src] or { points = 0, lastSale = 0 }
    local tierIndex, _ = GetReputationTier(rep.points)
    TriggerClientEvent("snake-drugs:updateReputation", src, tierIndex, rep.points)
end)

-- Optional: still supports legacy trigger-based gain
RegisterNetEvent("snake-drugs:sellDrug")
AddEventHandler("snake-drugs:sellDrug", function(drugName, amount)
    local playerId = source
    AddReputationPoints(playerId, drugName, amount)
end)

-- Export for external usage
exports('AddDrugReputation', function(playerId, drugName, amount)
    AddReputationPoints(playerId, drugName, amount)
end)

print("[snake-drugs] Server reputation system loaded with file-based persistence.")
