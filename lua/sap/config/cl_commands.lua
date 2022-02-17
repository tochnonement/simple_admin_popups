sap.CreateCommand('goto', {
    name = 'Goto',
    icon = 'https://i.imgur.com/825vH9b.png',
    callbacks = {
        ['sam'] = function(ply)
            RunConsoleCommand('sam', 'goto', ply:SteamID64())
        end
    }
})

sap.CreateCommand('bring', {
    name = 'Bring',
    icon = 'https://i.imgur.com/rza3lYM.png',
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
            if ply:IsFlagSet(FL_FROZEN) then
                RunConsoleCommand('sam', 'unfreeze', ply:SteamID64())
            else
                RunConsoleCommand('sam', 'freeze', ply:SteamID64())
            end
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