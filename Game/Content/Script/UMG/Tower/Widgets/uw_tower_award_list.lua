-- ========================================================
-- @File    : uw_tower_award_list.lua
-- @Brief   : 爬塔奖励条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListItem)
end

function tbClass:OnListItemObjectSet(InObj)
    self:PlayAnimation(self.AllEnter)
    self.ListFactory = self.ListFactory or Model.Use(self)

    self.tbData = InObj.Data


    if self.tbData.nGroup == 1 then
        WidgetUtils.Collapsed(self.Stars)
        WidgetUtils.HitTestInvisible(self.TxtFinishReward)
        self.TxtLevel:SetText(Text("ui.TxtDungeonsTowerReward"))
    elseif self.tbData.nGroup == 2 then
        WidgetUtils.Collapsed(self.TxtFinishReward)
        WidgetUtils.HitTestInvisible(self.Stars)
        if self.tbData.bCompleted then
            WidgetUtils.Collapsed(self.Normal)
            WidgetUtils.HitTestInvisible(self.Completed)
            self.TxtLevel:SetText(self.tbData.nowStarCount .. "/" .. self.tbData.starCount)
        else
            WidgetUtils.Collapsed(self.Completed)
            WidgetUtils.HitTestInvisible(self.Normal)
            self.TxtLevel:SetText(self.tbData.nowStarCount .. "/" .. self.tbData.starCount)
        end
    end

    self:DoClearListItems(self.ListItem)
    for _, v in pairs(self.tbData.tbAward) do
        local tbParam = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5]}
        local pObj = self.ListFactory:Create(tbParam)
        self.ListItem:AddItem(pObj)
    end

    if self.tbData.bReceive then
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Collapsed(self.PanelGain)
        WidgetUtils.Visible(self.PanelCompleted)
    elseif self.tbData.bCompleted then
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Visible(self.PanelGain)
        self.BtnGain.OnClicked:Clear()
        self.BtnGain.OnClicked:Add(self, function()
            if self.tbData.nGroup == 1 then
                ClimbTowerLogic.GetReward(nil, self.tbData.nID, 0)
            elseif self.tbData.nGroup == 2 then
                ClimbTowerLogic.GetReward(nil, self.tbData.nID, self.tbData.index)
            end
        end)
    else
        WidgetUtils.Collapsed(self.PanelGain)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Visible(self.PanelLock)
        self.BtnLock.OnClicked:Clear()
        self.BtnLock.OnClicked:Add(self, function()
            UI.ShowTip("ui.TxtNotAchieve")
        end)
    end
end

return tbClass
