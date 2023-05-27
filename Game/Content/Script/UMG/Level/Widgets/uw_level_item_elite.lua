-- ========================================================
-- @File    : uw_level_item_elite.lua
-- @Brief   : 关卡界面
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.Level.Widgets.uw_level_item")

function tbClass:Construct()
    BtnAddEvent(self.BtnElite, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
    self.Btn = self.BtnElite
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        WidgetUtils.HitTestInvisible(self.EliteSelected)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.EliteSelected)   
    end
end

function tbClass:OnInit()
    self.TxtLevelName:SetText(Text(self.tbCfg.sFlag))
    self.TxtLevelNum:SetText(GetLevelName(self.tbCfg))

    if #self.tbCfg.tbStarCondition > 0 then
        WidgetUtils.HitTestInvisible(self.StarNode)
        self.StarNode:Set(self.tbCfg)
    else
        WidgetUtils.Collapsed(self.StarNode)
    end

    if self.tbCfg.nType == ChapterLevelType.RANDOM then
        WidgetUtils.HitTestInvisible(self.FlagReward)
    else
        WidgetUtils.Collapsed(self.FlagReward)
    end
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.EliteNormal)
        WidgetUtils.HitTestInvisible(self.EliteLock)
        self.TxtLevelName:SetRenderOpacity(0.4)
    else
        WidgetUtils.Collapsed(self.EliteLock)
        WidgetUtils.SelfHitTestInvisible(self.EliteNormal)
        self.TxtLevelName:SetRenderOpacity(1)
    end
end

return tbClass