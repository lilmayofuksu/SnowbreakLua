-- ========================================================
-- @File    : uw_towerevent_chapter.lua
-- @Brief   : 爬塔-战术考核章节选择界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(self.Button, function()
        if self.OnClick then
            self.OnClick(self)
        end
    end)
end

function tbClass:UpdateLevel(Index, Level, OnClick)
    self.Index = Index
    self.Level = Level
    self.OnClick = OnClick
    if Level.nType == 1 then
        if Level.nBossId then
            self.TxtName:SetText(Text(string.format("monster.%d_name", Level.nBossId)))
        end
        if Level.nPictureBoss then
            SetTexture(self.Icon, Level.nPictureBoss)
        end
        WidgetUtils.SelfHitTestInvisible(self.Boss)
    else
        WidgetUtils.Collapsed(self.Boss)
    end
    self.TxtNum:SetText(Index)
    self.TxtNum2:SetText(Index)

    if Level:IsPass() then
        if Index % 2 == 0 then
            WidgetUtils.Collapsed(self.RightComplete)
            WidgetUtils.SelfHitTestInvisible(self.Leftcomplete)
        else
            WidgetUtils.Collapsed(self.Leftcomplete)
            WidgetUtils.SelfHitTestInvisible(self.RightComplete)
        end
    else
        WidgetUtils.Collapsed(self.Leftcomplete)
        WidgetUtils.Collapsed(self.RightComplete)
    end
end

function tbClass:DisplayLockedLevel(Index, Level, OnClick)
    self.OnClick = OnClick
    WidgetUtils.Collapsed(self.Leftcomplete)
    WidgetUtils.Collapsed(self.RightComplete)
    WidgetUtils.Collapsed(self.Normal)
    WidgetUtils.Collapsed(self.Boss)
    if Index % 2 == 0 then
        WidgetUtils.SelfHitTestInvisible(self.LockLeft)
    else
        WidgetUtils.SelfHitTestInvisible(self.LockRight)
    end
end

function tbClass:SetSelected(Selected)
    if Selected then
        WidgetUtils.SelfHitTestInvisible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
    end
end

return tbClass