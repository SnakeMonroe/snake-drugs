fx_version 'cerulean'
game 'rdr3'
lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Snake'
description 'Snake Drugs - Core Drug System for RSG'
version '1.0.0'

-- Dependencies
dependencies {
    'rsg-core',
    'rsg-inventory',
    'ox_lib',
    'ox_target'
}

-- Shared configs
shared_scripts {
    '@ox_lib/init.lua',
    '@rsg-core/shared/items.lua',
    'shared/config.lua'
}

-- Client-side
client_scripts {
    'client/sell.lua',
    'client/use.lua',
    'client/reputation.lua'
}

-- Server-side
server_scripts {
    'server/sell.lua',
    'server/use.lua',
    'server/reputation.lua'
}
