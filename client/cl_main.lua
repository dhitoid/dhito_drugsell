local QBCore, ESX = nil, nil

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

local spawnedNPCs = {}
local zoneActive = false  -- Tambahkan variabel ini untuk memeriksa status zona
local interactedNPCs = {}  -- Tabel untuk melacak NPC yang sudah di-interaksi

local function spawnNPC(location)
    local modelHash = GetHashKey(Config.NPC.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local ped = CreatePed(4, modelHash, location.x, location.y, location.z, math.random(0, 360), false, true)
    SetEntityAsMissionEntity(ped, true, true)
    NetworkRegisterEntityAsNetworked(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, false)
    Wait(100)
    local networkId = NetworkGetNetworkIdFromEntity(ped)
    TaskWanderStandard(ped, 10.0, 10)

    return ped
end

local function handleNPCRespawn()
    Wait(Config.NPC.respawnTime)
    if not zoneActive then return end -- Hindari respawn jika zona tidak aktif

    if getPlayersInZone(Config.Zone.location, Config.Zone.radius) > 0 then
        spawnZoneNPC()
    else
        zoneActive = false -- Matikan zona jika tidak ada pemain
    end
end


function despawnNPC(ped)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
        SetEntityAsNoLongerNeeded(ped)
    end
end

local npcInteractions = {}  -- Menyimpan jumlah interaksi per NPC

function handleNPCInteraction(ped)
    local playerPed = PlayerPedId()

    -- Mendapatkan ID jaringan NPC untuk menyimpan jumlah interaksi
    local npcNetworkId = NetworkGetNetworkIdFromEntity(ped)
    
    -- Inisialisasi jumlah interaksi jika belum ada
    if not npcInteractions[npcNetworkId] then
        npcInteractions[npcNetworkId] = 0
    end
    
    -- Update jumlah interaksi
    npcInteractions[npcNetworkId] = npcInteractions[npcNetworkId] + 1

    -- Jika sudah 2 kali interaksi, tampilkan notifikasi
    if npcInteractions[npcNetworkId] >= 2 then
        if Config.Notify == 'qb' then
            TriggerEvent('QBCore:Notify', 'DO NOT SPAM MY SWEET!', 'info')
        elseif Config.Notify == 'ox' then
            exports.ox_lib:notify({title = 'ATTENTION', description = 'DO NOT SPAM MY SWEET!', type = 'info'})
        end

        -- Reset jumlah interaksi setelah notifikasi
        npcInteractions[npcNetworkId] = 0
    end

    -- Pastikan NPC ada sebelum melanjutkan
    if not DoesEntityExist(ped) then
        print("NPC no longer exists.")
        return
    end

    local npcCoords = GetEntityCoords(ped)
    local playerCoords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(ped)
    local targetHeading = GetHeadingFromVector_2d(playerCoords.x - npcCoords.x, playerCoords.y - npcCoords.y)
    SetEntityHeading(ped, targetHeading)
    TaskLookAtEntity(ped, playerPed, 2000, 0, 2)

    local dict = "mp_ped_interaction"
    local flag = "handshake_guy_a"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(ped, dict, flag, 8.0, -8.0, 1500, 49, 0, false, false, false)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    TaskPlayAnim(playerPed, dict, flag, 8.0, -8.0, 1500, 49, 0, false, false, false)
    Wait(1500)

    -- Pastikan NPC ada sebelum memanggil event
    if DoesEntityExist(ped) then
        TriggerServerEvent('dhito_drugsell:exchange', NetworkGetNetworkIdFromEntity(ped))
    end

    despawnNPC(ped)
    for i, npc in ipairs(spawnedNPCs) do
        if npc == ped then
            table.remove(spawnedNPCs, i)
            break
        end
    end
    
    if Config.DispatchResource == 'ps-dispatch' then
        exports['ps-dispatch']:DrugSale()
    elseif Config.DispatchResource == 'qs-dispatch' then
        local dispatchData = {
            job = {'police', 'sheriff'},
            callLocation = GetEntityCoords(ped),
            callCode = { code = 'High Speed', fragment = 'Vehicle' },
            message = 'High-speed vehicle spotted at location',
            flashes = true,
            image = nil,
            blip = { sprite = 1, color = 2, scale = 1.0, text = 'High Speed', blink = true, duration = 5000 }
        }
        TriggerEvent('qs-dispatch:server:CreateDispatchCall', dispatchData)
    end
    Wait(Config.NPC.respawnTime)
    spawnZoneNPC()
end

local function getPlayersInZone(zoneLocation, radius)
    local playersInZone = 0
    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        if #(playerCoords - zoneLocation) <= radius then
            playersInZone = playersInZone + 1
        end
    end
    return playersInZone
end

function spawnZoneNPC()
    local playersInZone = getPlayersInZone(Config.Zone.location, Config.Zone.radius)

    if playersInZone == 0 then
        zoneActive = false
        return
    end    

    local dynamicMinCount = math.max(Config.NPC.minCount, playersInZone)
    local dynamicMaxCount = math.min(Config.NPC.maxCount, playersInZone * 2)

    if #spawnedNPCs >= dynamicMaxCount then
        return
    end

    zoneActive = true -- Tandai zona sebagai aktif
    local spawnCount = math.max(0, math.random(dynamicMinCount, math.max(dynamicMaxCount - #spawnedNPCs, dynamicMinCount)))

    for i = 1, spawnCount do
        local offset = vector3(math.random(-10, 10), math.random(-10, 10), math.random(-2, 2))
        local npcLocation = Config.Zone.location + offset
        local ped = spawnNPC(npcLocation)
        table.insert(spawnedNPCs, ped)

        if Config.Target == 'ox_target' then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'exchange_black_money',
                    icon = 'fas fa-exchange-alt',
                    label = 'Exchange Item',
                    canInteract = function()
                        local playerPed = PlayerPedId()
                        local npcCoords = GetEntityCoords(ped)
                        local playerCoords = GetEntityCoords(playerPed)
                        local distance = #(playerCoords - npcCoords)
                        return distance <= 1.5 and not interactedNPCs[NetworkGetNetworkIdFromEntity(ped)]  -- Hanya bisa di-interaksi jika belum
                    end,
                    onSelect = function()
                        handleNPCInteraction(ped)
                    end
                }
            })
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        icon = 'fas fa-exchange-alt',
                        label = 'Exchange Black Money',
                        action = function()
                            handleNPCInteraction(ped)
                        end
                    }
                },
                distance = 1.5
            })
        end
    end
end

CreateThread(function()
    while true do
        Wait(5000)
        local distance = #(GetEntityCoords(PlayerPedId()) - Config.Zone.location)
        local playersInZone = getPlayersInZone(Config.Zone.location, Config.Zone.radius)

        if distance < Config.Zone.radius and playersInZone > 0 then
            if not zoneActive then
                spawnZoneNPC()
            end
        else
            if zoneActive then
                zoneActive = false
                for _, ped in ipairs(spawnedNPCs) do
                    despawnNPC(ped)
                end
                spawnedNPCs = {}
                print("Zone deactivated. All NPCs despawned.")
            end
        end
    end
end)

if Config.DispatchResource ~= 'ps-dispatch' and Config.DispatchResource ~= 'qs-dispatch' then
    print("^1[ERROR]^7 Config.DispatchResource is invalid. Please set it to 'ps-dispatch' or 'qs-dispatch'.")
    return
end

if Config.Target ~= 'ox_target' and Config.Target ~= 'qb-target' then
    print("^1[ERROR]^7 Config.Target is invalid. Please set it to 'ox_target' or 'qb-target'.")
    return
end