Config = {}

Config.Framework = 'qbcore' -- qbcore / esx
Config.Inventory = 'ox_inventory' -- ox_inventory / qb-inventory
Config.DispatchResource = 'ps-dispatch'  -- ps-dispatch / qs-dispatch
Config.DispatchEvent = 'getrsourcestart' -- DO NOT TOUCH THIS
Config.Target = 'ox_target' -- ox_target / qb-target
Config.Notify = 'qb' -- qb / ox
Config.NotifyLanguage = 'en' -- id / en

Config.Zone = {
    location = vector3(-1134.89, 4924.42, 220.98), -- Zone location NPC / Lokasi zona NPC
    radius = 25.0 -- Radius zone
}

Config.PlayerinZone = {
    minPlayer = 1, -- Minimum jumlah pemain di zona
    maxPlayer = 5  -- Maksimum jumlah pemain di zona
}

Config.NPC = {
    model = 'a_m_y_acult_02', -- Model NPC
    minCount = 2, -- Jumlah minimum NPC
    maxCount = 5, -- Jumlah maksimum NPC
    respawnTime = 30000 -- Waktu respawn NPC dalam milidetik
}

Config.Exchange = {
    itemRequired = 'black_money', -- Items needed / Item yang dibutuhkan
    itemReward = 'papaver', -- Items given / Item yang diberikan
    minReward = 1, -- Minimum Reward Amount / Minimum Jumlah Reward
    maxReward = 1, -- Maximum Reward Amount / Maximum Jumlah Reward
    exchangeRate = 10 -- Amount of itemRequired to get itemReward / Jumlah itemRequired untuk mendapatkan itemReward
}

Config.NotifyMessages = {
    en = {
        successExchange = "Exchange successful! You received %d %s.",
        notEnoughItem = "You don't have enough %s!",
    },
    id = {
        successExchange = "Pertukaran berhasil! Anda menerima %d %s.",
        notEnoughItem = "Anda tidak memiliki cukup %s!",
    }
}