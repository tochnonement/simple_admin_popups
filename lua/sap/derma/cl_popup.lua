local sap = sap
local draw_RoundedBox = draw.RoundedBox
local draw_RoundedBoxEx = draw.RoundedBoxEx
local draw_Webicon = sap.webicon.Draw

surface.CreateFont('sap.Default', {
    font = 'Roboto',
    size = ScreenScale(6),
    extended = true
})

local PANEL = {}

function PANEL:Init()
    self.header = self:Add('Panel')
    self.header.color = sap.config.HeaderColor
    self.header.Paint = function(p, w, h)
        draw_RoundedBoxEx(4, 0, 0, w, h, p.color, true, true)
    end

    self.commands = self:Add('Panel')

    self.lblTitle = self.header:Add('DLabel')
    self.lblTitle:SetText('John Elburg')
    self.lblTitle:SetFont('sap.Default')
    self.lblTitle:SetTextColor(color_white)

    self.lblText = self:Add('DLabel')
    self.lblText:SetWrap(true)
    self.lblText:SetContentAlignment(7)
    self.lblText:SetFont('sap.Default')
    self.lblText:SetTextColor(sap.config.TextColor)
    -- self.lblText:SetText([[Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.]])
    self.lblText:SetText([[Lorem Ipsum]])

    self:AddCommands()
    self.claim = self:AddButton('Claim', 'https://i.imgur.com/C9G5cWP.png')
end

function PANEL:PerformLayout(w, h)
    local gap = ScreenScale(2)

    self.header:Dock(TOP)
    self.header:SetTall(ScreenScale(10))
    self.header:DockMargin(0, 0, 0, gap)

    self.lblTitle:Dock(FILL)
    self.lblTitle:DockMargin(gap, 0, 0, 0)

    self.lblText:Dock(LEFT)
    self.lblText:SetWide(w * 0.6)
    self.lblText:DockMargin(gap, 0, 0, gap)

    self.commands:Dock(FILL)
    self.commands:DockMargin(gap, 0, gap, gap)
end

function PANEL:Paint(w, h)
    draw_RoundedBox(4, 0, 0, w, h, sap.config.BackgroundColor)
end

function PANEL:GetBestHeight()
    local tall, btnTall, textTall = 0, 0, select(2, self.lblText:GetContentSize())

    for _, child in ipairs(self.commands:GetChildren()) do
        if child:IsVisible() then
            btnTall = btnTall + child:GetTall() + select(4, child:GetDockMargin())
        end
    end

    tall = tall + math.max(btnTall, textTall)
    tall = tall + self.header:GetTall()
    tall = tall + select(4, self.header:GetDockMargin()) + select(4, self.lblText:GetDockMargin())

    return tall
end

function PANEL:AddCommands()
    for _, cmd in ipairs(sap.GetCommands()) do
        local callback = cmd.callbacks[sap.config.AdminMod]
        if callback then
            self:AddButton(cmd.name, cmd.icon, callback)
        end
    end
end

function PANEL:AddButton(name, iconUrl, callback)
    local iconId = sap.webicon.Create(iconUrl, 'smooth mips')
    local gap = ScreenScale(1)
    local btnTall = ScreenScale(9)
    local iconSize = math.ceil(btnTall * 0.65)
    local iconPos = btnTall * 0.5 - iconSize * 0.5
    local colorIdle = sap.config.ButtonColor
    local colorHover = sap.config.ButtonHoverColor

    local button = self.commands:Add('Panel')
    button:SetTall(btnTall)
    button:DockMargin(0, 0, 0, gap)
    button:SetCursor('hand')
    button:Dock(TOP)
    button.callback = callback
    button.Paint = function(p, w, h)
        draw_RoundedBox(4, 0, 0, w, h, p:IsHovered() and colorHover or colorIdle)
    end
    button.OnMouseReleased = function(p, mousecode)
        if mousecode == MOUSE_LEFT and IsValid(self.player) then
            p.callback(self.player)
        end
    end

    local icon = button:Add('Panel')
    icon:SetWide(btnTall)
    icon:DockMargin(0, 0, gap * 2, 0)
    icon:Dock(LEFT)
    icon.Paint = function(p, w, h)
        draw_Webicon(iconId, iconPos, iconPos, iconSize, iconSize)
    end

    local lblName = button:Add('DLabel')
    lblName:SetText(name)
    lblName:SetFont('sap.Default')
    lblName:SetTextColor(sap.config.TextColor)
    lblName:Dock(LEFT)

    button.name = lblName
    button.icon = icon

    return button
end

function PANEL:SetPlayer(ply, text)
    self.lblTitle:SetText(ply:Name())
    self.lblText:SetText(text)
    self.player = ply
    self.claim.callback = function()
        net.Start('sap:ClaimTicket')
            sap.WritePlayer(self.player)
        net.SendToServer()
    end
end

vgui.Register('sap.Popup', PANEL)