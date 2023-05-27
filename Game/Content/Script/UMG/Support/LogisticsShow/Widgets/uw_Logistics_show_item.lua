-- ========================================================
-- @File    : uw_Logistics_show_item.lua
-- @Brief   : 后勤展示条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_Logistics_show_item = Class("UMG.SubWidget")
local LogiItem = uw_Logistics_show_item

LogiItem.QualPath = "UMG.Support.LogisticsShow.Widgets.uw_Logistics_star_data"

function LogiItem:Construct()
    self.pSatr = Model.Use(self, self.QualPath)
    self.Mask.OnMouseButtonDownEvent:Bind(
        self, LogiItem.DownFun)
end

function LogiItem:DownFun()
    self:OnMouseButtonUpEvent()
    if self.Logic.OnClick then
        self.Logic.OnClick()
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function LogiItem:OnInit()
    print("LogiItem:OnInit")
end
function LogiItem:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Logic == nil then
        return
    end
    self.Logic = InObj.Logic
    self.pItem = self.Logic.pItem
    self.txtLv:SetText(self.pItem:EnhanceLevel())
    self:SetQuality(self.pItem)
    --- Icon设置
    local ResId=self.pItem:Icon()
    local ResBreakId=self.pItem:IconBreak()

    local IconId= function()
        if Logistics.CheckUnlockBreakImg(self.pItem) then
            return  ResBreakId
        else
            return  ResId
        end
    end
    SetTexture(self.ImgIcon,IconId())
    self:Select(self.Logic.bSelect)

    if self.pItem:HasFlag(Item.FLAG_USE) then
        WidgetUtils.SelfHitTestInvisible(self.Use)
    else
        WidgetUtils.Collapsed(self.Use)
    end
    EventSystem.RemoveAllByTarget(InObj)
    self.ChangeHandel =
        EventSystem.OnTarget(
        self.Logic,
        self.Logic.SelectChange,
        function(InTarget, bSelect)
            self:Select(bSelect)
        end
    )
end

function LogiItem:OnMouseButtonUpEvent()
    --- 判断插槽是否已经装备
    local slotItem = Logistics.GetLogisticsSlot(Logistics.SelectType)
    local InModel = nil
    if slotItem then
        InModel = LogiType.LogiReplace
    else
        InModel = LogiType.LogiEquip
    end
    EventSystem.TriggerTarget(Logistics, Logistics.OnLogiPopTipHandle, true, self.pItem, InModel)
end

function LogiItem:Select(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.SelectNode)
    else
        WidgetUtils.Collapsed(self.SelectNode)
    end
end

--- 品质数据
function LogiItem:SetQuality(InItem)
    self:DoClearListItems(self.QualList)
    for i = 1, InItem:Break() + 1 do
        local tbParam = {}
        local NewItem = self.pSatr:Create(tbParam)
        self.QualList:AddItem(NewItem)
    end
    SetTexture(self.QuaLvbg,Item.ColorIcon[Item.TYPE_SUPPLIES][InItem:Color()])
    SetTexture(self.img_icon_have,InItem:CompanyID())
end

function LogiItem:QuaLvBg(InTexture)
    if InTexture then
        self.QuaLvbg:SetBrushFromTexture(InTexture)
    end
end

-- 公司LogoIcon
function LogiItem:SetLogo(InLogo,InLogoDes)
    self.img_icon_have:SetBrushFromAtlasInterface(InLogo,true)
end

return LogiItem
