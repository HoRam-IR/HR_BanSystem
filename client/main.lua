ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    TriggerServerEvent("StartDatabaseThread")
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    TriggerEvent('chat:addSuggestion', '/ban', 'Ban a Player', {
        { name="ID / Steam", help="ID Or SteamHex" },
        { name="Days", help="Moddat Zaman Ban"},
        { name="Reason", help="Reason"}
    })
    TriggerEvent('chat:addSuggestion', '/unban', 'Unban A Player', {
        { name="Steam Hex", help="SteamHex" }
    })
    local Steam = xPlayer.identifier
	local kvp = GetResourceKvpString("DarSathamNisti.lua")
	if kvp == nil or kvp == "" then
		identifier = {}
		table.insert(identifier, {hex = Steam})
		local json = json.encode(identifier)
		SetResourceKvp("DarSathamNisti.lua", json)
	else
        local Identifier = json.decode(kvp)
        local Find = false
        for k , v in ipairs(Identifier) do
            if v.hex == Steam then
                Find = true
            end
        end
        if not Find then
            table.insert(Identifier, {hex = Steam})
            local json = json.encode(Identifier)
            SetResourceKvp("DarSathamNisti.lua", json)
        end
        for k, v in ipairs(Identifier) do
            TriggerServerEvent("HR_BanSystem:CheckBan", v.hex)
        end
	end
end)
