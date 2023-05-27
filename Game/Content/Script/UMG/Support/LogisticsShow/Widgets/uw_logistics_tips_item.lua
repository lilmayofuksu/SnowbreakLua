-- ========================================================
-- @File    : uw_logistics_tips_item.lua
-- @Brief   : 角色后勤Tip item
-- @Author  :
-- @Date    :
-- ========================================================

local uw_logistics_tips_item = Class("UMG.SubWidget")
local LogiTipItem = uw_logistics_tips_item

--- 后勤角色属性路径
LogiTipItem.LogiAttrPath = "UMG/Role/Widget/uw_role_attribute_data"
--- 技能说明
LogiTipItem.LogiSkillDesPath = "UMG/Support/LogisticsShow/Widgets/uw_logistics_tips_skill_data"
--- 品质
LogiTipItem.QualPath = "UMG.Support.LogisticsShow.Widgets.uw_Logistics_star_data"
--- des color
LogiTipItem.colshow = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1)
LogiTipItem.colhidd = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.4)
LogiTipItem.colpreview = UE4.UUMGLibrary.GetSlateColor(0.85, 0.6, 0, 1)

function LogiTipItem:Construct()
    self.AtteItem = Model.Use(self)
    self.SkillDesItem = Model.Use(self, self.LogiSkillDesPath)
    self.QualItemPath = Model.Use(self, self.QualPath)
    WidgetUtils.Collapsed(self.PanelEmpty)

    self.BtnUp.OnClicked:Add(
        self,
        function()
            -- self:OnCultureClick()
            if not self.CurSupportCard then
                UI.ShowTip(Text('ui.TxtSupportWarn'))
               return
           end
            UI.Open("Logistics", self.CurSupportCard)
        end
    )

    self.BtnChange.OnClicked:Add(
        self,
        function()
            self:PlayAnimation(self.Click2, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
            if not self.CurSupportCard then
                UI.ShowTip(Text('ui.TxtSupportWarn'))
                return
            end
            self:OnReplaceClick()
            self.BtnChange:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        end
    )

    self.SupportSys = {
        {Click = self.CheckSkill,Page = self.PanelSkill},
        {Click = self.CheckSuit,Page = self.PanelSuit},
        {Click = self.CheckAffix,Page = self.PanelAffix},
    }

    -- for index, value in ipairs(self.SupportSys) do
    --     value.Click.OnCheckStateChanged:Add(
    --         self,
    --         function()
    --             self:SetSupportAttrSystem()
    --             value.Click:SetIsChecked(true)
    --             WidgetUtils.SelfHitTestInvisible(value.Page)
    --         end
    --     )
    -- end
   
    self.ClickState = {
        {Des = Text("ui.TxtProvide"),EventHandle =  Logistics.LogiCardEquip},
        {Des = Text("ui.replace"),EventHandle = Logistics.LogiCardReplace},
        {Des = Text("ui.TxtTransfer"),EventHandle = Logistics.LogiCardUnLoad},
    }


    self:BindToAnimationEvent(
        self.Click2,
        {
            self,
            function()
                self.CanvasPanel:SetRenderOpacity(0)
            end
        },
    UE4.EWidgetAnimationEvent.Finished)

    self:SetEquipModel(LogiType.LogiEquip)
end


function LogiTipItem:OnOpen(InSupportCard, nEquipNum, ActiveBtn)
    self.CurSupportCard = InSupportCard

    if not InSupportCard then
        WidgetUtils.Collapsed(self.PanelInfo)
        WidgetUtils.Collapsed(self.PanelBtn)
        WidgetUtils.SelfHitTestInvisible(self.PanelEmpty)
        UI.ShowTip(Text('ui.TxtSupportWarn'))
        return
    else
        WidgetUtils.Collapsed(self.PanelEmpty)
        WidgetUtils.SelfHitTestInvisible(self.PanelBtn)
        WidgetUtils.SelfHitTestInvisible(self.PanelInfo)
    end

    if InSupportCard and ActiveBtn then
        self:SetEquipModel(Logistics.OptionMode)
    end

    --- 播放All Enter动画
    self:PlayAnimation(self.AllEnter, 0, 1 ,UE4.EUMGSequencePlayMode.Forward, 1, false)
    --- 后勤卡套装技能
    self:SuitSkillDes(InSupportCard, nEquipNum)
    --- 后勤卡公司类型
    self:ItemTypeIcon(InSupportCard:Detail())
    --- 后勤卡词缀
    self.Affix:OnOpen(InSupportCard)
    --- 默认显示属性系统1
    -- self:SetSupportAttrSystem(2)
    ---  print(InSupportCard:Icon())
    local TypeId = InSupportCard:Icon()
    -- SetTexture(self.ImgCompany,TypeId,true)
end

--- 培养操作
function LogiTipItem:OnCultureClick()
    UI.CloseByName("LogiShow", nil, true)
    UI.Open("LogiCult", self.pItem)
    EventSystem.TriggerTarget(Logistics,Logistics.OnCultItem,self.pItem)
end

--- 替换操作
function LogiTipItem:OnReplaceClick()
    --- 发送操作
    EventSystem.TriggerTarget(Logistics, Logistics.LogiOperation,self.CurSupportCard, self.OnClickModel)

end

--- 按键显示的方式
---@param InMode integer  LogiType
function LogiTipItem:SetEquipModel(InMode)
    self.TxtWpBtn22:SetText(self.ClickState[InMode].Des)
    self.OnClickModel = self.ClickState[InMode].EventHandle
    WidgetUtils.SelfHitTestInvisible(self.culture)
end


--- 套装技能描述
function LogiTipItem:SuitSkillDes(InItem, nEquipNum)
    if nEquipNum then
        self.Suit:OnActive(InItem, 3, nEquipNum)
    else
        self.Suit:OnActive(InItem, 2)
    end
end

function LogiTipItem:ShowActiveSuitSkill(InSupportCard,InSuitSkill)
    local tbSuit = { self.TxtSuitDes1,self.TxtSuitDes2,}
    for index, value in ipairs(tbSuit) do
        value:SetColorAndOpacity('normal')
    end
    local function GetSuitId(InIndex)
        local SuitSkill = UE4.TArray(0)
        if InSupportCard then
            InSupportCard:GetSupporterSuitFirstSkill(InIndex,SuitSkill)
        end
        return SuitSkill:Get(1)
    end

    for T, tCount in pairs(InSuitSkill) do
        if tonumber(T) == GetSuitId(3) and tCount == 2 then
            tbSuit[1]:SetColorAndOpacity('green')
            tbSuit[2]:SetColorAndOpacity('green')
            break
        end
        if tonumber(T) == GetSuitId(2) and tCount == 1 then
            tbSuit[1]:SetColorAndOpacity('green')
            break
        end
    end
end

--- 套装技能激活
---@param nSuit  integer 技能套装
function LogiTipItem:OnTxtColor(InItem)
    local tbSlot = Logistics.GetSlots()
    local btag = self:CheckIsSlot(tbSlot, InItem)
    if btag then
        local equipsuit = 0
        for key, value in pairs(tbSlot) do
            if value:Particular() == InItem:Particular() then
                equipsuit = equipsuit + 1
            end
        end
        self:EquipPreview(equipsuit)
        return
    else
        local unequipsuit = 0
        for key, value in pairs(tbSlot) do
            if value:Particular() == InItem:Particular() then
                unequipsuit = unequipsuit + 1
            end
        end
        self:UnEquipPreview(unequipsuit)
        return
    end
end

--- 检查当前预览卡片是否装备
---@param InSlot table 装备的所有后勤卡
---@param InItem UE4.UItem 当前预览的后勤卡
function LogiTipItem:CheckIsSlot(InSlot, InItem)
    local tag = false
    for key, value in pairs(InSlot) do
        if value and value:Detail() == InItem:Detail() and value:Particular() == InItem:Particular() then
            tag = true
        end
    end
    return tag
end
--- 没装备的后勤卡预览
---@param InNun  integer 套装数
function LogiTipItem:UnEquipPreview(InSuit)
    if InSuit < 1 then
        self.SuitTwoDes:SetColorAndOpacity(self.colhidd)
        self.SuitThreeDes:SetColorAndOpacity(self.colhidd)
    elseif InSuit == 1 then
        self.SuitTwoDes:SetColorAndOpacity(self.colpreview)
        self.SuitThreeDes:SetColorAndOpacity(self.colhidd)
    elseif InSuit >= 2 then
        self.SuitTwoDes:SetColorAndOpacity(self.colshow)
        self.SuitThreeDes:SetColorAndOpacity(self.colpreview)
    end
end
--- 已装备的后勤卡预览
---@param InSuit  integer 套装数
function LogiTipItem:EquipPreview(InSuit)
    if InSuit == 1 then
        self.SuitTwoDes:SetColorAndOpacity(self.colhidd)
        self.SuitThreeDes:SetColorAndOpacity(self.colhidd)
    elseif InSuit == 2 then
        self.SuitTwoDes:SetColorAndOpacity(self.colshow)
        self.SuitThreeDes:SetColorAndOpacity(self.colhidd)
    elseif InSuit >= 3 then
        self.SuitTwoDes:SetColorAndOpacity(self.colshow)
        self.SuitThreeDes:SetColorAndOpacity(self.colshow)
    end
end

--- 获取后勤卡技能
------@param InItem  UE4.UItem 后勤卡
function LogiTipItem:GetSkills(InItem)
    local tbSkill = UE4.TArray(UE4.int32)
    InItem:GetSkills(1, tbSkill)
    if tbSkill:Length() == 0 then
        print(string.format("get skill fail"))
        return
    end
    return tbSkill
end

--- 技能描述
---@param InItem  UE4.UItem 后勤卡
function LogiTipItem:SkillDesList(InItem)
    local SkillId = Logistics.GetSKill(InItem)
    self.TxtSkillLevel:SetText(Text("Lv")..99)
    self.TxtSkillName:SetText(SkillName(SkillId))
    self.TxtSkillDes1:SetContent(SkillDesc(SkillId))
end

function LogiTipItem:ItemTypeIcon(InType)
    -- SetTexture(self.ImgType,Item.SupportTypeIcon[InType])
end

function LogiTipItem:SetSupportAttrSystem(InSys)
    for index, value in ipairs(self.SupportSys) do
        WidgetUtils.Collapsed(value.Page)
        value.Click:SetIsChecked(false)
    end
    if InSys then
        WidgetUtils.SelfHitTestInvisible(self.SupportSys[InSys].Page)
        self.SupportSys[InSys].Click:SetIsChecked(true)
    end
end

function LogiTipItem:AfterEquipUpdate(InSCard, nEquipSuit)
    self:SetEquipModel(Logistics.OptionMode)
    self:SuitSkillDes(InSCard, nEquipSuit)
end

return LogiTipItem
