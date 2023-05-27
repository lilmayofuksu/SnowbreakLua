-- ========================================================
-- @File    : uw_fight_action_item.lua
-- @Brief   : 操作设置item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnChoose, function ()
        if self.Index then
            EventSystem.Trigger(Event.OnActionChange, self.Index)
        end
    end)

    self.Event = EventSystem.On(
        Event.OnActionChange,
        function(nIndex)
            local bSelected = nIndex == self.Index
            if bSelected then
                WidgetUtils.SelfHitTestInvisible(self.ImgSl)
                self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
                PlayerSetting.Set(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE, {nIndex})
                PlayerSetting.Save()
            else
                WidgetUtils.Collapsed(self.ImgSl)
                self:StopAnimation(self.AllLoop)
            end
        end
    )
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.Event)
end

function tbClass:Set(tbParam)
    self.TxtName:SetText(Text(tbParam.sName))
    self.TxtDetail:SetText(Text(tbParam.sDetail))
    self.Index = tbParam.nIndex
    SetTexture(self.ImgMode, tbParam.nImg)
    if tbParam.bSelected then
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
        WidgetUtils.Collapsed(self.ImgSl)
        self:StopAnimation(self.AllLoop)
    end
end

return tbClass