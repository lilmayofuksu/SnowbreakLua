-- ========================================================
-- @File    : uw_Logistics_item.lua
-- @Brief   : 角色后勤条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_Logistics_item = Class("UMG.SubWidget")
local LogiItem = uw_Logistics_item

LogiItem.InObj = nil
LogiItem.OnSelectTypeHandle = "ON_SELECTTYPE_HANDLE"
LogiItem.QualPath = "UMG.Support.LogisticsShow.Widgets.uw_Logistics_star_data"

function LogiItem:Construct()
    self:ShowLogiItem(true, self.bEdit)
    WidgetUtils.Collapsed(self.PanelSelect)
    self.QualItem = Model.Use(self, self.QualPath)
    WidgetUtils.Collapsed(self.PanelUse)
    self.bSelect = false
    self.BtnSelect.OnClicked:Add(self, function()
        --- 点击插槽监听
        EventSystem.TriggerTarget(self, self.OnSelectTypeHandle)
        --- 后勤卡点击监听
        if self.OnClick then
            self.Data.ClickFun(self.Data.SupportCard)
            self:GetSelect(true)
        end
        if self.goClick then
            self.goClick(self.SlotIdx)
            self.goClick = nil
        end
    end)

    self:RegisterEventOnTarget(Logistics, Logistics.ShowHead, function(InTarget)
        self:SetMark(self.Data.RoleCard)
    end)

    self:RegisterEventOnTarget(Logistics, "OnListItemSelect", function(InTarget, InItem)
        if self.pCard and self.pCard ~= InItem then
            WidgetUtils.Collapsed(self.PanelSelect)
        end
    end)
    self.tbItemColor = {"#93939333", "#211b4433", "#4460ec33", "#a15ce533", "#f2a73d33", "#ee2b4c33"}
end

function LogiItem:Display(InParam)
    self.goClick = InParam.Click
    self.SlotIdx = InParam.Slot
    if not InParam.SupportCard then
        self:ShowLogiItem()
        return
    end
    self.Data = InParam.SupportCard
    self.OnClick = nil
    self:SetIcon(InParam.SupportCard)
    self:SetLogiName(InParam)
    self:SetColor(InParam.SupportCard)
end

function LogiItem:DisplayByGDPL(G, D, P, L, Level, BreakNum)
    local logiInfo = UE4.UItem.FindTemplate(G, D, P, L)
    if not logiInfo then return end

    self.OnClick = nil

    WidgetUtils.Collapsed(self.NumDes)
    WidgetUtils.Collapsed(self.ImgEmpty)
    WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
    WidgetUtils.SelfHitTestInvisible(self.CanvasDes)
    SetTexture(self.ImgType, Item.SupportTypeIcon[D])
    SetTexture(self.ImgQuality, Item.RoleColor2[logiInfo.Color])
    if self.ImgQuality2 then
        local hexColor = UE4.UUMGLibrary.GetSlateColorFromHex(self.tbItemColor[logiInfo.Color])
        self.ImgQuality2:SetColorAndOpacity(hexColor)
    end
    if BreakNum >= 4 then
        SetTexture(self.ImgIcon, logiInfo.IconBreak, false)
    else
        SetTexture(self.ImgIcon, logiInfo.Icon, false)
    end
    self.TextCurrLv:SetText(Level)
end

function LogiItem:UpdatSlot()
    EventSystem.TriggerTarget(Logistics, Logistics.OnUpdataLogisticsSlot)
end

function LogiItem:SetSelectType()
    EventSystem.TriggerTarget(self, self.OnSelectTypeHandle)
end

function LogiItem:InitClick(ClickFun)
    self.goClick = ClickFun
end


function LogiItem:ShowLogiItem(InShow, bEdit)
    if InShow then
        WidgetUtils.Collapsed(self.ImgAdd)
        WidgetUtils.Collapsed(self.ImgEmpty)
        WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
    else
        WidgetUtils.Collapsed(self.PanelSlot)
        if bEdit then
            WidgetUtils.Collapsed(self.ImgEmpty)
            WidgetUtils.HitTestInvisible(self.ImgAdd)
        else
            WidgetUtils.Collapsed(self.ImgAdd)
            WidgetUtils.HitTestInvisible(self.ImgEmpty)
        end
    end
end

function LogiItem:SetLogiName(InParam)
    local pItem = InParam.SupportCard
    if not pItem then return end
    if InParam.ShowNum then
        WidgetUtils.SelfHitTestInvisible(self.NumDes)
        WidgetUtils.Collapsed(self.CanvasDes)
        self.NumDes:SetText(string.format("%d/%d", InParam.nNum, pItem:Count()))
    else
        WidgetUtils.SelfHitTestInvisible(self.CanvasDes)
        WidgetUtils.Collapsed(self.NumDes)
    end

    if pItem and pItem:CanStack() then
        WidgetUtils.SelfHitTestInvisible(self.CanvasSlot)
        WidgetUtils.Collapsed(self.CanvasDes)
    elseif pItem and not pItem:CanStack() then
        self.TextCurrLv:SetText(pItem:EnhanceLevel())
    end
end

function LogiItem:SetLogiQual(InItem)
    --self.ImgQualBg:
    self:DoClearListItems(self.ListQual)
    for i = 1, InItem:Break() + 1 do
        local tbParam = {}
        local NewQual = self.QualItem:Create(tbParam)
        self.ListQual:AddItem(NewQual)
    end
end

function LogiItem:SetDynamicIcon(InItem)
    --- Icon 设置
    if not InItem then return end
    local ResourceId= InItem:Icon()
    local BreakResourceId = InItem:IconBreak()
    local IconId= function(Item)
        if Item:IsSupportCard() then
            if Item:Break()>=Logistics.GetBreakMax(Item) - 1 then
                return BreakResourceId
            else
                return ResourceId
            end
        else
            return Item:Icon()
        end
    end
    SetTexture(self.ImgIcon,IconId(InItem))
end

--- 标记被装备角色头像
function LogiItem:SetMark(InCard)
    if InCard and InCard:IsCharacterCard() then
        WidgetUtils.SelfHitTestInvisible(self.PanelUse)
        local HeadId = InCard:Icon()
        SetTexture(self.ImgHead,HeadId)
    else
        WidgetUtils.Collapsed(self.PanelUse)
    end
end

function LogiItem:SetColor(InCard)
    if InCard then
        SetTexture(self.ImgQuality, Item.RoleColor2[InCard:Color()])
        if self.ImgQuality2 then
            local hexColor = UE4.UUMGLibrary.GetSlateColorFromHex(self.tbItemColor[InCard:Color()])
            self.ImgQuality2:SetColorAndOpacity(hexColor)
        end
    end
end


function LogiItem:SetIcon(InItem)
    WidgetUtils.Collapsed(self.ImgEmpty)
    WidgetUtils.Collapsed(self.PanelSlot)
    if InItem then
        WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
        SetTexture(self.ImgType,Item.SupportTypeIcon[InItem:Detail()])
        local ResId = InItem:Icon()
        local ResBreakId = InItem:IconBreak()
        if InItem:IsSupportCard() then
            if Logistics.CheckUnlockBreakImg(InItem) then
                local IconId = ResBreakId
                SetTexture(self.ImgIcon,IconId,false)
            else
                local IconId = ResId
                SetTexture(self.ImgIcon,IconId,false)
            end
        else
            SetTexture(self.ImgIcon, ResId,false)
        end
    else
        WidgetUtils.SelfHitTestInvisible(self.ImgEmpty)
    end
end

function LogiItem:BelongedIcon(Id)
    if not Id or Id == 0 then
        print('IconId err')
        return
    end
    SetTexture(self.ImgType,Id,false)
end

--- 选中效果
function LogiItem:GetSelect(InShow)
    if InShow then
        WidgetUtils.SelfHitTestInvisible(self.PanelSelect)
        self:OnFinish()
	    self:PlayAnimation(self.Select, 0, 999, UE4.EUMGSequencePlayMode.Forward, 1, true)
        EventSystem.TriggerTarget(Logistics, "OnListItemSelect", self.pCard)
    end
end

function LogiItem:ShowLogiTemplate(InTemplate)
    WidgetUtils.Collapsed(self.ImgAdd)
    WidgetUtils.Collapsed(self.ImgEmpty)
    WidgetUtils.Collapsed(self.PanelSelect)
    WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
    WidgetUtils.Collapsed(self.PanelUse)
    WidgetUtils.Collapsed(self.CanvasDes)
    SetTexture(self.ImgIcon, InTemplate.Icon)
    if me:GetItemCount(InTemplate._G, InTemplate._D, InTemplate._P, InTemplate._L) > 0 then
        WidgetUtils.SelfHitTestInvisible(self.ImgHave)
    else
        WidgetUtils.Collapsed(self.ImgHave)
    end
    SetTexture(self.ImgQuality, Item.RoleColor2[InTemplate.Color])
    if self.ImgQuality2 then
        local hexColor = UE4.UUMGLibrary.GetSlateColorFromHex(self.tbItemColor[InTemplate.Color])
        self.ImgQuality2:SetColorAndOpacity(hexColor)
    end
    SetTexture(self.ImgType, Item.SupportTypeIcon[InTemplate._D])
end

function LogiItem:SetRed(bShow)
    if bShow then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

return LogiItem
