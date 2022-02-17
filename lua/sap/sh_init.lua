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