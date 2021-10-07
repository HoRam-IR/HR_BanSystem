fx_version 'cerulean'
game 'gta5' 

author '^HoRam#0060'
description 'BanSystem'
version '2.6.0'

client_scripts {
    'client/main.lua',
}

server_scripts { 
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
}

server_exports {
	'BanThis'
}
