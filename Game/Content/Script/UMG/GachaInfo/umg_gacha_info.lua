-- ========================================================
-- @File    : uw_gacha_info.lua
-- @Brief   : 抽奖信息查看
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Factory = Model.Use(self)
    self.tbFun = {
        {sName = "ui.TxtGachaInfoRate", nWidgetIdx = 0},
        {sName = "ui.TxtGachaRateTitle3", nWidgetIdx = 1},
        {sName = "ui.TxtGachaInfoRecord", nWidgetIdx = 2}
    }

    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
    end)
end

function tbClass:OnOpen(nId)
    if not nId then return end

    self.nId = nId
    self:DoClearListItems(self.ListSystem)

    for _, tbItem in ipairs(self.tbFun) do
        local tbParam = { tbData = tbItem, bSelect = false , fClick = function(pObj) self:OnSwitch(pObj)  end}
        local pObj = self.Factory:Create(tbParam)
        if self.pObj == nil then
            self.pObj = pObj
            tbParam.bSelect = true
        end
        self.ListSystem:AddItem(pObj)
    end

    if self.pObj then
        self:Active(self.pObj)
    end
end


function tbClass:OnSwitch(pObj)
    if self.pObj ~= pObj then
        if self.pObj then
            self.pObj.pUI:OnSelectChange(false)
        end
        self.pObj = pObj
        if self.pObj then
            self.pObj.pUI:OnSelectChange(true)
            self:Active(self.pObj)
        end
    end
end

function tbClass:Active(pObj)
    local nWidgetIdx = pObj.Data.tbData.nWidgetIdx
    self.Switcher:SetActiveWidgetIndex(nWidgetIdx)
    local pWidget = self.Switcher:GetActiveWidget()
    if pWidget then
        if pWidget.OnActive then
            pWidget:OnActive(self.nId);
        end
    end
end

return tbClass
