-- ========================================================
-- @File    : uw_defense_difficulty.lua
-- @Brief   : 防御活动难度选择界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class('UMG.SubWidget')

function tbClass:Construct()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.List)
    self:DoClearListItems(self.DropList)

    BtnAddEvent(self.BtnConfirm, function()
        DefendLogic.ChangeDiff(self.nDiff, function()
            local ui = UI.GetUI(DefendLogic.sUI)
            if ui and ui:IsOpen() then
                ui:ShowInfo(true)
                ui:PlayAnimation(ui.AllEnter)
            end
            WidgetUtils.Collapsed(self)
            self:ClearTimer()
        end)
    end)
end

function tbClass:Show()
    self.nId, self.nDiff = DefendLogic.GetIDAndDiff()
    self:ShowInfo()
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.List)
    for _, v in ipairs(DefendLogic.tbLevelOrder[self.nId]) do
        local tb = Copy(v)
        tb.FunClick = function()
            self.nDiff = tb.nDiff
            self:ShowInfo()
            local list = self.List:GetListItems()
            for i = 1, list:Length() do
                local data = list:Get(i)
                if data.Data and data.Data.UpdateSelect then
                    data.Data.UpdateSelect(self.nDiff)
                end
            end
        end
        local pObj = self.ListFactory:Create(tb)
        self.List:AddItem(pObj)
    end
    self:UpdateTime()
    if not self.TimerHandle then
        self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self,function() self:UpdateTime() end}, 1, true)
    end
end

function tbClass:ShowInfo()
    self.nId = DefendLogic.GetIDAndDiff()
    self.nDiff = self.nDiff or 1
    self.tbLevelConf = DefendLogic.GetLevelConf(self.nId, self.nDiff)
    self.TxtLevel:SetText(tostring(self.nDiff))
    self.TextBlock_780:SetText(Text(self.tbLevelConf.sDesc))
    SetTexture(self.Icon, self.tbLevelConf.nPictureBoss)
    self:DoClearListItems(self.DropList)
    for _, v in ipairs(self.tbLevelConf.tbShowReward) do
        local g,d,p,l,n = table.unpack(v)
        local tb = {G=g, D=d, P=p, L=l, N=n}
        self.DropList:AddItem(self.ListFactory:Create(tb))
    end
end

function tbClass:UpdateTime()
    local nDay, nHour, nMin, nSec = TimeDiff(DefendLogic.tbCurTimeConf[2], GetTime())
    local strTime = ''
    if nDay > 0 then
        strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
    else
        strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
    end
    self.TxtTime:SetText(strTime)
end

function tbClass:ClearTimer()
    if self.TimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
        self.TimerHandle = nil
    end
end

return tbClass