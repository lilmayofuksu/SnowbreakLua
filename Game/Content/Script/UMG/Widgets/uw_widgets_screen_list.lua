-- ========================================================
-- @File    : uw_widgets_screen_list.lua
-- @Brief   : 筛选排序条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect,function()
        if self.bSelect then
            self.tbData.OnReverse(self.bReverse)
            self:OnReverse()
        else
            self.tbData.OnTouch(self.bReverse)
        end
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectChange)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.TxtNormalName:SetText(self.tbData.sName)
    self.TxtSelectName:SetText(self.tbData.sName)
    self.TxtSelectName_1:SetText(self.tbData.sName)
    self:SetSelect(self.tbData.bSelect)
    pObj.SubUI = self
    self.bReverse = self.tbData.bReverse
    self.bSelect = self.tbData.bSelect
    if self.bSelect then
        if self.bReverse then
            WidgetUtils.Collapsed(self.PanelSelect2)
            WidgetUtils.Visible(self.PanelSelect)
        else
            WidgetUtils.Collapsed(self.PanelSelect)
            WidgetUtils.Visible(self.PanelSelect2)
        end
    else
        WidgetUtils.Collapsed(self.PanelSelect)
        WidgetUtils.Collapsed(self.PanelSelect2)
    end
    EventSystem.Remove(self.nSelectChange)
    self.nSelectChange = EventSystem.OnTarget(self.tbData, 'ON_SELECT_CHANGE', function()
        self:SetSelect(self.tbData.bSelect)
    end)
end

function tbClass:SetSelect(bSelect)
    if bSelect then
        self.bSelect = true
        if self.bReverse then
            WidgetUtils.Visible(self.PanelSelect)
        else
            WidgetUtils.Visible(self.PanelSelect2)
        end
    else
        self.bSelect = false
        WidgetUtils.Hidden(self.PanelSelect)
        WidgetUtils.Hidden(self.PanelSelect2)
    end
end

function tbClass:OnReverse()
    print("========>", self.bReverse)
    if self.bReverse then
        WidgetUtils.Collapsed(self.PanelSelect)
        WidgetUtils.Visible(self.PanelSelect2)
        self.bReverse = false
    else
        WidgetUtils.Collapsed(self.PanelSelect2)
        WidgetUtils.Visible(self.PanelSelect)
        self.bReverse = true
    end
end


return tbClass
