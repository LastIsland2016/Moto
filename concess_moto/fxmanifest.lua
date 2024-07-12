fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Job Concess Made By Sacario'

escrow_ignore {
	'shared/config.lua'
}

shared_script({
    '@es_extended/imports.lua',
    'shared/*.lua',
    '@ox_lib/init.lua'
});

client_scripts {
    'client/**/**/*.lua',
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/**/**/*.lua',
}

------------------------------------


dependency '/assetpacks'