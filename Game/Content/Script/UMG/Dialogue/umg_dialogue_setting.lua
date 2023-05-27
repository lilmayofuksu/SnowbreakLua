-- ========================================================
-- @File    : umg_dialogue_setting.lua
-- @Brief   : 剧情对话设置
-- @Author  :
-- @Date    :
-- ========================================================

local umg_dialogue_setting = Class("UMG.BaseWidget")

function umg_dialogue_setting:OnInit()
    self.CloseMask.OnMouseButtonDownEvent:Bind(self, umg_dialogue_setting.DownFun)

    self.ShowSpeed.OnValueChanged:Add(
        self,
        function(InTarget, Value)
            DialogueMgr.TextShowSpeed = Value
        end
    )

    self.ChangeSpeed.OnValueChanged:Add(
        self,
        function(InTarget, Value)
            DialogueMgr.SwitchSpeed = Value
        end
    )
end

function umg_dialogue_setting:DownFun()
    UI.Close(self)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function umg_dialogue_setting:OnOpen(...)
end

return umg_dialogue_setting
