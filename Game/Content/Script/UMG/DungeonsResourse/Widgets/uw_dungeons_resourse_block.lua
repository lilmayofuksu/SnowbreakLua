-- ========================================================
-- @File    : uw_dungeons_resourse_rolematerials.lua
-- @Brief   : 武器突破素材
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function() UI.Open('DungeonsSmap', self.nID) end)
    BtnAddEvent(self.BtnLock, function() Daily.ShowTip(self.cfg) end)
end

-- ---设置
-- ---@param cfg DailyTemplateLogic
-- function tbClass:Set(cfg)
--     self.nID = cfg.nID
--     self.cfg = cfg
--     ---是否开放
--     if cfg:IsOpen() then
--         WidgetUtils.Collapsed(self.PanelLock)
--         WidgetUtils.SelfHitTestInvisible(self.PanelNormal)

--         WidgetUtils.Collapsed(self.TxtTime)
--         self.TxtGoldTime:SetText(cfg:GetOpenDayStr())

--     else
--         WidgetUtils.Collapsed(self.PanelNormal)
--         WidgetUtils.SelfHitTestInvisible(self.PanelLock)

--         self.TxtGoldTimeOpen:SetText(cfg:GetOpenDayStr())
--     end

--     WidgetUtils.HitTestInvisible(self.PanelTag)
--     DailyActivity.ShowTag(self.PanelTag, self.nID)
-- end

function tbClass:OnListItemObjectSet(Obj)
    self.nID = Obj.Data.cfg.nID
    self.cfg = Obj.Data.cfg
    if self.cfg:IsOpen() then
        WidgetUtils.Collapsed(self.PanelLock)

        WidgetUtils.Collapsed(self.TxtTime)
        -- self.TxtGoldTime:SetText(self.cfg:GetOpenDayStr())

    else
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)

        -- self.TxtGoldTime:SetText(self.cfg:GetOpenDayStr())
    end
    WidgetUtils.HitTestInvisible(self.PanelTag)
    DailyActivity.ShowTag(self.PanelTag, self.nID)
    SetTexture(self.ImgPic, self.cfg.nEntryBg)
    self.TxtTips:SetText(Text("ui.".. self.cfg.Tips))
    self.TxtDungeons:SetText(self.cfg.I18N)

    local HasNew = false
    if Condition.Check(self.cfg.tbCondition) then
        for _, nChapterID in ipairs(self.cfg.tbChapter or {}) do
            local cfg = DailyChapter.Get(1, nChapterID)
            for _, levelId in ipairs(cfg.tbLevel) do
                local levelConf = DailyLevel.Get(levelId)
                if levelConf and DailyLevel.IsNew(levelConf) then
                    HasNew = true
                    break
                end
            end
        end
    end
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.New, HasNew)
end
return tbClass