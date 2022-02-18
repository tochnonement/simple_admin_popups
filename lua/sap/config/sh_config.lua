local config = sap.config

-- Available options: 'sam', 'ulx', 'serverguard'
-- Set it to nil to find admin mod automatically
config.AdminMod = nil
-- The command to create a ticket
config.Command = '!r'
-- Enable autoclose for tickets
config.AutoCloseEnabled = true
-- The time after which a ticket will be automatically closed
config.AutoCloseTime = 30
-- The delay between creating tickets
config.Delay = 30
-- Should people, who have created a ticket receive a notification  when someone claimed their ticket
config.ClaimNotify = true

if SERVER then return end

config.UnclaimedColor = Color(183, 21, 64)
config.ClaimedColor = Color(64, 177, 116)
config.HeaderColor = Color(58, 58, 58)
config.TextColor = Color(224, 224, 244)
config.BackgroundColor = Color(44, 44, 44, 230)
config.ButtonColor = Color(58, 58, 58)
config.ButtonHoverColor =  Color(68, 68, 68)