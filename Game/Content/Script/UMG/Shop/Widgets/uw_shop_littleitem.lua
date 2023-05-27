-- ========================================================
-- @File    : uw_shop_littleitem.lua
-- @Brief   : 商店界面-商店分类列表item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.BtnSelect.OnClicked:Add(self, function()
        self.tbParam.UpdateSelect()
    end)
end

function tbClass:UpdatePanel(info)
    self.tbParam = info

    local data = {version = self.tbParam.ShopInfo.nVersion}
    if not self.tbParam.bMall then
        data = ShopLogic.GetShopData(self.tbParam.ShopInfo.nShopId)
    end
    if not data or data.version ~= self.tbParam.ShopInfo.nVersion then
        self:UpdateLabel(self.tbParam.ShopInfo.nLabel)
    elseif self.tbParam.bMall and IBLogic.CheckShopBox(self.tbParam.ShopInfo.nShopId) then
        self:UpdateLabel(1)
    else
        self:UpdateLabel(0)
    end

    if self.tbParam.isSele then
        WidgetUtils.HitTestInvisible(self.CheckFirst)
        WidgetUtils.Collapsed(self.BgFirst)
    else
        WidgetUtils.HitTestInvisible(self.BgFirst)
        WidgetUtils.Collapsed(self.CheckFirst)
    end

    self.TxtBgFirst:SetText(Text(self.tbParam.ShopInfo.sName))
    self.TxtBgFirst_1:SetText(Text(self.tbParam.ShopInfo.sName))
    if self.tbParam.bMall then
        self.TxtBgFirst:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#F8FBFF99'))
    end

    if self.tbParam.ShopInfo.nShopIcon then
        SetTexture(self.IconBgFirst, self.tbParam.ShopInfo.nShopIcon)
        SetTexture(self.IconBgFirst_1, self.tbParam.ShopInfo.nShopIcon)
    end
end

function tbClass:SetSelect(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.CheckFirst)
        WidgetUtils.Collapsed(self.BgFirst)
    else
        WidgetUtils.HitTestInvisible(self.BgFirst)
        WidgetUtils.Collapsed(self.CheckFirst)
    end
    self.tbParam.isSele = bSelect
end

function tbClass:UpdateLabel(label)
    if label == 1 then
        WidgetUtils.HitTestInvisible(self.Red)
    elseif label == 2 then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

return tbClass
