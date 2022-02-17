local sap = sap
local config = sap.config

util.AddNetworkString('sap:NewTicket')
util.AddNetworkString('sap:CloseTicket')

local GetAdmins do
    local GetPlayers = player.GetAll

    function GetAdmins()
        local result, index = {}, 0
        local players = GetPlayers()
        for _, ply in ipairs(players) do
            if ply:IsAdmin() then
                index = index + 1
                result[index] = ply
            end
        end
        return result
    end
end

local CreateTicket, GetTickets, FindTicket, RemoveTicket do
    local remove = table.remove
    local time = os.time
    local format = string.format
    local net_Start = net.Start
    local net_Send = net.Send
    local timer_Create = timer.Create
    local timer_Remove = timer.Remove

    local storage, index = {}, 0

    function CreateTicket(ply, text)
        local admins = GetAdmins()

        index = index + 1
        storage[index] = {
            text = text,
            ply = ply,
            index = index,
            time = time()
        }

        net_Start('sap:NewTicket')
        net_Send(admins)

        if config.AutoCloseEnabled then
            timer_Create(format('sap.ticket_%s', ply:SteamID64()), config.AutoCloseTime, 1, function()
                RemoveTicket(ply)
            end)
        end
    end

    function FindTicket(ply)
        for i = 1, index do
            local ticket = storage[i]
            if ticket and ticket.ply == ply then
                return ticket
            end
        end
    end

    function RemoveTicket(ply)
        local ticket = FindTicket(ply)
        if ticket then
            local admins = GetAdmins()

            remove(storage, ticket.index)
            index = index - 1

            net.Start('sap:CloseTicket')
            net.Send(admins)

            timer_Remove(format('sap.ticket_%s', ply:SteamID64()))

            return true
        end
        return false
    end

    function GetTickets()
        return storage
    end
end

do
    local Explode = string.Explode
    local Trim = string.Trim
    local Run = hook.Run
    local concat = table.concat
    local remove = table.remove

    hook.Add('PlayerSay', 'sap.PlayerSay', function(ply, text)
        local args = Explode(' ', text)
        local cmd = args[1]
        remove(args, 1)
        local msg = Trim(concat(args, ' '))

        if
            cmd == config.Command
            and msg ~= ''
            and Run('PlayerCanCreateTicket', ply, text) ~= false
        then
            CreateTicket(ply, msg)
        end
    end)

    hook.Add('PlayerDisconnected', 'sap.PlayerDisconnected', function(ply)
        RemoveTicket(ply)
    end)
end

sap.CreateTicket = CreateTicket
sap.GetTickets = GetTickets