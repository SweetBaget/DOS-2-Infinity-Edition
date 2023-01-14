local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true, index
        end
    end

    return false
end

function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

--Предметы работающие на сюжетные моменты
local lvlItemsBlacklist = {
    "101fb00b-a37e-435f-a12c-fa715117fe87",
    "f5035f0a-62dc-460a-84be-c178c9ad2e2e"
}

-- local charIDs = {
--     ["Humans_Hero_Male"] = "25611432-e5e4-482a-8f5d-196c9e90001e",
--     ["Humans_Hero_Female"] = "de8ea39b-6989-4b93-b34a-81e549c540f2",
--     ["Elves_Hero_Male"] = "19913083-924e-45ec-8b5b-119d5913722f",
--     ["Elves_Hero_Female"] = "7ef846f5-34dc-450c-815e-a58dfc190a7b",
--     ["Dwarves_Hero_Male"] = "024d1763-b2aa-46ec-b705-6338059838be",
--     ["Dwarves_Hero_Female"] = "c1c58707-b06e-499e-9c43-91a90be602b0",
--     ["Lizards_Hero_Male"] = "fa12e21f-0a10-47dd-af46-ab2c9a53cf6d",
--     ["Lizards_Hero_Female"] = "e4a6bcfa-ecd6-4e56-8592-cd16b85a1c50",
--     ["Lizards_Hero_Male_Undead"] = "57b70554-36bf-4b86-b9aa-8f7cc3944153",
--     ["Lizards_Hero_Female_Undead"] = "725f9a47-a3d4-41d2-92cf-017d18c2b212",
--     ["Elves_Hero_Male_Undead"] = "9eeaaafd-c47d-4650-9200-b00430d61e83",
--     ["Elves_Hero_Female_Undead"] = "7f366172-9fd1-45df-8719-a6d14cb534b3",
--     ["Humans_Hero_Female_Undead"] = "3bd0693d-0b0a-4f6d-93e2-aea9be654bee",
--     ["Humans_Hero_Male_Undead"] = "5ab5d036-4606-4265-962e-c2e4d2d2408b",
--     ["Dwarves_Hero_Female_Undead"] = "373a1966-a54d-4a3e-be70-e779a654c914",
--     ["Dwarves_Hero_Male_Undead"] = "726442a5-6856-4b0d-91ed-5d2f003b8a0c"
-- }

local NewGamePlusChars = {
    "76f5a1b5-956b-4d55-90a3-c5fb34954555",
    "ca4c8f7f-b3ca-4467-bd5b-de0f0376b876",
    "e6cc8f2b-5667-408e-a86e-557326894ffa",
    "f8cf1195-62e1-4f94-8e2b-2072d55e7f50"
}

local storyChars = {
    "c8d55eaf-e4eb-466a-8f0d-6a9447b5b24c",
    "bb932b13-8ebf-4ab4-aac0-83e6924e4295",
    "a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f",
    "ad9a3327-4456-42a7-9bf4-7ad60cc9e54f",
    "02a77f1f-872b-49ca-91ab-32098c443beb",
    "f25ca124-a4d2-427b-af62-df66df41a978"
}

local racialTalents = {
    "Human_Inventive",
    "Human_Civil",
    "Dwarf_Sneaking",
    "Dwarf_Sturdy",
    "Elf_CorpseEater",
    "Elf_Lore",
    "Lizard_Persuasion",
    "Lizard_Resistance",
    "Zombie"
}

DamageTypeList = {
    ["Physical"] = 1,
    ["Piercing"] = 2,
    ["Corrosive"] = 3,
    ["Magic"] = 4,
    ["Chaos"] = 5,
    ["Fire"] = 6,
    ["Air"] = 7,
    ["Water"] = 8,
    ["Earth"] = 9,
    ["Poison"] = 10,
    ["Shadow"] = 11,
    ["Sulfuric"] = 12,
    ["Sentinel"] = 13
}

local function checkContainer(itemGUID)
    local GUID_list = {itemGUID}

    local IsContainer = Osi.ItemIsContainer(itemGUID)
    if IsContainer then
        local container = Ext.Entity.GetItem(itemGUID)
        local containerInventory = container:GetInventoryItems()
        for i, itemGUID_2 in pairs(containerInventory) do
            local GUIDS = checkContainer(itemGUID_2)
            for k, guid in pairs(GUIDS) do
                table.insert(GUID_list, guid)
            end
        end
    end

    return GUID_list
end

local function BeforeLoadGame()
    local charConstructs = {}
    for i, playerGUID in pairs(Osi.DB_NGP_PlayersEndGame:Get(nil)) do
    -- for i, playerGUID in pairs(Osi.DB_IsPlayer:Get(nil)) do
        playerGUID = playerGUID[1]
        print(playerGUID)
        if playerGUID == "NULL_00000000-0000-0000-0000-000000000000" then goto nextchar end
        local esvCharacter = Ext.Entity.GetCharacter(playerGUID)
        local playerInventory = esvCharacter:GetInventoryItems()

        local inventoryData = {}
        local charStats = {}

        for i, v in pairs(playerInventory) do 
            local GUIDS = checkContainer(v)
            for k, itemGUID in pairs(GUIDS) do
                local itemData = {}
                local item = Ext.Entity.GetItem(itemGUID)
                local damageType = 0
                if item.Stats then
                    local dmgType = ""
                    if item.Stats.ItemType == "Weapon" then 
                        dmgType = item.Stats.DynamicStats[1].DamageType 
                        damageType = DamageTypeList[dmgType]
                    end
                end
                local constr = Ext.CreateItemConstructor(item)
                if damageType ~= 0 then itemData["DamageTypeManual"] = damageType end
                itemData["Slot"] = constr[1].Slot
                itemData["Amount"] = constr[1].Amount
                itemData["ItemType"] = constr[1].ItemType
                itemData["GenerationLevel"] = constr[1].GenerationLevel
                itemData["StatsLevel"] = constr[1].StatsLevel
                itemData["GenerationStatsId"] = constr[1].GenerationStatsId
                itemData["GenerationRandom"] = constr[1].GenerationRandom
                itemData["StatsEntryName"] = constr[1].StatsEntryName
                itemData["IsIdentified"] = constr[1].IsIdentified
                itemData["HasGeneratedStats"] = constr[1].HasGeneratedStats
                itemData["RootTemplate"] = constr[1].RootTemplate
                itemData["DeltaModSet"] = constr[1].DeltaModSet
                itemData["DeltaMods"] = constr[1].DeltaMods
                itemData["RuneBoostSet"] = constr[1].RuneBoostSet
                itemData["RuneBoosts"] = constr[1].RuneBoosts
                itemData["GenerationBoostSet"] = constr[1].GenerationBoostSet
                itemData["GenerationBoosts"] = constr[1].GenerationBoosts
                if item.CurrentTemplate.DisplayName ~= "ls::TranslatedStringRepository::s_HandleUnknown" then
                    itemData["CustomDisplayName"] = item.CurrentTemplate.DisplayName
                end
                if item.CurrentTemplate.RootTemplate ~= "" then
                    itemData["CustomDescription"] = item.CurrentTemplate.Description
                end
                inventoryData[itemGUID] = itemData
            end
        end
        local playerSkills = {}
        for i, skill in pairs(esvCharacter:GetSkills()) do
            if esvCharacter:GetSkillInfo(skill).IsLearned == true then
                table.insert(playerSkills, skill)
            end
        end
        local playerStatuses = {}
        for i, status in pairs(esvCharacter:GetStatuses()) do
            if esvCharacter:GetStatus(status).IsFromItem == false then
                if esvCharacter:GetStatus(status).Influence == false then
                    table.insert(playerStatuses, status)
                end
            end
        end
        local playerSummons = {}
        for i, summonGUID in pairs(esvCharacter:GetSummons()) do
            local summonStats = {}
            summonStats["IsTotem"] = Ext.GetCharacter(summonGUID).Totem
            summonStats["LifeTime"] = Ext.GetCharacter(summonGUID).LifeTime
            summonStats["RootTemplate"] = Ext.GetCharacter(summonGUID).RootTemplate.RootTemplate
            summonStats["IsSummon"] = Ext.GetCharacter(summonGUID).Summon
            playerSummons[summonGUID] = summonStats
        end
        local playerPowerups = {}
        for stat, val in pairs(esvCharacter.Stats.DynamicStats[2]) do
            if val ~= 0 and val ~= false and val ~= "" then
                playerPowerups[stat] = val
            end
        end
        local charTalents = {}
        for i, v in pairs(esvCharacter.Stats.DynamicStats[1]) do
            if string.match(i, "TALENT_") then
                if v then
                    table.insert(charTalents, i)
                end
            end
        end
        charStats["playerCharTemplate"] = esvCharacter.RootTemplate.Id
        charStats["IsMale"] = esvCharacter.PlayerCustomData.IsMale
        charStats["playerRace"] = esvCharacter.PlayerCustomData.Race
        charStats["playerLevel"] = esvCharacter.Stats.Level
        charStats["playerSkills"] = playerSkills
        charStats["playerStatuses"] = playerStatuses
        charStats["playerSummons"] = playerSummons
        charStats["ItemsInInventory"] = inventoryData
        charStats["playerTalents"] = charTalents
        charStats["playerPowerups"] = playerPowerups
        charStats["playerTalentPoints"] = esvCharacter.PlayerUpgrade.TalentPoints
        charStats["playerIsAvatar"] = Osi.IsTagged(playerGUID, "AVATAR")
        charStats["playerSourcePoints"] = Osi.CharacterGetMaxSourcePoints(playerGUID)
        charStats["GameDifficulty"] = Ext.Utils.GetGlobalSwitches().Difficulty
        charConstructs[esvCharacter.MyGuid] = charStats
        ::nextchar::
    end

    local LV_Chest_Data = {}
    local LV_Chest_Inventory = Ext.Entity.GetItem("217e353f-6512-4808-aa11-3ec5cc06df49"):GetInventoryItems()
    for i, v in pairs(LV_Chest_Inventory) do 
        local GUIDS = checkContainer(v)
        for k, itemGUID in pairs(GUIDS) do
            local itemData = {}
            local item = Ext.Entity.GetItem(itemGUID)
            local damageType = 0
            if item.Stats then
                local dmgType = ""
                if item.Stats.ItemType == "Weapon" then 
                    dmgType = item.Stats.DynamicStats[1].DamageType 
                    damageType = DamageTypeList[dmgType]
                end
            end
            local constr = Ext.CreateItemConstructor(item)
            if damageType ~= 0 then itemData["DamageTypeManual"] = damageType end
            itemData["Slot"] = constr[1].Slot
            itemData["Amount"] = constr[1].Amount
            itemData["ItemType"] = constr[1].ItemType
            -- itemData["GenerationItemType"] = constr[1].GenerationItemType
            itemData["GenerationLevel"] = constr[1].GenerationLevel
            itemData["StatsLevel"] = constr[1].StatsLevel
            itemData["GenerationStatsId"] = constr[1].GenerationStatsId
            itemData["GenerationRandom"] = constr[1].GenerationRandom
            itemData["StatsEntryName"] = constr[1].StatsEntryName
            itemData["IsIdentified"] = constr[1].IsIdentified
            itemData["HasGeneratedStats"] = constr[1].HasGeneratedStats
            itemData["RootTemplate"] = constr[1].RootTemplate
            itemData["DeltaModSet"] = constr[1].DeltaModSet
            itemData["DeltaMods"] = constr[1].DeltaMods
            itemData["RuneBoostSet"] = constr[1].RuneBoostSet
            itemData["RuneBoosts"] = constr[1].RuneBoosts
            itemData["GenerationBoostSet"] = constr[1].GenerationBoostSet
            itemData["GenerationBoosts"] = constr[1].GenerationBoosts
            if item.CurrentTemplate.DisplayName ~= "ls::TranslatedStringRepository::s_HandleUnknown" then
                itemData["CustomDisplayName"] = item.CurrentTemplate.DisplayName
            end
            if item.CurrentTemplate.RootTemplate ~= "" then
                itemData["CustomDescription"] = item.CurrentTemplate.Description
            end
            LV_Chest_Data[itemGUID] = itemData
        end
    end
    charConstructs["LVChestInventory"] = LV_Chest_Data

    local data = Ext.Json.Stringify(charConstructs, {IterateUserdata = true, StringifyInternalTypes = true, AvoidRecursion = false, Beautify = false}) 
    Ext.IO.SaveFile("charConstructs.json", data)

    Osi.LoadGame("_NEWGAMEPLUS_")
end
Ext.Osiris.NewCall(BeforeLoadGame, "NGP_BeforeLoadGame", "")

local function AfterSaveLoaded(...)
    local charConstructs = Ext.Json.Parse(Ext.IO.LoadFile("charConstructs.json"))
    local playerLevel = 1
    for playerRootGUID, playerInfo in pairs(charConstructs) do
        if playerRootGUID ~= "LVChestInventory" then
            if playerLevel < playerInfo.playerLevel then
                playerLevel = playerInfo.playerLevel
            end
        end
    end
    Osi.DB_NGP_LevelToLevelUp:Delete(0)
    Osi.DB_NGP_LevelToLevelUp(playerLevel)

    local playerGUID = ""
    local charCounter = 1
    local templateCounter = 1

    local avatarPlayerGUID
    local isSecondIteration = false
    for z, x in pairs(charConstructs) do
        if x.playerIsAvatar == 1 then
            avatarPlayerGUID = z
            Ext.Utils.GetGlobalSwitches().Difficulty = x.GameDifficulty
        end
    end
    ::newiteration::
    for playerRootGUID, playerInfo in pairs(charConstructs) do
        if playerRootGUID == "LVChestInventory" then goto skipchar end
        if playerGUID == "" then 
            for playerRootGUID2, playerInfo2 in pairs(charConstructs) do
                if playerRootGUID2 == avatarPlayerGUID then
                    playerInfo = playerInfo2
                    playerRootGUID = playerRootGUID2
                end
            end
            playerGUID = Osi.CharacterGetHostCharacter()
        else
            if isSecondIteration == false then 
                isSecondIteration = true
                goto newiteration 
            end
            if playerRootGUID == avatarPlayerGUID then goto skipchar end
            playerGUID = NewGamePlusChars[charCounter]
            Osi.TeleportToPosition(playerGUID, templateCounter, 4, -305, "", 0, 0)
            Osi.CharacterMakePlayer(playerGUID, Osi.CharacterGetHostCharacter())
            Osi.DB_IsPlayer(playerGUID)

            Osi.DB_HighestChapter(playerGUID, 1)
            Osi.DB_Chapter(playerGUID, 1)
            Osi.ObjectSetFlag(playerGUID, "DOS2_CHAPTER1_FortJoy")
            Osi.DB_CheckPartyForPlayer(playerGUID)
            Osi.ProcRegisterPlayerTriggers(playerGUID)

            templateCounter = templateCounter + 1
            charCounter = charCounter + 1
        end
        local playerCharTemplate = playerInfo.playerCharTemplate
        local playerLevel = playerInfo.playerLevel
        local playerRace = playerInfo.playerRace
        print(playerGUID, playerCharTemplate, playerRootGUID)
        Osi.DB_CharToPlayerInfo(playerGUID, playerCharTemplate, playerRootGUID)

        --Устанавливает количество очков истока
        Osi.DB_MaxSourcePointsInited(playerGUID)
        Osi.CharacterOverrideMaxSourcePoints(playerGUID, playerInfo.playerSourcePoints)

        local neededCharacter = ""
        for i, charOnLevel in pairs(Ext.Entity.GetAllCharacterGuids()) do
            if playerCharTemplate == Ext.Entity.GetCharacter(charOnLevel).RootTemplate.Id or playerCharTemplate == charOnLevel then
                neededCharacter = charOnLevel
            end
        end

        if not has_value(storyChars, neededCharacter) then
            Ext.Entity.GetCharacter(playerGUID).PlayerCustomData.IsMale = playerInfo.IsMale
            Osi.DB_NGP_CharacterToRaceChange(playerGUID, playerRace)
        else
            Osi.CharacterTransformAppearanceTo(playerGUID, neededCharacter, 0, 1)
            Osi.CharacterTransformFromCharacter(playerGUID, neededCharacter, 1, 1, 1, 0, 0, 1, 0)
            --
        end

        local playerStatuses = playerInfo.playerStatuses
        for i, status in pairs(playerStatuses) do
            Osi.ApplyStatus(playerGUID, status, -1.0, 0, "NULL_00000000-0000-0000-0000-000000000000")
        end

        local playerSkills = playerInfo.playerSkills
        for i, skill in pairs(Ext.Entity.GetCharacter(playerGUID):GetSkills()) do Osi.CharacterRemoveSkill(playerGUID, skill) end
        for i, skill in pairs(playerSkills) do
            Osi.CharacterAddSkill(playerGUID, skill, 1)
        end

        --Если это не заранее заспавненый сюжетом персонаж, то одеваю его в стандартную одежду
        if playerGUID ~= "" then 
            local item1 = Osi.GetItemForItemTemplateInInventory(playerGUID, "70e9a8e5-ae97-4e0c-850c-c7d8b49962ae")
            if item1 == nil then
                Osi.ItemTemplateAddTo("70e9a8e5-ae97-4e0c-850c-c7d8b49962ae", playerGUID, 1, 0)
                item1 = Osi.GetItemForItemTemplateInInventory(playerGUID, "70e9a8e5-ae97-4e0c-850c-c7d8b49962ae")
            end
            Osi.CharacterEquipItem(playerGUID, item1)
            local item2 = Osi.GetItemForItemTemplateInInventory(playerGUID, "41dd45bf-c849-4da9-b3b2-ba3f58588b2f")
            if item2 == nil then 
                Osi.ItemTemplateAddTo("41dd45bf-c849-4da9-b3b2-ba3f58588b2f", playerGUID, 1, 0)
                item2 = Osi.GetItemForItemTemplateInInventory(playerGUID, "41dd45bf-c849-4da9-b3b2-ba3f58588b2f")
            end
            Osi.CharacterEquipItem(playerGUID, item2)
        end

        local countPos = 1
        for summonGuid, summon in pairs(playerInfo.playerSummons) do
            local newSummon = Osi.CharacterCreateAtPosition(templateCounter, 4, -305, summon.RootTemplate, 0)
            if summon.Summon then
                Osi.Proc_NGP_LevelUpSummons(newSummon, playerGUID, math.floor(summon.LifeTime/6))
            else
                Osi.Proc_NGP_LevelUpPets(newSummon, playerGUID)
            end
            countPos = countPos + 1
            templateCounter = templateCounter + 1
        end
        
        local undeadBool = false
        if neededCharacter == "" then
            if Osi.IsTagged(playerCharTemplate, "UNDEAD") == 1 or Osi.IsTagged(playerCharTemplate, "SHAPESHIFT_FANE") == 1 then undeadBool = true end
        else
            if Osi.IsTagged(neededCharacter, "UNDEAD") == 1 or Osi.IsTagged(neededCharacter, "SHAPESHIFT_FANE") == 1 then undeadBool = true end
        end
        --Одевает на пероснажа одежду мертвеца, если у него есть тэг нежить
        if undeadBool then
            local item1 = Osi.GetItemForItemTemplateInInventory(playerGUID, "cfa72ec3-f93e-4579-baaa-febfa5995c2c")
            if item1 == nil then
                Osi.ItemTemplateAddTo("cfa72ec3-f93e-4579-baaa-febfa5995c2c", playerGUID, 1, 0)
                item1 = Osi.GetItemForItemTemplateInInventory(playerGUID, "cfa72ec3-f93e-4579-baaa-febfa5995c2c")
            end
            Osi.CharacterEquipItem(playerGUID, item1)
            local item2 = Osi.GetItemForItemTemplateInInventory(playerGUID, "d97a50d4-926e-4a5c-ad92-817897051f83")
            if item2 == nil then 
                Osi.ItemTemplateAddTo("d97a50d4-926e-4a5c-ad92-817897051f83", playerGUID, 1, 0)
                item2 = Osi.GetItemForItemTemplateInInventory(playerGUID, "d97a50d4-926e-4a5c-ad92-817897051f83")
            end
            Osi.CharacterEquipItem(playerGUID, item2)
            local item3 = Osi.GetItemForItemTemplateInInventory(playerGUID, "8cf2afb0-fc6f-4154-9512-4a7ca676572e")
            if item3 == nil then
                Osi.ItemTemplateAddTo("8cf2afb0-fc6f-4154-9512-4a7ca676572e", playerGUID, 1, 0)
                item3 = Osi.GetItemForItemTemplateInInventory(playerGUID, "8cf2afb0-fc6f-4154-9512-4a7ca676572e")
            end
            Osi.CharacterEquipItem(playerGUID, item3)
        end
        Osi.Proc_NGP_MirrorCreate(playerGUID)
        Osi.Proc_NGP_LevelUP(playerGUID, playerLevel)
        ::skipchar::
    end
    local LVChestConstruct = charConstructs["LVChestInventory"]
    local LV_Chest = "217e353f-6512-4808-aa11-3ec5cc06df49"
    for i, item in pairs(LVChestConstruct) do
        local itemRoot = item.RootTemplate
        local ItemIsContainer = nil
        if pcall(function() local j = Osi.DB_MOD_ContainerIDs:Get(itemRoot) end) then
            ItemIsContainer = Osi.DB_MOD_ContainerIDs:Get(itemRoot)
        end
        if ItemIsContainer then goto skipitem end
        local Amount = item.Amount
        local GenerationBoosts = item.GenerationBoosts
        local GenerationBoostSet = item.GenerationBoostSet
        local RuneBoosts = item.RuneBoosts
        local RuneBoostSet = item.RuneBoostSet
        local DeltaMods = item.DeltaMods
        local DeltaModSet = item.DeltaModSet
        local newItem = Osi.CreateItemTemplateAtPosition(itemRoot, -999, -99, -99)
        if newItem == nil then
            print(itemRoot, "предмет с ошибкой корабль")
            goto skipitem
        end
        local esvClonedItem = Ext.Entity.GetItem(newItem)
        local constr = Ext.CreateItemConstructor(esvClonedItem, false)
        constr[1].Slot = item.Slot
        constr[1].Amount = item.Amount
        constr[1].ItemType = item.ItemType
        constr[1].GenerationItemType = item.ItemType
        constr[1].GenerationLevel = item.GenerationLevel
        constr[1].StatsLevel = item.StatsLevel
        constr[1].GenerationStatsId = item.GenerationStatsId
        constr[1].GenerationRandom = item.GenerationRandom
        constr[1].StatsEntryName = item.StatsEntryName
        constr[1].IsIdentified = item.IsIdentified
        if item.DamageTypeManual then constr[1].DamageTypeOverwrite = item.DamageTypeManual end
        constr[1].GMFolding = false
        constr[1].HasGeneratedStats = item.HasGeneratedStats
        if item.CustomDisplayName then
            constr[1].CustomDisplayName = Ext.L10N.GetTranslatedString(item.CustomDisplayName)
        end
        if item.CustomDescription then
            constr[1].CustomDescription = Ext.L10N.GetTranslatedString(item.CustomDescription)
        end
        
        local boostCount = 0
        if type(GenerationBoostSet) == "table" then
            for num, boost in pairs(GenerationBoostSet) do boostCount = boostCount + 1 end
            for i=1, boostCount do
                if item.GenerationBoostSet[i] then constr[1].GenerationBoostSet[i] = item.GenerationBoostSet[i] end
            end
        end
        if type(GenerationBoosts) == "table" then
            if boostCount == 0 then 
                local boostCount2 = 0
                for num, boost in pairs(GenerationBoosts) do boostCount2 = boostCount2 + 1 end
                for i=1, boostCount2 do
                    if item.GenerationBoosts[i] then constr[1].GenerationBoostSet[i] = item.GenerationBoosts[i] end
                end
            end
        end

        local deltaCount = 0
        if type(DeltaModSet) == "table" then
            for num, boost in pairs(DeltaModSet) do deltaCount = deltaCount + 1 end
            for i=1, deltaCount do
                if item.DeltaModSet[i] then constr[1].DeltaModSet[i] = item.DeltaModSet[i] end
            end
        end
        if type(DeltaMods) == "table" then
            if deltaCount == 0 then 
                local deltaCount2 = 0
                for num, boost in pairs(DeltaMods) do deltaCount2 = deltaCount2 + 1 end
                for i=1, deltaCount2 do
                    if item.DeltaMods[i] then constr[1].DeltaModSet[i] = item.DeltaMods[i] end
                end
            end
        end

        local runeCount = 0
        if type(RuneBoostSet) == "table" then
            for num, boost in pairs(RuneBoostSet) do runeCount = runeCount + 1 end
            for i=1, runeCount do
                if RuneBoostSet[i] then 
                    constr[1].RuneBoostSet[i] = item.RuneBoostSet[i]
                end
            end
        end
        if type(RuneBoosts) == "table" then
            if runeCount == 0 then 
                local runeCount2 = 0
                for num, boost in pairs(RuneBoosts) do runeCount2 = runeCount2 + 1 end
                for i=1, runeCount2 do
                    if item.RuneBoosts[i] then 
                        constr[1].RuneBoostSet[i] = item.RuneBoosts[i]
                    end
                end
            end
        end

        local finishItem = constr:Construct()
        Osi.ItemToInventory(finishItem.MyGuid, LV_Chest, Amount, 0, 1)
        Osi.ObjectSetFlag(finishItem.MyGuid, "NGP_LeveledUp", 0)
        Osi.ItemRemove(newItem)
        ::skipitem::
    end
    Osi.PROC_NGP_GoMirror()
end
Ext.Osiris.NewCall(AfterSaveLoaded, "NGP_AfterSaveGameLoaded", "")

local function LevelUpRegion()
    local charConstructs = Ext.Json.Parse(Ext.IO.LoadFile("charConstructs.json"))
    local playerLevel = 0
    for i, charWrited in pairs(charConstructs) do
        if i ~= "LVChestInventory" then
            playerLevel = charWrited.playerLevel
        end
    end
    for i, charOnLevel in pairs(Ext.Entity.GetAllCharacterGuids()) do
        if Osi.ObjectGetFlag(charOnLevel, "NGP_LeveledUp") == 1 then
            goto nextchar
        end
        local returnStage = false
        if Osi.ObjectIsOnStage(charOnLevel) == 0 then 
            returnStage = true
            Osi.SetOnStage(charOnLevel, 1) 
        end
        local charPercentageHP = Osi.CharacterGetHitpointsPercentage(charOnLevel)
        local entityLevel = Osi.CharacterGetLevel(charOnLevel)
        local entitylevelupgrade = entityLevel + playerLevel
        local upgradeCharactersLevel = 15
        if playerLevel < 15 then upgradeCharactersLevel = playerLevel end
        Osi.CharacterLevelUpTo(charOnLevel, upgradeCharactersLevel)
        --Я не знаю почему нужно делать -2
        for i=0, entitylevelupgrade-upgradeCharactersLevel-2 do
            Osi.CharacterLevelUp(charOnLevel)
        end
        local finishCharLevel = Osi.CharacterGetLevel(charOnLevel)
        Osi.CharacterSetHitpointsPercentage(charOnLevel, charPercentageHP)
        Osi.ObjectSetFlag(charOnLevel, "NGP_LeveledUp", 0)
        --Прокачка предметов в инвентаре персонажей
        for i2, itemInChar in pairs(Ext.Entity.GetCharacter(charOnLevel):GetInventoryItems()) do
            if Osi.ObjectGetFlag(itemInChar, "NGP_LeveledUp") == 1 then
                goto nextiteminchar
            end
            local returnStage2 = false
            if Osi.ObjectIsOnStage(itemInChar) == 0 then 
                returnStage2 = true
                Osi.SetOnStage(itemInChar, 1) 
            end
            local itemInCharLevel = Osi.ItemGetLevel(itemInChar)
            if itemInCharLevel == nil or itemInCharLevel == finishCharLevel then goto nextiteminchar end
            local entitylevelupgrade2 = itemInCharLevel + playerLevel - 1
            Osi.ItemLevelUpTo(itemInChar, entitylevelupgrade2)
            Osi.ObjectSetFlag(itemInChar, "NGP_LeveledUp", 0)
            if returnStage2 == true then 
                Osi.SetOnStage(itemInChar, 0) 
            end
            ::nextiteminchar::
        end
        if returnStage == true then 
            Osi.SetOnStage(charOnLevel, 0) 
        end
        ::nextchar::
    end
    for i, itemOnLevel in pairs(Ext.Entity.GetAllItemGuids()) do
        if has_value(lvlItemsBlacklist, itemOnLevel) then 
            goto nextitem 
        end
        if Osi.ObjectGetFlag(itemOnLevel, "NGP_LeveledUp") == 1 then
            goto nextitem
        end
        local returnStage = false
        if Osi.ObjectIsOnStage(itemOnLevel) == 0 then 
            returnStage = true
            Osi.SetOnStage(itemOnLevel, 1) 
        end
        local entityLevel = Osi.ItemGetLevel(itemOnLevel)
        if entityLevel == nil then goto nextitem end
        local entitylevelupgrade = entityLevel + playerLevel - 1
        Osi.ItemLevelUpTo(itemOnLevel, entitylevelupgrade)
        local finishItemLevel = Osi.ItemGetLevel(itemOnLevel)
        Osi.ObjectSetFlag(itemOnLevel, "NGP_LeveledUp", 0)
        for i2, itemInItem in pairs(Ext.Entity.GetItem(itemOnLevel):GetInventoryItems()) do
            if Osi.ObjectGetFlag(itemInItem, "NGP_LeveledUp") == 1 then
                goto nextiteminitem
            end
            local returnStage2 = false
            if Osi.ObjectIsOnStage(itemInItem) == 0 then 
                returnStage2 = true
                Osi.SetOnStage(itemInItem, 1) 
            end
            local entityLevel2 = Osi.ItemGetLevel(itemInItem)
            if entityLevel2 == nil or entityLevel2 == finishItemLevel then goto nextitem end
            local entitylevelupgrade2 = entityLevel2 + playerLevel - 1
            Osi.ItemLevelUpTo(itemInItem, entitylevelupgrade2)
            Osi.ObjectSetFlag(itemInItem, "NGP_LeveledUp", 0)
            if returnStage2 == true then 
                Osi.SetOnStage(itemInItem, 0) 
            end
            ::nextiteminitem::
        end
        if returnStage == true then 
            Osi.SetOnStage(itemOnLevel, 0) 
        end
        ::nextitem::
    end
end
Ext.Osiris.NewCall(LevelUpRegion, "NGP_LevelUpRegion", "")

local function GiveItemsToChar(CharForItems, CharFromPastGame)
    print(CharForItems, CharFromPastGame)
    if CharForItems == "NULL_00000000-0000-0000-0000-000000000000" then return end
    local charConstructs = Ext.Json.Parse(Ext.IO.LoadFile("charConstructs.json"))
    local itemConstructs
    for playerRootGUID, playerInfo in pairs(charConstructs) do
        if playerRootGUID == CharFromPastGame then
            itemConstructs = playerInfo.ItemsInInventory
        end
    end
    for i, item in pairs(itemConstructs) do
        local itemRoot = item.RootTemplate
        local ItemIsContainer = nil
        if pcall(function() local j = Osi.DB_MOD_ContainerIDs:Get(itemRoot) end) then
            ItemIsContainer = Osi.DB_MOD_ContainerIDs:Get(itemRoot)
        end
        if ItemIsContainer then
            if ItemIsContainer[1] then
                goto skipitem2 
            end
        end
        local Amount = item.Amount
        local GenerationBoosts = item.GenerationBoosts
        local GenerationBoostSet = item.GenerationBoostSet
        local RuneBoosts = item.RuneBoosts
        local RuneBoostSet = item.RuneBoostSet
        local DeltaMods = item.DeltaMods
        local DeltaModSet = item.DeltaModSet
        local newItem = Osi.CreateItemTemplateAtPosition(itemRoot, -999, -99, -99)
        if newItem == nil then
            print(itemRoot, "предмет с ошибкой")
            goto skipitem2
        end
        local esvClonedItem = Ext.Entity.GetItem(newItem)
        local constr = Ext.CreateItemConstructor(esvClonedItem, false)
        constr[1].Slot = item.Slot
        constr[1].Amount = item.Amount
        constr[1].ItemType = item.ItemType
        constr[1].GenerationItemType = item.ItemType
        constr[1].GenerationLevel = item.GenerationLevel
        constr[1].StatsLevel = item.StatsLevel
        constr[1].GenerationStatsId = item.GenerationStatsId
        constr[1].GenerationRandom = item.GenerationRandom
        constr[1].StatsEntryName = item.StatsEntryName
        constr[1].IsIdentified = item.IsIdentified
        if item.DamageTypeManual then constr[1].DamageTypeOverwrite = item.DamageTypeManual end
        constr[1].GMFolding = false
        constr[1].HasGeneratedStats = item.HasGeneratedStats
        if item.CustomDisplayName then
            constr[1].CustomDisplayName = Ext.L10N.GetTranslatedString(item.CustomDisplayName)
        end
        if item.CustomDescription then
            constr[1].CustomDescription = Ext.L10N.GetTranslatedString(item.CustomDescription)
        end
        
        local boostCount = 0
        if type(GenerationBoostSet) == "table" then
            for num, boost in pairs(GenerationBoostSet) do boostCount = boostCount + 1 end
            for i=1, boostCount do
                if item.GenerationBoostSet[i] then constr[1].GenerationBoostSet[i] = item.GenerationBoostSet[i] end
            end
        end
        if type(GenerationBoosts) == "table" then
            if boostCount == 0 then 
                local boostCount2 = 0
                for num, boost in pairs(GenerationBoosts) do boostCount2 = boostCount2 + 1 end
                for i=1, boostCount2 do
                    if item.GenerationBoosts[i] then constr[1].GenerationBoostSet[i] = item.GenerationBoosts[i] end
                end
            end
        end

        local deltaCount = 0
        if type(DeltaModSet) == "table" then
            for num, boost in pairs(DeltaModSet) do deltaCount = deltaCount + 1 end
            for i=1, deltaCount do
                if item.DeltaModSet[i] then constr[1].DeltaModSet[i] = item.DeltaModSet[i] end
            end
        end
        if type(DeltaMods) == "table" then
            if deltaCount == 0 then 
                local deltaCount2 = 0
                for num, boost in pairs(DeltaMods) do deltaCount2 = deltaCount2 + 1 end
                for i=1, deltaCount2 do
                    if item.DeltaMods[i] then constr[1].DeltaModSet[i] = item.DeltaMods[i] end
                end
            end
        end

        local runeCount = 0
        if type(RuneBoostSet) == "table" then
            for num, boost in pairs(RuneBoostSet) do runeCount = runeCount + 1 end
            for i=1, runeCount do
                if RuneBoostSet[i] then 
                    constr[1].RuneBoostSet[i] = item.RuneBoostSet[i]
                end
            end
        end
        if type(RuneBoosts) == "table" then
            if runeCount == 0 then 
                local runeCount2 = 0
                for num, boost in pairs(RuneBoosts) do runeCount2 = runeCount2 + 1 end
                for i=1, runeCount2 do
                    if item.RuneBoosts[i] then 
                        constr[1].RuneBoostSet[i] = item.RuneBoosts[i]
                    end
                end
            end
        end

        local finishItem = constr:Construct()
        Osi.ItemToInventory(finishItem.MyGuid, CharForItems, Amount, 0, 1)
        Osi.ObjectSetFlag(finishItem.MyGuid, "NGP_LeveledUp", 0)
        Osi.ItemRemove(newItem)
        ::skipitem2::
    end
end
Ext.Osiris.NewCall(GiveItemsToChar, "NGP_GiveItemsToChar", "(CHARACTERGUID)_C, (CHARACTERGUID)_P")

local function GiveStatsForChar(CharForItems, CharTemplate)
    if CharForItems == "NULL_00000000-0000-0000-0000-000000000000" then return end
    local charConstructs = Ext.Json.Parse(Ext.IO.LoadFile("charConstructs.json"))
    local playerTalents = {}
    local playerPowerups = {}
    local playerTalentPoints = 0

    for playerRootGUID, playerInfo in pairs(charConstructs) do
        if playerInfo.playerCharTemplate == CharTemplate then
            playerTalents = playerInfo.playerTalents
            playerPowerups = playerInfo.playerPowerups
            playerTalentPoints = playerInfo. playerTalentPoints
        end
    end
    local talentCount = 0
    for i, v in pairs(Ext.GetCharacter(CharForItems).Stats.DynamicStats[1]) do
        if string.match(i, "TALENT_") then
            if v then
                talentCount = talentCount + 1
            end
        end
    end
    if talentCount < 3 then
        Osi.CharacterAddAttributePoint(CharForItems, 3);
        Osi.CharacterAddAbilityPoint(CharForItems, 2);
        Osi.CharacterAddCivilAbilityPoint(CharForItems, 1);
    elseif talentCount == 3 then
        if has_value(storyChars, CharTemplate) then
            Osi.CharacterAddAttributePoint(CharForItems, 3);
            Osi.CharacterAddAbilityPoint(CharForItems, 2);
            Osi.CharacterAddCivilAbilityPoint(CharForItems, 1);
        end
    end
    local nowPlayerTalentPoints = Osi.CharacterGetTalentPoints(CharForItems)
    Osi.CharacterAddTalentPoint(CharForItems, -nowPlayerTalentPoints)
    Osi.CharacterAddTalentPoint(CharForItems, playerTalentPoints)
    for i, talent in pairs(playerTalents) do
        local realTalent = talent:gsub("TALENT_", "")
        if not has_value(racialTalents, realTalent) then
            Osi.CharacterAddTalent(CharForItems, realTalent)
        end
    end
    for power, up in pairs(playerPowerups) do
        Osi.CharacterAddAttribute(CharForItems, power, up)
    end
end
Ext.Osiris.NewCall(GiveStatsForChar, "NGP_GiveStatsForChar", "(CHARACTERGUID)_C, (CHARACTERGUID)_P")

local function NGP_ResetCharacterMenu()
    Ext.Net.PostMessageToClient(Osi.CharacterGetHostCharacter(), "NGP_ResetCreationMenu", "")
end
Ext.Osiris.NewCall(NGP_ResetCharacterMenu, "NGP_ResetCharacterMenu", "")

local function NGP_SubscribeRawInput()
    Ext.Net.PostMessageToClient(Osi.CharacterGetHostCharacter(), "NGP_SubscribeRawInput", "")
end
Ext.Osiris.NewCall(NGP_SubscribeRawInput, "NGP_SubscribeRawInput", "")

--Прокачка персонажей появляющихся по ходу игры
Ext.Osiris.RegisterListener("CharacterCreateAtPosition", 6, "after", function(x, y, z, charTemplate, playSpawn, charOnLevel)
    if Osi.GlobalGetFlag("NewGamePlus_Finish") == 0 then return end
    if Osi.ObjectGetFlag(charOnLevel, "NGP_LeveledUp") == 1 then return end
    Osi.ObjectSetFlag(charOnLevel, "NGP_LeveledUp", 0)
    local playerLevel = Osi.DB_NGP_LevelToLevelUp:Get(nil)[1][1]
    local entityLevel = Osi.CharacterGetLevel(charOnLevel)
    local entitylevelupgrade = entityLevel + playerLevel
    local upgradeCharactersLevel = 15
    if playerLevel < 15 then upgradeCharactersLevel = playerLevel end
    Osi.CharacterLevelUpTo(charOnLevel, upgradeCharactersLevel)
    --Я не знаю почему нужно делать -2
    for i=0, entitylevelupgrade-upgradeCharactersLevel-2 do
        Osi.CharacterLevelUp(charOnLevel)
    end
end)

-- Прокачка предеметов появляющихся по ходу игры
Ext.Osiris.RegisterListener("ItemAddedToContainer", 2, "after", function(itemAdded, container)
    if Osi.GlobalGetFlag("NewGamePlus_Finish") == 0 then return end
    if Osi.ObjectGetFlag(itemAdded, "NGP_LeveledUp") == 1 then return end
    Osi.ObjectSetFlag(itemAdded, "NGP_LeveledUp", 0)
    local playerLevel = Osi.DB_NGP_LevelToLevelUp:Get(nil)[1][1]
    local entityLevel = Osi.ItemGetLevel(itemAdded)
    local containerLevel = Osi.ItemGetLevel(container)
    if entityLevel == nil or entityLevel == containerLevel then return end
    local entitylevelupgrade = entityLevel + playerLevel - 1
    Osi.ItemLevelUpTo(itemAdded, entitylevelupgrade)
end)
--Прокачка предеметов появляющихся по ходу игры
Ext.Osiris.RegisterListener("ItemTemplateAddedToContainer", 3, "after", function(templateItem, itemAdded, container)
    if Osi.GlobalGetFlag("NewGamePlus_Finish") == 0 then return end
    if Osi.ObjectGetFlag(itemAdded, "NGP_LeveledUp") == 1 then return end
    Osi.ObjectSetFlag(itemAdded, "NGP_LeveledUp", 0)
    local playerLevel = Osi.DB_NGP_LevelToLevelUp:Get(nil)[1][1]
    local entityLevel = Osi.ItemGetLevel(itemAdded)
    local containerLevel = Osi.ItemGetLevel(container)
    if entityLevel == nil or entityLevel == containerLevel then return end
    local entitylevelupgrade = entityLevel + playerLevel - 1
    Osi.ItemLevelUpTo(itemAdded, entitylevelupgrade)
end)
--Прокачка предеметов появляющихся по ходу игры
Ext.Osiris.RegisterListener("CreateItemTemplateAtPosition", 5, "after", function(template, x, y, z, itemAdded)
    if Osi.GlobalGetFlag("NewGamePlus_Finish") == 0 then return end
    if Osi.ObjectGetFlag(itemAdded, "NGP_LeveledUp") == 1 then return end
    Osi.ObjectSetFlag(itemAdded, "NGP_LeveledUp", 0)
    local playerLevel = Osi.DB_NGP_LevelToLevelUp:Get(nil)[1][1]
    local entityLevel = Osi.ItemGetLevel(itemAdded)
    if entityLevel == nil then return end
    local entitylevelupgrade = entityLevel + playerLevel - 1
    Osi.ItemLevelUpTo(itemAdded, entitylevelupgrade)
end)
--Прокачка предеметов появляющихся по ходу игры
Ext.Osiris.RegisterListener("ItemTemplateAddedToCharacter", 3, "after", function(template, itemAdded, char)
    if Osi.GlobalGetFlag("NewGamePlus_Finish") == 0 then return end
    if Osi.ObjectGetFlag(itemAdded, "NGP_LeveledUp") == 1 then return end
    Osi.ObjectSetFlag(itemAdded, "NGP_LeveledUp", 0)
    if Osi.DB_NGP_Trade:Get(nil, nil)[1] then
        if Osi.DB_NGP_Trade:Get(nil, nil)[1][1] == char then return end
    end
    local charLevel = Osi.CharacterGetLevel(char)
    local entityLevel = Osi.ItemGetLevel(itemAdded)
    if entityLevel == nil or entityLevel == charLevel then return end
    local entitylevelupgrade = entityLevel + charLevel - 1
    Osi.ItemLevelUpTo(itemAdded, entitylevelupgrade)
end)