local function CheckLuckStat()
    local heighestLuck = 0
    for num, char in pairs(Osi.DB_IsPlayer:Get(nil)) do
        local charLuck = Ext.Entity.GetCharacter(char[1]).Stats.Luck
        if charLuck > heighestLuck then
            heighestLuck = charLuck
        end
    end
    if not Osi.DB_HieghestLuck:Get(nil)[1] then
        Osi.DB_HieghestLuck(heighestLuck)
    else
        local lastLuck = Osi.DB_HieghestLuck:Get(nil)[1][1]
        if lastLuck == heighestLuck then 
            return
        end
    end
    if heighestLuck >= 10 then
        local currentTable = Ext.Stats.TreasureTable.GetLegacy("Luck10")
        local lucktopTable = Ext.Stats.TreasureTable.GetLegacy("LuckTop")
        local luckTopCategories = {}
        for num, category in pairs(lucktopTable["SubTables"][1]["Categories"]) do
            local moreAccuracyTable = Ext.Stats.TreasureTable.GetLegacy(category["TreasureTable"])
            local moreAccuracyCategory = moreAccuracyTable["SubTables"][1]["Categories"][1]
            table.insert(luckTopCategories, moreAccuracyCategory)
        end
        local missChanceDrop = 24-heighestLuck
        if missChanceDrop < 1 then
            if currentTable.SubTables[1].DropCounts[1].Chance == 1 then
                print("Максимальная удача, не обновляю таблицу")
                return
            end
            missChanceDrop = 1
        end
        if currentTable then
            currentTable.SubTables[1].DropCounts[1].Chance = missChanceDrop
            currentTable["SubTables"][1]["Categories"] = luckTopCategories
            Ext.Stats.TreasureTable.Update(currentTable)
        end
        Osi.DB_HieghestLuck:Delete(nil)
        Osi.DB_HieghestLuck(heighestLuck)
    end
end
Ext.Osiris.NewCall(CheckLuckStat, "DP_CatchLuckStat", "")