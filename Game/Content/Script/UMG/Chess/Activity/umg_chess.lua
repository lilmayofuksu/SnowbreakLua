-- ========================================================
-- @File    : umg_chess.lua
-- @Brief   : 棋盘活动主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.AWARD_btn, function()
        local tbConf = DLC_Logic.GetCurConf()
        if tbConf then UI.Open('Dlc1Award', 4) end
    end)
    BtnAddEvent(self.BtnInfo, function()
        UI.Open("HelpImages", 19)
    end)
    WidgetUtils.Collapsed(self.TowerInfo)
    WidgetUtils.Collapsed(self.TowerAward)
    WidgetUtils.SelfHitTestInvisible(self.BtnAward)
    self.tbNodeWidget = {}
    for i = 1, 3 do
        self.tbNodeWidget[i] = self['Left'..i]
        self.tbNodeWidget[i + 3] = self['Right'..i]
    end
end

function tbClass:OnOpen()
    self.tbOpenConf = ChessLogic.GetTimeConf()
    if not self.tbOpenConf then return end
    self.TxtYear:SetText(os.date('%Y.%m.%d', self.tbOpenConf.nEndTime))
    self.TxtTime:SetText(os.date('%H:%M', self.tbOpenConf.nEndTime))
    self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Silver, Cash.MoneyType_Vigour})

    local tbMap = ChessLogic.tbMapConf[self.tbOpenConf.nId]
    for i, widget in ipairs(self.tbNodeWidget) do
        if tbMap[i] then
            WidgetUtils.SelfHitTestInvisible(widget)
            widget:Show(tbMap[i])
        else
            WidgetUtils.Collapsed(widget)
        end
    end
    local saveKey = 'EnterChess' .. me:Id()
    if not UE4.UUserSetting.GetBool(saveKey, false) then
        UI.Open("HelpImages", 19)
        UE4.UUserSetting.SetBool(saveKey, true)
        UE4.UUserSetting.Save()
    end
    self:UpdateMission()

    if self.tbOpenConf.nStroy > 0 and not ChessLogic.IsOpFinish() then
        UE4.UUMGLibrary.PlayPlot(GetGameIns(), self.tbOpenConf.nStroy, {GetGameIns(), function()
            ChessLogic.SetOpFinish()
        end})
    end
end

function tbClass:UpdateMission()
    local Mat = self.ImgBar:GetDynamicMaterial()
    if not Mat then return end
    local tbMission = DLC_Logic.GetMissionGroup(4)
    if #tbMission == 0 then
        Mat:SetScalarParameterValue("Percent", 1)
        return
    end
    local gotNum = 0
    for _, conf in pairs(tbMission) do
        local state = AchievementDLC.CheckAchievementReward(conf)
        if state == 2 then gotNum = gotNum + 1 end
    end
    Mat:SetScalarParameterValue("Percent", gotNum / #tbMission)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.New, DLC_Logic.HasCanGetMission())
end

return tbClass