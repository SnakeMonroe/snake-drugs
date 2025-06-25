-- Process Drug Event
RegisterServerEvent('snake-drugs:processDrug')
AddEventHandler('snake-drugs:processDrug', function(drugId)
    local src = source
    local drug = Config.Drugs[drugId]

    if not drug or not drug.enabled then
        print(('[snake-drugs][DEBUG] Invalid or disabled drug: %s'):format(drugId))
        return
    end

    local player = exports['rsg-inventory']:GetPlayer(src)
    if not player then
        print(('[snake-drugs][DEBUG] No player found for source %s'):format(src))
        return
    end

    local items = player.PlayerData.items or {}
    local missingIngredient = false
    local pestleSlot, pestleItem

    -- Check ingredients
    for itemName, requiredAmount in pairs(drug.ingredients) do
        local hasAmount = 0
        for slot, item in pairs(items) do
            if item.name == itemName then
                hasAmount = item.amount or 0
                if itemName == "pestleandmortar" then
                    pestleSlot = slot
                    pestleItem = item
                end
                break
            end
        end
        if hasAmount < requiredAmount then
            missingIngredient = true
            break
        end
    end

    if missingIngredient then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Processing Failed',
            description = "Missing required ingredients.",
            type = 'error',
            position = 'top'
        })
        return
    end

    -- Remove ingredients (except pestleandmortar)
    for itemName, amount in pairs(drug.ingredients) do
        if itemName ~= "pestleandmortar" then
            player.Functions.RemoveItem(itemName, amount)
        end
    end

    -- Degrade pestleandmortar
    if pestleItem and Config.Tools and Config.Tools.pestleandmortar and Config.Tools.pestleandmortar.degrade then
        local info = pestleItem.info or {}
        local loss = Config.Tools.pestleandmortar.loss or 10
        local breakAt = Config.Tools.pestleandmortar.breakAt or 0
        local defaultQuality = Config.Tools.pestleandmortar.defaultQuality or 100

        info.quality = (info.quality or defaultQuality) - loss

        player.Functions.RemoveItem("pestleandmortar", 1, pestleSlot)
        if info.quality <= breakAt then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Item Broke',
                description = "Your Pestle and Mortar broke.",
                type = 'error',
                position = 'top'
            })
        else
            player.Functions.AddItem("pestleandmortar", 1, nil, info)
        end
    end

    -- Give processed item
    player.Functions.AddItem(drug.output.item, drug.output.amount)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Processing Complete',
        description = ('Received %dx %s.'):format(drug.output.amount, drug.label),
        type = 'success',
        position = 'top'
    })

    print(('[snake-drugs][DEBUG] Player %d processed %dx %s'):format(src, drug.output.amount, drug.label))
end)

-- Sell Drugs Event
RegisterServerEvent('snake-drugs:sellDrugs')
AddEventHandler('snake-drugs:sellDrugs', function()
    local src = source
    local player = exports['rsg-inventory']:GetPlayer(src)
    if not player then
        print(('[snake-drugs][DEBUG] No player found for source %s'):format(src))
        return
    end

    local items = player.PlayerData.items or {}
    local totalSold, totalEarned = 0, 0
    local alertedLaw = false

    for drugId, drugData in pairs(Config.Drugs) do
        if drugData.enabled and drugData.sell and drugData.sell.enabled then
            for slot, item in pairs(items) do
                if item.name == drugData.output.item then
                    local amount = item.amount or 0
                    if amount > 0 then
                        local price = drugData.sell.price or 10
                        local payout = amount * price

                        player.Functions.RemoveItem(item.name, amount)
                        player.Functions.AddMoney("cash", payout)

                        totalSold = totalSold + amount
                        totalEarned = totalEarned + payout

                        print(('[snake-drugs][DEBUG] Player %d sold %dx %s for $%d'):format(src, amount, item.name, payout))

                        if not alertedLaw and math.random() <= (drugData.sell.lawAlertChance or 0) then
                            alertedLaw = true
                            AlertCops(src, item.name, amount)
                        end
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
            position = 'top'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'No Drugs',
            description = 'You have no drugs to sell.',
            type = 'error',
            position = 'top'
        })
    end
end)

-- Law Alert Handler
function AlertCops(sellerSrc, item, amount)
    local sellerPed = GetPlayerPed(sellerSrc)
    local sellerCoords = GetEntityCoords(sellerPed)

    for _, playerId in ipairs(GetPlayers()) do
        local target = exports['rsg-inventory']:GetPlayer(playerId)
        if target and target.PlayerData and target.PlayerData.job then
            local jobName = target.PlayerData.job.name
         
            -- Match any job with "law" in the name (like vallaw, rholaw, etc.)
            if jobName:lower():find("law") then
                TriggerClientEvent('snake-drugs:lawAlert', playerId, {
                    coords = sellerCoords,
                    message = ('Citizen reported suspicious activity involving %dx %s.'):format(amount, item)
                })
            end
        end
    end

    print(('[snake-drugs][ALERT] Law notified about %s x%d from player %d'):format(item, amount, sellerSrc))
end
