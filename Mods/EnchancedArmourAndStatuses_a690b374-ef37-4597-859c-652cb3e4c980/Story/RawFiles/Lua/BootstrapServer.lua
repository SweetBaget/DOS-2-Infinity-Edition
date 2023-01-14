function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

local ignoreStatuses = Set{
	"FEAR",
	"CHICKEN",
	"SLEEPING",
	"TAUNTED",
	"CHARMED",
	"MADNESS",
	"PETRIFIED",
	"DRAIN",
	"SHACKLES_OF_PAIN"
}

local function CustomGetStatusChance_KCE(params)
	local status = params.Status
	if ignoreStatuses[status.StatusId] then return end
	Ext.StatSetAttribute(status.StatusId, "SavingThrow", "None")
	if status.CanEnterChance == 100 then 
		status.ForceStatus = true 
	end
	local isEnterCheck = params.IsEnterCheck
    local target = Ext.Entity.GetGameObject(status.TargetHandle)
    if target ~= nil and not target.Dead and not target:HasTag("GHOST") then
        if status.ForceStatus then
			return 100
        end
        
        local savingThrow = Game.Math.GetSavingThrowForStatus(status)
        if savingThrow ~= "None" then
            if isEnterCheck then
                if Game.Math.CanTriggerTorturer(status) then
                    return 100
                else
                    return status.CanEnterChance * Game.Math.GetSavingThrowChanceMultiplier(target, savingThrow)
                end
            end
        elseif not isEnterCheck then
            return 100
        end
    end
    return status.CanEnterChance
end
Ext.Events.StatusGetEnterChance:Subscribe(CustomGetStatusChance_KCE)

local MagicDamageTypes =  Set{   
	"Fire",
	"Air",
	"Water",
	"Earth",
	"Poison",
	"Shadow"
}
--ARMOUR--
local function KCE_CalculateDamage(Character, origDamage, DamageHandle, DamageType)
	local CharacterPhysArmour = Osi.NRD_CharacterGetStatInt(Character, "CurrentArmor")
	local CharacterMagicArmour = Osi.NRD_CharacterGetStatInt(Character, "CurrentMagicArmor")

	local Resistance = Osi.NRD_CharacterGetComputedStat(Character, DamageType .. "Resistance", 0)
	print("Оригинальный урон:", origDamage, "Тип урона:", DamageType, "Сопротивление урону:", Resistance)
    local Damage = origDamage + math.floor(origDamage * -Resistance / 100.0)
	print("Урон с учетом резистов цели:", Damage)
	if Damage < 0 then return 0, 0 end

	local FinishArmor = 0
	local FinishHealth = 0
	local ArmorAbsorbtion = 0
	if DamageType == "Physical" then
		if CharacterPhysArmour <= 0 then
			return 0, 0
		else
			--1000 > 50
			if Damage > CharacterPhysArmour then
				if Damage * 0.5 > CharacterPhysArmour then
					ArmorAbsorbtion = CharacterPhysArmour --Броня сломается полностью, взяв на себя весь урон
					FinishArmor = ArmorAbsorbtion
				else
					ArmorAbsorbtion = Damage * 0.5
					FinishArmor = ArmorAbsorbtion * 0.5
				end
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --1000 - 50 = 950 урона по хп
			--500 > 5000
			else
				ArmorAbsorbtion = Damage * 0.5 --250 урона заблокировано броней
				FinishArmor = math.ceil(ArmorAbsorbtion * 0.5) --урон по броне = 250*0.5=125 урона (округление в меньшую сторону)
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --500-250=250 урона по хп
			end
		end
		print("Итоговый урон брони:", FinishArmor, "Итоговый урон здоровью:", FinishHealth, "Поглощенный урон:", ArmorAbsorbtion, "\n")
		return FinishArmor, FinishHealth
	elseif MagicDamageTypes[DamageType] then
		if CharacterMagicArmour <= 0 then
			return 0, 0
		else
			--1000 > 50
			if Damage > CharacterMagicArmour then
				if Damage * 0.5 > CharacterMagicArmour then
					ArmorAbsorbtion = CharacterMagicArmour --Броня сломается полностью, взяв на себя весь урон
					FinishArmor = ArmorAbsorbtion
				else
					ArmorAbsorbtion = Damage * 0.5
					FinishArmor = ArmorAbsorbtion * 0.5
				end
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --1000 - 50 = 950 урона по хп
			--500 > 5000
			else
				ArmorAbsorbtion = Damage * 0.5 --250 урона заблокировано броней
				FinishArmor = math.ceil(ArmorAbsorbtion * 0.5) --урон по броне = 250*0.5=125 урона (округление в меньшую сторону)
				FinishHealth = math.ceil(Damage - ArmorAbsorbtion) --500-250=250 урона по хп
			end
		end
		print("Итоговый урон брони:", FinishArmor, "Итоговый урон здоровью:", FinishHealth, "Поглощенный урон:", ArmorAbsorbtion, "\n")
		return FinishArmor, FinishHealth
	end
	print("Урон обрабатывается игрой", "\n")
	return FinishArmor, FinishHealth
end
Ext.Osiris.NewQuery(KCE_CalculateDamage,"KCE_CalculateDamage","[in](CHARACTERGUID)_Character, [in](INTEGER)_Damage, [in](INTEGER64)_Handle, [in](STRING)_DamageType, [out](INTEGER)_FinishArmor, [out](INTEGER)_FinishHealth")


local replaceStatuses = Set{
	"KNOCKED_DOWN",
	"STUNNED",
	"FROZEN"
}
local function KCE_ApplyNewStatuses(target, statusName, handle, source)
	if replaceStatuses[statusName] then
		local status = Ext.GetStatus(target, handle)
		local forceStatus = status.ForceStatus
		local durationStatus = status.LifeTime
		print("KCE_" .. statusName)
		Osi.ApplyStatus(target, "KCE_" .. statusName, durationStatus, forceStatus, source)
	end
end
Ext.Osiris.NewCall(KCE_ApplyNewStatuses,"KCE_ApplyNewStatuses","(CHARACTERGUID)_Target, (STRING)_StatusName, (INTEGER64)_Handle, (CHARACTERGUID)_Source")