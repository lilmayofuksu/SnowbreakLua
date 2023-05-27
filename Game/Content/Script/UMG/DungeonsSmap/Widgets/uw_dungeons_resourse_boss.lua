-- ========================================================
-- @File    : uw_dungeons_resourse_boss.lua
-- @Brief   : Boss条目
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnBoss, function() if self.fClick then self.fClick(self.nLevelID) end end)
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
        WidgetUtils.Collapsed(self.BossCompleted)
    else
        WidgetUtils.HitTestInvisible(self.BossCompleted)  
    end

    ---开放判断
    if tbCfg:CheckCondition() then
        WidgetUtils.Collapsed(self.BossLock)
        WidgetUtils.SelfHitTestInvisible(self.BossNormal)
    else
        WidgetUtils.HitTestInvisible(self.BossLock)
        WidgetUtils.Collapsed(self.BossNormal)
    end
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.BossSelected)
        self:PlayAnimation(self['AllLoop'], 0, 0)
    else
        self:StopAllAnimations()
        WidgetUtils.Collapsed(self.BossSelected)
    end
end

return tbClass