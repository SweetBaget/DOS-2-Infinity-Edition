local function CheckPress(bool)
    Surface = Ext.StatGetAttribute("NRD_Trade", "SurfaceType")
    rerollPrice = 0 - Ext.StatGetAttribute("NRD_Trade", "ForkLevels")

    if Surface == "Water" then
        Ext.StatSetAttribute("NRD_Trade", "SurfaceType", "Fire")
        characterGold = CharacterGetGold(CharacterGetHostCharacter()) --Количество золота персонажа на данный момент

        if -characterGold > rerollPrice then --Если золота у персонажа не хватает, то не выполняем программу
            print("Недостаточно золота для новой поставки")
            return 0
        end
        CharacterAddGold(CharacterGetHostCharacter(), rerollPrice) --Забираем у игрока стоимость прокрута
        return 1
    else
        return 0

    end
end
Ext.NewQuery(CheckPress, "NRD_CheckPress", "[in](STRING)_Surface, [out](INTEGER)_Bool");

local function SessionLoaded() --ДОБАВИТЬ ЕСЛИ ЭФФЕКТ ЕСТЬ ТО НЕ СРАБАТЫВАЕТ
	local stat = Ext.CreateStat("NRD_Trade", "SkillData", "Rain_Water")
    stat.SurfaceType = "Fire"
    stat.ForkLevels = 1
    Ext.SyncStat("NRD_Trade")
end
Ext.RegisterListener("SessionLoaded", SessionLoaded);