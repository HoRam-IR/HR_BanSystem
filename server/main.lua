ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local JoinCoolDown = {}
local BannedAlready = false
local isBypassing = false
local DatabaseStuff = {}
local BannedAccounts = {}
local Admins = {
    'steam:',
    'steam:',
	'steam:',
}

AddEventHandler('Initiate:BanSql', function(hex, id, reason, name, day)
    MySQL.Async.execute('UPDATE hr_bansystem SET Reason = @Reason, isBanned = @isBanned, Expire = @Expire WHERE Steam = @Steam', 
    {
        ['@isBanned'] = 1,
        ['@Reason'] = reason,
        ['@Steam'] = hex,
        ['@Expire'] = os.time() + (day * 86400)
    })
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 131, 0, 0.4); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> [Punishment]<br>  {1}</div>',
        args = { name, '^1' .. name .. ' ^0Be Dalil ^1' ..reason.." ^0Be Moddat ^1"..day.." ^0Rooz Ban Shod."}
    })
    DropPlayer(id, reason)
    SetTimeout(1000, function()
	    ReloadBans()
    end)
end)

AddEventHandler('TargetPlayerIsOffline', function(hex, reason, xAdmin, day)
    MySQL.Async.fetchAll('SELECT Steam FROM hr_bansystem WHERE Steam = @Steam',
    {
        ['@Steam'] = hex

    }, function(data)
        if data[1] then
            MySQL.Async.execute('UPDATE hr_bansystem SET Reason = @Reason, isBanned = @isBanned, Expire = @Expire WHERE Steam = @Steam', 
            {
                ['@isBanned'] = 1,
                ['@Reason'] = reason,
                ['@Steam'] = hex,
                ['@Expire'] = os.time() + (day * 86400)
            })
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 131, 0, 0.4); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> [Punishment]<br>  {1}</div>',
                args = { hex, '^1' .. hex .. ' ^0Be Dalil ^1' ..reason.." ^0Be Moddat ^1"..day.." ^0Rooz Ban Shod."}
            })
            SetTimeout(1000, function()
                ReloadBans()
            end)
        else
            TriggerClientEvent('chatMessage', xAdmin, "[Database]", {255, 0, 0}, " ^0I Cant Find This Steam. :( It Is InCorrect")
        end
    end)
end)

AddEventHandler('playerConnecting', function(name, setKickReason)
    local source = source
    local Steam = "NONE"
    local Lice = "NONE"
    local Live = "NONE"
    local Xbox = "NONE"
    local Discord = "NONE"
    local IP = "NONE"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            Steam = v
        elseif string.sub(v, 1,string.len("license:")) == "license:" then
            Lice = v
        elseif string.sub(v, 1,string.len("live:")) == "live:" then
            Live = v
        elseif string.sub(v, 1,string.len("xbl:")) == "xbl:" then
            Xbox = v
        elseif string.sub(v,1,string.len("discord:")) == "discord:" then
            Discord = v
        elseif string.sub(v, 1,string.len("ip:")) == "ip:" then
            IP = v
        end
    end
    if Steam == nil or Lice == nil or Steam == "" or Lice == "" then
        setKickReason("\n \n HR_BanSystem: \n Steam Ya License Shoma Peyda Nashod. \n Lotfan FiveM Ra Restart Konid.")
        CancelEvent()
        return
    end
    local NilTokens = 0
    if GetNumPlayerTokens(source) == 0 or GetNumPlayerTokens(source) == nil or GetNumPlayerTokens(source) < 0 or GetNumPlayerTokens(source) == "null" or GetNumPlayerTokens(source) == "**Invalid**" then
        DiscordLog(source, "Max Token Numbers Are nil")
        setKickReason("\n \n HR_BanSystem: \n Moshkeli Dar Darayft Etelaat System Shoma Vojud Darad. \n Lotfan FiveM Ra Restart Konid.")
        CancelEvent()
        return
    end
    for i = 0, GetNumPlayerTokens(source) do 
        if GetPlayerToken(source, i) == nil or GetPlayerToken(source, i) == "" or GetNumPlayerTokens(source) == 0 or GetNumPlayerTokens(source) == nil then
            NilTokens = NilTokens + 1
        end
    end
    if NilTokens > 2 then
        DiscordLog(source, "More Than 2 Nil Tokens")
        setKickReason("\n \n HR_BanSystem: \n Moshkeli Dar Darayft Etelaat System Shoma Vojud Darad. \n Lotfan FiveM Ra Restart Konid.")
        CancelEvent()
        NilTokens = 0
        return
    else
        NilTokens = 0
    end
    if JoinCoolDown[Steam] == nil then
        JoinCoolDown[Steam] = os.time()
    elseif os.time() - JoinCoolDown[Steam] < 10 then 
        setKickReason("\n \n HR_BanSystem: \n ErrorCode : #12\n \n Lotfan Gozineye Connect Be Server Ra SPAM Nakonid.")
        CancelEvent()
        return
    else
        JoinCoolDown[Steam] = nil
    end
    for a, b in pairs(BannedAccounts) do
        for c, d in pairs(b) do 
            for e, f in pairs(json.decode(d.Tokens)) do
                for g = 0, GetNumPlayerTokens(source)-1 do
                    if d.Steam == tostring(Steam) or d.License == tostring(Lice) or d.Live == tostring(Live) or d.Xbox == tostring(Xbox) or d.Discord == tostring(Discord) or d.IP == tostring(IP) or GetPlayerToken(source, g) == f then
                        if os.time() < tonumber(d.Expire) then
                            BannedAlready = true
                            if d.Steam ~= tostring(Steam) then 
                                if GetPlayerToken(source, g) ~= f then 
                                    isBypassing = true
                                end
                            end
                            if d.Steam ~= tostring(Steam) and d.License ~= tostring(Lice) and not isBypassing then
                                isBypassing = true
                            end
                            setKickReason("\n \n HR_BanSystem: \n Ban ID: #"..d.ID.."\n Reason: "..d.Reason.."\n Expiration: You Have Been Banned For #"..math.floor(((tonumber(d.Expire) - os.time())/86400)).." Day(s)! \nHWID: "..f)
                            CancelEvent()
                            break
                        else
                            CreateUnbanThread(tostring(d.Steam))
                            break
                        end
                    end
                end
            end
        end
    end
    if not BannedAlready and not isBypassing then
        InitiateDatabase(tonumber(source), nil, 0, false)
    end
    if BannedAlready then
        DiscordLog(source, "Tried To Join But He/She Is Banned")
        BannedAlready = false
    end
    if isBypassing then
        DiscordLog(source, "Tried To Join Using Bypass Method")
        InitiateDatabase(tonumber(source), "Tried To Bypass HR_BanSystem", os.time() + (200 * 86400), true)
        isBypassing = false
        ReloadBans()
    end
end)

function CreateUnbanThread(Steam)
    MySQL.Async.fetchAll('SELECT Steam FROM hr_bansystem WHERE Steam = @Steam',
    {
        ['@Steam'] = Steam

    }, function(data)
        if data[1] then
            MySQL.Async.execute('UPDATE hr_bansystem SET Reason = @Reason, isBanned = @isBanned, Expire = @Expire WHERE Steam = @Steam', 
            {
                ['@isBanned'] = 0,
                ['@Reason'] = "",
                ['@Steam'] = Steam,
                ['@Expire'] = 0
            })
            SetTimeout(1000, function()
                ReloadBans()
            end)
        end
    end)
end

function InitiateDatabase(source, reason, expire, Banned)
    local reason = reason
    if reason == nil then
        reason = ""
    end
    local Banned = Banned
    if Banned == true then
        Banned = 1
    else
        Banned = 0
    end
    local source = source
    local ST = "None"
    local LC = "None"
    local LV = "None"
    local XB = "None"
    local DS = "None"
    local IiP = "None"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            ST  = v
        elseif string.sub(v, 1,string.len("license:")) == "license:" then
            LC  = v
        elseif string.sub(v, 1,string.len("live:")) == "live:" then
            LV  = v
        elseif string.sub(v, 1,string.len("xbl:")) == "xbl:" then
            Xbox = v
        elseif string.sub(v,1,string.len("discord:")) == "discord:" then
            DS = v
        elseif string.sub(v, 1,string.len("ip:")) == "ip:" then
            IiP = v
        end
    end
    DatabaseStuff[ST] = {}
    for i = 0, GetNumPlayerTokens(source) - 1 do 
        table.insert(DatabaseStuff[ST], GetPlayerToken(source, i))
    end
    MySQL.Async.fetchAll('SELECT Steam FROM hr_bansystem WHERE Steam = @Steam',
    {
        ['@Steam'] = ST

    }, function(data)
        if not data[1] then
            MySQL.Async.execute('INSERT INTO hr_bansystem (Steam, License, Tokens, Discord, IP, Xbox, Live, Reason, Expire, isBanned) VALUES (@Steam, @License, @Tokens, @Discord, @IP, @Xbox, @Live, @Reason, @Expire, @isBanned)',
            {
                ['@Steam'] = ST,
                ['@License'] = LC,
                ['@Discord'] = DS,
                ['@Xbox'] = XB,
                ['@IP'] = IiP,
                ['@Live'] = LV,
                ['@Reason'] = reason,
                ['@Tokens'] = json.encode(DatabaseStuff[ST]),
                ['@Expire'] = expire,
                ['@isBanned'] = Banned
            })
            DatabaseStuff[ST] = nil
        end 
    end)
end

RegisterCommand('banreload', function(source, args)
    if IsPlayerAllowedToBan(source) then
        ReloadBans()
        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Ban List Reloaded.")
    end
end)

RegisterServerEvent("HR_BanSystem:BanMe")
AddEventHandler("HR_BanSystem:BanMe", function(Reason, Time)
    local source = source
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            Cheat = v
        end
    end
    TriggerEvent('Initiate:BanSql', Cheat, tonumber(source), tostring(Reason), GetPlayerName(source), tonumber(Time))
end)

function BanThis(source, Reason, Time)
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            STP = v
        end
    end
    TriggerEvent('Initiate:BanSql', STP, tonumber(source), tostring(Reason), GetPlayerName(source), tonumber(Time))
end

RegisterCommand('ban', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = tonumber(args[1])
    if IsPlayerAllowedToBan(source) then
        if args[1] then
            if tonumber(args[2]) then
                if tostring(args[3]) then
                    if tonumber(args[1]) then
                        if GetPlayerName(target) then
                            for k, v in ipairs(GetPlayerIdentifiers(target)) do
                                if string.sub(v, 1, string.len("steam:")) == "steam:" then
                                    Hex = v
                                end
                            end
                            TriggerEvent('Initiate:BanSql', Hex, tonumber(target), tostring(args[3]), GetPlayerName(target), tonumber(args[2]))
                        else
                            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Player Is Not Online.")
                        end
                    else
                        if string.find(args[1], "steam:") ~= nil then
                            TriggerEvent('TargetPlayerIsOffline', args[1], tostring(args[3]), tonumber(xPlayer.source), tonumber(args[2]))
                        else
                            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Incorrect Steam Hex.")
                        end
                    end
                else
                    TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Shoma Dar Ghesmat Sevom Faghat Bayad Dalil Vared Konid.")
                end
            else
                TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Shoma Dar Ghesmat Dovom Faghat Adad Mitavanid Vared Konid.")
            end
        else
            TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0Bakhsh 1 Khali Ast.")
        end
    else
        TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^0You Are Not An Admin.")
    end
end)

RegisterServerEvent("HR_BanSystem:CheckBan")
AddEventHandler("HR_BanSystem:CheckBan", function(hex)
    local source = source
    MySQL.Async.fetchAll('SELECT * FROM hr_bansystem WHERE Steam = @Steam',
    {
        ['@Steam'] = hex

    }, function(data)
        if data[1] then
            if data[1].isBanned == 1 then
                DiscordLog(source, "Tried To Bypass BanSystem")
                DropPlayer(source, "Tried To Bypass HR_BanSystem")
            end
        end
    end)
end)

RegisterCommand('unban', function(source, args)
    if IsPlayerAllowedToBan(source) then
        if tostring(args[1]) then
            MySQL.Async.fetchAll('SELECT Steam FROM hr_bansystem WHERE Steam = @Steam',
            {
                ['@Steam'] = args[1]
    
            }, function(data)
                if data[1] then
                    MySQL.Async.execute('UPDATE hr_bansystem SET Reason = @Reason, isBanned = @isBanned, Expire = @Expire WHERE Steam = @Steam', 
                    {
                        ['@isBanned'] = 0,
                        ['@Reason'] = "",
                        ['@Steam'] = args[1],
                        ['@Expire'] = 0
                    })
                    ReloadBans()
                    TriggerClientEvent('chatMessage', source, "[BanSystem]", {255, 0, 0}, " ^2Unabn Movafaghiat Amiz Bood.")
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
    BannedAccounts = {}
    MySQL.Async.fetchAll('SELECT * FROM hr_bansystem', {}, function(info)
        for i = 1, #info do
            if info[i].isBanned == 1 then
                table.insert(BannedAccounts, {info[i]})
            end
        end
    end)
end

AddEventHandler("onMySQLReady",function()
	ReloadBans()
    WhileTrue()
    print("Ban List Loaded")
end)

function WhileTrue()
    SetTimeout(120000, function()
        WhileTrue()
        ReloadBans()
    end)
end

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

function DiscordLog(source, method)
    PerformHttpRequest('', function(err, text, headers)
    end, 'POST',
    json.encode({
    username = 'Player',
    embeds =  {{["color"] = 65280,
                ["author"] = {["name"] = 'Overland Logs ',
                ["icon_url"] = 'https://cdn.probot.io/QDwVwOiMTw.gif'},
                ["description"] = "** 🌐 Ban Log 🌐**\n```css\n[Guy]: " ..GetPlayerName(source).. "\n" .. "[ID]: " .. source.. "\n" .. "[Method]: " .. method .. "\n```",
                ["footer"] = {["text"] = "© OverLand Logs- "..os.date("%x %X  %p"),
                ["icon_url"] = 'https://cdn.probot.io/QDwVwOiMTw.gif',},}
                },
    avatar_url = 'https://cdn.probot.io/QDwVwOiMTw.gif'
    }),
    {['Content-Type'] = 'application/json'
    })
end