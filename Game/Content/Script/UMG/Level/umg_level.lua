-- ========================================================
-- @File    : umg_level.lua
-- @Brief   : 关卡界面
-- ========================================================
---@class tbClass :ULuaWidget
---@param LevelScrollBox UScrollBox
---@param LevelContent UUserWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    WidgetUtils.Collapsed(self.ClickBtn)
    self.AWARD_btn.OnClicked:Add(self, function() UI.Open("StarAward") end)
    self.ClickBtn.OnClicked:Add(self, function()
            WidgetUtils.Collapsed(self.LevelInfo)
            WidgetUtils.Collapsed(self.ClickBtn)
            WidgetUtils.Visible(self.LevelScrollBox)
            WidgetUtils.Visible(self.Title)
        end
    )
    self.nDifficultChangeHandle = EventSystem.OnTarget(Chapter, Chapter.DIFFICULT_CHANGE, function(_, nDifficult)
        self.nDifficult = nDifficult
        self:ShowLevels()
    end)

    self.LevelScrollBox.OnUserScrolled:Add(self, self.ScrollHandle)
end

function tbClass:OnClose()
    EventSystem.Remove(self.nDifficultChangeHandle)
    GuideLogic.CheckCloseGuide(self.sName)
    if self.timerIdx then UE4.Timer.Cancel(self.timerIdx); self.timerIdx = nil end
    WidgetUtils.Visible(self.LevelScrollBox)
end

---UI打开
---@param bMain bool 是不是主线关卡
---@param nChapterID Integer 章节ID
---@param nDifficult Integer 困难等级
---@param tbParam table {levelId = 0}
function tbClass:OnOpen(bMain, nDifficult, nChapterID, tbParam)
    Launch.SetType(LaunchType.CHAPTER)
    self.LevelScrollBox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.bMain = (bMain == nil) and Chapter.IsMain() or bMain
    self.nChapterID = nChapterID or Chapter.GetChapterID()
    self.nDifficult = nDifficult or Chapter.GetChapterDifficult()

    local bPoping = UI.bPoping
    PreviewScene.Enter(PreviewType.Dungeons, function()
        local logic = PreviewScene.Class('Dungeons')
        if logic and logic.PlaySequence then
            local idx = 0
            if self.nChapterID <= 3 then idx = 0 elseif self.nChapterID <= 6 then idx = 1 else idx = 2 end
            if bPoping then
                logic:PlaySequence(6 + idx, true, nil, idx, 1)
            else
                logic:PlaySequence(6 + idx, true, nil, idx)
                self:DisableScroll()
            end
        end
    end)
    self.OrgOffset, self.lastOffset = nil, nil

    Chapter.SetChapterID(self.nChapterID)
    if tbParam and tbParam.levelId then
        Chapter.SetLevelID(tbParam.levelId)
    end

    EventSystem.TriggerTarget(
        Survey,
        Survey.POST_SURVEY_EVENT,
        Survey.CHAPTER
    )

    self.Difficulty:Select(self.nDifficult, function(nDiff)
        if nDiff == CHAPTER_LEVEL.NORMAL then
            WidgetUtils.HitTestInvisible(self.Hard)
        else
            WidgetUtils.Collapsed(self.Hard)
        end
    end, function(nDif)
        return Chapter.GetDiffUnlock(nDif, self.bMain, self.nChapterID)
    end)

    if tbParam and tbParam.levelId then
        self:ShowDetail(ChapterLevel.Get(tbParam.levelId))
        self.LevelContent:ScrollIntoView(tbParam.levelId, true)
    end

    if Chapter.bShowLevelInfo then
        if not GuideLogic.IsLevelReturn() then
            local nLevelID = Launch.GetLevelID()
            local tbLevelCfg = ChapterLevel.Get(nLevelID)
            if tbLevelCfg ~= nil then
                self:ShowDetail(tbLevelCfg)
                self.LevelContent:ScrollIntoView(nLevelID, true)
            end
        end
        Chapter.bShowLevelInfo = false
    end
end

function tbClass:ShowLevels()
    if not self.nChapterID or not self.nDifficult then return end
    self.LevelScrollBox:ClearChildren()
    WidgetUtils.Collapsed(self.LevelInfo)
    print("level info :" , self.bMain, self.nChapterID, self.nDifficult, UI.bPoping)
    ---章节配置信息
    local chapterCfg = Chapter.GetChapterCfg(self.bMain, self.nDifficult, self.nChapterID)
    if not chapterCfg then return end
    ---隐藏一些控件
    WidgetUtils.Collapsed(self.LevelInfo)
    WidgetUtils.Collapsed(self.ClickBtn)
    WidgetUtils.Visible(self.Title)

    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.TxtNumFirst, self.nChapterID < 10)
    self.TxtNum:SetText(self.nChapterID)

    self.TxtLevel:SetText(Text(chapterCfg.sName))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Hard, self.nDifficult > 1)

    ---显示星级信息
    local nAllNum, nGetNum = Chapter.GetChapterStarInfo(self.bMain, self.nDifficult, self.nChapterID)
    if nAllNum > 0 then
        WidgetUtils.SelfHitTestInvisible(self.StarNode)
        self.TxtStarNum:SetText(nGetNum)
        self.TxtStarNumTotal:SetText(nAllNum)
        self.ExpBar:SetPercent(nGetNum / nAllNum)
    else
        WidgetUtils.Collapsed(self.StarNode)
    end
    local sParam = tostring(self.nChapterID)
    if self.nDifficult > 1 then
        sParam = sParam .. "_" .. self.nDifficult
    end

    self.LevelContent = LoadWidget("/Game/UI/UMG/Level/Widgets/uw_level_chapter.uw_level_chapter_C")
    if not self.LevelContent then return end

    self.LevelScrollBox:AddChild(self.LevelContent)

    self.LevelContent:Set(chapterCfg, function(nLevelID) self:ShowDetail(nLevelID) end)

    self.New:SetTag(string.format('%d_%d', self.nChapterID, self.nDifficult))

    ---剧情需要显示奖励
    if Chapter.tbShowAward and #Chapter.tbShowAward > 0 then
        UI.Open("GainItem", Chapter.tbShowAward, function()
            Chapter.tbShowAward = nil
        end)
    end

    if UI.bPoping or UI.bRecover then
        self.LevelContent:ScrollIntoView(Chapter.GetLevelID(), true)
    else
        self.LevelContent:ScrollIntoView(Chapter.GetProceedLevel(self.nChapterID, self.nDifficult), Chapter.GetProceedChapter(self.nDifficult) == self.nChapterID)
    end
end

---显示关卡细节
function tbClass:ShowDetail(tbLevelCfg)
    Chapter.SetLevelID(tbLevelCfg.nID)
    if Chapter.IsPlot(tbLevelCfg.nID) then
        UI.Open('StoryInfo', tbLevelCfg.nID)
    else
        if self.LevelInfo == nil then
            self.LevelInfo = WidgetUtils.AddChildToPanel(self.ContentNode, '/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C', 5)
        end
        if self.LevelInfo then
            self.LevelInfo:Show(tbLevelCfg, nil, function() WidgetUtils.Visible(self.Title) end)
            WidgetUtils.Visible(self.ClickBtn)
            WidgetUtils.Visible(self.LevelScrollBox)
            WidgetUtils.Collapsed(self.Title)
        end
    end
end

---位置更新
function tbClass:Tick(MyGeometry, InDeltaTime)
    self.Target = self.LevelScrollBox:GetScrollOffset()
    self.Current = UE4.UKismetMathLibrary.FInterpTo(self.Current, self.Target, InDeltaTime, 10)
end

function tbClass:DisableScroll()
    WidgetUtils.HitTestInvisible(self.LevelScrollBox)
    self.timerIdx = UE4.Timer.Add(1, function()
        WidgetUtils.Visible(self.LevelScrollBox)
        self.timerIdx = nil
    end)
end

function tbClass.ScrollHandle(self, offset)
    if not self then return end
    local max = self.LevelScrollBox:GetScrollOffsetOfEnd()
    if not self.OrgOffset then
        self.OrgOffset = self.LevelScrollBox:GetScrollOffset()
    end
    offset = (offset - self.OrgOffset) * 0.03
    if offset == 0 then return end

    if not self.lastOffset then
        local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
        self.pViewTarget = pCameraManger.ViewTarget.Target
        self.orgCameraPos = self.pViewTarget:K2_GetActorLocation()
    end

    self.lastOffset = offset

    if self.nChapterID <= 3 then
        self.pViewTarget:K2_SetActorLocation(UE4.FVector(self.orgCameraPos.X + offset, self.orgCameraPos.Y, self.orgCameraPos.Z))
    elseif self.nChapterID <= 6 then
        self.pViewTarget:K2_SetActorLocation(UE4.FVector(self.orgCameraPos.X - offset, self.orgCameraPos.Y, self.orgCameraPos.Z))
    else
        self.pViewTarget:K2_SetActorLocation(UE4.FVector(self.orgCameraPos.X + offset, self.orgCameraPos.Y, self.orgCameraPos.Z))
    end
end

return tbClass
