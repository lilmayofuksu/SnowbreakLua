-- ========================================================
-- @File    : uw_iteminfo_partinfo.lua
-- @Brief   : 道具信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
end

---显示模板信息
---@param pItemTemplate FItemTemplate
function tbClass:ShowTemplate(pItemTemplate)
    self.TxtNameItem:SetText(Text(pItemTemplate.I18N))
    self.TxtIntro:SetText(Text(pItemTemplate.I18N .. "_des"))
    local g, d, p, l = pItemTemplate.Genre, pItemTemplate.Detail, pItemTemplate.Particular, pItemTemplate.Level
    local cfg = WeaponPart.GetPartConfigByGDPL(g, d, p, l)
    if not cfg then 
        print("ShowTemplate Error:", g, d, p, l)
        return 
    end

    if cfg then
        local nType = WeaponPart.GetAllowWeaponType(cfg)
        SetTexture(self.ImgType, Item.WeaponTypeIcon[nType])
    end


    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItemTemplate.Color])
    if pItemTemplate.Icon > 0 then
        SetTexture(self.ImgIcon, pItemTemplate.Icon)
    end
    
    self:DoClearListItems(self.ListAtt)

    local tbAttr = WeaponPart.GetPartAttr(cfg)
    for k, v in pairs(tbAttr) do
        local sAdd = WeaponPart.ConvertType(k, v)
        local tbParam = {sPreWord = Text("attribute." .. k), nNum = sAdd, bItemInfo=true, nIcon = Resource.GetAttrPaint(k)}
        self.ListAtt:AddItem(self.Factory:Create(tbParam))
    end

    self:DealJumpInfo({pItemTemplate.Genre,pItemTemplate.Detail,pItemTemplate.Particular,pItemTemplate.Level})
end

---显示道具信息
---@param pItem UItem
function tbClass:ShowItem(pItem, _, rikiState)
    self.TxtNameItem:SetText(Item.GetName(pItem))
    if not rikiState or rikiState ~= RikiLogic.tbState.Lock then
        WidgetUtils.Visible(self.PanelIntro)
        self.TxtIntro:SetText(Item.GetDes(pItem))
    else
        WidgetUtils.Collapsed(self.PanelIntro)
    end
    
    local cfg = WeaponPart.GetPartConfig(pItem)
    if not cfg then 
        print("ShowItem Error:", pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level() )
        return 
    end
  
    if cfg then
        local nType = WeaponPart.GetAllowWeaponType(cfg)
        SetTexture(self.ImgType, Item.WeaponTypeIcon[nType])
    end

    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItem:Color()])
    if pItem:Icon() > 0 then
        SetTexture(self.ImgIcon, pItem:Icon())
    end

    self:DoClearListItems(self.ListAtt)
    local tbAttr = WeaponPart.GetPartAttr(cfg)
    if not next(tbAttr) then
        print('Item Config Error: no PartAttr', pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level())
    end
    for k, v in pairs(tbAttr) do
        local sAdd = WeaponPart.ConvertType(k, v)
        local tbParam = {sPreWord = Text("attribute." .. k), nNum = sAdd, nIcon = Resource.GetAttrPaint(k)}
        self.ListAtt:AddItem(self.Factory:Create(tbParam))
    end

    self:DealJumpInfo({pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level()})
end

function tbClass:SetNum(n)
    if self.TxtNum == nil then return end
    if n==nil then
        self.TxtNum:SetText()
        return
    end
    if self.TxtNum~=nil then
        self.TxtNum:SetText(n)
    end
end

--处理跳转信息
function tbClass:DealJumpInfo(gdpl)
    if UI.bPoping then
        return
    end

    local hasDropWay = DropWay.ShowWaysOnUI(self, self.ListObtain, self.Factory, gdpl, self)

    WidgetUtils.Hidden(self.BtnObtainReturn)
    WidgetUtils.Collapsed(self.PanelListObtain)
    WidgetUtils.Visible(self.PanelContent)
    if Map.GetCurrentID() ~= 2 then--非主场景不显示跳转按钮
        hasDropWay = false;
    end
    if not hasDropWay then
        WidgetUtils.Collapsed(self.BtnObtain)
        WidgetUtils.Collapsed(self.PanelObtain)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelObtain)
    WidgetUtils.Visible(self.BtnObtain)
end

return tbClass
