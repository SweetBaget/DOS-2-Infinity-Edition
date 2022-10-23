Ext.RegisterNetListener("RV_RerollItems", function (channel, payload)
    local data = Ext.Json.Parse(payload)

    GUIDTradeInitiatorCharacter = Osi.CharacterGetHostCharacter()
    GUIDSelectedCharacter = data.selectCharacter

    local rerollPrice = 0 - data.rerollPrice
    local characterGold = Osi.UserGetGold(GUIDSelectedCharacter) --Количество золота персонажа на данный момент

    if -characterGold > rerollPrice then --Если золота у персонажа не хватает, то не выполняем программу
        Ext.Net.PostMessageToClient(GUIDTradeInitiatorCharacter, "RV_NotEnoughGoldMessage", "RV_NotEnoughGoldMessage")
        return 0
    end
    Osi.UserAddGold(GUIDSelectedCharacter, rerollPrice) --Забираем у игрока стоимость прокрута
    -- Ext.Net.PostMessageToClient(GUIDTradeInitiatorCharacter, "RV_SortMessage", "RV_SortMessage")

    Osi.SetStoryEvent(GUIDSelectedCharacter, "RV_GoReroll") --Инициация рероллла
end)