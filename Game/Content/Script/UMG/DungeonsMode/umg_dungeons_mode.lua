-- ========================================================
-- @File    : umg_dungeons_mode.lua
-- @Brief   : 出击导航界面
-- ========================================================
---@class tbClass : ULuaWidget
---@param Content UWrapBox
local tbClass = Class("UMG.BaseWidget")

local tbNavigation = {}
tbNavigation[LaunchType.CHAPTER] = {sName = "ui.TxtLevel", nIcon = 1701060, nType = FunctionType.Chapter}
tbNavigation[LaunchType.DAILY] = {sName = "ui.TxtResourse", nIcon = 1701061, nType = FunctionType.DungeonsResourse}
tbNavigation[LaunchType.TOWER] = {sName = "ui.TxtChallenge", nIcon = 1701062, nType = FunctionType.Tower}
tbNavigation[LaunchType.ONLINE] = {sName = "ui.TxtTime", nIcon = 1701063, nType = FunctionType.TimeActivitie}
tbNavigation[LaunchType.ROLE] = {sName = "ui.TxtRolePiece", nIcon = 1701130, nType = FunctionType.RoleLevel}

function tbClass:OnOpen(nSelectType)
    self.tbItem = {}
    local nNum = 0
    for nType, tbInfo in pairs(tbNavigation) do
        local pWidget = self.Content:GetChildAt(nNum)
        if pWidget then
            WidgetUtils.SelfHitTestInvisible(pWidget)
            pWidget:Set(nType, tbInfo, function(n) self:GoTo(n) end)
            self.tbItem[nType] = pWidget
            pWidget:SelectChange(false)
        end
        nNum = nNum + 1
    end
    ---
    for i = nNum + 1, self.Content:GetChildrenCount() do
        local pWidget = self.Content:GetChildAt(i - 1)
        WidgetUtils.Collapsed(pWidget)
    end
    self:Select(nSelectType)
end

function tbClass:OnClose()
    EventSystem.Remove(self.nHandle)
end

function tbClass:GoTo(nType)
    if self.nType == nType then return end

    FunctionRouter.CheckEx(tbNavigation[nType].nType, function()
        self:Select(nType)
        local top = UI.GetTop()
        if top then
            UI.Close(top, nil, true)
        end
        PreviewScene.SkipDungeonsSeq = true
        FunctionRouter.GoTo(tbNavigation[nType].nType)
    end)
end

function tbClass:Select(nType)
    if self.nType == nType then return end
    if self.nType then
        self.tbItem[self.nType]:SelectChange(false)
    end
    self.nType = nType
    self.tbItem[self.nType]:SelectChange(true)
end



return tbClass