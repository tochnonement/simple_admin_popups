sap = {}
sap.config = {}

AddCSLuaFile('sap/sh_init.lua')
AddCSLuaFile('sap/cl_init.lua')
AddCSLuaFile('sap/derma/cl_popup.lua')
AddCSLuaFile('sap/config/sh_config.lua')
AddCSLuaFile('sap/config/cl_commands.lua')
AddCSLuaFile('sap/libraries/cl_webicon.lua')

include('sap/config/sh_config.lua')
include('sap/sh_init.lua')

if SERVER then
    include('sap/sv_init.lua')
else
    include('sap/libraries/cl_webicon.lua')
    include('sap/cl_init.lua')
    include('sap/config/cl_commands.lua')
    include('sap/derma/cl_popup.lua')
end

hook.Run('sap.Loaded')