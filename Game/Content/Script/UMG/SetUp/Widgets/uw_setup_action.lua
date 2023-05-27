-- ========================================================
-- @File    : uw_setup_action.lua
-- @Brief   : 设置
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_OPERATION

function tbClass:Construct()
    BtnAddEvent(self.BtnCustomize, function ()
        self:OnSelect()
        UI.Open('Customize', self.Index)
    end)

    BtnAddEvent(self.BtnChoose, function ()
        self:OnSelect()
    end)

    self.Event = EventSystem.On(
        Event.OnActionChange,
        function(nIndex)
            local bSelected = nIndex == self.Index
            if bSelected then
                WidgetUtils.SelfHitTestInvisible(self.ImgSl)
                PlayerSetting.Set(SID, OperationType.ACTION_MODE, {nIndex})
                if self.pFunc then self.pFunc(nIndex) end
            else
                WidgetUtils.Collapsed(self.ImgSl)
            end
        end
    )
end

function tbClass:OnDestruct()
    BtnClearEvent(self.BtnCustomize)
    EventSystem.Remove(self.Event)
end

function tbClass:Set(tbParam)
    self.TxtName:SetText(Text(tbParam.sName))
    self.TxtDetail:SetText(Text(tbParam.sDetail))
    self.Index = tbParam.nIndex
    self.pFunc = tbParam.fOnChange
    SetTexture(self.ImgMode, tbParam.nImg)
    if tbParam.bSelected then
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
    else
        WidgetUtils.Collapsed(self.ImgSl)
    end
end

function tbClass:OnSelect()
    EventSystem.Trigger(Event.OnActionChange, self.Index)
end

return tbClass