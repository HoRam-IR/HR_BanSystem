
AddEventHandler('onClientResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  Citizen.Wait(1000)
  TriggerServerEvent("HR_BanSystem:ClientLoaded")
end)

AddEventHandler('playerSpawned', function()
  Citizen.Wait(1000)
  TriggerServerEvent("HR_BanSystem:ClientLoaded")
end)

RegisterNetEvent('HR_BanSystem:playerLoaded')
AddEventHandler('HR_BanSystem:playerLoaded', function(Iden)
    TriggerEvent('chat:addSuggestion', '/ban', 'Ban a Player', {
        { name="ID / Steam", help="ID Or SteamHex" },
        { name="Duration", help="Ban Duration( 1 Equals 1 Day )"},
        { name="Reason", help="Reason"}
    })
    TriggerEvent('chat:addSuggestion', '/unban', 'Unban A Player', {
        { name="Steam Hex", help="SteamHex" }
    })
    local Steam = Iden
	local kvp = GetResourceKvpString("KireSefid") -- lamo must of you dont know what this mean XD
	if kvp == nil or kvp == "" then
		Identifier = {}
		table.insert(Identifier, {hex = Steam})
		local json = json.encode(Identifier)
		SetResourceKvp("KireSefid", json) -- lamo must of you dont know what this mean XD
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
