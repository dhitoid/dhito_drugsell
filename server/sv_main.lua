local QBCore, ESX = nil, nil

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

RegisterServerEvent('dhito_drugsell:exchange', function(pedNetId)
    local src = source
    local Player = nil

    if Config.Framework == 'qbcore' then
        Player = QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' then
        Player = ESX.GetPlayerFromId(src)
    end
    
    if Config.Inventory ~= 'ox_inventory' and Config.Inventory ~= 'qb-inventory' then
        print("^1ERROR:^7 Config.Inventory is invalid. Please set it to 'ox_inventory' or 'qb-inventory'.")
        return
    end  

    if Config.Notify ~= 'qb' and Config.Notify ~= 'ox' then
        print("^1ERROR:^7 Config.Notify is invalid. Please set it to 'qb' or 'ox'.")
        return
    end

    if Player then
        local blackMoneyCount = 0
        if Config.Inventory == 'ox_inventory' then
            blackMoneyCount = exports.ox_inventory:Search(src, 'count', Config.Exchange.itemRequired)
        elseif Config.Inventory == 'qb-inventory' then
            local item = Player.Functions.GetItemByName(Config.Exchange.itemRequired)
            blackMoneyCount = item and item.amount or 0
        end

        if blackMoneyCount >= Config.Exchange.exchangeRate then
            local rewardCount = math.random(Config.Exchange.minReward, Config.Exchange.maxReward)

            if Config.Inventory == 'ox_inventory' then
                exports.ox_inventory:RemoveItem(src, Config.Exchange.itemRequired, Config.Exchange.exchangeRate)
                exports.ox_inventory:AddItem(src, Config.Exchange.itemReward, rewardCount)
            elseif Config.Inventory == 'qb-inventory' then
                Player.Functions.RemoveItem(Config.Exchange.itemRequired, Config.Exchange.exchangeRate)
                Player.Functions.AddItem(Config.Exchange.itemReward, rewardCount)
            end

            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
            
             local successMessage = string.format(Config.NotifyMessages[Config.NotifyLanguage].successExchange, rewardCount, Config.Exchange.itemReward)
            
            if Config.Notify == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, successMessage, 'success')
            elseif Config.Notify == 'ox' then
                TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = successMessage})
            end
        else
            local notEnoughMessage = string.format(Config.NotifyMessages[Config.NotifyLanguage].notEnoughItem, Config.Exchange.itemRequired)
            
            if Config.Notify == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, notEnoughMessage, 'error')
            elseif Config.Notify == 'ox' then
                TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = notEnoughMessage})
            end
        end
    end
end)