-- ========================================================
-- @File    : umg_common_clean_result.lua
-- @Brief  : 扫荡结果
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnOK, function()  UI.Close(self) end)
end

---打开时的回调
function tbClass:OnOpen(tbParam)
    for i=1,LaunchType.MaxMopup do
        local UIWidgets = self["Item"..i]
        WidgetUtils.Collapsed(UIWidgets)
    end
    WidgetUtils.Collapsed(self.Num)

    self.nMaxShow = tbParam and #tbParam or 0
    self.tbAwardList = tbParam

    self:ShowLevel()
    -- self:ShowAward()
    -- self.detime = 0.2
end

function tbClass:OnClose()
end

--显示等级
function tbClass:ShowLevel()
    WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
    self.TxtLevel:SetText(me:Level())

    local nMaxExp = Player.GetMaxExp(me:Level())
    if nMaxExp == 0 then
        local nLastMax = Player.GetMaxExp(me:Level() - 1)
        self.BarExp:SetPercent(1)
        self.TxtAddExp:SetText(nLastMax .. "/" .. nLastMax)
    else
        self.BarExp:SetPercent(me:Exp() / nMaxExp)
        self.TxtAddExp:SetText(me:Exp() .. "/" .. nMaxExp)
    end
end

function tbClass:ShowAward()
    self.nShowNum = (self.nShowNum or 0) + 1
    if self.nShowNum > self.nMaxShow then
        self.nShowNum = self.nMaxShow
        self.detime = 0
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.Num)
    self.Num:SetText(self.nShowNum)

    for i=1,LaunchType.MaxMopup do
        local UIWidgets = self["Item"..i]
        if i <= self.nShowNum  then
            WidgetUtils.SelfHitTestInvisible(UIWidgets)

            local tbAward = self.tbAwardList and self.tbAwardList[1] or {}
            local tbParam = {nIdx = i, tbAwards = tbAward}
            UIWidgets:DoShow(tbParam)
        else
            WidgetUtils.Collapsed(UIWidgets)
        end
    end

    self.nShowAward = 1
end

---
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0.3 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 0.5 then return end

    if self.nShowAward ~= 1 then
        self:ShowAward()
    elseif self.nShowAward == 1 then
        self.ScrollBox_171:ScrollToEnd()
        self.detime = 0
        self.nShowAward = 2
    end
end

return tbClass
