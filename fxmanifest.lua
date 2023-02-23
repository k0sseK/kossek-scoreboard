fx_version 'cerulean'
game 'gta5'
author 'k0sseK'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/main.js',
    'html/assets/*.png',
    'html/assets/*.jpg'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'bridge/**/server.lua',
    'server/main.lua'
}

lua54 'yes'