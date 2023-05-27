-- ========================================================
-- @File    : umg_mall.lua
-- @Brief   : 商城界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.tbShopItem = {}
    self.Factory = Model.Use(self)
    self:CloseShopTips()
    self.ListTab:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListView_300:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnOpen(nShopId, nGoodsId)
    if not nShopId then
        nShopId = self.SelectShopId
    end

    self.nSelectGoodsId = nGoodsId

    if nShopId and self.SelectShopId ~= nShopId then
        local shopInfo = IBLogic.GetShopConfig(nShopId)
        if shopInfo then
            self.SelectShopId = shopInfo.nShopId
        end
    end

    self:ShowShopGroup()

    self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Money})
    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnClose()
end

--显示左边列表
function tbClass:ShowShopGroup()
    self:DoClearListItems(self.ListTab)
    local nSelGroup = nil
    if self.SelectShopId then
        local shopInfo = IBLogic.GetShopConfig(self.SelectShopId)
        if shopInfo then
            nSelGroup = shopInfo.nGroupId
        end
    end

    local allTab = IBLogic.GetAllGroup()
    for _, tbShop in pairs(allTab) do
        if tbShop and #tbShop >= 1 then
            local groupId = tbShop[1].nGroupId
            local shopId = tbShop[1].nShopId
            local data = {}
            if not self.SelectShopId then
                self.SelectShopId = shopId
                nSelGroup = groupId
            end
            data.nGroupId = groupId
            data.isSele = (groupId == nSelGroup)
            data.nGroupIcon = tbShop[1].nGroupIcon
            data.UpdateSelect = function(nCurGroup)
                self:ClickTable(nCurGroup)
            end
            local pObj = self.Factory:Create(data)
            self.ListTab:AddItem(pObj)
            self.tbShopItem[groupId] = pObj.Data
        end
    end

    self:ShowRightPanel(self.SelectShopId)
end

--点击左侧一级标签
function tbClass:ClickTable(nCurGroup, nCurShopId)
    if not nCurGroup and not nCurShopId then return end

    if nCurShopId and nCurShopId == self.SelectShopId then
        return
    end

    local tbCurShop = IBLogic.GetShopConfig(self.SelectShopId)
    if tbCurShop and tbCurShop.nGroupId == nCurGroup then
        return
    end

    local nShowShopId = nCurShopId
    if not nShowShopId then
       local tbGroup = IBLogic.GetGroupList(nCurGroup)
       if not tbGroup or #tbGroup == 0 then
            return
       end

       nShowShopId = tbGroup[1].nShopId
    end

    local tbShowShop = IBLogic.GetShopConfig(nShowShopId)
    if not tbCurShop or not tbShowShop or tbCurShop.nGroupId ~= tbShowShop.nGroupId then
        if tbCurShop then --取消当前选中
            self.tbShopItem[tbCurShop.nGroupId]:SetSelect(false)
        end

        if tbShowShop then --设置点击选中
            self.tbShopItem[tbShowShop.nGroupId]:SetSelect(true)
        end
    end

    self:ShowRightPanel(nShowShopId)
    if nCurGroup then
        self:PlayAnimation(self.tap_select)
    end
end

--- 显示右侧面板
function tbClass:ShowRightPanel(nShopId)
    if not nShopId then return end
    if self.SelectShopId ~= nShopId then
        self.SelectShopId = nShopId
    end

    local tbConfig = IBLogic.GetShopConfig(nShopId)
    if not tbConfig then return end

    self:ShowTopTable(tbConfig.nGroupId)

    self.Switcher:SetActiveWidgetIndex((tbConfig.nWidgetType - 1) or 0)

    local tbModel = self.Switcher:GetActiveWidget()
    if not tbModel then return end

    local tbData = {tbConfig = tbConfig, nSelectGoodsId = self.nSelectGoodsId}

    if tbModel.ShowMallInfo then
        tbModel:ShowMallInfo(tbData)
        self:SetMallName(tbConfig.sName)
        if tbModel.AllEnter then
            tbModel:PlayAnimation(tbModel.AllEnter)
        end
    end

    WidgetUtils.SelfHitTestInvisible(tbModel)

    if self.nSelectGoodsId then
        local tbGoods = IBLogic.GetIBGoods(self.nSelectGoodsId)
        local bLimit = IBLogic.CheckProductSellOut(self.nSelectGoodsId)
        if tbGoods and not bLimit and (tbGoods.nType == IBLogic.Type_IBGift or tbGoods.nType == IBLogic.Type_IBSkin) then
            self:OpenShopTips(tbGoods)
        end
        self.nSelectGoodsId = nil
    end

    self:PlayAnimation(self.Enter)
end

--服务器返回
function tbClass:OnByGoodsUpdate()
    self:CloseShopTips()
    self:ShowShopGroup()
end

---跳转到指定分类
function tbClass:GotoMall(shopId, nGoodsId)
    self:CloseShopTips()
    local info = IBLogic.GetShopConfig(shopId)
    if not info then return end

    if self.SelectShopId == shopId then return end
    
    self.SelectShopId = shopId
    self.nSelectGoodsId = nGoodsId
    self:ShowShopGroup()
end

---打开商品详情页
function tbClass:OpenShopTips(tbGoods)
    if self.ShopTips == nil then
        self.ShopTips = WidgetUtils.AddChildToPanel(self.ContentNode, '/Game/UI/UMG/Shop/Widgets/uw_mall_tips.uw_mall_tips_C', 3)
    end
    if not self.ShopTips then return end

    WidgetUtils.SelfHitTestInvisible(self.ShopTips)

    local tbData = {bMall = true, tbConfig = tbGoods}
    self.ShopTips:OnOpen(tbData)
    self.ShopTips:PlayAnimation(self.ShopTips.AllEnter)
end

---关闭商品详情页
function tbClass:CloseShopTips()
    WidgetUtils.Collapsed(self.ShopTips)
end

--设置名字
function tbClass:SetMallName(sName)
    if not sName then
        self.Position:SetText("")
        return
    end

    self.Position:SetText(Text(sName))
end


--显示顶上二级切换按钮
function tbClass:ShowTopTable(nCurGroup)
    self:DoClearListItems(self.ListView_300)
    if not nCurGroup then 
        WidgetUtils.Collapsed(self.SecondTab)
        return 
    end

    local allTab = IBLogic.GetGroupList(nCurGroup)
    if not allTab or #allTab == 1 then
        WidgetUtils.Collapsed(self.SecondTab)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.SecondTab)

    for _, tbShop in ipairs(allTab) do
        local tbParam = {sName = tbShop.sName, nShopId=tbShop.nShopId}
        tbParam.isSele = (tbShop.nShopId == self.SelectShopId)
        local pObj = self.Factory:Create(tbParam)
        self.ListView_300:AddItem(pObj)
       -- self.tbShopItem[groupId] = pObj.Data
    end
end

return tbClass
