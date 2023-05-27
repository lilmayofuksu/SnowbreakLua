-- ========================================================
-- @File    : uw_defense_info.lua
-- @Brief   : 防御活动详情
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListMonster)
    self.Popup:Init('', function() UI.Close(self) end)
end

function tbClass:OnOpen()
    local nId, nDiff  = DefendLogic.GetIDAndDiff()
    local tbLevelInfo = DefendLogic.GetLevelConf(nId, nDiff)
    local levelOrder = DefendLogic.GetLevelOrderConf(nId, nDiff)
    self.TxtContent_1:SetText(Text(levelOrder.sBuffDesc))

    for i = 1, 3 do WidgetUtils.Collapsed(self.Conditions:GetChildAt(i - 1)) end

    -- local starConditionList, starIdx = UE4.ULevelStarTaskManager.GetDefendStarInfos(), 0
    -- for _, Id in ipairs(tbLevelInfo.tbTarget) do
    --     local targetConf = DefendLogic.tbTarget[Id]
    --     if targetConf and targetConf.nType == 2 then
    --         starIdx = starIdx + 1
    --         local widget = self.Conditions:GetChildAt(starIdx - 1)
    --         if widget then
    --             widget.Des:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    --             WidgetUtils.SelfHitTestInvisible(widget)
    --             widget:SetInfo(starConditionList:Get(starIdx).Description, DefendLogic.GetTargetState(starIdx) ~= 0)
    --         end
    --     end
    -- end

    self:DoClearListItems(self.ListMonster)
    for _, v in ipairs(tbLevelInfo.tbMonster) do
        self.ListMonster:AddItem(self.ListFactory:Create(v[1]))
    end
end

return tbClass