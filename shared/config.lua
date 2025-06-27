Config = {}

-- DRUG DEFINITIONS
Config.Drugs = {
    opium = {
        label = "Opium",
        enabled = true,

        -- Processing ingredients required to craft opium
        ingredients = {
            prairiepoppy = 3,
        },

        -- Output item from processing
        output = {
            item = "opium",
            amount = 1
        },

        -- Selling configuration
        sell = {
            enabled = true,
            price = 50,
            lawAlertChance = 1.00, -- 100% chance to alert law enforcement
            minSellAmount = 1,
            maxSellAmount = 5
        },

        -- Usage effects when consuming opium
        use = {
            enabled = true,
            duration = 60, -- effect duration in seconds
            effects = {
                healRate = 50.0,         -- Health regen per tick
                staminaDrain = 0.3,     -- Stamina drain multiplier (lower is better)
                movementSlow = 0.4,     -- Movement speed multiplier
                stumble = true,         -- Enables random stumble effect
                screenEffect = "blue"   -- Visual screen overlay effect
            }
        },

        -- Locations where processing can happen
        locations = {
            vector3(1419.35, 389.25, 89.7)
        }
    }
}

-- TOOL CONFIGURATION (for degradation mechanics)
Config.Tools = {
    pestleandmortar = {
        degrade = true,
        loss = 5,          -- quality lost per use
        breakAt = 0,       -- quality threshold to break
        defaultQuality = 100
    },
    opiumpipe = {
        degrade = true,
        loss = 10,         -- quality lost per use
        breakAt = 0,       -- quality threshold to break
        defaultQuality = 100
    }
}

-- SELLING SYSTEM SETTINGS
Config.Selling = {
    enabled = true,
    interactionDistance = 3.0,
    sellCooldown = 5000,              -- cooldown between sells in ms
    notifyPosition = 'top',           -- notification position on screen
    sellInteractionIcon = "fas fa-hand-holding-usd",
    maxNPCsNearby = 10,
    requireDrugsInInventory = true,

    -- UI messages during selling
    startSellMessage = {
        enabled = true,
        title = "Selling Started",
        description = "You are now selling.",
        type = "inform",
        position = "top"
    },

    declineRatio = 3, -- ratio to determine sale rejection chance
    declineNotification = {
        enabled = true,
        title = "Rejected",
        description = "What? Are you crazy!?",
        type = "error",
        position = "top"
    },

    rejection = {
        enabled = true,
        chance = 1 / 3,           -- 33% chance to reject sale
        notifyPlayer = true,
        rejectionNotifyPosition = 'top',
        runAway = true,           -- NPC runs away on rejection
        alertPolice = true        -- Police alerted on rejection
    }
}

-- LAW ENFORCEMENT ALERTS
Config.LawAlerts = {
    enabled = true,
    notify = true,
    blip = true,
    blipTime = 30,                -- Blip duration in seconds
    blipSprite = 161,
    blipColor = 1,
    notifyPosition = 'top',
    notifyType = 'error',
    lawAlertMessage = "Suspicious activity reported in the area."
}
