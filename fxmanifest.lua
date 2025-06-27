fx_version 'cerulean'
game 'rdr3'
lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Snake'
description 'Snake Drugs - Core Drug System for RSG'
version '1.0.0'

-- Dependencies used
dependencies {
    'rsg-core',
    'rsg-inventory',
    'ox_lib',
    'ox_target'
}

-- Shared scripts for both client and server
shared_scripts {
    '@ox_lib/init.lua',
    '@rsg-core/shared/items.lua',
    'shared/config.lua'
}

-- Client-side scripts
client_scripts {
    'client/sell.lua',
    'client/use.lua'
}

-- Server-side scripts
server_scripts {
    'server/sell.lua',
    'server/use.lua'
}
