-- ========================================================
-- @File    : uw_dungeons_resourse_weaponbreak.lua
-- @Brief   : 武器突破素材
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function() UI.Open('DungeonsSmap', self.nID) end)
    BtnAddEvent(self.BtnLock, function() Daily.ShowTip(self.cfg) end)
end

---设置
---@param cfg DailyTemplateLogic
function tbClass:Set(cfg)
    self.nID = cfg.nID
    self.cfg = cfg
    ---是否开放
    if cfg:IsOpen() then
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.SelfHitTestInvisible(self.PanelNormal)

        WidgetUtils.Collapsed(self.TxtTime)
        self.TxtGoldTime:SetText(cfg:GetOpenDayStr())

    else
        WidgetUtils.Collapsed(self.PanelNormal)
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)

        self.TxtGoldTimeOpen:SetText(cfg:GetOpenDayStr())
    end

    WidgetUtils.HitTestInvisible(self.PanelTag)
    DailyActivity.ShowTag(self.PanelTag, self.nID)
end

return tbClass