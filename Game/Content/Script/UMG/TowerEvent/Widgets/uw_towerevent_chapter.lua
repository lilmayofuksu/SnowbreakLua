-- ========================================================
-- @File    : uw_towerevent_chapter.lua
-- @Brief   : 爬塔-战术考核章节选择界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.tbOffsetRight = {-1080, -1080, -1080, -1080, -1080, -1080, -1080, -750, -350, -350, 0, 0}
end

function tbClass:UpdateChapters(bFirstOpen, ChapterList)
    local ShowOneUnlock = false
    local NowChapter = TowerEventChapter.GetChapterID()
    self.tbLevelWidge = {}
    for i, Chapter in pairs(TowerEventChapter.tbChapter) do
        if ShowOneUnlock then
            WidgetUtils.Collapsed(self[string.format('Level%02d', i)])
            WidgetUtils.Collapsed(self[string.format('Title%02d', i)])
        else
            WidgetUtils.SelfHitTestInvisible(self[string.format('Level%2d', i)])
            WidgetUtils.SelfHitTestInvisible(self[string.format('Title%2d', i)])
            local bOK, tbDes, tbAllResule = Condition.Check(Chapter.tbCondition)
            local nPassLevel, Proportion = TowerEvent.GetChapterPassNum(Chapter.nID)
            WidgetUtils.Collapsed(self['Per'..i])
            WidgetUtils.Collapsed(self['Select'..i])
            if nPassLevel == #Chapter.tbLevel then
                WidgetUtils.Collapsed(self['Lock'..i])
                WidgetUtils.SelfHitTestInvisible(self['Unlock'..i])
                WidgetUtils.Collapsed(self['CustomText'..i])
                self:SetChapterOpacity(i, 0.5)
                self['Chapter'..i]:SetText('TxtChapterFinish')
            elseif bOK then
                WidgetUtils.Collapsed(self['Lock'..i])
                WidgetUtils.SelfHitTestInvisible(self['Unlock'..i])
                WidgetUtils.SelfHitTestInvisible(self['Per'..i])
                WidgetUtils.SelfHitTestInvisible(self['CustomText'..i])
                self['Per'..i]:SetText(string.format("%d%%", math.ceil(Proportion * 100)))
                ChapterList:ScrollWidgetIntoView(self[string.format('Level%02d', i)], true, UE4.EDescendantScrollDestination.Center, 0)
            else
                WidgetUtils.SelfHitTestInvisible(self['Lock'..i])
                WidgetUtils.Collapsed(self['Unlock'..i])
                WidgetUtils.Collapsed(self['CustomText'..i])
                ShowOneUnlock = true
                local ScrollSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(ChapterList)
                local offset = ScrollSlot:GetOffsets()
                offset.Right = self.tbOffsetRight[i] or 0
                ScrollSlot:SetOffsets(offset)
            end

            BtnClearEvent(self['Btn'..i])
            if ShowOneUnlock then
                BtnAddEvent(self['Btn'..i], function()
                    Audio.PlaySounds(3005)
                    local str = tbDes and tbDes[1]
                    for key, condition in pairs(Chapter.tbCondition) do
                        if not tbAllResule[key] and condition[1] == Condition.ACCOUNT_LEVEL then
                            str = Text("ui.Toweropen", condition[2])
                        end
                    end
                    if str then
                        UI.ShowMessage(str)
                    end
                end)
            else
                BtnAddEvent(self['Btn'..i], function()
                    Audio.PlaySounds(3005)
                    self:OnClick(i, Chapter, nPassLevel)
                end)
            end
            self['Name'..i]:SetText(string.format(Text('ui.TxtTowereventNum'), i))

            if NowChapter == i and not bFirstOpen then
                self:OnClick(i, Chapter, nPassLevel)
            end
        end
    end
    if not ShowOneUnlock then
        local ScrollSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(ChapterList)
        local offset = ScrollSlot:GetOffsets()
        offset.Right = 0
        ScrollSlot:SetOffsets(offset)
    end
end

function tbClass:OnClick(Index, Chapter, nPassLevel)
    if Index ~= self.NowSelect then
        if self.NowSelect then
            WidgetUtils.Collapsed(self['Select'..self.NowSelect])
        end
        WidgetUtils.SelfHitTestInvisible(self['Select'..Index])
        self.NowSelect = Index
    end
    if self.NowSelect then
        local tbParam = {Index = Index, Chapter = Chapter, nPassLevel = nPassLevel}
        tbParam.OnTitleBack = function()
            if self.NowSelect then
                WidgetUtils.Collapsed(self['Select'..self.NowSelect])
                self.NowSelect = nil
            end
        end
        TowerEventChapter.SetChapterID(Chapter.nID)
        if UI.IsOpen("TowerEventNode") then
            return
        end
        UI.Open("TowerEventNode", tbParam)
    end
end

function tbClass:SetChapterOpacity(Index, Opacity)
    self['Name'..Index]:SetOpacity(Opacity)
    self['NameBg'..Index]:SetOpacity(Opacity)
    self['Chapter'..Index]:SetOpacity(Opacity)
    self['ProgressLine'..Index]:SetOpacity(Opacity)
end

return tbClass