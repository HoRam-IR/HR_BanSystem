ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function() -- this event will trigger when the player has connected to the server
    TriggerServerEvent('HR_BanSystem:InsertMe')
    TriggerEvent('chat:addSuggestion', '/tokenban', 'Ban a Player', {
        { name="ID / Steam", help="ID Or SteamHex" },
        { name="Reason", help="Ban Reason" }
    })
    TriggerEvent('chat:addSuggestion', '/reloadtk', 'Reload Banlist', {})
    TriggerEvent('chat:addSuggestion', '/unbantk', 'Unban A Player', {
        { name="Steam Hex", help="SteamHex" }
    })
    TriggerEvent('chat:addSuggestion', '/multiacc', 'whitelist multi accounts', {
        { name="Steam Hex", help="SteamHex" }
    })
end)