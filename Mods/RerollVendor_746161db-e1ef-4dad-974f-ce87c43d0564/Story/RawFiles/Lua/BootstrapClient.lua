local FIRSTPARAMSORT = 1
local SECONDPARAMSORT = 0
local ACTIVATEBOOL = false
local rerollPrice = 0

local function SessionLoaded()
    Ext.IO.AddPathOverride("Public/Game/GUI/trade.swf", "Public/RerollVendor_746161db-e1ef-4dad-974f-ce87c43d0564/GUI/trade.swf")
end
Ext.Events.SessionLoaded:Subscribe(SessionLoaded)

local function setRerollVariables(selectedPlayer, ui)
    local ui_Root = ui:GetRoot()
    local charToTraderRelation = tonumber(ui_Root.trade_mc.mcRepContainer.attitude_txt.text) --0.0025 скидки за 1отношение
    if charToTraderRelation == nil or charToTraderRelation == "" then return end
    local characterLevel = selectedPlayer.Stats.Level
    local tradeSkill = selectedPlayer.Stats.Barter

    rerollPrice = math.floor((20 + (characterLevel*characterLevel*characterLevel/4)) * (1 - ((tradeSkill * 0.05) + (charToTraderRelation * 0.0025))))
    local RerollPriceTooltip = Ext.L10N.GetTranslatedString("h7bff6614g652ag4174g8c2cg7afc64f5981f")

    ui_Root.trade_mc.reroll_mc.tooltip = RerollPriceTooltip .. " " .. tostring(rerollPrice)
    -- print("Отношение торговца", ui_Root.trade_mc.mcRepContainer.attitude_txt.text, "к игроку", selectedPlayer.Stats.Name)
end

-- Ext.RegisterNetListener("RV_SortMessage", function ()
--     local ui = Ext.UI.GetByType(46)
--     ui:ExternalInterfaceCall("sortSelectID", FIRSTPARAMSORT, SECONDPARAMSORT);
-- end)

Ext.RegisterNetListener("RV_NotEnoughGoldMessage", function ()
    local GUI_36 = Ext.UI.GetByType(36)
    ErrorMessage = Ext.L10N.GetTranslatedString("h06d24f60ga616g453cg8922g4fe8b4b924b0")
    GUI_36:Invoke("showCastNot", "<font color=\"#C80030\">".. ErrorMessage ..  "</font>", 1.5, 148) 
end)

Ext.RegisterUITypeCall(46, "rerollItems", function(ui)
    local data = {selectCharacter = Ext.Entity.GetCharacter(ui:GetPlayerHandle()).MyGuid, rerollPrice = rerollPrice}
    Ext.Net.PostMessageToServer("RV_RerollItems", Ext.Json.Stringify(data))

    setRerollVariables(Ext.Entity.GetCharacter(ui:GetPlayerHandle()), ui)
end)

Ext.RegisterUITypeInvokeListener(46, "selectCharacter", function(ui)
    setRerollVariables(Ext.Entity.GetCharacter(ui:GetPlayerHandle()), ui)
end)

-- local function catchSortParameters(params)
--     local ui = params.UI
--     local call = params.Function
--     local firstParamSort = params.Args[1]
--     local secondParamSort = params.Args[2]
--     if ui:GetTypeId() ~= 46 then return end
--     if call ~= "sortSelectID" then return end
--     FIRSTPARAMSORT = firstParamSort
--     SECONDPARAMSORT = secondParamSort
-- end
-- Ext.Events.UICall:Subscribe(catchSortParameters)

Ext.Events.UIObjectCreated:Subscribe(function (e)
    local ui = e.UI 
    if ui:GetTypeId() == 46 then
        ui:CaptureExternalInterfaceCalls()
        ui:CaptureInvokes()
    end
end)

-- Ext.Events.UICall:Subscribe(function (e)
--     if e.Function == "registerAnchorId" then return end
--     if e.Function == "update" then return end
--     if e.Function == "updateStatuses" then return end
--     if e.Function == "removeLabel" then return end
--     if e.Function == "updateSlotData" then return end
--     Ext.Utils.Print("Call", e.UI.Type, e.Function, e.Args[1], e.Args[2], e.Args[3], e.Args[4], e.Args[5])
-- end)

-- Ext.Events.UIInvoke:Subscribe(function (e)
--     if e.Function == "registerAnchorId" then return end
--     if e.Function == "update" then return end
--     if e.Function == "updateStatuses" then return end
--     if e.Function == "removeLabel" then return end
--     if e.Function == "updateSlotData" then return end
--     Ext.Utils.Print(e.UI.Type, e.Function, e.Args[1], e.Args[2], e.Args[3], e.Args[4], e.Args[5])
-- end)