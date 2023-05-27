-- ========================================================
-- @File    : umg_bag_sell.lua
-- @Brief   : 仓库出售面板
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListSell)
    self.ListSell:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.Txt2:SetContent(Text('ui.TxtBagSell03'))
    self.Txt3:SetContent(Text('ui.TxtBagSell03'))
    self.Check1.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            if bChecked then
                self.SellAddByColor(1)
            else
                self.SellRemoveByColor(1)
            end
        end
    )
    self.Check2.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            if bChecked then
                self.SellAddByColor(2)
            else
                self.SellRemoveByColor(2)
            end
        end
    )
    self.Check3.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            if bChecked then
                self.SellAddByColor(3)
            else
                self.SellRemoveByColor(3)
            end
        end
    )
    BtnAddEvent(
        self.BtnInc,
        function()
            self.SellInc()
        end
    )
    self.BtnInc.OnLongPressed:Add(
        self,
        function()
            self.SellInc()
        end
    )
    BtnAddEvent(
        self.BtnDec,
        function()
            self.SellDec()
        end
    )
    self.BtnDec.OnLongPressed:Add(
        self,
        function()
            self.SellDec()
        end
    )
    BtnAddEvent(
        self.BtnMax,
        function()
            self.SellMax()
        end
    )
end

function tbClass:Set(bCanStack, tbItems, nCount)
    if bCanStack then
        WidgetUtils.Visible(self.PanelSell1)
        WidgetUtils.Collapsed(self.PanelSell2)
        WidgetUtils.Collapsed(self.SellSum)
    else
        WidgetUtils.Collapsed(self.PanelSell1)
        WidgetUtils.Visible(self.PanelSell2)
        WidgetUtils.Visible(self.SellSum)
    end

    self:DoClearListItems(self.ListSell)
    self.tbSelled = {}
    if tbItems then
        for _, tbItem in ipairs(tbItems) do
            local tbParam = nil
            if #tbItem == 5 then
                tbParam = {
                    G = tbItem[1],
                    D = tbItem[2],
                    P = tbItem[3],
                    L = tbItem[4],
                    N = tbItem[5]
                }
            elseif #tbItem == 2 then
                tbParam = {
                    nCashType = tbItem[1],
                    nNum = tbItem[2]
                }
            end
            self.ListSell:AddItem(self.Factory:Create(tbParam))
        end
    end

    self:SetCount(nCount)
end

function tbClass:ResetCheck()
    self.Check1:SetIsChecked(false)
    self.Check2:SetIsChecked(false)
    self.Check3:SetIsChecked(false)
end

function tbClass:SetCount(nCount)
    if nCount then
        self.Count:SetText(nCount)
        self.Sum:SetText(nCount)
    end
end

return tbClass
