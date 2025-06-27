local currentReputation = {
    tier = 1,
    points = 0,
    tierName = "Runner"
}

-- Config reference
local tiers = Config.Reputation.tiers

-- Tier perks
local tierPerks = {
    [1] = {
        "Access to low-end deals",
        "15% chance for higher-end deals",
        "20% chance for mid-tier deals"
    },
    [2] = {
        "Better prices than Runner",
        "20% chance for higher-end deals",
        "25% chance for mid-tier deals"
    },
    [3] = {
        "Mid-tier prices more frequent",
        "25% chance for higher-end deals",
        "30% chance for mid-tier deals"
    },
    [4] = {
        "Access to cartel deals",
        "30% chance for higher-end deals",
        "35% chance for mid-tier deals"
    },
    [5] = {
        "Top-tier Drug Baron pricing",
        "35% chance for higher-end deals",
        "40% chance for mid-tier deals"
    }
}

-- Drug unlocks by tier
local drugUnlocks = {
    [1] = "Opium",
    [2] = "Hemp",
    [3] = "Peyote",
    [4] = "Cocaine",
    [5] = "Heroin"
}

-- /rep command to display minimal info via ox_lib
RegisterCommand("rep", function()
    local tier = currentReputation.tier
    local tierData = tiers[tier]
    local nextTier = tiers[tier + 1]
    local maxPoints = nextTier and nextTier.minRep or tierData.maxRep

    local description = ("Rep: %d / %d\n\nRank: %s"):format(
        currentReputation.points,
        maxPoints,
        tierData.name or "Unknown"
    )

    TriggerEvent('ox_lib:notify', {
        title = "Reputation",
        description = description,
        type = "info",
        position = "top"
    })
end, false)


-- Receive rep updates from server
RegisterNetEvent("snake-drugs:updateReputation")
AddEventHandler("snake-drugs:updateReputation", function(tierIndex, points)
    currentReputation.tier = tierIndex
    currentReputation.points = points
    currentReputation.tierName = tiers[tierIndex] and tiers[tierIndex].name or "Unknown"
end)

-- Request rep on spawn
AddEventHandler('playerSpawned', function()
    TriggerServerEvent("snake-drugs:getReputation")
end)
