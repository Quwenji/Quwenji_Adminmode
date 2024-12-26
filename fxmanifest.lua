-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'

author 'Quwenji'
description 'Admin Mode Script für ESX'
version '1.0.0'
lua54 'yes'

escrow_ignore {
    'config.lua'
}


shared_scripts {
    'config.lua'
}
-- Abhängigkeiten sicherstellen
dependencies {
    'es_extended'
}

server_scripts {
    '@es_extended/locale.lua',
    'server/main.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'client/main.lua',
}
