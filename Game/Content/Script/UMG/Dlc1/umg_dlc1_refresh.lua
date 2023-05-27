-- ========================================================
-- @File    : umg_dlc1_story.lua
-- @Brief   : 关卡界面
-- ========================================================
---@class tbClass :ULuaWidget
---@param LevelScrollBox UScrollBox
---@param LevelContent UUserWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    WidgetUtils.Collapsed(self.ClickBtn)
    self.ClickBtn.OnClicked:Add(self, function()
            if self.LevelInfo then WidgetUtils.Collapsed(self.LevelInfo) end
            WidgetUtils.Collapsed(self.ClickBtn)
            WidgetUtils.Visible(self.LevelScrollBox)
            WidgetUtils.Visible(self.Title)
        end
    )

    BtnAddEvent(self.BtnShop, function() UI.Open('Dlc1Shop') end)
    BtnAddEvent(self.BtnMission, function() UI.Open('Dlc1Award') end)

    self.LevelScrollBox.OnUserScrolled:Add(self, self.ScrollHandle)
end

function tbClass:OnClose()
    
end

---UI打开
---@param bMain bool 是不是主线关卡
---@param nChapterID Integer 章节ID
---@param nDifficult Integer 困难等级
---@param tbParam table {levelId = 0}
function tbClass:OnOpen(nChapterID, tbParam)
    Launch.SetType(LaunchType.DLC1_CHAPTER)
    self.nChapterID = nChapterID or DLC_Chapter.GetChapterID()
    DLC_Chapter.SetChapterID(self.nChapterID)
    if tbParam and tbParam.levelId then
        DLC_Chapter.SetLevelID(tbParam.levelId)
    end

    if tbParam and tbParam.levelId then
        self:ShowDetail(DLCLevel.Get(tbParam.levelId))
    end

    self:ShowLevels()
    self:ShowTime()
    self:UpdateRed()

    if DLC_Chapter.bShowLevelInfo then
        local nLevelID = Launch.GetLevelID()
        local tbLevelCfg = DLCLevel.Get(nLevelID)
        if tbLevelCfg ~= nil then
            self:ShowDetail(tbLevelCfg)
            self.LevelContent:ScrollIntoView(nLevelID, true)
        end
        DLC_Chapter.bShowLevelInfo = false
    end
end

function tbClass:ShowTime()
    local cfg = DLC_Chapter.GetChapterCfg(self.nChapterID)

    if cfg.CloseTime > 0 then
        WidgetUtils.Visible(self.TimeBox)
        local seconds = math.ceil(cfg.CloseTime - GetTime())
        local hour = math.floor(seconds / 3600)
        if hour >= 24 then  --天
            WidgetUtils.Visible(self.TxtDay)
            self.TxtTime:SetText(math.floor(seconds / 3600 / 24))
        else  --小时:分钟:秒
            WidgetUtils.Hidden(self.TxtDay)
            local min = math.floor((seconds % 3600) / 60)
            local sec = (seconds % 3600) % 60
            self.TxtTime:SetText(string.format("%02d:%02d:%02d", hour, min, sec))
        end
    else
        WidgetUtils.Hidden(self.TimeBox)
    end
end

function tbClass:ShowLevels()
    if not self.nChapterID then return end
    self.LevelScrollBox:ClearChildren()
    if self.LevelInfo then WidgetUtils.Collapsed(self.LevelInfo) end
    ---章节配置信息
    local chapterCfg = DLC_Chapter.GetChapterCfg(self.nChapterID)
    if not chapterCfg then return end
    ---隐藏一些控件
    WidgetUtils.Collapsed(self.ClickBtn)
    WidgetUtils.Visible(self.LevelScrollBox)
    WidgetUtils.Visible(self.Title)

    --WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Hard, self.nDifficult > 1)

    self.LevelContent = LoadWidget("/Game/UI/UMG/DLC1/Widgets/uw_dlc1_levelere.uw_dlc1_levelere_C")
    if not self.LevelContent then return end

    self.LevelScrollBox:AddChild(self.LevelContent)

    self.LevelContent:Set(chapterCfg, function(nLevelID) self:ShowDetail(nLevelID) end)


    ---剧情需要显示奖励
    if DLC_Chapter.tbShowAward and #DLC_Chapter.tbShowAward > 0 then
        UI.Open("GainItem", DLC_Chapter.tbShowAward, function()
            DLC_Chapter.tbShowAward = nil
        end)
    end

    if UI.bPoping or UI.bRecover then
        self.LevelContent:ScrollIntoView(DLC_Chapter.GetLevelID(), true)
    else
        self.LevelContent:ScrollIntoView(DLC_Chapter.GetProceedLevel(self.nChapterID), true)
    end
end

---显示关卡细节
function tbClass:ShowDetail(tbLevelCfg)
    DLC_Chapter.SetLevelID(tbLevelCfg.nID)
    if DLC_Chapter.IsPlot(tbLevelCfg.nID) then
        UI.Open('StoryInfo', tbLevelCfg.nID)
    else
        if not self.LevelInfo then
            self.LevelInfo = WidgetUtils.AddChildToPanel(self.ContentNode, '/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C', 5)
        end
        if self.LevelInfo then 
            self.LevelInfo:Show(tbLevelCfg, nil, function() WidgetUtils.Visible(self.Title) end) 
        end
        WidgetUtils.Visible(self.ClickBtn)
        WidgetUtils.SelfHitTestInvisible(self.LevelScrollBox)
        WidgetUtils.Collapsed(self.Title)
    end
end

function tbClass:UpdateRed()
    WidgetUtils.Collapsed(self.NewShop)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.NewMission, DLC_Logic.HasCanGetMission())
end

---位置更新
function tbClass:Tick(MyGeometry, InDeltaTime)
    self.Target = self.LevelScrollBox:GetScrollOffset()
    self.Current = UE4.UKismetMathLibrary.FInterpTo(self.Current, self.Target, InDeltaTime, 10)
    self.BG:SetRenderTranslation(UE4.FVector2D(-self.Current * 0.1 * 0.5, 0))
end

function tbClass.ScrollHandle(self, offset)
    if not self then return end
    local max = self.LevelScrollBox:GetScrollOffsetOfEnd()
    if not self.OrgOffset then
        self.OrgOffset = 0
    end
    local off = (offset - self.OrgOffset) * 0.05
    if off == 0 then return end
    local transform = self.BG.RenderTransform
    transform.Translation.X = transform.Translation.X - off
    self.BG:SetRenderTransform(transform)
    self.OrgOffset = offset
end

return tbClass
