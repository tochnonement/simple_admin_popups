local sap = sap

do
    local storage, index = {}, 0

    function sap.CreateCommand(id, data)
        index = index + 1
        data.id = id
        storage[index] = data
    end

    function sap.GetCommands()
        return storage
    end
end

do
    local popups = {}

    local ReadPlayer = sap.ReadPlayer
    local ReadString = net.ReadString
    local SendToServer = net.SendToServer
    local net_Start = net.Start
    local insert = table.insert
    local format = string.format
    local ipairs = ipairs

    local function movePopups()
        local basePos = ScreenScale(5)
        local gap = ScreenScale(2)
        local x, y = basePos, basePos
        for _, popup in ipairs(popups) do
            if popup.finished then
                popup:MoveTo(-popup:GetWide(), y, 0.33)
            else
                if not popup.moved then
                    popup:SetPos(10, y)
                end
                popup:MoveTo(x, y, 0.33)
                y = y + popup:GetTall() + gap
            end
            popup.moved = true
        end
    end

    local function findPopup(ply)
        for _, popup in ipairs(popups) do
            if popup.player == ply then
                return popup
            end
        end
    end

    net.Receive('sap:NewTicket', function()
        local ply, text = ReadPlayer(), ReadString()

        local popup = vgui.Create('sap.Popup')
        popup:SetPos(10, 10)
        popup:SetSize(ScrW() * 0.2, 1)
        popup:SetPlayer(ply, text)
        popup:SetPaintedManually(true)

        popup.index = insert(popups, popup)

        timer.Simple(0.66, function()
            if IsValid(popup) then
                local height = popup:GetBestHeight()
                popup:SetPaintedManually(false)
                popup:SetHeight(height)
                popup:SetAlpha(0)
                popup:AlphaTo(255, 0.33)
                movePopups()
            end
        end)
    end)

    net.Receive('sap:TicketClosed', function()
        local ply = ReadPlayer()
        local popup = findPopup(ply)

        if IsValid(popup) then
            popup.finished = true
            movePopups()
            popup:AlphaTo(0, 0.33, nil, function(anim, panel)
                panel:Remove()
                table.remove(popups, panel.index)
            end)
        end
    end)

    net.Receive('sap:TicketClaimed', function()
        local admin = ReadPlayer()
        local ply = ReadPlayer()
        local popup = findPopup(ply)

        if IsValid(admin) and IsValid(ply) and popup then
            local newTitle = format('%s - Claimed by %s', popup.lblTitle:GetText(), admin:Name())

            popup.lblTitle:SetText(newTitle)

            if admin == LocalPlayer() then
                popup.claim.name:SetText('Close')
                popup.claim.callback = function(ply)
                    net_Start('sap:CloseTicket')
                        sap.WritePlayer(popup.player)
                    SendToServer()
                end
                popup.header.color = sap.config.ClaimedColor
            else
                popup.claim:SetVisible(false)
            end
        end
    end)
end