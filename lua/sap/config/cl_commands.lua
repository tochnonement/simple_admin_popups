sap.CreateCommand('goto', {
    name = 'Goto',
    icon = 'https://i.imgur.com/JZ68F3c.png',
    callbacks = {
        ['sam'] = function(ply)
            RunConsoleCommand('sam', 'bring', ply:SteamID64())
        end
    }
})

sap.CreateCommand('bring', {
    name = 'Bring',
    icon = 'https://i.imgur.com/raABZXo.png',
    callbacks = {
        ['sam'] = function(ply)
            RunConsoleCommand('sam', 'bring', ply:SteamID64())
        end
    }
})

sap.CreateCommand('freeze', {
    name = 'Freeze',
    icon = 'https://i.imgur.com/LgPUsyg.png',
    callbacks = {
        ['sam'] = function(ply)
            RunConsoleCommand('sam', 'freeze', ply:SteamID64())
        end
    }
})

sap.CreateCommand('return', {
    name = 'Return',
    icon = 'https://i.imgur.com/ZJEgOjG.png',
    callbacks = {
        ['sam'] = function(ply)
            RunConsoleCommand('sam', 'return', ply:SteamID64())
        end
    }
})