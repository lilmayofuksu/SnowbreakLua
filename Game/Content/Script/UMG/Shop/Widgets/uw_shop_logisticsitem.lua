-- ========================================================
-- @File    : uw_shop_logisticsitem.lua
-- @Brief   : 购买详情界面-后勤小队item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function ()
        if self.Cfg then
            UI.Open("ItemInfo", self.Cfg._G, self.Cfg._D, self.Cfg._P, self.Cfg._L)
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    if not pObj or not pObj.Data then return end

    self.Cfg = pObj.Data
    ---商品信息
    local iteminfo = UE4.UItem.FindTemplate(self.Cfg._G, self.Cfg._D, self.Cfg._P, self.Cfg._L)
    if not iteminfo then
        return
    end

    ---图标
    SetTexture(self.ImgIcon, iteminfo.Icon)
    SetTexture(self.ImgTypeLogistics, Item.SupportTypeIcon[self.Cfg._D])
    if me:GetItemCount(self.Cfg._G, self.Cfg._D, self.Cfg._P, self.Cfg._L) > 0 then
        WidgetUtils.Collapsed(self.Lock)
        WidgetUtils.Collapsed(self.PanelNone)
        WidgetUtils.HitTestInvisible(self.PanelGet)
        Color.SetColorFromHex(self.ImgIcon, "FFFFFFFF")
    else
        WidgetUtils.Collapsed(self.PanelGet)
        WidgetUtils.HitTestInvisible(self.Lock)
        WidgetUtils.HitTestInvisible(self.PanelNone)
        Color.SetColorFromHex(self.ImgIcon, "868686FF")
    end
end

return tbClass
