TriggerEvent('esx_society:registerSociety', 'railway', 'Railway', 'society_railway', 'society_railway', 'society_railway', {type = 'public'})

RegisterServerEvent('esx_railwayjob:success')
AddEventHandler('esx_railwayjob:success', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = math.random(Config.Grades[xPlayer.job.grade].salary * 0.5, Config.Grades[xPlayer.job.grade].salary)
    
    if xPlayer.job.name == 'railway' then
        xPlayer.addMoney(amount)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez reçu ~g~' .. amount .. '$ ~w~pour votre service')
    end
end)

ESX.RegisterServerCallback('esx_railwayjob:getStockItems', function(source, cb)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_railway', function(inventory)
        cb(inventory.items)
    end)
end)

ESX.RegisterServerCallback('esx_railwayjob:getPlayerInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.inventory

    cb({items = items})
end)