

-- ========================================================
-- @File    : uw_Logistics_item_data.lua
-- @Brief   : 后勤展示条目
-- @Author  :
-- @Date    :
-- ========================================================
local uw_Logistics_item_data =Class("UMG.SubWidget")
local LogisticsData = uw_Logistics_item_data

LogisticsData.bSelect = false
LogisticsData.OnSelect = "ON_LOGISTICS_SELECT"
LogisticsData.SupportCard = nil
LogisticsData.RoleCard = nil
LogisticsData.bEdit = false

function LogisticsData:OnInit(InParam)
    self.SupportCard = InParam.SupportCard
    self.RoleCard = InParam.BeEquipCard
    self.ClickFun = function()
        if InParam.funClick then
            InParam.funClick(InParam.SupportCard)
        end
    end
    self.nNum = InParam.nNum or 1
    self.ShowNum = InParam.ShowNum
    self.tbSkillTemplateId = InParam.tbSkillTemplateId
    self.ShowPanelteam = InParam.ShowPanelteam
    self.SelectItem = InParam.SelectItem
end

function LogisticsData:SetSelect(bSelect)
    self.bSelect = bSelect
    EventSystem.TriggerTarget(self, self.OnSelect)
end


return LogisticsData