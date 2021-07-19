fx_version 'cerulean'
game 'gta5' 

author '^HoRam#1400'
description 'BanSystem'
version '1.2.0'

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
