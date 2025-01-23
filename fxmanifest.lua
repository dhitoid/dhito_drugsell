fx_version 'cerulean'
game 'gta5'

description 'NPC Drug Trade System By DT DEVELOPMENT ID'
author 'DHITO'
version '1.0.0'

shared_script {
    -- '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/cl_main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

lua54 'yes'

dependency 'ox_lib'