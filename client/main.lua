local isSelling = false
local activeTargetPeds = {}
local usedNpcs = {}
local lastSellTime = 0
local hasDrugsCallback = nil

-- Command to get player coords for testing
RegisterCommand('getcoords', function()
    local coords = GetEntityCoords(PlayerPedId())
    print(('vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
end, false)

-- Add drug processing zones to ox_target
CreateThread(function()
    for drugId, drug in pairs(Config.Drugs) do
        if drug.enabled and drug.locations then
            for _, coords in pairs(drug.locations) do
                exports['ox_target']:addBoxZone({
                    coords = coords,
                    size = vec3(1.0, 1.0, 1.0),
                    rotation = 0,
                    debug = false,
                    options = {
                        {
                            label = ('Process %s'):format(drug.label),
                            icon = 'fa-solid fa-vial',
                            onSelect = function()
                                TriggerServerEvent('snake-drugs:processDrug', drugId)
                            end,
                            canInteract = function()
                                return true
                            end
                        }
                    }
                })
            end
        end
    end
end)

-- Handle server response for checking if player has drugs to sell
RegisterNetEvent('snake-drugs:hasDrugsResponse', function(result)
    if hasDrugsCallback then
        hasDrugsCallback(result)
        hasDrugsCallback = nil
    end
end)

-- Check if player has drugs to sell
function HasDrugsToSell(cb)
    hasDrugsCallback = cb
    TriggerServerEvent('snake-drugs:hasDrugsToSell')
end

-- Get nearby NPC peds within radius
function GetNearbyPeds(radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local nearby = {}

    local handle, foundPed = FindFirstPed()
    local success
    repeat
        if foundPed ~= ped and not IsPedAPlayer(foundPed) and not IsPedDeadOrDying(foundPed) then
            local dist = #(coords - GetEntityCoords(foundPed))
            if dist <= radius then
                table.insert(nearby, foundPed)
            end
        end
        success, foundPed = FindNextPed(handle)
    until not success
    EndFindPed(handle)

    return nearby
end

-- Enable selling interaction with NPCs
function EnableSelling()
    isSelling = true
    usedNpcs = {}

    CreateThread(function()
        while isSelling do
            Wait(Config.Selling.sellCooldown or 5000)

            -- Remove old target entities
            for _, ped in ipairs(activeTargetPeds) do
                exports['ox_target']:removeEntity(ped)
            end
            activeTargetPeds = {}

            local peds = GetNearbyPeds(Config.Selling.interactionDistance or 3.0)
            for _, ped in pairs(peds) do
                exports['ox_target']:addLocalEntity(ped, {
                    {
                        name = 'drug_sell_' .. tostring(ped),
                        label = 'Sell Drugs',
                        icon = Config.Selling.sellInteractionIcon or 'fas fa-hand-holding-usd',
                        canInteract = function()
                            local cooldown = (GetGameTimer() - lastSellTime) > (Config.Selling.sellCooldown or 5000)
                            return isSelling and cooldown
                        end,
                        onSelect = function()
                            if usedNpcs[ped] then
                                if Config.Selling.notifyAlreadySold then
                                    TriggerEvent('ox_lib:notify', {
                                        title = 'Not Interested',
                                        description = Config.Selling.notifyAlreadySoldMessage or "This person is not interested.",
                                        type = 'error',
                                        position = Config.Selling.notifyPosition or 'top'
                                    })
                                end
                                return
                            end

                            HasDrugsToSell(function(hasDrugs)
                                if hasDrugs then
                                    usedNpcs[ped] = true

                                    local rejectionConfig = Config.Selling.rejection or {}
                                    local shouldReject = rejectionConfig.enabled and math.random() < (rejectionConfig.chance or 0.2)

                                    if shouldReject then
                                        if rejectionConfig.notifyPlayer then
                                            TriggerEvent('ox_lib:notify', {
                                                title = 'Offer Rejected',
                                                description = 'This person freaked out and ran off!',
                                                type = 'error',
                                                position = rejectionConfig.rejectionNotifyPosition or 'top'
                                            })
                                        end

                                        if rejectionConfig.runAway and DoesEntityExist(ped) then
                                            TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, false, false)
                                            SetPedKeepTask(ped, true)
                                        end

                                        if rejectionConfig.alertPolice then
                                            local coords = GetEntityCoords(PlayerPedId())
                                            TriggerServerEvent('snake-drugs:alertPolice', {
                                                coords = coords,
                                                drug = 'rejection'
                                            })
                                        end

                                        exports['ox_target']:removeEntity(ped)
                                        for i, activePed in ipairs(activeTargetPeds) do
                                            if activePed == ped then
                                                table.remove(activeTargetPeds, i)
                                                break
                                            end
                                        end
                                        return
                                    end

                                    -- NPC accepts sale
                                    lastSellTime = GetGameTimer()
                                    TriggerServerEvent('snake-drugs:sellDrugs')

                                    if DoesEntityExist(ped) then
                                        TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, false, false)
                                        SetPedKeepTask(ped, true)
                                    end

                                    exports['ox_target']:removeEntity(ped)
                                    for i, activePed in ipairs(activeTargetPeds) do
                                        if activePed == ped then
                                            table.remove(activeTargetPeds, i)
                                            break
                                        end
                                    end
                                else
                                    DisableSelling()
                                    TriggerEvent('ox_lib:notify', {
                                        title = 'No Drugs',
                                        description = 'You have no drugs to sell. Selling stopped.',
                                        type = 'error',
                                        position = Config.Selling.notifyPosition or 'top'
                                    })
                                end
                            end)
                        end
                    }
                })
                table.insert(activeTargetPeds, ped)
            end
        end
    end)
end

-- Disable selling interaction
function DisableSelling()
    isSelling = false
    for _, ped in ipairs(activeTargetPeds) do
        exports['ox_target']:removeEntity(ped)
    end
    activeTargetPeds = {}
    usedNpcs = {}
end

-- Command to toggle selling
RegisterCommand('drugsell', function()
    if isSelling then
        DisableSelling()
        TriggerEvent('ox_lib:notify', {
            title = 'Stopped Selling',
            description = 'You have stopped selling.',
            type = 'error',
            position = Config.Selling.notifyPosition or 'top'
        })
    else
        HasDrugsToSell(function(hasDrugs)
            if hasDrugs then
                EnableSelling()
                TriggerEvent('ox_lib:notify', {
                    title = 'Selling Drugs',
                    description = 'You are now selling.',
                    type = 'inform',
                    position = Config.Selling.notifyPosition or 'top'
                })
            else
                TriggerEvent('ox_lib:notify', {
                    title = 'No Drugs',
                    description = 'You require drugs to start selling.',
                    type = 'error',
                    position = Config.Selling.notifyPosition or 'top'
                })
            end
        end)
    end
end)

-- Law alert blip handler
RegisterNetEvent('snake-drugs:lawAlert', function(data)
    if not data or not Config.LawAlerts.enabled then return end

    if Config.LawAlerts.blip and data.coords then
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, Config.LawAlerts.blipSprite or 161)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, Config.LawAlerts.blipColor or 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Suspicious Activity")
        EndTextCommandSetBlipName(blip)

        Citizen.Wait((Config.LawAlerts.blipTime or 30) * 1000)
        RemoveBlip(blip)
    end
end)

-- ===== OPIUM USAGE INTEGRATION =====

-- Function to attempt to use opium
function UseOpium()
    -- Trigger server to check for opium and opium pipe
    TriggerServerEvent('snake-drugs:useOpium')
end

-- Listen for server response about opium usage
RegisterNetEvent('snake-drugs:opiumResult', function(success, reason)
    local ped = PlayerPedId()

    if not success then
        local msg = reason == 'missing_pipe' and 'You need an opium pipe to use this.'
                    or reason == 'missing_opium' and 'You need opium to do that.'
                    or 'Unknown error.'
        TriggerEvent('ox_lib:notify', {
            title = 'Opium Use Failed',
            description = msg,
            type = 'error',
            position = Config.Selling.notifyPosition or 'top'
        })
        return
    end

    -- Start smoking animation and freeze player
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING", 0, true)
    FreezeEntityPosition(ped, true)

    Citizen.Wait(5000)  -- duration of smoking

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)

    -- Fade effect
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)

    -- Visual effects
    SetTimecycleModifier("hud_def_blur")
    SetTimecycleModifierStrength(1.5)

    -- Drunk movement + camera shake
    SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1.0)
    ShakeGameplayCam("DRUNK_SHAKE", 0.8)

    -- Buff duration 30 seconds
    local startTime = GetGameTimer()
    local duration = 30000

    Citizen.CreateThread(function()
        while GetGameTimer() - startTime < duration do
            -- Heal player slowly (max health)
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            if health < maxHealth then
                SetEntityHealth(ped, math.min(health + 1, maxHealth))
            end

            -- Restore stamina
            RestorePlayerStamina(PlayerId(), 1.0)

            Citizen.Wait(1000)
        end

        -- Remove effects after duration
        ClearTimecycleModifier()
        ResetPedMovementClipset(ped, 0.0)
        ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    end)
end)

-- Register usable item for opium pipe
exports['rsg-inventory']:RegisterUsableItem('opiumpipe', function()
    UseOpium()
end)

-- Optional command to test using opium pipe
RegisterCommand('useopium', function()
    UseOpium()
end)
