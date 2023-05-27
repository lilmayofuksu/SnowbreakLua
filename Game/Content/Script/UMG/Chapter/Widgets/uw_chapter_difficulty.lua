-- ========================================================
-- @File    : uw_chapter_difficulty.lua
-- @Brief   : 章节难度选择
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    ---绑定点击事件
    self.Btn1.Button.OnClicked:Add(self, function()
        if Chapter.GetChapterDifficult() == CHAPTER_LEVEL.EASY then
            return
        end
        if self.fCheck and self.fCheck(CHAPTER_LEVEL.EASY) == false then return end
        self:UpdeteSelect(CHAPTER_LEVEL.EASY)
    end)

    self.Btn2.Button.OnClicked:Add(self, function()
        if Chapter.GetChapterDifficult() == CHAPTER_LEVEL.NORMAL then
            return
        end
        if self.fCheck and self.fCheck(CHAPTER_LEVEL.NORMAL) == false then return end
        self:UpdeteSelect(CHAPTER_LEVEL.NORMAL)
    end)

    self.Btn1.TextCommon:SetText(Text("ui.TxtNormal"))
    self.Btn1.TextSelected:SetText(Text("ui.TxtNormal"))
    self.Btn2.TextCommon:SetText(Text("ui.TxtHard"))
    self.Btn2.TextSelected:SetText(Text("ui.TxtHard"))
    WidgetUtils.Collapsed(self.Btn1.IconHard)
    WidgetUtils.HitTestInvisible(self.Btn1.IconNormal)
    WidgetUtils.Collapsed(self.Btn2.IconNormal)
    WidgetUtils.HitTestInvisible(self.Btn2.IconHard)
end

function tbClass:Select(nLevel, funDiffChange, fCheck)
    self.funDiffChange = funDiffChange
    self.fCheck = fCheck
    self:UpdeteSelect(nLevel)
end

function tbClass:UpdeteSelect(nLevel)
    ---表现修改
    if nLevel == CHAPTER_LEVEL.EASY then
        WidgetUtils.Collapsed(self.Btn1.Common)
        WidgetUtils.Collapsed(self.Btn2.Selected)
        WidgetUtils.HitTestInvisible(self.Btn1.Selected)
        WidgetUtils.HitTestInvisible(self.Btn2.Common)
        self.Btn1.IconNormal:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#111125CC'))
    elseif nLevel == CHAPTER_LEVEL.NORMAL then
        WidgetUtils.HitTestInvisible(self.Btn1.Common)
        WidgetUtils.HitTestInvisible(self.Btn2.Selected)
        WidgetUtils.Collapsed(self.Btn1.Selected)
        WidgetUtils.Collapsed(self.Btn2.Common)
        self.Btn1.IconNormal:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFFFF'))
    elseif nLevel == CHAPTER_LEVEL.DIFFCULT then
    end
    ---设置难度选择等级
    Chapter.SetChapterDifficult(nLevel)
    if self.funDiffChange then
        self.funDiffChange(nLevel)
    end
end

return tbClass