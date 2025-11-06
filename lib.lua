local bl_lib = {}

local QBCore = nil
local ESX = nil

CreateThread(function()
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        bl_lib.Framework = 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        bl_lib.Framework = 'esx'
    else
        bl_lib.Framework = 'standalone'
    end
end)

function bl_lib.Notify(source, message, type)
    type = type or 'inform'

    if bl_lib.Framework == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, message, type)
    elseif bl_lib.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    else
        print(('[Notify][%s] %s'):format(source or 'server', message))
    end
end

function bl_lib.Localize(key)
    return Locales and Locales[key] or key
end

function bl_lib.GetNearbyVehicle(ped, maxDistance)
    local coords = GetEntityCoords(ped)
    local vehicles = GetGamePool("CVehicle")

    for _, vehicle in pairs(vehicles) do
        if #(coords - GetEntityCoords(vehicle)) < (maxDistance or 5.0) then
            return vehicle
        end
    end
    return nil
end

function bl_lib.HasVehicleKey(source, config)
    if bl_lib.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end

        if not config.RequireKeyItem then return true end

        if config.Inventory == "ox" then
            local count = exports.ox_inventory:Search(source, 'count', config.KeyItemName)
            return count and count > 0
        elseif config.Inventory == "qb" then
            local item = Player.Functions.GetItemByName(config.KeyItemName)
            return item ~= nil
        elseif config.Inventory == "qs" then
            local qs = exports['qs-inventory']
            local count = qs:GetItemCount(source, config.KeyItemName)
            return count and count > 0
        end

    elseif bl_lib.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end

        if not config.RequireKeyItem then return true end

        local item = xPlayer.getInventoryItem(config.KeyItemName)
        return item and item.count > 0

    else
        return not config.RequireKeyItem
    end

    return false
end

bl_lib.Version = '1.1.0'

return bl_lib
