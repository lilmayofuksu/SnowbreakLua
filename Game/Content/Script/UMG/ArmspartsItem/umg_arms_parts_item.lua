-- ========================================================
-- @File    : umg_arms_parts_item.lua
-- @Brief   : 武器配件装配界面
-- ========================================================
---@class tbClass
---@field PartsList UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.PartsList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnInit()
    BtnAddEvent(self.BtnFilter, function() self:Filter() end)
    self.ListViewFactory = Model.Use(self)
end

---@param InWeapon UWeaponItem 武器
---@param InType EWeaponSlotType 类型
function tbClass:OnOpen(InWeapon, InType)
    self.pWeapon = InWeapon or self.pWeapon
    if not self.pWeapon then return end
    self.Type = InType or self.nType

    ---显示配件列表
    self.GainParts = {}
    local all = WeaponPart.GetGainPartsByType(self.Type)
    for _, pPart in ipairs(all or {}) do
        local sGDPL = string.format("%s-%s-%s-%s", pPart:Genre(), pPart:Detail(), pPart:Particular(), pPart:Level())
        self.GainParts[sGDPL] = pPart
    end

    self:ShowPartList()
    Weapon.PreviewShow(self.pWeapon)
    ---显示配件详情
    self:ShowDetail()
    PreviewScene.Enter(PreviewType.weapon, function() end)
    Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), 'weaponPart_' .. UE4.UUMGLibrary.GetEnumValueAsString('EWeaponSlotType', InType))
end

---界面关闭处理
function tbClass:OnClose()
    if self.pWeapon and self.Type then
        local pEquipPart = self.pWeapon:GetWeaponSlot(self.Type)
        local nAppearID = 0
        if pEquipPart then 
            ---配件配置
            local tbPartConfig = WeaponPart.GetPartConfig(pEquipPart)
            if tbPartConfig then
                nAppearID = tbPartConfig.AppearID
            end
        end
        Weapon.UpdatePart(self.pWeapon, self.Type, nAppearID)
    end

    Weapon.PreviewClose(false)
    Weapon.ReplacePartCallBack = nil
end

---配件筛选
function tbClass:Filter()
    local pWidget = UI.Open('SortPanel')
    if pWidget then
        pWidget:SetData({}, function(tbSort)  end)
    end
end

function tbClass:IsGet(tbInfo)
   local sGDPL = string.format("%s-%s-%s-%s", tbInfo.G, tbInfo.D, tbInfo.P, tbInfo.L)
   if self.GainParts and self.GainParts[sGDPL] then return true end
   return false
end

---显示配件列表
function tbClass:ShowPartList()
    ---获取装配的配件
    local pPart = self.pWeapon:GetWeaponSlot(self.Type)
    ---获取所有的配件
    local tbParts = Weapon.GetShowPartsByType(self.pWeapon, self.Type) or {}

    ---排序
    table.sort(tbParts,function(a, b)
        local aGet = self:IsGet(a)
        local bGet = self:IsGet(b)

        if aGet and bGet then
            return a.Color > b.Color
        end
        
        if aGet then return true end
        if bGet then return false end

        return a.Color > b.Color 
    end)

    self:DoClearListItems(self.PartsList)

    local bHas = (pPart ~= nil)
    self.SelectPartItem = nil

    ---特殊条目 
    local nType = 1
    if tbParts[1] then
        nType = WeaponPart.GetAllowWeaponType(WeaponPart.GetPartConfigByGDPL(tbParts[1].G, tbParts[1].D, tbParts[1].P, tbParts[1].L))
    end

    local tbEmptyParam = {bSelect = false, bLock = false, nType = nType, nFlag = 0}
    local pEmpty = self.ListViewFactory:Create(tbEmptyParam)
    tbEmptyParam.OnTouch = function() self:Select(pEmpty)  end
    tbEmptyParam.SetSelected = function(tb) EventSystem.TriggerTarget(tb, "SET_SELECTED")  end
    self.PartsList:AddItem(pEmpty)

    for _, v in ipairs(tbParts) do
        local g, d, p, l = v.G, v.D, v.P, v.L
        local tbParam = {gdpl = g and {g, d, p, l} or nil, bEquip = false, nFlag = 1}
        tbParam.pItem = self.GainParts[string.format("%s-%s-%s-%s", g, d, p, l)]
        local NewObj = self.ListViewFactory:Create(tbParam)
        NewObj.tbConfig = v
        local bSelect = false
        if bHas then
             ---选中当前装备的配件
            if pPart:Genre() == g and pPart:Detail() == d and pPart:Particular() == p and pPart:Level() == l then
                self.SelectPartItem = NewObj
                bSelect = true
                tbParam.bEquip = true
            end
        else
            if self.SelectPartItem == nil then
                self.SelectPartItem = NewObj
                bSelect = true
            end
        end
        tbParam.bSelect = bSelect
        tbParam.bLock = false
        tbParam.OnTouch = function()
            self:Select(NewObj)
        end

        tbParam.SetSelected = function(tb)
            EventSystem.TriggerTarget(tb, "SET_SELECTED")
        end

        tbParam.SetNew = function(self)
            EventSystem.TriggerTarget(self, "SET_NEW")
        end
        self.PartsList:AddItem(NewObj)
    end

    if #tbParts < 7 then
        for i = #tbParts + 2, 8 do
            local tbNotParam = {bSelect = false, bLock = false, nFlag = 2}
            local pNot = self.ListViewFactory:Create(tbNotParam)
            self.PartsList:AddItem(pNot)
        end
    end
end

---选择改变
---@param InPart UObject
function tbClass:Select(InPart)
    if self.SelectPartItem ~= InPart then
        if self.SelectPartItem then
            self.SelectPartItem.Data.bSelect = false
            self.SelectPartItem.Data:SetSelected()
        end
        self.SelectPartItem = InPart
        if self.SelectPartItem then
            self.SelectPartItem.Data.bSelect = true
            self.SelectPartItem.Data:SetSelected()
        end
        self:ShowDetail() 
    end
end

---显示配件详情
function tbClass:ShowDetail()
    local pEquipPart = self.pWeapon:GetWeaponSlot(self.Type)
    WidgetUtils.Collapsed(self.AddBtn)
    ---无配件
    if not self.SelectPartItem then 
        WidgetUtils.Collapsed(self.InfoContent)
        return 
    end
    local BtnShowName = "ui.equipment"

    if self.SelectPartItem.Data.gdpl == nil then
        WidgetUtils.Collapsed(self.InfoContent)
        Weapon.UpdatePart(self.pWeapon, self.Type, 0)
        ---如果装配了 显示确定
        if pEquipPart then
            WidgetUtils.Visible(self.AddBtn)
            BtnClearEvent(self.AddBtn)
            BtnAddEvent(self.AddBtn, function()  self:UnEquip() end)
            BtnShowName = 'ui.TxtDialogueConfirm'
            self.BtnName:SetText(Text(BtnShowName))
        end
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.InfoContent)
    ---当前选择的配件
    local tbConfig = self.SelectPartItem.tbConfig
    if not tbConfig then return end
    

    SetTexture(self.ImgRarity_1, Weapon.GetQualityIcon(tbConfig.Color))
    SetTexture(self.ImgRarity, Weapon.GetQualityIcon(tbConfig.Color))
    ---显示部件属性
    self:DoClearListItems(self.AttrList)
    local tbAttr = WeaponPart.GetPartAttr(tbConfig)
    for k, v in pairs(tbAttr) do
        local sAdd = WeaponPart.ConvertType(k, v)

        local tbParam = { sDes = Text("attribute." .. k), nIcon = Resource.GetAttrPaint(k) , nNow = self:GetEquipPartAttr(k), nAdd = sAdd}
        local pObj = self.ListViewFactory:Create(tbParam)
        self.AttrList:AddItem(pObj)
    end

    
    ---显示替换按钮
    local pSelectPart = WeaponPart.GetPart(tbConfig.G, tbConfig.D, tbConfig.P, tbConfig.L)
    if pSelectPart and pEquipPart ~= pSelectPart then
        WidgetUtils.Visible(self.AddBtn)
        BtnClearEvent(self.AddBtn)
        BtnAddEvent(self.AddBtn, function()  self:Replace()  end)
        self.BtnName:SetText(Text(BtnShowName))
    end

    ---设置配件名称
    local PartTemplate = UE4.UItem.FindTemplate(tbConfig.G, tbConfig.D, tbConfig.P, tbConfig.L)
    self.PartName:SetText(Text(PartTemplate.I18N))

    local nAppearID = self.SelectPartItem.tbConfig.AppearID
    if Weapon.IsShowDefaultPart(self.pWeapon) == false then 
        Weapon.UpdatePart(self.pWeapon, self.Type, nAppearID)
        Weapon.PlayPartEffect(self.pWeapon, self.Type, PartTemplate.Color)
    end
  
    WeaponPart.Read(tbConfig.G, tbConfig.D, tbConfig.P, tbConfig.L)
    self.SelectPartItem.Data:SetNew()
end

---获取装配的配件属性
function tbClass:GetEquipPartAttr(InName)
    ---装配的配件
    local pEquipPart = self.pWeapon:GetWeaponSlot(self.Type)
    if not pEquipPart then return 0 end
    ---配件配置
    local tbPartConfig = WeaponPart.GetPartConfig(pEquipPart)
    ---配件属性列表
    local tbAttr = WeaponPart.GetPartAttr(tbPartConfig)
    if tbAttr then   return tbAttr[InName] or 0  end
    return 0
end

---卸下配件
function tbClass:UnEquip()
    local pEquipPart = self.pWeapon:GetWeaponSlot(self.Type)
    if pEquipPart then  Weapon.Req_ReplacePart(self.pWeapon, -1, self.Type) end
end

---替换配件
function tbClass:Replace()
    if not self.SelectPartItem then return   end
    local tbConfig = self.SelectPartItem.tbConfig
    local pPart = WeaponPart.GetPart(tbConfig.G, tbConfig.D, tbConfig.P, tbConfig.L)
    if pPart then  Weapon.Req_ReplacePart(self.pWeapon, pPart:Id(), self.Type) end
end

return tbClass
