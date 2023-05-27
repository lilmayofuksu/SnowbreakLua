-- ========================================================
-- @File    : uw_fight_level_star_list.lua
-- @Brief   : 战斗界面 星级任务
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_level_star_list = Class("UMG.SubWidget")

local LevelStarItem = uw_fight_level_star_list

function LevelStarItem:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end

    InObj.Data.Refresh = function (tbParam)
        self:Refresh(tbParam)
    end

    self:Refresh(InObj.Data)
end

function LevelStarItem:Refresh(tbParam)
    if tbParam.bFinished then
        WidgetUtils.Collapsed(self.PanelOff)
        WidgetUtils.HitTestInvisible(self.PanelOn)
        self.ParticleOn:ActivateSystem(true)
        self.TxtDescOn:SetText(tbParam.Description)
    else
        WidgetUtils.Collapsed(self.PanelOn)
        WidgetUtils.HitTestInvisible(self.PanelOff)
        self.TxtDescOff:SetText(tbParam.Description)
    end
end

return LevelStarItem
