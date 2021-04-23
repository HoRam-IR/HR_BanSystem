fx_version 'cerulean'
game 'gta5' 

author '^HoRam#1400'
description 'BanSystem'
version '1.0.0'

client_scripts {
    'client/main.lua',
    'settings/cl_settings.lua'
}

server_scripts { 
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
    'settings/sv_settings.lua'
}

