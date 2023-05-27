-- ========================================================
-- @File    : uw_level_item_common.lua
-- @Brief   : 关卡界面
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.Level.Widgets.uw_level_item")

function tbClass:Construct()
    BtnAddEvent(self.BtnCommon, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
    self.Btn = self.BtnCommon
end

function tbClass:OnSelectChange(bSelect)    
    if bSelect then
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        WidgetUtils.HitTestInvisible(self.CommonSelected)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.CommonSelected)   
    end
end

function tbClass:OnInit()
    self.TxtLevelName:SetText(Text(self.tbCfg.sFlag))
    self.TxtLevelNum:SetText(GetLevelName(self.tbCfg))
    if self.StarNode then
        self.StarNode:Set(self.tbCfg)
    end
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.CommonNormal)
        WidgetUtils.HitTestInvisible(self.CommonLock)
        self.TxtLevelName:SetRenderOpacity(0.4)
    else
        WidgetUtils.Collapsed(self.CommonLock)
        WidgetUtils.SelfHitTestInvisible(self.CommonNormal)
        self.TxtLevelName:SetRenderOpacity(1)
    end
end

return tbClass