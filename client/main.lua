ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    TriggerEvent('chat:addSuggestion', '/ban', 'Ban a Player', {
        { name="ID / Steam", help="ID Or SteamHex" },
        { name="Duration", help="Ban Duration"},
        { name="Reason", help="Reason"}
    })
    TriggerEvent('chat:addSuggestion', '/unban', 'Unban A Player', {
        { name="Steam Hex", help="SteamHex" }
    })
    local Steam = xPlayer.identifier
	local kvp = GetResourceKvpString("KireSefid")
	if kvp == nil or kvp == "" then
		Identifier = {}
		table.insert(Identifier, {hex = Steam})
		local json = json.encode(Identifier)
		SetResourceKvp("KireSefid", json)
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
            SetResourceKvp("KireSefid", json)
        end
        for k, v in ipairs(Identifier) do
            TriggerServerEvent("HR_BanSystem:CheckBan", v.hex)
        end
	end
end)

----------------EULEN EXECUTER (STOP RESOURCE DETECTION)----------------------

AddEventHandler("onClientResourceStop", function(resource)
    if GetCurrentResourceName() == resource then
        ForceSocialClubUpdate() -----will close fivem process on resource stop
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if GetCurrentResourceName() == resource then
        ForceSocialClubUpdate()-----will close fivem process on resource stop
    end
end)
