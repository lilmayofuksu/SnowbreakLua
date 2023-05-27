-- ========================================================
-- @File    : uw_mall_tableitem.lua
-- @Brief   : 商城 子分类
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)

    BtnAddEvent(self.Button, function()
        if not self.tbParam then return end

        local mallUI = UI.GetUI("Mall")
        if mallUI and mallUI:IsOpen() then
            mallUI:ClickTable(nil, self.tbParam.nShopId)
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data

    function self.tbParam.SetSelect(owner, bSelect)
        if bSelect then
            self:OnSelect()
        else
            self:UnSelect()
        end
        owner.isSele = bSelect
    end


    self.tbParam:SetSelect(self.tbParam.isSele)
    self:ShowInfo()
end

function tbClass:OnSelect()
    WidgetUtils.HitTestInvisible(self.Selected)
end

function tbClass:UnSelect()
    WidgetUtils.Collapsed(self.Selected)
end

function tbClass:ShowInfo()
    if not self.tbParam or not self.tbParam.sName then
        self.TextCommon:SetText("")
        return
    end

    self.TextCommon:SetText(Text(self.tbParam.sName))
end

return tbClass
