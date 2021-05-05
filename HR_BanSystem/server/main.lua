----------------Salam Aleykom Baw Khoobi?--------------------------------
-------------------------AJ gharare Behet Dars Pas Bedam :} -------------
--------------------------------Dawsham Hamid & Aria :} -----------------

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local AllTokens = {} -- all players token(Anti Multiple Accounts)
local PlayerTokens = {} --playertokens when connects to the server
local DatabaseStuff = {} -- insert smth in db
local BannedTokens = {}   --banned tokens from server
local AllSteams = {}     --all steam hex (Anti Multiple Accounts)
local AllLicenses = {}    -- all players license (Anti Multiple Accounts)
local MultiAcc = {
    Token = false,
    Hex = false,
    Licensess = false
}
local Admins = {
    'steam:2876463943f3rt',
    'example'
}

AddEventHandler('TargetPlayerIsOnline', function(hex, id, reason, name)
    MySQL.Async.execute('UPDATE plyrinfo SET Reason = @Reason, isBanned = @isBanned WHERE steam = @steam', 
    {
        ['@isBanned'] = 1,
        ['@Reason'] = reason,
        ['@steam'] = hex
    })
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 131, 0, 0.4); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> [Punishment]<br>  {1}</div>',
        args = { name, '^2' .. name .. ' ^0Banned! ^2Reason: ^0' ..reason}
    })
    DropPlayer(id, reason)
    Informations()
	ReloadBans()
end)

AddEventHandler('TargetPlayerIsOffline', function(hex, reason, xAdmin)
    MySQL.Async.fetchAll('SELECT steam FROM plyrinfo WHERE steam = @steam',
    {
        ['@steam'] = hex

    }, function(data)
        if data[1] then
            MySQL.Async.execute('UPDATE plyrinfo SET Reason = @Reason, isBanned = @isBanned WHERE steam = @steam', 
            {
                ['@isBanned'] = 1,
                ['@Reason'] = reason,
                ['@steam'] = hex
            })
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 131, 0, 0.4); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> [Offline Punishment]<br>  {1}</div>',
                args = { name, '^2' .. hex .. ' ^0Banned! ^2Reason: ^0' ..reason}
            })
            Informations()
            ReloadBans()
        else
            TriggerClientEvent('chatMessage', xAdmin, "[Database]", {255, 0, 0}, " ^0I Cant Find This Steam. :( It Is InCorrect")
        end
    end)
end)

AddEventHandler('playerConnecting', function(name, setKickReason)
	for k,v in ipairs(GetPlayerIdentifiers(source)) do
	   	if string.sub(v, 1, string.len("steam:")) == "steam:" then
			Steam = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			Lice = v
		end
	end
    if Steam == nil or Lice == nil then
    setKickReason("\n \n HR_BanSystem: \n Your Steam And Rockstar License Is nil")
    CancelEvent()
    end
    PlayerTokens[Steam] = {}
    for i = 0, GetNumPlayerTokens(source) do 
        table.insert(PlayerTokens[Steam], GetPlayerToken(source, i))
    end
    for i = 1, #BannedTokens , 1 do
        for c = 1, #PlayerTokens[Steam], 1 do
            if BannedTokens[i] == PlayerTokens[Steam][c] then
                setKickReason("\n \n HR_BanSystem: \n You Are Banned From Server")
                CancelEvent()
                break
            end
        end
    end
    MultiAcc[Steam] = {} 
    for i = 1, #AllTokens , 1 do
        for c = 1, #PlayerTokens[Steam], 1 do
            if AllTokens[i] == PlayerTokens[Steam][c] then
                MultiAcc[Steam].Token = true
            end
        end
    end
    for a = 1, #AllSteams , 1 do
        if AllSteams[a] == Steam then
            MultiAcc[Steam].Hex = true
        end
    end
    for j = 1, #AllLicenses, 1 do
        if AllLicenses[j] == Lice then
            MultiAcc[Steam].Licensess = true
        end
    end
    if not MultiAcc[Steam].Licensess and MultiAcc[Steam].Token and not MultiAcc[Steam].Hex then
        setKickReason("\n \n HR_BanSystem: \n Multiple Accounts Detected(Not Allowed) \n Please Login With Your Primary Account")
        CancelEvent()
        MultiAcc[Steam] = nil
    elseif MultiAcc[Steam].Licensess and MultiAcc[Steam].Token and not MultiAcc[Steam].Hex then
        setKickReason("\n \n HR_BanSystem: \n Multiple Accounts Detected(Not Allowed) \n Please Login With Your Primary Account")
        CancelEvent()
        MultiAcc[Steam] = nil
    elseif not MultiAcc[Steam].Licensess and MultiAcc[Steam].Token and MultiAcc[Steam].Hex then
        setKickReason("\n \n HR_BanSystem: \n Multiple Accounts Detected(Not Allowed) \n Please Login With Your Primary Account")
        CancelEvent()
        MultiAcc[Steam] = nil
    elseif MultiAcc[Steam].Licensess and MultiAcc[Steam].Token and MultiAcc[Steam].Hex then
        MultiAcc[Steam] = nil
        ---------- EZ PZ baw nasaiidam-----------
    elseif not MultiAcc[Steam].Licensess and not MultiAcc[Steam].Token and not MultiAcc[Steam].Hex then
        MultiAcc[Steam] = nil
    end
end)

RegisterServerEvent('HR_BanSystem:InsertMe')
AddEventHandler('HR_BanSystem:InsertMe', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	for k,v in ipairs(GetPlayerIdentifiers(source)) do
	   	if string.sub(v, 1, string.len("steam:")) == "steam:" then
			Hex = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			Lices = v
		end
	end
    DatabaseStuff[Hex] = {}
    for i = 0, GetNumPlayerTokens(source) do 
        table.insert(DatabaseStuff[Hex], GetPlayerToken(source, i))
    end
    MySQL.Async.fetchAll('SELECT steam FROM plyrinfo WHERE steam = @steam',
    {
        ['@steam'] = Hex

    }, function(data)
        if not data[1] then
            MySQL.Async.execute('INSERT INTO plyrinfo (steam, license, tokens) VALUES (@steam, @license, @tokens)',
            {
                ['@steam'] = Hex,
                ['@license'] = Lices,
                ['@tokens'] = json.encode(DatabaseStuff[Hex])
            })
            DatabaseStuff[Hex] = nil
        end 
    end)
end)

RegisterCommand('tokenban', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = tonumber(args[1])
    local cPlayer = ESX.GetPlayerFromId(target)
    if IsPlayerAllowedToBan(source) then
        if args[1] then
            if args[2] then
                if tonumber(args[1]) then
                    if not tonumber(args[2]) then
                        if GetPlayerName(target) then
			    local identi = ExtractIdentifiers(cPlayer.source)		
                            local Hex = identi.steam
                            TriggerEvent('TargetPlayerIsOnline', Hex, tonumber(cPlayer.source), tostring(args[2]), GetPlayerName(cPlayer.source))
                        else
                            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Player Is Not Online.")
                        end
                    else
                        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0You Have To Enter A Reason.")
                    end
                else
                    if string.find(args[1], "steam:") ~= nil then
                        TriggerEvent('TargetPlayerIsOffline', args[1], tostring(args[2]), tonumber(xPlayer.source))
                    else
                        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Incorrect Steam Hex.")
                    end
                end
            else
                TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0args[2] is empty")
            end
        else
            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0args[1] is empty.")
        end
    else
        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0You Are Not An Admin.")
    end
end)

RegisterCommand('reloadtk', function(source, args)
    if IsPlayerAllowedToBan(source) then
        Informations()
        ReloadBans()
        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^2Reloaded")
    end
end)

RegisterCommand('unbantk', function(source, args)
    if IsPlayerAllowedToBan(source) then
        if tostring(args[1]) then
            MySQL.Async.fetchAll('SELECT steam FROM plyrinfo WHERE steam = @steam',
            {
                ['@steam'] = args[1]
    
            }, function(data)
                if data[1] then
                    MySQL.Async.execute('UPDATE plyrinfo SET Reason = @Reason, isBanned = @isBanned WHERE steam = @steam', 
                    {
                        ['@isBanned'] = 0,
                        ['@Reason'] = "",
                        ['@steam'] = args[1]
                    })
                    Informations()
                    ReloadBans()
                    TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^2Success")
                else
                    TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0The Entered Steam Is Incorrect.")
                end
            end)
        else
            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0The Entered Steam Is Incorrect.")
        end
    else
        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0You Are Not An Admin.")
    end
end)

RegisterCommand('multiacc', function(source, args)
    if IsPlayerAllowedToBan(source) then
        if tostring(args[1]) then
            MySQL.Async.fetchAll('SELECT steam FROM plyrinfo WHERE steam = @steam',
            {
                ['@steam'] = args[1]
    
            }, function(data)
                if data[1] then
                    MySQL.Async.execute('UPDATE plyrinfo SET WhiteList = @WhiteList WHERE steam = @steam', 
                    {
                        ['@WhiteList'] = 1,
                        ['@steam'] = args[1]
                    })
                else
                    TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0The Entered Steam Is Incorrect.")
                end
            end)
        else
            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0The Entered Steam Is Incorrect.")
        end
    else
        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0You Are Not An Admin.")
    end
end)

function ReloadBans()
    BannedTokens = {}
    MySQL.Async.fetchAll('SELECT * FROM plyrinfo', {}, function(info)
        for i = 1, #info do
            if info[i].isBanned == 1 then
                local Tokenz = json.decode(info[i].tokens)
                for k, v in ipairs(Tokenz) do 
                    table.insert(BannedTokens, v)
                end
            end
        end
    end)
end

function Informations()
    AllTokens = {}
    AllSteams = {}  
    AllLicenses = {}
	MySQL.Async.fetchAll('SELECT * FROM plyrinfo',{},function (data)
	for i=1, #data, 1 do
            if data[i].WhiteList == 0 then
                local Tokenzz = json.decode(data[i].tokens)
                local Steamz = data[i].steam
                local Licensez = data[i].license
                for k, v in ipairs(Tokenzz) do 
                    table.insert(AllTokens, v)
                end
                table.insert(AllSteams, data[i].steam)
                table.insert(AllLicenses, data[i].license)
	    end
	end
    end)
end

AddEventHandler("onMySQLReady",function()
    Informations()
	ReloadBans()
    print("Ban List Loaded")
end)

Citizen.CreateThread(function() -- this is very very very very very very very weired but .... i dont have any idea about refreshing informations
    while true do 
        Citizen.Wait(60000)
        Informations()
        Citizen.Wait(20000)
        ReloadBans()
    end
end)

function IsPlayerAllowedToBan(player)
    local allowed = false
	for i, id in ipairs(Admins) do
		for x, pid in ipairs(GetPlayerIdentifiers(player)) do
			if string.lower(pid) == string.lower(id) then
				allowed = true
			end
		end
	end		
    return allowed
end
