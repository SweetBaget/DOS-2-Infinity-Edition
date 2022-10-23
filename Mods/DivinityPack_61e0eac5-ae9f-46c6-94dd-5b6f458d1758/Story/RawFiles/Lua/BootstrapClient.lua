local function onHelmetOptionChanged(ui, call, state)
    helmetState = state
    player = Ext.Entity.GetCharacter(ui:GetPlayerHandle()) 
    NaturalHealthBool = player.Stats.TALENT_WarriorLoreNaturalHealth
    if (NaturalHealthBool == true and helmetState == 0) then
        player:SetScale(1.0 + player.Stats.WarriorLore * 0.025)
    end
    if (NaturalHealthBool == true and helmetState == 1) then
        player:SetScale(1)
    end
    if NaturalHealthBool == false then
        player:SetScale(1)
    end
end

local function onRecountAbilityPoints(ui, call, state)
    local ui = Ext.UI.GetByPath("Public/Game/GUI/characterSheet.swf")
    local ui_root = Ext.UI.GetByPath("Public/Game/GUI/characterSheet.swf"):GetRoot()
    helmetState = ui_root.stats_mc.equip_mc.helmet_mc.stateID
    player = Ext.Entity.GetCharacter(ui:GetPlayerHandle()) 
    NaturalHealthBool = player.Stats.TALENT_WarriorLoreNaturalHealth
    if (NaturalHealthBool == true and helmetState == 0) then
        player:SetScale(1.0 + player.Stats.WarriorLore * 0.025)
    end
    if (NaturalHealthBool == true and helmetState == 1) then
        player:SetScale(1)
    end
    if NaturalHealthBool == false then
        player:SetScale(1)
    end
end

function OnSessionLoaded()
    local ui = Ext.UI.GetByPath("Public/Game/GUI/characterSheet.swf")
    Ext.RegisterUITypeInvokeListener(119, "setAvailableCombatAbilityPoints", onRecountAbilityPoints)
    Ext.RegisterUICall(ui, "setHelmetOption", onHelmetOptionChanged)
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)