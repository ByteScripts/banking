fx_version 'cerulean'
games { 'gta5' }
use_experimental_fxv2_oal 'yes'
lua54 'yes'

dependencies {
    'oxmysql',
    'ox_lib',
    'es_extended'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_script 'init.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'init.lua'
}

files {
    'client.lua',
    'server.lua',
    'modules/**/client.lua',
    'modules/**/shared.lua',
    'utils/client/**/*',
    'utils/shared/**/*',
    'utils/server/**/*',
    'data/*.*',
}
