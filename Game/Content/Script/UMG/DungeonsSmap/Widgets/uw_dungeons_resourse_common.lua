-- ========================================================
-- @File    : uw_dungeons_resourse_common.lua
-- @Brief   : 普通条目
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnCommon, function() if self.fClick then self.fClick(self.nLevelID) end end)
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
        WidgetUtils.Collapsed(self.CommonCompleted)
    else
        WidgetUtils.HitTestInvisible(self.CommonCompleted)
    end

    if tbCfg.nType == 99 then
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonCompleted, tbCfg:IsPass())
    end
    self:UpdateRed(tbCfg)

    ---开放判断
    if tbCfg:CheckCondition() then
        WidgetUtils.Collapsed(self.CommonLock)
        WidgetUtils.SelfHitTestInvisible(self.CommonNormal)
    else
        WidgetUtils.HitTestInvisible(self.CommonLock)
        WidgetUtils.Collapsed(self.CommonNormal)
    end

    if tbCfg.nGuarantee and tbCfg.nGuarantee > 0 then
        WidgetUtils.SelfHitTestInvisible(self.Minimum)
        self.Num:SetText(tbCfg.nGuarantee)
    else
        WidgetUtils.Collapsed(self.Minimums)
    end

    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.CommonSelected)
        self:PlayAnimation(self['AllLoop'], 0, 0)
    else
        WidgetUtils.Collapsed(self.CommonSelected)
    end
end

function tbClass:UpdateRed(tbCfg)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.New, DailyLevel.IsNew(tbCfg))
end

return tbClass