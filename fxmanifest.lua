fx_version 'cerulean'
game 'rdr3'
lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'Snake Drugs - Core Drug System for RSG'

dependencies {
    'ox_lib',
    'ox_target',
    'rsg-inventory',
    'rsg-core'
}

shared_scripts {
    'shared/shared.lua',
    'config.lua',
    '@rsg-core/shared/items.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
