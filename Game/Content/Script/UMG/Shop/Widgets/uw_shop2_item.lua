-- ========================================================
-- @File    : uw_shop2_item.lua
-- @Brief   : 商店2界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function() self:OnSelect() end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data;
   -- Dump(self.tbParam)
    self.tbParam.refresh = function(tb) 
        if tb == self.tbParam then 
            self:Refresh() 
        end
    end   
    self:Refresh() 
end

function tbClass:OnSelect()
    self.tbParam.onSelect()
end

function tbClass:Refresh()
    --图标、名字
    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbGDPLN[1], self.tbParam.tbGDPLN[2], self.tbParam.tbGDPLN[3], self.tbParam.tbGDPLN[4])
    if iteminfo then
        self.TxtName:SetText(Text(iteminfo.I18N))
        SetTexture(self.Icon, iteminfo.Icon)
        SetTexture(self.Rarity, Item.ItemShopColorIcon[iteminfo.Color])
    end

    --限购
    local buyNum = ShopLogic.GetBuyNum(self.tbParam.nGoodsId)
    if self.tbParam.nLimitNum < 0 then
        WidgetUtils.Collapsed(self.LimitNum)
    else
        WidgetUtils.Visible(self.LimitNum)
        self.TxtLimitNum:SetText(self.tbParam.nLimitNum - buyNum .. "/" .. self.tbParam.nLimitNum)
        if self.tbParam.nLimitNum - buyNum == 0 then
            self.TxtLimitNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
        else
            self.TxtLimitNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        end
    end
    
    WidgetUtils.SetVisibleOrCollapsed(self.Select, self.tbParam.selected)
end

return tbClass
