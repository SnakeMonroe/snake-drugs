local Core = exports['rsg-core']:GetCoreObject()

-- Register opium as usable from inventory/hotbar
Core.Functions.CreateUseableItem('opium', function(source, item)
    local player = Core.Functions.GetPlayer(source)
    if not player then return end

    local items = player.PlayerData.items or {}
    local pipeSlot, pipeItem

    -- Search for opium pipe in inventory
    for slot, i in pairs(items) do
        if i.name == 'opiumpipe' then
            pipeSlot = slot
            pipeItem = i
            break
        end
    end

    if not pipeItem then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Opium",
            description = "You need an opium pipe to use this.",
            type = "error",
            position = "top"
        })
        return
    end

    -- Remove 1 opium from inventory
    local removed = player.Functions.RemoveItem('opium', 1)
    print(('[snake-drugs] Player %d removed 1 opium: %s'):format(source, tostring(removed)))

    if not removed then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Opium",
            description = "Failed to remove opium from your inventory.",
            type = "error",
            position = "top"
        })
        return
    end

    -- Pipe degradation logic
    local config = Config.Tools and Config.Tools.opiumpipe
    if config and config.degrade and pipeItem then
        local info = pipeItem.info or {}
        local loss = config.loss or 1
        local breakAt = config.breakAt or 0
        local defaultQuality = config.defaultQuality or 100

        info.quality = (info.quality or defaultQuality) - loss

        -- Remove the old pipe item first
        local removedPipe = player.Functions.RemoveItem('opiumpipe', 1, pipeSlot)
        print(('[snake-drugs] Player %d removed 1 opiumpipe: %s'):format(source, tostring(removedPipe)))

        if info.quality <= breakAt then
            TriggerClientEvent('ox_lib:notify', source, {
                title = "Opium Pipe",
                description = "Your opium pipe broke.",
                type = "error",
                position = "top"
            })
        else
            -- Add the degraded pipe back to inventory
            local addedPipe = player.Functions.AddItem('opiumpipe', 1, nil, info)
            print(('[snake-drugs] Player %d added degraded opiumpipe back: %s'):format(source, tostring(addedPipe)))
        end
    end

    -- Trigger drug effects on client
    TriggerClientEvent('snake-drugs:useOpium', source)
    print(('[snake-drugs] Player %d used opium.'):format(source))
end)