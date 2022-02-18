local sap = sap
local config = sap.config

util.AddNetworkString('sap:NewTicket')
util.AddNetworkString('sap:CloseTicket')
util.AddNetworkString('sap:ClaimTicket')
util.AddNetworkString('sap:TicketClosed')
util.AddNetworkString('sap:TicketClaimed')
util.AddNetworkString('sap:ChatMessage')

local GetAdmins, IsAdmin, SendToAdmins do
    local GetPlayers = player.GetAll

    function IsAdmin(ply)
        return config.HasAccess(ply) == true
    end

    function GetAdmins()
        local result, index = {}, 0
        local players = GetPlayers()
        for _, ply in ipairs(players) do
            if IsAdmin(ply) then
                index = index + 1
                result[index] = ply
            end
        end
        return result
    end

    function SendToAdmins()
        local admins = GetAdmins()
        net.Send(admins)
    end
end

local CreateTicket, GetTickets, FindTicket, RemoveTicket, ChatMessage do
    local WritePlayer = sap.WritePlayer
    local WriteString = net.WriteString
    local WriteUInt = net.WriteUInt
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
            WritePlayer(ply)
            WriteString(text)
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

            net_Start('sap:TicketClosed')
                WritePlayer(ply)
            net_Send(admins)

            timer_Remove(format('sap.ticket_%s', ply:SteamID64()))

            return true
        end
        return false
    end

    function GetTickets()
        return storage
    end

    function ChatMessage(ply, msgId)
        net_Start('sap:ChatMessage')
            WriteUInt(msgId, 4)
        net_Send(ply)
    end
end

do
    local Explode = string.Explode
    local Trim = string.Trim
    local Run = hook.Run
    local Time = CurTime
    local concat = table.concat
    local remove = table.remove

    hook.Add('PlayerSay', 'sap.PlayerSay', function(ply, text)
        local args = Explode(' ', text)
        local cmd = args[1]
        remove(args, 1)
        local msg = Trim(concat(args, ' '))
        local curtime = Time()

        if cmd == config.Command and msg ~= '' then
            if ply:GetVar('sap_Delay', 0) <= curtime then
                if Run('PlayerCanCreateTicket', ply, text) ~= false and FindTicket(ply) == nil then
                    CreateTicket(ply, msg)
                    ChatMessage(ply, sap.messages.MSG_CREATED)
                    ply:SetVar('sap_Delay', curtime + sap.config.Delay)
                end
            else
                ChatMessage(ply, sap.messages.MSG_DELAY)
            end
            return ''
        end
    end)

    hook.Add('PlayerDisconnected', 'sap.PlayerDisconnected', function(ply)
        RemoveTicket(ply)
    end)
end

do
    local ReadPlayer = sap.ReadPlayer
    local WritePlayer = sap.WritePlayer
    local format = string.format
    local Start = net.Start
    local timer_Remove = timer.Remove

    net.Receive('sap:ClaimTicket', function(len, ply)
        local target = ReadPlayer()

        if IsAdmin(ply) and IsValid(target) then
            local ticket = FindTicket(target)

            if ticket then
                timer_Remove(format('sap.ticket_%s', target:SteamID64()))

                Start('sap:TicketClaimed')
                    WritePlayer(ply)
                    WritePlayer(target)
                SendToAdmins()

                ChatMessage(ply, sap.messages.MSG_CLAIMED)

                if sap.config.ClaimNotify then
                    ChatMessage(target, sap.messages.MSG_CLAIMED_TO_PLAYER)
                end

                hook.Run('PlayerClaimedTicket', ply, target)
            end
        end
    end)

    net.Receive('sap:CloseTicket', function(len, ply)
        local target = ReadPlayer()

        if IsAdmin(ply) and IsValid(target) then
            RemoveTicket(target)

            ChatMessage(ply, sap.messages.MSG_CLOSED)
        end
    end)
end

sap.CreateTicket = CreateTicket
sap.RemoveTicket = RemoveTicket
sap.FindTicket = FindTicket
sap.GetTickets = GetTickets