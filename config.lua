Config = {}

Config.Drugs = {
    opium = {
        label = "Opium",
        ingredients = {
            prairiepoppy = 3,
        },
        output = {
            item = "opium",
            amount = 1
        },
        enabled = true,

        sell = {
            enabled = true,
            price = 50,
            lawAlertChance = 1.00,
            minSellAmount = 1,
            maxSellAmount = 5
        },

        locations = {
            vector3(1419.35, 389.25, 89.7)
        }
    },
}

Config.Tools = {
    pestleandmortar = {
        degrade = true,
        loss = 5,
        breakAt = 0,
        defaultQuality = 100
    }
}

-- Selling system settings
Config.Selling = {
    enabled = true,
    interactionDistance = 3.0,
    sellCooldown = 5000,
    notifyPosition = 'top',
    sellInteractionIcon = "fas fa-hand-holding-usd",
    maxNPCsNearby = 10,
    requireDrugsInInventory = true,

    startSellMessage = {
        enabled = true,
        title = "Selling Started",
        description = "You are now selling.",
        type = "inform",
        position = "top"
    },

    declineRatio = 3,
    declineNotification = {
        enabled = true,
        title = "Rejected",
        description = "What? Are you crazy!?",
        type = "error",
        position = "top"
    },

    -- 👇 Rejection system configuration with 1 in 3 chance
    rejection = {
        enabled = true,              -- Enable NPC rejection logic
        chance = 1 / 3,              -- 33.3% chance to reject (1 in 3)
        notifyPlayer = true,         -- Show notify if rejected
        rejectionNotifyPosition = 'top',
        runAway = true,              -- NPC runs away if rejected
        alertPolice = true           -- Police alerted on rejection
    }
}

-- Law enforcement alert config
Config.LawAlerts = {
    enabled = true,
    notify = true,
    blip = true,
    blipTime = 30,
    blipSprite = 161,
    blipColor = 1,
    notifyPosition = 'top',
    notifyType = 'error',
    lawAlertMessage = "Suspicious activity reported in the area."
}
