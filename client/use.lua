local isUsingDrug = false

-- Apply configured effects (healing, screen effect, movement slow, stumble)
local function ApplyOpiumEffects(config)
    local ped = PlayerPedId()

    -- Apply screen effect (Timecycle Modifier)
    if config.effects.screenEffect == "blue" then
        SetTimecycleModifier("spectator5") -- milder visual effect
        SetTimecycleModifierStrength(0.5)
        print("[snake-drugs] Timecycle effect applied.")
    end

    -- Slow movement: use SetPedMoveRateOverride and SetPedMaxMoveBlendRatio for RedM
    local slowAmount = config.effects.movementSlow or 1.0
    SetPedMoveRateOverride(ped, slowAmount)
    SetPedMaxMoveBlendRatio(ped, slowAmount)

    -- Stumble effect (character animation)
    if config.effects.stumble then
        CreateThread(function()
            -- Request animation dictionary once
            RequestAnimDict("move_m@drunk@verydrunk")
            while not HasAnimDictLoaded("move_m@drunk@verydrunk") do Wait(10) end

            local endTime = GetGameTimer() + (config.duration * 1000)
            while GetGameTimer() < endTime do
                if math.random() < 0.1 then -- 10% chance every second to stumble
                    -- Play stumble animation for 2 seconds (adjust as needed)
                    TaskPlayAnim(ped, "move_m@drunk@verydrunk", "idle", 8.0, -8.0, 2000, 1, 0, false, false, false)
                    Wait(2000)
                else
                    Wait(1000)
                end
            end
        end)
    end

    -- Heal over time
    CreateThread(function()
        local endTime = GetGameTimer() + (config.duration * 1000)
        while GetGameTimer() < endTime do
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            if health < maxHealth then
                SetEntityHealth(ped, math.min(health + math.ceil(config.effects.healRate or 1), maxHealth))
            end
            Wait(2000)
        end
    end)

    -- Restore stamina (continuously restore at max rate)
    CreateThread(function()
        local endTime = GetGameTimer() + (config.duration * 1000)
        while GetGameTimer() < endTime do
            RestorePlayerStamina(PlayerId(), 1.0)
            Wait(1000)
        end
    end)
end

-- Clear all effects: visual, movement, animation
local function ClearOpiumEffects()
    ClearTimecycleModifier()
    SetPedMoveRateOverride(PlayerPedId(), 1.0)
    SetPedMaxMoveBlendRatio(PlayerPedId(), 1.0)
    ClearPedTasks(PlayerPedId())
    print("[snake-drugs] Cleared drug effects.")
end

-- Use opium event handler
RegisterNetEvent('snake-drugs:useOpium', function()
    print("[snake-drugs] Event received: useOpium")

    if isUsingDrug then
        print("[snake-drugs] Already using a drug. Ignoring.")
        return
    end

    local drugConfig = Config and Config.Drugs and Config.Drugs["opium"]
    if not drugConfig or not drugConfig.use or not drugConfig.use.enabled then
        print("[snake-drugs] Opium config missing or disabled.")
        return
    end

    isUsingDrug = true
    local ped = PlayerPedId()

    -- Animations removed for testing

    -- Apply effects
    ApplyOpiumEffects(drugConfig.use)

    -- Notify start
    TriggerEvent('ox_lib:notify', {
        title = "Opium",
        description = "You feel the effects of the opium...",
        type = "inform",
        position = Config.Selling and Config.Selling.notifyPosition or "top"
    })

    -- Wait full duration of drug effect
    Wait(drugConfig.use.duration * 1000)

    -- Clear effects
    ClearOpiumEffects()

    -- Notify end
    TriggerEvent('ox_lib:notify', {
        title = "Opium",
        description = "The opium effects have worn off.",
        type = "inform",
        position = Config.Selling and Config.Selling.notifyPosition or "top"
    })

    isUsingDrug = false
end)
