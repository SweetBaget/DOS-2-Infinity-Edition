local function SessionLoaded()
    Ext.AddPathOverride("Public/Game/GUI/trade.swf", "Public/RerollVendor_746161db-e1ef-4dad-974f-ce87c43d0564/GUI/trade.swf")
end
Ext.RegisterListener("SessionLoaded", SessionLoaded)

Ext.RegisterUINameInvokeListener("disableRepairBtn", function()
    local goo = Ext.GetBuiltinUI("Public/Game/GUI/trade.swf")

    local player = Ext.GetCharacter(goo:GetPlayerHandle()) 
    characterLevel = player.Stats.Level
    tradeSkill = player.Stats.Barter

    rerollPrice = math.floor((20 + (characterLevel*characterLevel*characterLevel/4)) * (1 - (tradeSkill * 0.05)))

    local ui = Ext.GetBuiltinUI("Public/Game/GUI/trade.swf"):GetRoot() 
    ui.trade_mc.reroll_mc.tooltip = "Reroll Vendor's Items\nPrice: " .. tostring(rerollPrice)
    
    Ext.RegisterUICall(goo, "rerollItems", function()
        Ext.StatSetAttribute("NRD_Trade", "SurfaceType", "Water")
        Ext.StatSetAttribute("NRD_Trade", "ForkLevels", rerollPrice)
    end)
end, "After")