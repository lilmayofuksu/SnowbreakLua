-- ========================================================
-- @File    : umg_iteminfo.lua
-- @Brief   : 道具信息展示
-- ========================================================
---@class tbClass : UUserWidget
---@field PanelInfo UOverlay
local tbClass = Class("UMG.BaseWidget")

tbClass.tbDisplayRoute = {}
tbClass.tbDisplayRoute[UE4.EItemType.CharacterCard] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_item.uw_iteminfo_item_C", bShowLock=true}
tbClass.tbDisplayRoute[UE4.EItemType.Weapon] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_weaponinfo.uw_iteminfo_weaponinfo_C", bShowLock=true}
tbClass.tbDisplayRoute[UE4.EItemType.SupporterCard] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_supportinfo.uw_iteminfo_supportinfo_C", bShowLock=true}
tbClass.tbDisplayRoute[UE4.EItemType.Useable] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_item.uw_iteminfo_item_C", bShowLock=false}
tbClass.tbDisplayRoute[UE4.EItemType.Suplies] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_item.uw_iteminfo_item_C", bShowLock=false}
tbClass.tbDisplayRoute[UE4.EItemType.WeaponParts] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_partinfo.uw_iteminfo_partinfo_C", bShowLock=false}
tbClass.tbDisplayRoute[UE4.EItemType.CharacterSkin] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_item.uw_iteminfo_item_C", bShowLock=false}
tbClass.tbDisplayRoute[UE4.EItemType.HouseGift] = {ui="/Game/UI/UMG/ItemInfo/Widgets/uw_iteminfo_item.uw_iteminfo_item_C", bShowLock=true}

function tbClass:OnInit()
    BtnAddEvent(
        self.BtnClose,
        function()
            UI.Close(self)
        end
    )

    BtnAddEvent(
        self.BtnLock,
        function()
            if self.SetLock then
                self.SetLock(self.pItem, false)
                WidgetUtils.Collapsed(self.BtnLock)
                WidgetUtils.Visible(self.BtnUnlock)
            end
            
        end
    )

    BtnAddEvent(
        self.BtnUnlock,
        function()
            if self.SetLock then
                self.SetLock(self.pItem, true)
                WidgetUtils.Collapsed(self.BtnUnlock)
                WidgetUtils.Visible(self.BtnLock)
            end   
        end
    )

    self.nLastType = nil
end

--- 打开时回调, 传gdpl或道具对象
function tbClass:OnOpen(...)
    local tbParam = {...}
    --WidgetUtils.Collapsed(self.PanelObtainReturn)
    if #tbParam > 0 then self.tbParam = tbParam end
    if self.tbParam == nil then return end

    local sParam1Type = type(self.tbParam[1])
    if #self.tbParam == 1 or #self.tbParam == 2 then
        if sParam1Type == "string" and self.tbParam[1] == "ShowJPInfo" then
            self:ShowJPMoneyInfo()
        elseif tonumber(self.tbParam[1]) then
            self:ShowMoneyInfo(self.tbParam[1])--传递代币Id
        else
            self:ShowItem(...) --传递道具对象
        end
    else -- 反之视为传递GDPLN
        local g, d, p, l, n = table.unpack(self.tbParam)
        n = n or me:GetItemCount(g, d, p, l)
        self:ShowItem(me:GetDefaultItem(g, d, p, l, n), tbParam)
        WidgetUtils.Collapsed(self.PanelLock)
    end
    self:PlayAnimationReverse(self.click1)
    self:ShowBottomBtn()
end

function tbClass:ShowTemplate(g, d, p, l,n)
    local pItemTemplate = UE4.UItem.FindTemplate(g, d, p, l)
    if not pItemTemplate then
        UI.Close(self)
        return
    end
    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItemTemplate.Color])
    local pPanelInfo = self:GetPanelInfo(pItemTemplate.Genre)
    if not pPanelInfo then
        UI.Close(self)
        return
    end
    pPanelInfo:ShowTemplate(pItemTemplate)
    ---显示模板信息数量
    pPanelInfo:SetNum(n)
    WidgetUtils.Collapsed(self.PanelLock)

    self:AddReturnEvent(pPanelInfo)
end

function tbClass:ShowItem(pItem, tbInfo)
    self.pItem = pItem or self.pItem
    if type(tbInfo) == 'table' then
        self.tbEnhanceInfo = tbInfo or self.tbEnhanceInfo
    end

    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[self.pItem:Color()])
    if self.pItem:HasFlag(Item.FLAG_LOCK) then
        WidgetUtils.Visible(self.BtnLock)
        WidgetUtils.Collapsed(self.BtnUnlock)
    else
        WidgetUtils.Visible(self.BtnUnlock)
        WidgetUtils.Collapsed(self.BtnLock)
    end

    local pPanelInfo = self:GetPanelInfo(self.pItem.Type)
    if not pPanelInfo then
        UI.Close(self)
        return
    end
    pPanelInfo:ShowItem(self.pItem, true, tbInfo)
    if pPanelInfo.ShowPanelNerve then
        ---刷新专属道具描述
        pPanelInfo:ShowPanelNerve(self.tbParam[6], self.pItem)
    end
    self:AddReturnEvent(pPanelInfo)
end

function tbClass:ShowMoneyInfo(nId)
    local moneycfg = Cash.GetMoneyCfgInfo(nId)
    if not moneycfg then return end

    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[moneycfg.nColor])
    WidgetUtils.Collapsed(self.PanelLock)

    local pPanelInfo = self:GetPanelInfo(4)
    pPanelInfo:ShowMoneyInfo(moneycfg,true)

    self:AddReturnEvent(pPanelInfo)
end

function tbClass:GetPanelInfo(nType)
    self.nType = nType
    self.UIInfo = self.UIInfo or {}
    if self.nLastType and self.UIInfo[self.nLastType] then
        WidgetUtils.Collapsed(self.UIInfo[self.nLastType])
    end
    if not self.UIInfo[nType] then
        self.UIInfo[nType] = LoadWidget(self.tbDisplayRoute[nType].ui)
        if self.tbDisplayRoute[nType].bShowLock then
            WidgetUtils.Visible(self.PanelLock)
        else
            WidgetUtils.Collapsed(self.PanelLock)
        end
        self.PanelInfo:AddChild(self.UIInfo[nType])
    end
    self.nLastType = nType
    local pNewWidget = self.UIInfo[self.nLastType]
    if self.nLastType and pNewWidget then
        WidgetUtils.SelfHitTestInvisible(pNewWidget)
        ---背包是这个控件 特殊处理
        local pSwitcher  = self.PanelInfo:Cast(UE4.UWidgetSwitcher)
        if pSwitcher then
            pSwitcher:SetActiveWidget(pNewWidget)
        end
    end
    return self.UIInfo[nType]
end

---显示或隐藏获取途径按钮
function tbClass:ShowBtnObtain(bShow)
    if self.nType then
        local pPanelInfo = self:GetPanelInfo(self.nType)
        if pPanelInfo then
            if bShow then
                WidgetUtils.Visible(pPanelInfo.BtnObtain)
            else
                WidgetUtils.Collapsed(pPanelInfo.BtnObtain)
            end
        end
    end
end

function tbClass:ShowBottomBtn()
    if (self.nType == UE4.EItemType.Weapon and not FunctionRouter.IsOpenById(FunctionType.WeaponReplace)) or
        (self.nType == UE4.EItemType.SupporterCard and not FunctionRouter.IsOpenById(FunctionType.Logistics)) then
        WidgetUtils.Collapsed(self.PanelBottom)
        return
    end


    if self.tbEnhanceInfo and self.tbEnhanceInfo.sEnhance and self.tbEnhanceInfo.fEnhance then
        self.TxtBottom:SetText(self.tbEnhanceInfo.sEnhance)
        self.TxtBottom2:SetText(self.tbEnhanceInfo.sEnhance)
        WidgetUtils.SelfHitTestInvisible(self.PanelBottom)
        self.BtnBottom.OnClicked:Clear()
        self.BtnBottom.OnClicked:Add(self,function ()
            self.tbEnhanceInfo.fEnhance(self.pItem)
        end)
    else
        WidgetUtils.Collapsed(self.PanelBottom)
    end
end

function tbClass:AddReturnEvent(panel)
    if not panel then return end
    self.BtnObtainReturn.OnClicked:Clear()
    self.BtnObtainReturn.OnClicked:Add(self,function ()
        WidgetUtils.Collapsed(panel.PanelListObtain)
        WidgetUtils.SelfHitTestInvisible(panel.ScrollContent)
        WidgetUtils.Visible(panel.PanelContent)
        WidgetUtils.SelfHitTestInvisible(panel.PanelObtain)
        WidgetUtils.Visible(panel.BtnObtain)

        self:ShowReturn(false)
    end)

    panel.BtnObtain.OnClicked:Clear()
    panel.BtnObtain.OnClicked:Add(
        panel,
        function()
            WidgetUtils.Collapsed(panel.PanelContent)
            WidgetUtils.Collapsed(panel.BtnObtain)
            WidgetUtils.Collapsed(panel.ScrollContent)
            WidgetUtils.SelfHitTestInvisible(panel.PanelListObtain)
            WidgetUtils.Visible(panel.BtnObtainReturn)
            WidgetUtils.Visible(panel.ListObtain)
            self:ShowReturn(true)
        end
    )
end

function tbClass:ShowReturn(bShow)
    if bShow then
        WidgetUtils.SelfHitTestInvisible(self.PanelObtainReturn)
    else
        WidgetUtils.Collapsed(self.PanelObtainReturn)
    end
end

function tbClass:ShowJPMoneyInfo()
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.ImgQuality)

    local pPanelInfo = self:GetPanelInfo(4)
    pPanelInfo:ShowJPMoneyInfo()
    self:AddReturnEvent(pPanelInfo)
end

return tbClass
