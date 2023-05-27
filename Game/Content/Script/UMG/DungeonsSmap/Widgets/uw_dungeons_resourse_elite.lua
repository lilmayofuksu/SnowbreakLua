-- ========================================================
-- @File    : uw_dungeons_resourse_elite.lua
-- @Brief   : 精英条目
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function() if self.fClick then self.fClick(self.nLevelID) end end)
end

function tbClass:Set(nLevelID, bSelect, fClick)
    self.bSelect = bSelect
    local tbCfg = DailyLevel.Get(nLevelID)
    if not tbCfg then return end
    self.nLevelID = nLevelID
    self.TxtLevelName:SetText(Text(tbCfg.sName))
    self.fClick = fClick
    self:OnSelectChange(bSelect)

    ---是否完成
    if tbCfg:IsFirstPass() then
        WidgetUtils.Collapsed(self.EliteCompleted)
    else
        WidgetUtils.HitTestInvisible(self.EliteCompleted)  
    end

    ---开放判断
    if tbCfg:CheckCondition() then
        WidgetUtils.Collapsed(self.EliteLock)
        WidgetUtils.SelfHitTestInvisible(self.EliteNormal)
    else
        WidgetUtils.HitTestInvisible(self.EliteLock)
        WidgetUtils.Collapsed(self.EliteNormal)
    end
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.EliteSelected)
        self:PlayAnimation(self['AllLoop'], 0, 0)
    else
        self:StopAllAnimations()
        WidgetUtils.Collapsed(self.EliteSelected)
    end
end

return tbClass