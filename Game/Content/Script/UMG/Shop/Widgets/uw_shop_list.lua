-- ========================================================
-- @File    : uw_shop_list.lua
-- @Brief   : 商店界面-商店分类列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.ItemPath = "/Game/UI/UMG/Shop/Widgets/uw_shop_littleitem.uw_shop_littleitem_C"

    BtnAddEvent(self.BtnSelect, function()
        if not self.tbParam then return end
        if #self.Data > 1 and self.tbParam.isSele then
            if self.ListPanel:GetVisibility() == UE4.ESlateVisibility.Collapsed then
                WidgetUtils.SelfHitTestInvisible(self.ListPanel)
                self:SetSecondTabIcon(self.Data[1].nShopIcon, self.Data[1].nUnselectIcon)
            else
                WidgetUtils.Collapsed(self.ListPanel)
                self:SetSecondTabIcon(self.Data[1].nGroupIcon, self.Data[1].nUnselectIcon)
                self.tbParam.FunRefreshListTab()
            end
            return
        end
        self.tbParam.UpdateSelect()
        self.tbParam.UpdateShop(self.tbParam.SeleShop)
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    self.InOwner = pObj.Data.Owner
    self.Data = pObj.Data.tbCfg
    self.bMall = pObj.Data.bMall

    function self.tbParam.SetSelect(owner, bSelect)
        if bSelect then
            self:OnSelect()
        else
            self:UnSelect()
        end
        owner.isSele = bSelect
    end

    function self.tbParam.UpdateLabel()
        self:UpdateLabel()
    end

    self:UpdateLabel()
    self.tbParam:SetSelect(self.tbParam.isSele)

    if #self.Data > 1 then
        WidgetUtils.Visible(self.SecondTab)
        WidgetUtils.Collapsed(self.FirstTab)
        self.TxtBgSecond:SetText(Text(self.Data[1].sGroupName))
        self.TxtCheckSecond:SetText(Text(self.Data[1].sGroupName))
        if not self.bMall then
            self.TxtBgSecond:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF'))
        --    self.TxtCheckSecond:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF'))
        end
        if self.Data[1].nGroupIcon then
            if self.Data[1].nUnselectIcon then
                SetTexture(self.IconBgFirst, self.Data[1].nUnselectIcon)
            else
                SetTexture(self.IconBgFirst, self.Data[1].nGroupIcon)
            end
            if not self.bMall then
                self.IconBgFirst:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF'))
            end

            SetTexture(self.IconBgFirst_1, self.Data[1].nGroupIcon)

            if self.tbParam.isSele and self.Data[1].nShopIcon then
                self:SetSecondTabIcon(self.Data[1].nShopIcon, self.Data[1].nUnselectIcon)
            else 
                self:SetSecondTabIcon(self.Data[1].nGroupIcon, self.Data[1].nUnselectIcon)
            end
        end
    else
        WidgetUtils.Visible(self.FirstTab)
        WidgetUtils.Collapsed(self.SecondTab)
        self.TxtBgFirst:SetText(Text(self.Data[1].sName))
        self.TxtBgFirst_1:SetText(Text(self.Data[1].sName))
        if not self.bMall then
            self.TxtBgFirst:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF'))
         --   self.TxtBgFirst_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF'))
        end
        if self.Data[1].nGroupIcon then
            if self.Data[1].nUnselectIcon then
                SetTexture(self.IconBgFirst, self.Data[1].nUnselectIcon)
            else
                SetTexture(self.IconBgFirst, self.Data[1].nGroupIcon)
            end
            if not self.bMall then
                self.IconBgFirst:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF'))
            end
            SetTexture(self.IconBgFirst_1, self.Data[1].nGroupIcon)
        end
    end

    if self.Data[1] and self.Data[1].nGroupBg then
        SetTexture(self.Image, self.Data[1].nGroupBg)
        SetTexture(self.Image_4, self.Data[1].nGroupBg)
    end

    self:PlayAnimation(self.NewAnimation)
end

function tbClass:OnSelect()
    if #self.Data > 1 then
        WidgetUtils.Visible(self.CheckSecond)
        WidgetUtils.Collapsed(self.BgSecond)
        WidgetUtils.SelfHitTestInvisible(self.ListPanel)
        self.ListSecondary:ClearChildren()
        self.tbItem = {}
        for _, v in pairs(self.Data) do
            local pWidget = LoadWidget(self.ItemPath)
            if pWidget then
                if not self.tbParam.SeleShop then  --选择第一个
                    self.tbParam.SeleShop = v.nShopId
                end
                local cfg = {}
                cfg.bMall = self.bMall
                cfg.ShopInfo = v
                cfg.isSele = self.tbParam.SeleShop == v.nShopId
                cfg.UpdateSelect = function()
                    if self.tbParam.SeleShop == v.nShopId then return end
                    if self.tbParam.SeleShop and self.tbItem[self.tbParam.SeleShop] then
                        self.tbItem[self.tbParam.SeleShop]:SetSelect(false)
                    end
                    self.tbItem[v.nShopId]:SetSelect(true)
                    self.tbParam.SeleShop = v.nShopId
                    self.tbParam.UpdateShop(cfg.ShopInfo.nShopId)
                end
                self.ListSecondary:AddChild(pWidget)
                pWidget:UpdatePanel(cfg)
                self.tbItem[v.nShopId] = pWidget
            end
        end

        self:SetSecondTabIcon(self.Data[1].nShopIcon, self.Data[1].nUnselectIcon)
    else
        self.tbItem = nil
        WidgetUtils.HitTestInvisible(self.CheckFirst)
        WidgetUtils.Collapsed(self.BgFirst)
    end
end

function tbClass:UnSelect()
    if #self.Data > 1 then
        WidgetUtils.HitTestInvisible(self.BgSecond)
        WidgetUtils.Collapsed(self.CheckSecond)
        WidgetUtils.Collapsed(self.ListPanel)
        self:SetSecondTabIcon(self.Data[1].nGroupIcon, self.Data[1].nUnselectIcon)
    else
        WidgetUtils.HitTestInvisible(self.BgFirst)
        WidgetUtils.Collapsed(self.CheckFirst)
    end
end

function tbClass:UpdateLabel()
    local label = 0
    for _, v in pairs(self.Data) do
        local data = {version = v.nVersion}
        if not self.bMall then
            data = ShopLogic.GetShopData(v.nShopId)
        end

        if not data or data.version ~= v.nVersion then
            if self.tbItem and self.tbItem[v.nShopId] then
                self.tbItem[v.nShopId]:UpdateLabel(v.nLabel)
            end
            label = v.nLabel
        elseif self.bMall and IBLogic.CheckShopBox(v.nShopId) then
            label = 1
        else
            if self.tbItem and self.tbItem[v.nShopId] then
                self.tbItem[v.nShopId]:UpdateLabel(0)
            end
        end
    end
    if label == 1 then
        WidgetUtils.HitTestInvisible(self.Red)
    elseif label == 2 then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

function tbClass:SetSecondTabIcon(nGroupIcon, nOtherIcon)
    if nOtherIcon then
        SetTexture(self.IconBgSecond, nOtherIcon)
        if not self.bMall then
            self.IconBgSecond:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48B3'))
        end
    end

    if not nGroupIcon then return end

    if not nOtherIcon then
        SetTexture(self.IconBgSecond, nGroupIcon)
        if not self.bMall then
            self.IconBgSecond:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48B3'))
        end
    end

    SetTexture(self.IconCheckSecond, nGroupIcon)
end

return tbClass
