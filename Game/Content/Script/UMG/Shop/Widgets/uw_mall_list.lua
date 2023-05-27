-- ========================================================
-- @File    : uw_mall_list.lua
-- @Brief   : 商城分类列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.ItemPath = "/Game/UI/UMG/Shop/Widgets/uw_mall_littleitem.uw_mall_littleitem_C"

    BtnAddEvent(self.BtnSelect, function()
        if not self.tbParam then return end
        if #self.Data > 1 and self.tbParam.isSele then
            if self.ListPanel:GetVisibility() == UE4.ESlateVisibility.Collapsed then
                self:SetGroupIcon(true)
                WidgetUtils.SelfHitTestInvisible(self.ListPanel)
            else
                WidgetUtils.Collapsed(self.ListPanel)
                self:SetGroupIcon()
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
        self:SetGroupIcon(self.tbParam.isSele)
    else
        WidgetUtils.Visible(self.FirstTab)
        WidgetUtils.Collapsed(self.SecondTab)
        self.TxtBgFirst:SetText(Text(self.Data[1].sName))
        self.TxtBgFirst_1:SetText(Text(self.Data[1].sName))
        if self.Data[1].nGroupIcon then
            SetTexture(self.IconBgFirst, self.Data[1].nGroupIcon)
            SetTexture(self.IconBgFirst_1, self.Data[1].nGroupIcon)
        end
    end

    self:PlayAnimation(self.NewAnimation)
end

function tbClass:OnSelect()
    if #self.Data > 1 then
        WidgetUtils.Visible(self.CheckSecond)
        WidgetUtils.Collapsed(self.BgSecond)
        WidgetUtils.SelfHitTestInvisible(self.ListPanel)
        self:SetGroupIcon(true)
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
                    self.tbParam.UpdateShop(v.nShopId)
                end
                self.ListSecondary:AddChild(pWidget)
                pWidget:UpdatePanel(cfg)
                self.tbItem[v.nShopId] = pWidget
            end
        end
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
        self:SetGroupIcon()
    else
        WidgetUtils.HitTestInvisible(self.BgFirst)
        WidgetUtils.Collapsed(self.CheckFirst)
    end
end

function tbClass:UpdateLabel()
    local label = 0
    for _, v in pairs(self.Data) do
        if IBLogic.CheckShopBox(v.nShopId) then
            label = 1
        else
            if self.tbItem and self.tbItem[v.nShopId] then
                self.tbItem[v.nShopId]:UpdateLabel(0)
            end
        end
    end
    if label == 1 then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

--设置多标签模式下，主标签的icon 展开和收缩模式
function tbClass:SetGroupIcon(bExtend)
    if #self.Data <= 1 then return end

    if bExtend and self.Data[1].nShopIcon then
        SetTexture(self.IconBgSecond, self.Data[1].nShopIcon)
        SetTexture(self.IconCheckSecond, self.Data[1].nShopIcon)
    elseif self.Data[1].nGroupIcon then
        SetTexture(self.IconBgSecond, self.Data[1].nGroupIcon)
        SetTexture(self.IconCheckSecond, self.Data[1].nGroupIcon)
    end
end

return tbClass
