-- Alert Cops when drug activity is detected
function AlertCops(sellerSrc, item, amount)
    local ped = GetPlayerPed(sellerSrc)
    if not ped then return end
    local coords = GetEntityCoords(ped)

    for _, playerId in ipairs(GetPlayers()) do
        local target = exports['rsg-inventory']:GetPlayer(playerId)
        if target and target.PlayerData.job then
            local jobName = target.PlayerData.job.name
            if jobName == "police" or jobName == "sheriff" then
                if Config.LawAlerts.notify then
                    TriggerClientEvent('snake-drugs:lawAlert', playerId, {
                        sellerSrc = sellerSrc,
                        item = item,
                        amount = amount,
                        coords = coords,
                        message = Config.LawAlerts.lawAlertMessage
                            or ("Suspicious drug activity: %d x %s being sold nearby!"):format(amount, item)
                    })
                end

                if Config.LawAlerts.blip then
                    TriggerClientEvent('snake-drugs:blip', playerId, coords,
                        Config.LawAlerts.blipTime or 30,
                        Config.LawAlerts.blipSprite or 161,
                        Config.LawAlerts.blipColor or 1)
                end
            end
        end
    end

    print(('[snake-drugs][ALERT] Law notified: %dx %s by player %d'):format(amount, item, sellerSrc))
end

-- NPC Rejection Alert (triggered by client)
RegisterServerEvent('snake-drugs:alertPolice')
AddEventHandler('snake-drugs:alertPolice', function(data)
    if not Config.LawAlerts.enabled or not data or not data.coords then return end

    for _, playerId in ipairs(GetPlayers()) do
        local target = exports['rsg-inventory']:GetPlayer(playerId)
        if target and target.PlayerData.job then
            local job = target.PlayerData.job.name
            if job == "police" or job == "sheriff" then
                if Config.LawAlerts.notify then
                    TriggerClientEvent('snake-drugs:lawAlert', playerId, {
                        coords = data.coords,
                        item = data.drug or "unknown",
                        message = "A civilian reported suspicious drug activity nearby!"
                    })
                end

                if Config.LawAlerts.blip then
                    TriggerClientEvent('snake-drugs:blip', playerId, data.coords,
                        Config.LawAlerts.blipTime or 30,
                        Config.LawAlerts.blipSprite or 161,
                        Config.LawAlerts.blipColor or 1)
                end
            end
        end
    end

    print(('[snake-drugs][ALERT] NPC reported player for %s at %s'):format(data.drug or "unknown", json.encode(data.coords)))
end)

-- Drug Processing
RegisterServerEvent('snake-drugs:processDrug')
AddEventHandler('snake-drugs:processDrug', function(drugId)
    local src = source
    local drug = Config.Drugs[drugId]
    if not drug or not drug.enabled then return end

    local player = exports['rsg-inventory']:GetPlayer(src)
    if not player then return end

    local items = player.PlayerData.items or {}
    local missingIngredient = false
    local pestleSlot, pestleItem

    for itemName, requiredAmount in pairs(drug.ingredients) do
        local found = false
        for slot, item in pairs(items) do
            if item.name == itemName and (item.amount or 0) >= requiredAmount then
                found = true
                if itemName == "pestleandmortar" then
                    pestleSlot = slot
                    pestleItem = item
                end
                break
            end
        end
        if not found then
            missingIngredient = true
            break
        end
    end

    if missingIngredient then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Processing Failed',
            description = 'Missing required ingredients.',
            type = 'error',
            position = Config.Selling.notifyPosition
        })
        return
    end

    for itemName, amount in pairs(drug.ingredients) do
        if itemName ~= "pestleandmortar" then
            player.Functions.RemoveItem(itemName, amount)
        end
    end

    if pestleItem and Config.Tools.pestleandmortar.degrade then
        local info = pestleItem.info or {}
        local loss = Config.Tools.pestleandmortar.loss or 1
        local breakAt = Config.Tools.pestleandmortar.breakAt or 0
        local defaultQuality = Config.Tools.pestleandmortar.defaultQuality or 100

        info.quality = (info.quality or defaultQuality) - loss
        player.Functions.RemoveItem("pestleandmortar", 1, pestleSlot)

        if info.quality <= breakAt then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Item Broke',
                description = 'Your Pestle and Mortar broke.',
                type = 'error',
                position = Config.Selling.notifyPosition
            })
        else
            player.Functions.AddItem("pestleandmortar", 1, nil, info)
        end
    end

    player.Functions.AddItem(drug.output.item, drug.output.amount)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Processing Complete',
        description = ('Received %dx %s.'):format(drug.output.amount, drug.label),
        type = 'success',
        position = Config.Selling.notifyPosition
    })

    print(('[snake-drugs] Player %d processed %dx %s'):format(src, drug.output.amount, drug.label))
end)

-- Sell Drugs
RegisterServerEvent('snake-drugs:sellDrugs')
AddEventHandler('snake-drugs:sellDrugs', function()
    local src = source
    local player = exports['rsg-inventory']:GetPlayer(src)
    if not player then return end

    if not Config.Selling.enabled then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Selling Disabled',
            description = 'Drug selling is currently disabled.',
            type = 'error',
            position = Config.Selling.notifyPosition
        })
        return
    end

    local items = player.PlayerData.items or {}
    local totalSold, totalEarned = 0, 0
    local alertedLaw = false

    for drugId, drug in pairs(Config.Drugs) do
        if drug.enabled and drug.sell and drug.sell.enabled then
            for slot, item in pairs(items) do
                if item.name == drug.output.item and (item.amount or 0) > 0 then
                    if Config.Selling.rejection.enabled and math.random() < (Config.Selling.rejection.chance or 0) then
                        if Config.Selling.rejection.notifyPlayer then
                            TriggerClientEvent('ox_lib:notify', src, {
                                title = Config.Selling.declineNotification.title,
                                description = Config.Selling.declineNotification.description,
                                type = Config.Selling.declineNotification.type,
                                position = Config.Selling.declineNotification.position
                            })
                        end

                        if Config.Selling.rejection.runAway then
                            TriggerClientEvent('snake-drugs:npcRunAway', src)
                        end

                        if Config.Selling.rejection.alertPolice and Config.LawAlerts.enabled then
                            local ped = GetPlayerPed(src)
                            if ped then
                                local coords = GetEntityCoords(ped)
                                TriggerEvent('snake-drugs:alertPolice', { coords = coords, drug = item.name })
                            end
                        end
                        return
                    end

                    local amountToSell = math.random(drug.sell.minSellAmount or 1, drug.sell.maxSellAmount or 5)
                    amountToSell = math.min(amountToSell, item.amount)
                    local price = drug.sell.price or 10
                    local payment = price * amountToSell

                    player.Functions.RemoveItem(item.name, amountToSell)
                    player.Functions.AddMoney("cash", payment)

                    totalSold = totalSold + amountToSell
                    totalEarned = totalEarned + payment

                    print(('[snake-drugs] Player %d sold %dx %s for $%d'):format(src, amountToSell, item.name, payment))

                    if Config.LawAlerts.enabled and not alertedLaw and math.random() <= (drug.sell.lawAlertChance or 0) then
                        alertedLaw = true
                        AlertCops(src, item.name, amountToSell)
                    end

                    break
                end
            end
        end
    end

    if totalSold > 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Drugs Sold',
            description = ('Sold %d item(s) for $%d'):format(totalSold, totalEarned),
            type = 'success',
            position = Config.Selling.notifyPosition
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'No Drugs to Sell',
            description = 'You have no drugs to sell.',
            type = 'error',
            position = Config.Selling.notifyPosition
        })
    end
end)

-- Custom Opium Usage Handler (supports rsg-inventory and degradation)
RegisterServerEvent('snake-drugs:useOpium')
AddEventHandler('snake-drugs:useOpium', function()
    local src = source
    local inventory = exports['rsg-inventory']
    local player = inventory:GetPlayer(src)
    if not player then return end

    local items = player.PlayerData.items or {}
    local pipeSlot, pipeItem

    -- Find opium pipe
    for slot, item in pairs(items) do
        if item.name == 'opium_pipe' then
            pipeSlot = slot
            pipeItem = item
            break
        end
    end

    -- Require pipe
    if not pipeItem then
        TriggerClientEvent('snake-drugs:opiumResult', src, false, 'missing_pipe')
        return
    end

    -- Require opium
    if not inventory:HasItem(src, 'opium', 1) then
        TriggerClientEvent('snake-drugs:opiumResult', src, false, 'missing_opium')
        return
    end

    -- Consume opium
    inventory:RemoveItem(src, 'opium', 1)

    -- Degrade pipe
    if Config.Tools.opium_pipe and Config.Tools.opium_pipe.degrade then
        local info = pipeItem.info or {}
        local loss = Config.Tools.opium_pipe.loss or 1
        local breakAt = Config.Tools.opium_pipe.breakAt or 0
        local defaultQuality = Config.Tools.opium_pipe.defaultQuality or 100

        info.quality = (info.quality or defaultQuality) - loss
        inventory:RemoveItem(src, 'opium_pipe', 1, pipeSlot)

        if info.quality <= breakAt then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Item Broke',
                description = 'Your opium pipe broke.',
                type = 'error',
                position = Config.Selling.notifyPosition
            })
        else
            inventory:AddItem(src, 'opium_pipe', 1, nil, info)
        end
    end

    TriggerClientEvent('snake-drugs:opiumResult', src, true)
    print(('[snake-drugs] Player %d used opium.'):format(src))
end)
