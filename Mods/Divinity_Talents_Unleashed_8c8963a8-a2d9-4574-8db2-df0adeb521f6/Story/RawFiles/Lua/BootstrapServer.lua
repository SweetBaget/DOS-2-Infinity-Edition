local function DTU_WildMag_Projectile(Initiator)
    local posTable = {9999}
    CharacterInitiator = Ext.Entity.GetCharacter(Initiator)
    InitiatorPosition = CharacterInitiator.Stats.Position
    x_cord, y_cord, z_cord = InitiatorPosition[1], InitiatorPosition[2], InitiatorPosition[3]

    CharacthersAroundInitiator = Ext.Entity.GetCharacterGuidsAroundPosition(x_cord, y_cord, z_cord, 6.0)
    for i,v in pairs(CharacthersAroundInitiator) do
        if (Ext.Entity.GetCharacter(v).Stats.NetID == CharacterInitiator.Stats.NetID) or (Ext.Entity.GetCharacter(v).Dead == true) or (CharacterIsEnemy(Initiator, v) == 0) then goto continue end
        CharacterPosition = Ext.Entity.GetCharacter(v).Stats.Position
        x_cord_char, y_cord_char, z_cord_char = CharacterPosition[1], CharacterPosition[2], CharacterPosition[3]
        resultClose = math.sqrt((x_cord - x_cord_char)^2 + (y_cord - y_cord_char)^2 + (z_cord - z_cord_char)^2)
        if resultClose < posTable[1] then
            posTable[1] = resultClose 
            closestCharacter = v
        end
        ::continue::
    end
    if closestCharacter == nil then
        return
    end
    
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", "Projectile_DimensionalBolt_DTU")
    NRD_ProjectileSetInt("CasterLevel", CharacterInitiator.Stats.Level)
    NRD_ProjectileSetVector3("SourcePosition", x_cord, y_cord + 4, z_cord) --Поднимаю проджектайл на высоту чтобы он не врезался в кастера
    NRD_ProjectileSetGuidString("TargetPosition", closestCharacter)
    NRD_ProjectileLaunch()
end
Ext.Osiris.NewCall(DTU_WildMag_Projectile, "DTU_WildMag_Projectile", "(CHARACTERGUID)_Char")