fx_version 'cerulean'
game 'rdr3'
lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Snake'
description 'Snake Drugs - Core Drug System for RSG'
version '1.0.0'

-- Dependencies (ensure these exist in your resources)
dependencies {
    'ox_lib',
    'ox_target',
    'rsg-inventory',
    'rsg-core'
}

-- Shared between client and server
shared_scripts {
    '@ox_lib/init.lua',               -- recommended for ox_lib
    '@rsg-core/shared/items.lua',    -- item definitions
    'config.lua',
    'shared/shared.lua'
}

-- Client-side scripts
client_scripts {
    'client/main.lua'
}

-- Server-side scripts
server_scripts {
    'server/main.lua'
}
