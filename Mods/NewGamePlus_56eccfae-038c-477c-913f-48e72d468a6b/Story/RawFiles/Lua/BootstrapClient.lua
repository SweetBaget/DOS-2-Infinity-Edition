Ext.RegisterNetListener("NGP_ResetCreationMenu", function (channel, payload)
    local CreationMenu = Ext.UI.GetByType(3)
    local CreationMenuRoot = CreationMenu:GetRoot()
    -- 3 Цвет кожи faceSelector_mc
    -- 4 Лицо facialSelector_mc
    -- 5 Прическа hairSelector_mc
    -- 6 Цвет волос skinSelector_mc
    -- 7 Черты лица hairColourSelector_mc
    -- 8 Голос voiceSelector_mc
    CreationMenu:ExternalInterfaceCall("selectOption", 3, 0, true)
    CreationMenuRoot.CCPanel_mc.appearance_mc.faceSelector_mc.selection_mc.selectEl(0)
    CreationMenu:ExternalInterfaceCall("selectOption", 6, 0, true)
    CreationMenuRoot.CCPanel_mc.appearance_mc.skinSelector_mc.selection_mc.selectEl(0)
    CreationMenu:ExternalInterfaceCall("selectOption", 8, 0, true)
    CreationMenuRoot.CCPanel_mc.appearance_mc.voiceSelector_mc.selection_mc.selectEl(0)
end)

Ext.RegisterNetListener("NGP_SubscribeRawInput", function (channel, payload)
    Ext.Events.RawInput:Subscribe(function (e)
        e.Input.Input.InputId = "f8"
        e.Input.Input.DeviceId = "Key"
    end)
end)