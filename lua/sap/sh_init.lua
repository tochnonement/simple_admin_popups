local sap = sap

do
    sap.messages = {}
    local index = 0
    local handlers = {}

    local AddText = CLIENT and chat.AddText

    local color_white = color_white
    local color_red = Color(226, 66, 66)
    local color_green = Color(90, 221, 90)
    local color_blue = Color(88, 166, 255)
    local color_tag = Color(255, 210, 60)
    local tag = '(SAP)'
    local space = ' '

    local function createMsg(id, data)
        index = index + 1
        if CLIENT then
            handlers[index] = data
        end
        sap.messages[id] = index
        return index
    end

    createMsg('MSG_CLAIMED', function()
        AddText(color_tag, tag, space, color_white, 'You have', color_green, ' claimed ', color_white, 'the ticket.')
    end)

    createMsg('MSG_CLAIMED_TO_PLAYER', function()
        AddText(color_tag, tag, space, color_blue, 'Someone', color_white, ' has ', color_green, 'claimed ', color_white, 'your ticket.')
    end)

    createMsg('MSG_CLOSED', function()
        AddText(color_tag, tag, space, color_white, 'You have', color_red, ' closed ', color_white, 'the ticket.')
    end)

    createMsg('MSG_DELAY', function()
        AddText(color_tag, tag, space, color_white, 'You have already created a ticket recently, wait a while.')
    end)

    createMsg('MSG_CREATED', function()
        AddText(color_tag, tag, space, color_white, 'You have created a ticket!')
    end)

    if CLIENT then
        local ReadUInt = net.ReadUInt

        net.Receive('sap:ChatMessage', function()
            local msgId = ReadUInt(4)

            handlers[msgId]()
        end)
    end
end

do
    local IsValid = IsValid
    local WriteUInt = net.WriteUInt
    local ReadUInt = net.ReadUInt
    local EntIndex = FindMetaTable('Entity').EntIndex

    function sap.WritePlayer(ply)
        local index = EntIndex(ply)

        if IsValid(ply) then
            WriteUInt(index, 8)
        else
            WriteUInt(index, 0)
        end
    end

    function sap.ReadPlayer(ply)
        local index = ReadUInt(8)
        if index then
            return Entity(index)
        end
    end
end

do
    local waitGamemode = (GM or GAMEMODE) == nil and hook.Add or function(_, _, fn) fn() end
    local function catchAdminMod()
        local id = ''
        if sam then
            id = 'sam'
        elseif serverguard then
            id = 'serverguard'
        elseif ulx then
            id = 'ulx'
        end
        return id
    end

    waitGamemode('Initialize', 'sap.CatchAdminMod', function()
        if sap.config.AdminMod == nil then
            sap.config.AdminMod = catchAdminMod()
        end
    end)
end