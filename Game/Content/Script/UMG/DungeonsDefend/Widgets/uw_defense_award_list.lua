-- @File    : uw_defense_award_list.lua
-- @Brief   : 防御活动奖励
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class('UMG.SubWidget')

function tbClass:Construct()
    BtnAddEvent(self.BtnGain, function()
        if self.cfg then
            if DefendLogic.CanChangeDiff() then
                UI.OpenMessageBox(false, Text('ui.Defense_1stTime_GetReward'), function()
                    DefendLogic.GetReward(self.cfg.nId)
                end, function() end)
            else
                DefendLogic.GetReward(self.cfg.nId)
            end
        end
    end)
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListItem)
end

function tbClass:OnListItemObjectSet(pObj)
    self:Init(pObj.Data)
end

function tbClass:Init(cfg)
    self.cfg = cfg
    WidgetUtils.SelfHitTestInvisible(self.TxtLevel)
    if cfg.nType == 1 then
        self.TxtLevel:SetText(Text('defenselevel.Defense_Mission', cfg.nWave))
    elseif cfg.nType == 2 then
        self.TxtLevel:SetText(cfg.ConditionInfo.Description)
    end
    local state = DefendLogic.GetTargetState(cfg.nId)
    if state == 0 then
        WidgetUtils.Collapsed(self.PanelGain)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
    elseif state == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelGain)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.Collapsed(self.PanelGain)
        WidgetUtils.SelfHitTestInvisible(self.PanelCompleted)
        WidgetUtils.Collapsed(self.PanelLock)
    end

    self:DoClearListItems(self.ListItem)
    for _, v in ipairs(cfg.tbReward) do
        local tb = {}
        tb.G, tb.D, tb.P, tb.L, tb.N = table.unpack(v)
        self.ListItem:AddItem(self.ListFactory:Create(tb))
    end
end

return tbClass