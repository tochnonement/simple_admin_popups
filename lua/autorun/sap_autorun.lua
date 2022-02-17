sap = {}
sap.config = {}

AddCSLuaFile('sap/sh_init.lua')
AddCSLuaFile('sap/cl_init.lua')
AddCSLuaFile('sap/config/sh_config.lua')

include('sap/config/sh_config.lua')

if SERVER then
    include('sap/sv_init.lua')
else
    include('sap/cl_init.lua')
end

include('sap/sh_init.lua')