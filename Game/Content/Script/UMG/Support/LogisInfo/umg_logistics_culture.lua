-- ========================================================
-- @File    : umg_logistics_culture.lua
-- @Brief   : 后勤养成界面
-- @Author  :
-- @Date    :
-- ========================================================

local umg_logistics_culture = Class("UMG.SubWidget")
local LogiCult = umg_logistics_culture
LogiCult.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"
LogiCult.SuitDesPath = "UMG.Support.LogiAffix.Widgets.uw_suitskill_des_data"
LogiCult.SatrPath = "UMG.Support.LogisticsShow.Widgets.uw_Logistics_star_data"
LogiCult.HiddsuitBG = UE4.FLinearColor(1, 1, 1, 1)
LogiCult.ShowsuitBG = UE4.FLinearColor(0, 0, 0.18, 1)
LogiCult.colshow = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1)
LogiCult.colhidd = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.4)

function LogiCult:Construct()
    self.pAttrItem = Model.Use(self, self.AttrPath)
    self.DesItem = Model.Use(self, self.SuitDesPath)
    self.pSatrItem = Model.Use(self, self.SatrPath)
    self.MainAttrItem = Model.Use(self)
end


function LogiCult:Tick(MyGeometry,InDelayTime)
    self.SpineL2d:Tick(InDelayTime)
end

function LogiCult:OnActive(pLogicCard)
    --- 播放All Enter动画
    self:PlayAnimation(self.AllEnter, 0, 1 ,UE4.EUMGSequencePlayMode.Forward, 1, false)
    self.pLogiCard = pLogicCard or Logistics.CulCard
    self.pRole = Logistics.CurRole

    EventSystem.TriggerTarget(Logistics, "SetSupportTexture", self.pLogiCard)
    self.AttrTip:OnOpen(self.pLogiCard, self.pRole and Logistics.GetSuitEquipNum(self.pLogiCard, self.pRole) or nil)
    WidgetUtils.Collapsed(self.AttrTip.BtnUp)
    WidgetUtils.Collapsed(self.AttrTip.BtnChange)
    WidgetUtils.Collapsed(self.AttrTip.Shadow)
    WidgetUtils.Collapsed(self.AttrTip.Image_12)
    -- self:SetSelfSkillDes(self.pLogiCard)
end

--- 属性列表
---@param InType integer 属性列表
function LogiCult:InfoAttrList(InItem)
    WidgetUtils.Collapsed(self.Attr1)
    WidgetUtils.Collapsed(self.Attr2)
    WidgetUtils.Collapsed(self.SubAttr1)
    WidgetUtils.Collapsed(self.SubAttr2)

    local MainAttrList = Logistics.GetMainAttr(InItem)
    local tbSubAttr = Logistics.GetSubAttr(InItem)
    for _, tbMainAttr in pairs(MainAttrList) do
        local tbMainParam = {
            nValue = tbMainAttr.Attr,
            sType = tbMainAttr.sType,
            sDes = Text(string.format('attribute.%s', tbMainAttr.sType)),
        }
        self["Attr".._]:Display(tbMainParam)
        WidgetUtils.HitTestInvisible(self["Attr".._])
    end
    if tbSubAttr then
        local tbSubParam = {
            nValue = tbSubAttr.Attr,
            sType = tbSubAttr.sType,
            sDes = Text(string.format('attribute.%s', tbSubAttr.sType)),
            IsPercent = tbSubAttr.IsPercent,
        }
        self.SubAttr1:Display(tbSubParam)
    end
    WidgetUtils.HitTestInvisible(self.SubAttr1)
end

function LogiCult:OnClick()
    --- 当前后勤卡
    if self.pLogiCard then
        if self.pLogiCard:Break() >= #Item.tbBreakLevelLimit[self.pLogiCard:BreakLimitID()] then
            UI.Open("LogiBreak", self.pLogiCard)
            return
        end
        if Logistics.GetCultType(self.pLogiCard) == 1 then
            UI.Open("LogiUp", self.pLogiCard)
            return
        end
        if Logistics.GetCultType(self.pLogiCard) == 2 then
            UI.Open("LogiBreak", self.pLogiCard)
            return
        end
    end
end

--- 等级
---@param InLv any 等级
function LogiCult:SetTextLv(InItem)
    self.TextLevel:SetText(InItem:EnhanceLevel())
end

--- 信任度
---@param InTrust  integer 信任度
function LogiCult:SetTextTrust(InItem)
    self.TxtTrust:SetText(InItem:Trust() .. "%")
end

--- 后勤名
---@param InName any 后勤卡名称
function LogiCult:SetTxtDes(InItem)
    if InItem then
        self.TextName:SetText(Text(InItem:I18N()))
        self.TxtType:SetText(Text(Logistics.tbTeamDes[InItem:Detail()]))
    end
end

function LogiCult:SetTxtDataDes(InItem)
    self.TxtLv:SetText(Text("ui.arms_lv2"))
    self.TxtNum:SetText(InItem:EnhanceLevel().."/99")
end

function LogiCult:SetIconDes(InItem)
    -- {1200000,1200001,1200002}
    local tbIcon = {
        {IconId = 1200002,pWidget = self.ImgType},
        {IconId = 1700035,pWidget = self.ImgRarity},
        {IconId = 1701021,pWidget = self.ImgCompany},
    }
    -- 
    for index, value in ipairs(tbIcon) do
        local TypeId = InItem:Icon()
        SetTexture(value.pWidget,TypeId,true)
    end
end

---后勤卡品质
---@param InQual integer 品质稀有度
function LogiCult:SetColor(InSupportCard)
    SetTexture(self.ImgRarity,Item.ItemInfoColorIcon[InSupportCard:Color()])
end

--- 后勤技能等级
---@param InLv integer 套装技能等级
function LogiCult:SetTxtSkillEvol(InLv)
    self.TxtSkillEvol:SetText(InLv)
end

--- 后勤技能套装
---@param InNum1 integer suitL
---@param InNum2 integer suitR
function LogiCult:SetTxtSkillSuit(InNum1, InNum2)
    self.SkillSuitL:SetText(InNum1 .. Text("ui.skillsuit"))
    self.SkillSuitR:SetText(InNum2 .. Text("ui.skillsuit"))
end

-- function LogiCult:ShowSuitSkill(InSuit)
--     local colorshow = UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1)
--     local colorhidd = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1)
--     self.SkillSuitL:SetColorAndOpacity(colorhidd)
--     self.SkillSuitR:SetColorAndOpacity(colorhidd)
--     if InSuit == 2 then
--         self.ImgTwoSuitBg:SetColorAndOpacity(self.ShowsuitBG)
--         self.ImgThiSuitBg:SetColorAndOpacity(self.HiddsuitBG)
--         self.SkillSuitL:SetColorAndOpacity(colorshow)
--         self.SkillSuitR:SetColorAndOpacity(colorhidd)
--         return
--     end
--     if InSuit == 3 then
--         self.ImgTwoSuitBg:SetColorAndOpacity(self.HiddsuitBG)
--         self.ImgThiSuitBg:SetColorAndOpacity(self.ShowsuitBG)
--         self.SkillSuitL:SetColorAndOpacity(colorhidd)
--         self.SkillSuitR:SetColorAndOpacity(colorshow)
--         -- self.TxtSuit3:SetColorAndOpacity(colorhidd)
--         -- self.TxtSuit3_2:SetColorAndOpacity(colorshow)
--         return
--     end
-- end

function LogiCult:SuitDes()
    self:DoClearListItems(self.ListSkill)
    local colorType = self.colshow
    for i = 1, 2 do
        if Logistics.GetSuitSkill(self.pLogiCard):Length() == 2 then
            if i == 1 then
                colorType = self.colshow
            end
            if i == 2 then
                colorType = self.colhidd
            end
        end
        local tbParam = {
            tbSkillId = self:GetSuitSkillId(i),
            InCol = colorType
        }
        local NewItem = self.DesItem:Create(tbParam)
        self.ListSkill:AddItem(NewItem)
    end
end

function LogiCult:GetSuitSkillId(InIndex)
    local tbTwoSuit, tbThirdSuit = Logistics.GetSuitSkill(self.pLogiCard)
    if InIndex == 1 then
        return tbTwoSuit
    end
    if InIndex == 2 then
        return tbThirdSuit
    end
end

--- 星级展示
---@param nStar  interge 需要展示的Intem
function LogiCult:SetStar(InStar)
    self.RoleStar:OnOpen({nStar = InStar,nLv =self.pLogiCard:EnhanceLevel(), bWeapon = false})
end


--- 角色卡logo描述
function LogiCult:SetLogo(InLogo,InLogoDes)
    self.LogoImg:SetBrushFromAtlasInterface(InLogo,true)
    self.LogoDesImg:SetBrushFromAtlasInterface(InLogoDes,true)

end

--- 后勤卡技能描述
function LogiCult:SetSelfSkillDes(InItem)
    local tbSkill = UE4.TArray(UE4.int32)
    InItem:GetSkills(1, tbSkill)
    if not tbSkill then
       return 
    end
    local nLevel = InItem:Break()+1
    for i = 1, tbSkill:Length() do
        local nSkillId = tbSkill:Get(1)
        self.TxtSkillInfo:SetText(SkillDesc(nSkillId, nil, nLevel))
        self.SkillName:SetText(SkillName(nSkillId))
    end
    self.TxtSkillLv:SetText(Text('ui.SkillLv').. nLevel)
end

function LogiCult:OnDisable()
    -- body
end

return LogiCult
