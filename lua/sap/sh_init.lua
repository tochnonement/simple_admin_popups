local sap = sap

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

    hook.Add('PostGamemodeLoaded', 'sap.CatchAdminMod', function()
        if sap.config.AdminMod == nil then
            sap.config.AdminMod = catchAdminMod()
        end
    end)
end