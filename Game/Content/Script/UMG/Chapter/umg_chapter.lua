-- ========================================================
-- @File    : umg_chapter.lua
-- @Brief   : 章节界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field chapters UScrollBox 章节列表容器
---@field nDifficult Integer 章节难度
---@field nChapterID Integer 章节ID
local tbClass= Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.nDifficultChangeHandle = EventSystem.OnTarget(Chapter, Chapter.DIFFICULT_CHANGE, function(_, nDifficult)
        self.nDifficult = nDifficult
        self.tbChapterId = nil
        self:ShowChapter()
    end)

    self.nChapterTypeChangeHandle = EventSystem.OnTarget(Chapter, Chapter.CHAPTER_TYPE_CHANGE, function(_, bMain)
        self.bMain = bMain
        self:ShowChapter()
    end)

    BtnAddEvent(self.Larrow, function()
        if not self.nIndex or not self.tbChapterId then return end
        if self.nIndex > 1 then
            self.nIndex = self.nIndex - 1
            self:ShowChapter()
        end
    end)
    BtnAddEvent(self.Rarrow, function()
        if not self.nIndex or not self.tbChapterId then return end
        if self.nIndex < #self.tbChapterId then
            self.nIndex = self.nIndex + 1
            self:ShowChapter()
        end
    end)
    self.tbContentWidget, self.tbChapterWidget = {}, {}
    WidgetUtils.Collapsed(self.Subtab)

    self.LevelScrollBox.OnUserScrolled:Add(self, self.ScrollHandle)
end

function tbClass:OnClose()
    EventSystem.Remove(self.nDifficultChangeHandle)
    EventSystem.Remove(self.nChapterTypeChangeHandle)
    if self.timerIdx then UE4.Timer.Cancel(self.timerIdx); self.timerIdx = nil end
    WidgetUtils.Visible(self.LevelScrollBox)
end

function tbClass:OnOpen(bMain, nChapterID, nDifficult)
    Launch.SetType(LaunchType.CHAPTER)
    self.LevelScrollBox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.bMain = (bMain == nil) and Chapter.IsMain() or bMain
    self.nChapterID = nChapterID or Chapter.GetChapterID()
    self.nDifficult = nDifficult or Chapter.GetChapterDifficult()

    local bPoping = UI.bPoping
    PreviewScene.Enter(PreviewType.Dungeons, function()
        local logic = PreviewScene.Class('Dungeons')
        if logic and logic.PlaySequence then
            if bPoping then
                local idx = 0
                if self.nChapterID <= 3 then idx = 0 elseif self.nChapterID <= 6 then idx = 1 else idx = 2 end
                logic:PlaySequence(6 + idx, false, 1, idx)
                self:DisableScroll()
            else
                if PreviewScene.SkipDungeonsSeq then
                    logic:PlaySequence(1, true, nil, nil, 1)
                    PreviewScene.SkipDungeonsSeq = false
                else
                    logic:PlaySequence(1, true)
                    self:DisableScroll()
                end
            end
        end
    end)
    self.OrgOffset, self.lastOffset = nil, nil

    self.Difficulty:Select(self.nDifficult, function(nDiff)
        if nDiff == CHAPTER_LEVEL.NORMAL then
            WidgetUtils.HitTestInvisible(self.Hard)
        else
            WidgetUtils.Collapsed(self.Hard)
        end
    end, function(nDif)
        return Chapter.GetDiffUnlock(nDif, self.bMain)
    end)
    self.Subtab:Init(1)
    self:ScrollIntoView()

    WidgetUtils.PlayEnterAnimation(self)
end

---显示章节
function tbClass:ShowChapter()
    if self:IsOpen() == false then return end

    if self.nDifficult == nil then return end
    local tbChapters = Chapter.GetChapterCfgs(self.bMain, self.nDifficult)
    if tbChapters == nil then return end

    local idx, widget, contentIdx = 1, nil, 1
    for i, v in pairs(tbChapters) do
        if i <= 2 then
            self['Item'..i]:Init(v, v.nID, function(pItem) self:SelectChange(pItem) end)
            WidgetUtils.PlayEnterAnimation(self['Item'..i])
            self.tbChapterWidget[i] = self['Item'..i]
        else
            if i % 2 == 1 then
                idx = 1
                if self.tbContentWidget[i] then
                    widget = self.tbContentWidget[i]
                else
                    widget = LoadWidget("/Game/UI/UMG/Chapter/Widgets/uw_chapter_content.uw_chapter_content_C")
                    self.PanelBox:AddChild(widget)
                    self.tbContentWidget[i] = widget
                    widget:SetRenderTranslation(UE.FVector2D(-185 * contentIdx, 0))
                    contentIdx = contentIdx + 1
                end
                for j = 1, 2 do WidgetUtils.Collapsed(widget['Item'..j]) end
            end
            WidgetUtils.SelfHitTestInvisible(widget['Item'..idx])
            widget['Item'..idx]:Init(v, v.nID, function(pItem) self:SelectChange(pItem) end)
            WidgetUtils.PlayEnterAnimation(widget['Item'..idx])
            self.tbChapterWidget[i] = widget['Item'..idx]
            idx = idx + 1
        end
    end
end

---章节选择改变
---@param InID Integer 章节ID
function tbClass:SelectChange(pItem)
    local nID = pItem.nID
    Chapter.SetChapterID(nID)
    UI.Open("Level", self.bMain, self.nDifficult, nID)
end

function tbClass:ScrollIntoView()
    local chapterId = 1
    if UI.bPoping then
        chapterId = Chapter.GetChapterID()
    else
        chapterId = Chapter.GetProceedChapter(Chapter.GetChapterDifficult())
    end
    self.LevelScrollBox:ScrollWidgetIntoView(self.tbChapterWidget[chapterId], false, UE4.EDescendantScrollDestination.TopOrLeft, 400)
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
    offset = (offset - self.OrgOffset) * 0.1
    if offset == 0 then return end

    if not self.lastOffset then
        local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
        self.pViewTarget = pCameraManger.ViewTarget.Target
        self.orgCameraPos = self.pViewTarget:K2_GetActorLocation()
    end

    self.lastOffset = offset
    self.pViewTarget:K2_SetActorLocation(UE4.FVector(offset + self.orgCameraPos.X, self.orgCameraPos.Y, self.orgCameraPos.Z))
end

return tbClass
