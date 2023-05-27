-- ========================================================
-- @File    : uw_towerevent_chapter.lua
-- @Brief   : 爬塔-战术考核关卡选择界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:UpdateLevels(Chapter, LevelList, Callback)
    local index = nil
    local progress = 1
    self.Callback = Callback
    local ShowOneUnlock = false
    for i, LevelID in pairs(Chapter.tbLevel) do
        local Level = TowerEventLevel.Get(LevelID)
        if Level and not ShowOneUnlock then
            WidgetUtils.SelfHitTestInvisible(self[string.format('Level%02d', i)])
            WidgetUtils.SelfHitTestInvisible(self[string.format('Node%d', i)])
            WidgetUtils.SelfHitTestInvisible(self[string.format('Dot%d', i)])
            local bOK, tbDes = Condition.Check(Level.tbCondition)
            if TowerEventChapter.GetLevelID() == Level.nID then
                index = i
            end
            if Level:IsPass() then
                self['Node'..i]:UpdateLevel(i, Level, function(InLevel)
                    self:OnSelect(InLevel)
                end)
                if i == #Chapter.tbLevel then
                    progress = i
                end
            elseif bOK then
                self['Node'..i]:UpdateLevel(i, Level, function(InLevel)
                    self:OnSelect(InLevel)
                end)
                progress = i
            elseif not ShowOneUnlock then
                self['Node'..i]:DisplayLockedLevel(i, Level, function()
                    if tbDes and tbDes[1] then
                        UI.ShowMessage(tbDes[1])
                    end
                end)
                ShowOneUnlock = true
            end
        else
            WidgetUtils.Collapsed(self[string.format('Node%d', i)])
            WidgetUtils.Collapsed(self[string.format('Dot%d', i)])
        end
    end
    if index then
        LevelList:ScrollWidgetIntoView(self['Node'..index], true, UE4.EDescendantScrollDestination.Center, 0)
        WidgetUtils.SelfHitTestInvisible(self['Select'..index])
        self['Node'..index]:SetSelected(true)
        self.NowSelect = self['Node'..index]
    else
        LevelList:ScrollWidgetIntoView(self['Node'..progress], true, UE4.EDescendantScrollDestination.Center, 0)
    end
end

function tbClass:OnSelect(InLevel)
    if self.NowSelect ~= InLevel then
        if self.NowSelect then
            local Index = self.NowSelect.Index
            WidgetUtils.Collapsed(self['Select'..Index])
            self.NowSelect:SetSelected(false)
        end

        if InLevel then
            local Index= InLevel.Index
            WidgetUtils.SelfHitTestInvisible(self['Select'..Index])
            InLevel:SetSelected(true)
            self.NowSelect = InLevel
        end
    end

    if InLevel then
        TowerEventChapter.SetLevelID(InLevel.Level.nID)
        if self.Callback then
            self.Callback(InLevel.Level, function()
                if self.NowSelect then
                    local Index = self.NowSelect.Index
                    WidgetUtils.Collapsed(self['Select'..Index])
                    self.NowSelect:SetSelected(false)
                    self.NowSelect = nil
                end
            end)
        end
    end
end
return tbClass