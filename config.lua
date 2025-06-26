Config = {}

Config.Drugs = {
    opium = {
        label = "Opium",
        ingredients = {
            prairiepoppy = 3,
        },
        output = {
            item = "opium",
            amount = 1,
        },
        enabled = true,

        sell = {
            enabled = true,
            price = 50,
            lawAlertChance = 1.00,        -- 100% chance to alert law on sale
            minSellAmount = 1,
            maxSellAmount = 5,
        },

        use = {
            enabled = true,               -- Enable usage of opium
            requiredItem = "opiumpipe",  -- Note: key matched to inventory item ('opiumpipe' matches your usable item registration)
            healAmount = 25,              -- Amount of health restored
            duration = 60000,             -- Effect duration in milliseconds (60 seconds)
            effect = "stamina_boost",     -- Identifier for custom effect (adapt as needed)
            animation = {
                dict = "mp_suicide",
                name = "pill",
                flag = 49,
                duration = 3000,
            },
            notify = {
                enabled = true,
                title = "Opium Used",
                description = "You feel relaxed and energized.",
                type = "success",
                position = "top",
            },
        },

        locations = {
            vector3(1419.35, 389.25, 89.7),
        },
    },
}

Config.Tools = {
    pestleandmortar = {
        degrade = true,
        loss = 5,
        breakAt = 0,
        defaultQuality = 100,
    },
}

Config.Selling = {
    enabled = true,
    interactionDistance = 3.0,
    sellCooldown = 5000,
    notifyPosition = "top",
    sellInteractionIcon = "fas fa-hand-holding-usd",
    maxNPCsNearby = 10,
    requireDrugsInInventory = true,

    startSellMessage = {
        enabled = true,
        title = "Selling Started",
        description = "You are now selling.",
        type = "inform",
        position = "top",
    },

    declineRatio = 3, -- Optional: ratio for rejection logic

    declineNotification = {
        enabled = true,
        title = "Rejected",
        description = "What? Are you crazy!?",
        type = "error",
        position = "top",
    },

    rejection = {
        enabled = true,
        chance = 1 / 3,             -- 33% chance NPC rejects sale
        notifyPlayer = true,
        rejectionNotifyPosition = "top",
        runAway = true,             -- NPC runs away on rejection
        alertPolice = true,         -- Police alerted on rejection
    },
}

Config.LawAlerts = {
    enabled = true,
    notify = true,
    blip = true,
    blipTime = 30,         -- Blip duration in seconds
    blipSprite = 161,
    blipColor = 1,
    notifyPosition = "top",
    notifyType = "error",
    lawAlertMessage = "Suspicious activity reported in the area.",
}
