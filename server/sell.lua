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
                if item.name == drug.output.item then
                    local available = item.amount or 0
                    if available > 0 then
                        -- Rejection logic
                        if Config.Selling.rejection.enabled then
                            local rejectionChance = Config.Selling.rejection.chance or 0
                            if math.random() < rejectionChance then
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
                        end

                        local amountToSell = math.random(drug.sell.minSellAmount or 1, drug.sell.maxSellAmount or 5)
                        amountToSell = math.min(amountToSell, available)

                        local price = drug.sell.price or 10
                        local payment = price * amountToSell

                        player.Functions.RemoveItem(item.name, amountToSell)
                        player.Functions.AddMoney("cash", payment)

                        totalSold = totalSold + amountToSell
                        totalEarned = totalEarned + payment

                        -- Alert police randomly
                        if Config.LawAlerts.enabled and not alertedLaw and math.random() <= (drug.sell.lawAlertChance or 0) then
                            alertedLaw = true
                            AlertCops(src, item.name, amountToSell)
                        end

                        -- Notify player of sale
                        TriggerClientEvent('snake-drugs:saleResult', src, payment)

                        -- ✅ Properly update rep
                        exports['snake-drugs']:AddDrugReputation(src, drugId, amountToSell)

                        break
                    end
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

function AlertCops(src, drugName, amount)
    local ped = GetPlayerPed(src)
    if not ped then return end
    local coords = GetEntityCoords(ped)
    TriggerEvent('snake-drugs:alertPolice', {
        coords = coords,
        drug = drugName,
        amount = amount
    })
end

RegisterNetEvent('snake-drugs:hasDrugsToSell')
AddEventHandler('snake-drugs:hasDrugsToSell', function()
    local src = source
    local player = exports['rsg-inventory']:GetPlayer(src)
    if not player then return end

    local hasDrugs = false
    local items = player.PlayerData.items or {}

    for _, drug in pairs(Config.Drugs) do
        if drug.enabled and drug.sell and drug.sell.enabled then
            for _, item in pairs(items) do
                if item.name == drug.output.item and item.amount > 0 then
                    hasDrugs = true
                    break
                end
            end
        end
        if hasDrugs then break end
    end

    TriggerClientEvent('snake-drugs:hasDrugsResponse', src, hasDrugs)
end)
