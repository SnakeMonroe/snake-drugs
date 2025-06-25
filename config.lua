Config = {}

Config.Drugs = {
    opium = {
        label = "Opium",
        ingredients = {
            prairiepoppy = 3,
            -- pestleandmortar = 1, -- optional
        },
        output = {
            item = "opium",
            amount = 1
        },
        enabled = true,

        sell = {
            enabled = true,            -- Enable/disable selling of this drug
            price = 50,                -- Price per 1 unit sold
            lawAlertChance = 1.00      -- 100% chance to alert law enforcement
        },

        locations = {
            vector3(1419.35, 389.25, 89.7)
        }
    },

    -- Add more drugs here...
}

Config.Tools = {
    pestleandmortar = {
        degrade = true,
        loss = 5,
        breakAt = 0,
        defaultQuality = 100
    }
}

-- Selling system general settings
Config.Selling = {
    enabled = true,                  -- Master toggle for the entire drug selling system
    interactionDistance = 3.0,      -- Max distance to interact with NPCs for selling
    sellCooldown = 5000,            -- Cooldown between sales in milliseconds
    notifyPosition = 'top',         -- Notification position on screen
    sellInteractionIcon = "fas fa-hand-holding-usd",  -- Icon for the sell interaction
    maxNPCsNearby = 10,             -- Max NPCs considered around player for selling
}

-- Law enforcement alert configuration
Config.LawAlerts = {
    enabled = true,             -- Master switch for law alerts
    notify = true,              -- Use ox_lib to show on-screen notification to law players
    blip = true,                -- Create a temporary map blip for law
    blipTime = 30,              -- Duration in seconds for how long the blip stays
    blipSprite = 161,           -- Blip sprite ID (161 is default skull)
    blipColor = 1,              -- Blip color ID (1 = red)
    notifyPosition = 'top',     -- Position of the notification (top, bottom, etc.)
    notifyType = 'error'        -- Notification type (inform, error, success, etc.)
}
