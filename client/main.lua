local isSelling = false
local activeTargetPeds = {}
local lastSellTime = 0

-- /getcoords helper command
RegisterCommand('getcoords', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    print(('vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
end, false)

-- Setup drug processing zones from Config.Drugs using ox_target
CreateThread(function()
    for drugId, drug in pairs(Config.Drugs) do
        if drug.enabled and drug.locations then
            for _, coords in pairs(drug.locations) do
                exports['ox_target']:addBoxZone({
                    coords = coords,
                    size = vec3(1.0, 1.0, 1.0),
                    rotation = 0,
                    debug = true,
                    options = {
                        {
                            label = ('Process %s'):format(drug.label),
                            icon = 'fa-solid fa-vial',
                            onSelect = function()
                                ProcessDrug(drugId)
                            end
                        }
                    }
                })
            end
        end
    end
end)

function ProcessDrug(drugId)
    TriggerServerEvent('snake-drugs:processDrug', drugId)
end

function GetNearbyPeds(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyPeds = {}

    local handle, ped = FindFirstPed()
    local success
    repeat
        local pedCoords = GetEntityCoords(ped)
        local dist = #(playerCoords - pedCoords)

        if ped ~= playerPed and not IsPedAPlayer(ped) and dist <= radius and not IsPedDeadOrDying(ped, true) then
            table.insert(nearbyPeds, ped)
        end

        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)

    return nearbyPeds
end

function EnableSelling()
    isSelling = true

    CreateThread(function()
        while isSelling do
            Wait(5000)

            for _, ped in pairs(activeTargetPeds) do
                exports['ox_target']:removeEntity(ped)
            end
            activeTargetPeds = {}

            local peds = GetNearbyPeds(Config.Selling.interactionDistance or 20.0)

            for _, ped in pairs(peds) do
                exports['ox_target']:addLocalEntity(ped, {
                    {
                        name = 'drug_sell_' .. tostring(ped),
                        label = 'Sell Drugs',
                        icon = Config.Selling.sellInteractionIcon or 'fas fa-hand-holding-usd',
                        canInteract = function()
                            return isSelling and (GetGameTimer() - lastSellTime) > (Config.Selling.sellCooldown or 5000)
                        end,
                        onSelect = function()
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
                        end
                    }
                })
                table.insert(activeTargetPeds, ped)
            end
        end
    end)
end

function DisableSelling()
    isSelling = false
    for _, ped in pairs(activeTargetPeds) do
        exports['ox_target']:removeEntity(ped)
    end
    activeTargetPeds = {}
end

RegisterCommand('drugsell', function()
    if not isSelling then
        TriggerEvent('ox_lib:notify', {
            title = 'Selling Drugs',
            description = 'You are now selling.',
            type = 'inform',
            position = Config.Selling.notifyPosition or 'top'
        })
        EnableSelling()
    else
        TriggerEvent('ox_lib:notify', {
            title = 'Stopped Selling',
            description = 'You are no longer selling.',
            type = 'error',
            position = Config.Selling.notifyPosition or 'top'
        })
        DisableSelling()
    end
end)

-- Law Alert Handler (respects Config.LawAlerts)
RegisterNetEvent('snake-drugs:lawAlert', function(data)
    if not data or not Config.LawAlerts.enabled then return end

    -- Notify police via ox_lib
    if Config.LawAlerts.notify and data.message then
        TriggerEvent('ox_lib:notify', {
            title = 'Suspicious Activity',
            description = data.message,
            type = Config.LawAlerts.notifyType or 'error',
            position = Config.LawAlerts.notifyPosition or 'top'
        })
    end

    -- Show blip on map
    if Config.LawAlerts.blip and data.coords then
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, Config.LawAlerts.blipSprite or 161)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, Config.LawAlerts.blipColor or 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Suspicious Activity")
        EndTextCommandSetBlipName(blip)

        Wait((Config.LawAlerts.blipTime or 30) * 1000)
        RemoveBlip(blip)
    end
end)
