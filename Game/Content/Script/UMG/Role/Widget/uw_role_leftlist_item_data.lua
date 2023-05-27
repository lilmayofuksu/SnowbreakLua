-- ========================================================
-- @File    : umg_growth_data.lua
-- @Brief   : 角色成长属性列表
-- @Author  :
-- @Date    :
-- ========================================================

local Data = Class("UMG.SubWidget")

Data.Index = 0
Data.bSelect = false
Data.SelectChange = "SELECT_CHANGE"
Data.nSys = 0
Data.TabId = 0

--- 角色系统页签名
Data.tbPageName = {
    "ui.MainRole",
    "ui.MainRole",
    "ui.weapon_stu",
    "ui.other",
    "ui.roleup_break",
    "ui.roleup_skill",
    "ui.roleup_ProLevel",
}

--- 页签名
function Data:GetPageName(nSys)
    local Idx = self.Index + 1
    return Text(self.tbPageName[Idx] or "")
end

function Data:Init(InIndex, InSelect, Sys, InClick, InSupportCard)
    self.Index = InIndex
    self.bSelect = InSelect
    self.nSys = Sys
    self.Click = InClick
    self.pSupportCard = InSupportCard
end

function Data:SetSelect(InSelect)
    if self.bSelect ~= InSelect then
        self.bSelect = InSelect
        EventSystem.TriggerTarget(self, self.SelectChange)
    end
end

function Data:OnDestruct()
    EventSystem.Remove(self.SelectChange)
end

return Data
