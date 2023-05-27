-- @File    : uw_defense_award.lua
-- @Brief   : 防御活动奖励界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    self.Popup:Init('', function() UI.Close(self) end)
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListNum)
    BtnAddEvent(self.BtnQuick, function()
        if DefendLogic.CanChangeDiff() then
            UI.OpenMessageBox(false, Text('ui.Defense_1stTime_GetReward'), function()
                DefendLogic.GetRewardAll()
            end, function() end)
        else
            DefendLogic.GetRewardAll()
        end
    end)
end

function tbClass:OnOpen()
    self.ListNum:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:DoClearListItems(self.ListNum)
    local tbLevelConf = DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
    local tbCanGet, tbNoComp, tbGot = {}, {}, {}
    for _, id in ipairs(tbLevelConf.tbTarget) do
        local tbTargetConf = DefendLogic.tbTarget[id]
        local tb = Copy(tbTargetConf)
        local state = DefendLogic.GetTargetState(tb.nId)
        if state == 0 then table.insert(tbNoComp, tb)
        elseif state == 1 then table.insert(tbCanGet, tb)
        elseif state == 2 then table.insert(tbGot, tb) end
    end
    for _, v in ipairs(tbCanGet) do
        self.ListNum:AddItem(self.ListFactory:Create(v))
    end
    for _, v in ipairs(tbNoComp) do
        self.ListNum:AddItem(self.ListFactory:Create(v))
    end
    for _, v in ipairs(tbGot) do
        self.ListNum:AddItem(self.ListFactory:Create(v))
    end
    WidgetUtils.SetVisibleOrCollapsed(self.BtnQuick, DefendLogic.CanGetReward())
end

function tbClass:OnClose()
    DefendLogic.ShowGetAll()
end

return tbClass