local IpBanCheck = true -- Script should check ip for banning?
local JoinCoolDown = {}
local DatabaseStuff = {}
local BannedAccounts = {}
local Admins = {
    "steam:11000",
    "example",
}

SendMessage = function(Source,Title,Color,Msg)
    if Source == 0 then
        print(Title,Msg)
    else
        TriggerClientEvent('chatMessage', Source, Title, Color, Msg)
    end
end

DisplayTime = function(time)
    local days = math.floor(time/86400)
    local remaining = time % 86400
    local hours = math.floor(remaining/3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining/60)
    remaining = remaining % 60
    local seconds = remaining
    if (hours < 10) then
        hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
        minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
        seconds = "0" .. tostring(seconds)
    end
    answer = tostring(days)..' Day(s) '..hours..':'..minutes..':'..seconds
    return answer
end

AddEventHandler('esx:playerLoaded', function(source)
    local source = source
    local BannedAlready2 = false
    local isBypassing2 = false
    local Steam = "NONE"
    local Lice = "NONE"
    local Lice2 = "NONE"
    local Live = "NONE"
    local Xbox = "NONE"
    local Discord = "NONE"
    local IP = "NONE"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            Steam = v
        elseif string.sub(v, 1,string.len("license:")) == "license:" then
            Lice = v
        elseif string.sub(v, 1,string.len("license2:")) == "license2:" then
            Lice2 = v
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
    if GetNumPlayerTokens(source) == 0 or GetNumPlayerTokens(source) == nil or GetNumPlayerTokens(source) < 0 or GetNumPlayerTokens(source) == "null" or GetNumPlayerTokens(source) == "**Invalid**" or not GetNumPlayerTokens(source) then
        DiscordLog(source, "Player Token Numbers Are Unknown")
        DropPlayer(source, "HR_BanSystem: \n There is a problem retrieving your fivem informations \n Please Restart FiveM.")
        return
    end
    for a, b in pairs(BannedAccounts) do
        for c, d in pairs(b) do 
            for e, f in pairs(json.decode(d.Tokens)) do
                for g = 0, GetNumPlayerTokens(source) - 1 do
                    if GetPlayerToken(source, g) == f or d.License == tostring(Lice) or d.License2 == tostring(Lice2) or d.Live == tostring(Live) or d.Xbox == tostring(Xbox) or d.Discord == tostring(Discord) or (IpBanCheck and d.IP == tostring(IP) or false) or d.Steam == tostring(Steam) then
                        if (type(d.Expire) == 'string' and string.lower(d.Expire) == "permanet") or os.time() < tonumber(d.Expire) then
                            BannedAlready2 = tostring(d.Reason)
                            if d.Steam ~= tostring(Steam) then
                                isBypassing2 = d.Expire
                            end
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
    if BannedAlready2 then
        DiscordLog(source, "Has tried To join. (Rejected from joining before loading into the server) Ban Reason: " .. BannedAlready2)
        DropPlayer(source, "You were banned from this server.")
    end
    if isBypassing2 then
        DiscordLog(source, "Has tried To join using Bypass method by changing identifiers (New identifiers has been banned.")
        BanNewAccount(tonumber(source), "Tried To Bypass HR_BanSystem", isBypassing2)
        DropPlayer(source, "You were banned from this server.")
    end
end)

AddEventHandler('Initiate:BanSql', function(hex, id, reason, name, day)
    local time
    if (type(day) == 'string' and string.lower(day) == "permanet") or tonumber(day) == 0 then
	time = "Permanet"
    else
	time = tonumber(day)
   end
    MySQL.Async.execute('UPDATE hr_bansystem SET Reason = @Reason, isBanned = @isBanned, Expire = @Expire WHERE Steam = @Steam', 
    {
        ['@isBanned'] = 1,
        ['@Reason'] = reason,
        ['@Steam'] = hex,
        ['@Expire'] = (type(time) == 'string' and time) or (os.time() + (time * 86400))
    })
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 131, 0, 0.4); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> [Punishment]<br>  {1}</div>',
        args = { name, '^1' .. name .. ' ^0has been banned, Reason: ^1' ..reason.." ^0Duration: ^1".. (type(day) == 'string' and "Permanet" or time .." ^0 Day(s).")}
    })
    DropPlayer(id, reason)
    SetTimeout(5000, function()
        ReloadBans()
    end)
end)

AddEventHandler('TargetPlayerIsOffline', function(hex, reason, xAdmin, day)
    local time
    if (type(day) == 'string' and string.lower(day) == "permanet") or tonumber(day) == 0 then
	time = "Permanet"
    else
	time = tonumber(day)
    end
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
                ['@Expire'] = (type(time) == 'string' and time) or (os.time() + (time * 86400))
            })
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 131, 0, 0.4); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> [Punishment]<br>  {1}</div>',
                args = { hex, '^1' .. hex .. ' ^0has been banned, Reason: ^1' ..reason.." ^0Duration: t ^1".. (type(day) == 'string' and "Permanet" or time .." ^0 Day(s).")}
            })
            SetTimeout(5000, function()
                ReloadBans()
            end)
        else
            SendMessage(xAdmin, "[Database]", {255, 0, 0}, "^0I Can't find this steam hex. :( It is incorrect")
        end
    end)
end)

AddEventHandler('playerConnecting', function(name, setKickReason)
    local source = source
    local BannedAlready = false
    local isBypassing = false
    local Steam = "NONE"
    local Lice = "NONE"
    local Lice2 = "NONE"
    local Live = "NONE"
    local Xbox = "NONE"
    local Discord = "NONE"
    local IP = "NONE"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            Steam = v
        elseif string.sub(v, 1,string.len("license:")) == "license:" then
            Lice = v
        elseif string.sub(v, 1,string.len("license2:")) == "license2:" then
            Lice2 = v
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
    if Steam == nil or Lice == nil or Steam == "" or Lice == "" or Steam == "NONE" or Lice == "NONE" then
        setKickReason("\n \n HR_BanSystem: \n Your Steam identifier could not be fetched. \n Please restart your steam, then start your FiveM again.")
        CancelEvent()
        return
    end
    if GetNumPlayerTokens(source) == 0 or GetNumPlayerTokens(source) == nil or GetNumPlayerTokens(source) < 0 or GetNumPlayerTokens(source) == "null" or GetNumPlayerTokens(source) == "**Invalid**" or not GetNumPlayerTokens(source) then
        DiscordLog(source, "Max Token Numbers Are nil")
        setKickReason("\n \n HR_BanSystem: \n There is a problem retrieving your fivem informations \n Please Restart FiveM.")
        CancelEvent()
        return
    end
    if JoinCoolDown[Steam] == nil then
        JoinCoolDown[Steam] = os.time()
    elseif os.time() - JoinCoolDown[Steam] < 15 then 
        setKickReason("\n \n HR_BanSystem: \n Don't spam the connect button!")
        CancelEvent()
        return
    else
        JoinCoolDown[Steam] = nil
    end
    for a, b in pairs(BannedAccounts) do
        for c, d in pairs(b) do 
            for e, f in pairs(json.decode(d.Tokens)) do
                for g = 0, GetNumPlayerTokens(source) - 1 do
                    if GetPlayerToken(source, g) == f or d.License == tostring(Lice) or d.License2 == tostring(Lice2) or d.Live == tostring(Live) or d.Xbox == tostring(Xbox) or d.Discord == tostring(Discord) or (IpBanCheck and d.IP == tostring(IP) or false) or d.Steam == tostring(Steam) then
                       if (type(d.Expire) == 'string' and string.lower(d.Expire) == "permanet")  or os.time() < tonumber(d.Expire) then
                            BannedAlready = tostring(d.Reason)
                            if d.Steam ~= tostring(Steam) then
                                isBypassing = d.Expire
                            end
                            setKickReason("\n \n HR_BanSystem: \n Ban ID: #"..d.ID.."\n Reason: "..d.Reason.."\n Expiration: You have been banned for ".. ((type(d.Expire) == 'string' and string.lower(d.Expire) == "permanet") and "Permanet" or DisplayTime((tonumber(d.Expire) - os.time()))) .." ! \nHWID: "..f)
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
        InitiateDatabase(tonumber(source))
    end
    if BannedAlready then
        DiscordLog(source, "Has tried To join. (Rejected from joining before loading into the server) Ban Reason: " .. BannedAlready)
    end
    if isBypassing then
        DiscordLog(source, "Has tried To join using Bypass method by changing identifiers (New identifiers has been banned.)")
        BanNewAccount(tonumber(source), "Tried To Bypass HR_BanSystem", isBypassing)
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
            SetTimeout(5000, function()
                ReloadBans()
            end)
        end
    end)
end

function InitiateDatabase(source)
    local source = source
    local ST = "None"
    local LC = "None"
    local LC2 = "None"
    local LV = "None"
    local XB = "None"
    local DS = "None"
    local IiP = "None"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            ST  = v
        elseif string.sub(v, 1,string.len("license:")) == "license:" then
            LC  = v
        elseif string.sub(v, 1,string.len("license2:")) == "license2:" then
            LC2  = v
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
    if ST == "None" then print(source.." Failed To Create User") return end
    DatabaseStuff[ST] = {}
    for i = 0, GetNumPlayerTokens(source) - 1 do 
        table.insert(DatabaseStuff[ST], GetPlayerToken(source, i))
    end
    MySQL.Async.fetchAll('SELECT * FROM hr_bansystem WHERE Steam = @Steam',
    {
        ['@Steam'] = ST

    }, function(data) 
        if data[1] == nil then
            MySQL.Async.execute('INSERT INTO hr_bansystem (Steam, License, License2, Tokens, Discord, IP, Xbox, Live, Reason, Expire, isBanned) VALUES (@Steam, @License, @License2, @Tokens, @Discord, @IP, @Xbox, @Live, @Reason, @Expire, @isBanned)',
            {
                ['@Steam'] = ST,
                ['@License'] = LC,
                ['@License2'] = LC2,
                ['@Discord'] = DS,
                ['@Xbox'] = XB,
                ['@IP'] = IiP,
                ['@Live'] = LV,
                ['@Reason'] = "",
                ['@Tokens'] = json.encode(DatabaseStuff[ST]),
                ['@Expire'] = 0,
                ['@isBanned'] = 0
            })
            DatabaseStuff[ST] = nil
        end 
    end)
end

function BanNewAccount(source, Reason, Time)
    local source = source
    local ST = "None"
    local LC = "None"
    local LC2 = "None"
    local LV = "None"
    local XB = "None"
    local DS = "None"
    local IiP = "None"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            ST  = v
        elseif string.sub(v, 1,string.len("license:")) == "license:" then
            LC  = v
        elseif string.sub(v, 1,string.len("license2:")) == "license2:" then
            LC2  = v
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
    if ST == "None" then print(source.." Failed To Create User") return end
    DatabaseStuff[ST] = {}
    for i = 0, GetNumPlayerTokens(source) - 1 do 
        table.insert(DatabaseStuff[ST], GetPlayerToken(source, i))
    end
    MySQL.Async.fetchAll('SELECT * FROM hr_bansystem WHERE Steam = @Steam',
    {
        ['@Steam'] = ST

    }, function(data) 
        if data[1] == nil then
            MySQL.Async.execute('INSERT INTO hr_bansystem (Steam, License, License2, Tokens, Discord, IP, Xbox, Live, Reason, Expire, isBanned) VALUES (@Steam, @License, @License2, @Tokens, @Discord, @IP, @Xbox, @Live, @Reason, @Expire, @isBanned)',
            {
                ['@Steam'] = ST,
                ['@License'] = LC,
                ['@License2'] = LC2,
                ['@Discord'] = DS,
                ['@Xbox'] = XB,
                ['@IP'] = IiP,
                ['@Live'] = LV,
                ['@Reason'] = Reason,
                ['@Tokens'] = json.encode(DatabaseStuff[ST]),
                ['@Expire'] = Time,
                ['@isBanned'] = 1
            })
            DatabaseStuff[ST] = nil
            SetTimeout(5000, function()
                ReloadBans()
            end)
        end 
    end)
end

RegisterCommand('banreload', function(source, args)
    if source == 0 or IsPlayerAllowedToBan(source) then
        ReloadBans()
        SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0Ban List Reloaded.")
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
    TriggerEvent('Initiate:BanSql', Cheat, tonumber(source), tostring(Reason), GetPlayerName(source), Time)
end)

function BanThis(source, Reason, Times)
    local time = Times
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            STP = v
        end
    end
    if Times == nil or not Times then
        time = 365
    end
    TriggerEvent('Initiate:BanSql', STP, tonumber(source), tostring(Reason), GetPlayerName(source), time)
end

RegisterCommand('ban', function(source, args)
    local source = source
    local target = tonumber(args[1])
    if source == 0 or IsPlayerAllowedToBan(source) then
        if args[1] then
            if string.lower(tostring(args[2])) == 'permanet' or tonumber(args[2]) then
                if tostring(args[3]) then
                    if tonumber(args[1]) then
                        if GetPlayerName(target) then
                            for k, v in ipairs(GetPlayerIdentifiers(target)) do
                                if string.sub(v, 1, string.len("steam:")) == "steam:" then
                                    Hex = v
                                end
                            end
                            DiscordLog(tonumber(source), "Banned " .. tostring(GetPlayerName(target)) .. " for " .. (string.lower(tostring(args[2])) == 'permanet' and "Permanet" or (tonumber(args[2]) == 0 and "Permanet" or tonumber(args[2]))) .. " Reason: " .. table.concat(args, " ",3) )
                            TriggerEvent('Initiate:BanSql', Hex, tonumber(target), table.concat(args, " ",3), GetPlayerName(target), args[2])
                        else
                            SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0Player Is Not Online.")
                        end
                    else
                        if string.find(args[1], "steam:") ~= nil then
                            DiscordLog(tonumber(source), "Banned " .. tostring(args[1]) .. " for " .. (string.lower(tostring(args[2])) == 'permanet' and "Permanet" or (tonumber(args[2]) == 0 and "Permanet" or tonumber(args[2]))) .. " Reason: " .. table.concat(args, " ",3) )
                            TriggerEvent('TargetPlayerIsOffline', args[1], table.concat(args, " ",3), tonumber(source), args[2])
                        else
                            SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0The entered steam hex is incorrect.")
                        end
                    end
                else
                    SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0Please enter a ban reason.")
                end
            else
                SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0Please enter the ban duration.")
            end
        else
            SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0Please enter the player server ID or steam hex.")
        end
    else
        if source ~= 0 then
            SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0You don't have admin's privilege.")
        end
    end
end)

RegisterServerEvent("HR_BanSystem:ClientLoaded")
AddEventHandler("HR_BanSystem:ClientLoaded", function()
    local source = source
    local ST = "None"
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1,string.len("steam:")) == "steam:" then
            ST  = v
            break
        end
    end
    if ST == "None" then print(source.." Failed To KVP Check") return end
    TriggerClientEvent("HR_BanSystem:playerLoaded", source, ST)
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
                DiscordLog(source, "Has tried to Bypass the ban system with KVP Method")
                DropPlayer(source, "You were already banned fromn this server!")
            end
        end
    end)
end)

RegisterCommand('unban', function(source, args)
    if source == 0 or IsPlayerAllowedToBan(source) then
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
                    SetTimeout(5000, function()
                        ReloadBans()
                    end)
                    DiscordLog(tonumber(source), "Unbanned " .. tostring(args[1]))
                    SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^2Player unbanned successfully.")
                else
                    SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0The entered steam hex is incorrect.")
                end
            end)
        else
            SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0The entered steam hex is incorrect.")
        end
    else
        if source ~= 0 then
            SendMessage(source, "[BanSystem]", {255, 0, 0}, " ^0You don't have admin's privilege.")
        end
    end
end)

function ReloadBans()
    Citizen.CreateThread(function()
        BannedAccounts = {}
        MySQL.Async.fetchAll('SELECT * FROM hr_bansystem', {}, function(info)
            for i = 1, #info do
                if info[i].isBanned == 1 then
                    Citizen.Wait(2)
                    table.insert(BannedAccounts, {info[i]})
                end
            end
        end)
    end)
end

MySQL.ready(function()
    ReloadBans()
    print("Ban List Loaded")
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

function DiscordLog(source, method)
    PerformHttpRequest("",function(err, text, headers)
        end, "POST",
            json.encode(
                {
                    username = "Player",
                    embeds = {
                        {
                            ["color"] = 65280,
                            ["author"] = {
                                ["name"] = "Ban Logs ",
                                ["icon_url"] = ""
                            },
                            ["description"] = "** 🌐 Ban Log 🌐**\n```css\n[Guy]: " .. (source == 0 and "Console" or GetPlayerName(source)) .. "\n" .. "[ID]: " .. (source == 0 and "Console" or source) .. "\n" .. "[Method]: " .. method .. "\n```",
                            ["footer"] = {
                                ["text"] = "© Ban Logs- " .. os.date("%x %X  %p"),
                                ["icon_url"] = ""
                            }
                        }
                    },
                    avatar_url = ""
                }
            ),
        {
        ["Content-Type"] = "application/json"
    })
end

