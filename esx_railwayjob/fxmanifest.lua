fx_version 'adamant'
game 'gta5'

description 'ESX Railway Job'
author 'ESX Legacy'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/train_models.lua',
    'client/controls.lua',
    'client/rail_snap.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/grades.lua'
}

dependencies {
    'es_extended',
    'esx_skin'
}