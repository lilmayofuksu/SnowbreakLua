-- ========================================================
-- @File    : umg_logistics.lua
-- @Brief   : 角色后勤界面
-- @Author  :
-- @Date    :
-- ========================================================

--- @class umg_logistics:ULuaWidget

local umg_logistics = Class("UMG.BaseWidget")
local Logist = umg_logistics
Logist.tbSelectTypeHandle = {}
Logist.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"
--- 公司IconId
Logist.tbComponyIcon = {1200000,1200001,1200002}

function Logist:Construct()
    self.pAttrItem = Model.Use(self,self.AttrPath)
    self.LogisticsSlot = {self.Logis1,self.Logis2,self.Logis3}
    BtnAddEvent(self.WpBtn, function()
        --- 默认进入第一插槽
        Logistics.SelectType = 1
        local val1, val2 = FunctionRouter.IsOpenById(19)
        if not val1 then
            UI.ShowTip(val2[1])
            return
        end
        UI.Open("LogiShow", self.CurCard)
    end)
    BtnAddEvent(self.BtnAdd, function()
        local val1, val2 = FunctionRouter.IsOpenById(19)
        if not val1 then
            UI.ShowTip(val2[1])
            return
        end
        Logistics.SelectType = 3
        UI.Open("LogiShow", self.CurCard, Logistics.SelectType)
    end)

    BtnAddEvent(self.DetailClick, function()
        -- UI.ShowTip("ui.TxtNotOpen")
        UI.Open("SupportDetail",self.CurCard)
    end)
end

--- 预览信息界面
function Logist:InfoDes(InCard)
    self:ShowSlot(InCard)
    self:OnListAtt(InCard)
end

function Logist:OnActive(pInCard, InFrom, click, CharacterCard)
    local pParent = UI.GetUI("Role")
    if not pParent then return end
    pParent:ShowSortWidget("Show")

    self.CurCard = CharacterCard or RoleCard.GetItem({pInCard.Genre,pInCard.Detail,pInCard.Particular,pInCard.Level})
    if not self.CurCard then return end

    if self.CurCard:IsTrial() then
        WidgetUtils.Collapsed(self.WpBtn)
    else
        WidgetUtils.Visible(self.WpBtn)
    end

    --- 角色展示模型
    RoleCard.ModifierModel(nil, self.CurCard, PreviewType.role_logistics, UE4.EUIWidgetAnimType.Role_Logistics)

    if #(self:GetAllSupport()) == 0 then
        WidgetUtils.Collapsed(self.PanelAtt)
        WidgetUtils.Collapsed(self.SuitSkill)
        WidgetUtils.Collapsed(self.DetailClick)
        -- WidgetUtils.SelfHitTestInvisible(self.PanelEmpty)
    else
        -- WidgetUtils.Collapsed(self.PanelEmpty)
        WidgetUtils.SelfHitTestInvisible(self.PanelAtt)
        WidgetUtils.SelfHitTestInvisible(self.SuitSkill)
    end
    self:ShowSlot(self.CurCard, InFrom)
    self:OnListAtt(self.CurCard)
    local SuitSkill = UE4.TArray(UE4.int32)
    SuitSkill = self.CurCard:GetSupporterSuitFirstSkill()
    self.SuitSkill:OnActive(SuitSkill:ToTable(), 1)
    self:PlayAnimation(self.AllEnter)
end

function Logist:GetAllSupport()
    local tbAllSlot = UE4.TArray(UE4.USupporterCard)
    me:GetSupporterCards(tbAllSlot)
    return tbAllSlot:ToTable()
end

function Logist:OnListAtt(InCard)
    local ListMainAttr = {}
    local ListSubAttr = {}

    ---获得属性并合并相同的属性
    for i = 1, 3 do
        local pSlot = InCard:GetSupporterCardForIndex(i)
        if pSlot then
            local MainAttrList = Logistics.GetMainAttr(pSlot)
            local SubAttr = Logistics.GetSubAttr(pSlot)
            if MainAttrList then
                --- 合并相同的属性值
                for _, MainAttr in pairs(MainAttrList) do
                    local IsMerged = false
                    for _, tbAttr in pairs(ListMainAttr) do
                        if tbAttr.sType == MainAttr.sType then
                            tbAttr.Attr = tbAttr.Attr + MainAttr.Attr
                            IsMerged = true
                            break
                        end
                    end
                    if not IsMerged then
                        table.insert(ListMainAttr, MainAttr)
                    end
                end
            end

            if SubAttr then
                --- 合并相同的属性值
                local IsMerged = false
                for _, tbAttr in pairs(ListSubAttr) do
                    if tbAttr.sType == SubAttr.sType then
                        tbAttr.Attr = tbAttr.Attr + SubAttr.Attr
                        IsMerged = true
                        break
                    end
                end
                if not IsMerged then
                    table.insert(ListSubAttr, SubAttr)
                end
            end
        end
    end

    for i = 1, 3 do
        local tbAttr = ListSubAttr[i]
        local attWidget = self["SubAttr"..i]
        if tbAttr then
            WidgetUtils.HitTestInvisible(attWidget)
            attWidget:Display(tbAttr)
            attWidget:ShowBG(true)
            attWidget:SetColor("#3C3D48FF")
        else
            WidgetUtils.Collapsed(attWidget)
        end
    end

    for i = 1, 4 do
        local tbAttr = ListMainAttr[i]
        local attWidget = self["Attr"..i]
        if tbAttr then
            WidgetUtils.HitTestInvisible(attWidget)
            attWidget:Display(tbAttr)
            attWidget:ShowBG(false)
            attWidget:SetColor("#4439C2FF")
        else
            WidgetUtils.Collapsed(attWidget)
        end
    end

    if #ListSubAttr==0 and #ListMainAttr==0 then
        WidgetUtils.HitTestInvisible(self.NoActivity)
        self.TxtSuitInfo2_1:SetContent(Text("ui.TxtNoAttributes"))
    else
        WidgetUtils.Collapsed(self.NoActivity)
    end
end

--- 后勤卡S三个插槽列表
function Logist:ShowSlot(InCard, InFrom)
    local SlotNum = 0
    local tbRedData = RoleCard.CheckCardRedDot(InCard, {5})
    local bTrail = InCard:IsTrial()
    for index, value in pairs(self.LogisticsSlot) do
        local pSlot = InCard:GetSupporterCardForIndex(index)
        if not pSlot then
            if bTrail then
                value:ShowLogiItem(false, false)
            else
                value:ShowLogiItem(false, true)
                Logistics.OptionMode = 1
                value:SetRed(tbRedData and tbRedData[index])
            end
        else
            SlotNum = SlotNum + 1
            value:ShowLogiItem(true)
            value:SetLogiName({SupportCard = pSlot})
            value:BelongedIcon(self.tbComponyIcon[index])
            Logistics.OptionMode = 3
            value:SetIcon(pSlot)
            value:SetColor(pSlot)
            value:SetRed(false)
        end
        if not bTrail or pSlot then
            value:InitClick(function()
                Logistics.SelectType = index
                local val1,val2 = FunctionRouter.IsOpenById(19)
                if not val1 then
                    UI.ShowTip(val2[1])
                    return
                end
                UI.Open("LogiShow", self.CurCard, index, InFrom)
            end)
        end
    end
    if SlotNum == 0 then
        WidgetUtils.Collapsed(self.DetailClick)
    else
        WidgetUtils.Visible(self.DetailClick)
    end
    self.Num:SetText(SlotNum)
end

function Logist:OnClose()
    for _, value in pairs(self.LogisticsSlot) do
        EventSystem.Remove(value.OnSelectTypeHandle)
    end

    if self.tbSelectTypeHandle then
        for _, value in pairs(self.tbSelectTypeHandle) do
            if value then
                EventSystem.Remove(self.tbSelectTypeHandle)
            end
        end
    end
end

return Logist