function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end
Ext.Print("Got the event-------------------")

local CustomGetStatusChance_KCE = function (status, isEnterCheck)
    local target = Ext.GetGameObject(status.TargetHandle)
    if target ~= nil and not target.Dead and not target:HasTag("GHOST") then
        if status.ForceStatus then
            Ext.Print("Condition 1")
			return 100
        end
        
        if isEnterCheck and Game.Math.CanTriggerTorturer(status) then
			Ext.Print("Condition 2")
            return status.CanEnterChance
		elseif isEnterCheck and not Game.Math.CanTriggerTorturer(status) then 
			return status.CanEnterChance
        elseif not isEnterCheck then
			Ext.Print("Condition 3")
            return status.CanEnterChance
        end
    end
    return status.CanEnterChance
end
Ext.RegisterListener("StatusGetEnterChance", CustomGetStatusChance_KCE)

local function KCE_TEST(AnyInt, AnyString)
	print(AnyInt, AnyString)
	return AnyString
end
Ext.NewQuery(KCE_TEST,"KCE_TEST","[in](INTEGER)_AnyInt, [in](STRING)_AnyStr, [out](STRING)_Finish")

	
local PhysDamage = Set{"Physical", "Corrosive", "Sulfuric"}
--ARMOUR--
local function KCE_CalculateDamage(Character, Damage, DamageHandle, DamageType)
	CharacterPhysArmour = NRD_CharacterGetStatInt(Character, "CurrentArmor")
	CharacterMagicArmour = NRD_CharacterGetStatInt(Character, "CurrentMagicArmor")

	Resistance = NRD_CharacterGetComputedStat(Character, DamageType .. "Resistance", 0)
	print("Оригинальный урон:", Damage, "Тип урона:", DamageType, "Сопротивление урону:", Resistance)
    Damage = Damage + math.floor(Damage * -Resistance / 100.0)
	print("Просчитанный урон:", Damage)

	if PhysDamage[DamageType] then
		if CharacterPhysArmour <= 0 then
			FinishArmor = 0
			FinishHealth = Damage
		else
			--1000 > 50
			if Damage > CharacterPhysArmour then
				ArmorAbsorbtion = CharacterPhysArmour * 0.5 --25 урона заблокировано броней
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --1000-25=975 урона по хп
				if Damage >= CharacterMagicArmour*10 then
					FinishArmor = CharacterPhysArmour
				else
					FinishArmor = math.ceil(ArmorAbsorbtion * 0.5) --урон по броне = 25*0.5= 12 урона (округление в меньшую сторону)
				end
			--500 > 5000
			else
				ArmorAbsorbtion = Damage * 0.5 --250 урона заблокировано броней
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --500-250=250 урона по хп
				FinishArmor = math.ceil(ArmorAbsorbtion * 0.5) --урон по броне = 250*0.5=125 урона (округление в меньшую сторону)
			end
		end
	else
		if CharacterMagicArmour <= 0 then
			FinishArmor = 0
			FinishHealth = Damage
		else
			--1000 > 50
			if Damage > CharacterMagicArmour then
				ArmorAbsorbtion = CharacterMagicArmour * 0.5 --25 урона заблокировано броней
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --1000-25=975 урона по хп
				if Damage >= CharacterMagicArmour*10 then
					FinishArmor = CharacterMagicArmour
				else
					FinishArmor = math.ceil(ArmorAbsorbtion * 0.5) --урон по броне = 25*0.5= 12 урона (округление в меньшую сторону)
				end
			--500 > 5000
			else
				ArmorAbsorbtion = Damage * 0.5 --250 урона заблокировано броней
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --500-250=250 урона по хп
				FinishArmor = math.ceil(ArmorAbsorbtion * 0.5) --урон по броне = 250*0.5=125 урона (округление в меньшую сторону)
			end
		end
	end
	print("Итоговый урон брони:", FinishArmor, "Итоговый урон здоровью:", FinishHealth)
	return FinishArmor,FinishHealth
end
Ext.NewQuery(KCE_CalculateDamage,"KCE_CalculateDamage","[in](CHARACTERGUID)_Character, [in](INTEGER)_Damage, [in](INTEGER64)_Handle, [in](STRING)_DamageType, [out](INTEGER)_FinishArmor, [out](INTEGER)_FinishHealth")