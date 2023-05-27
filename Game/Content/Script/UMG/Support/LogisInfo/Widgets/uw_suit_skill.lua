-- ========================================================
-- @File    : uw_suit_skill.lua
-- @Brief   : 后勤养成套装技能描述
-- @Author  :
-- @Date    :
-- ========================================================

local tbSuitSkill = Class("UMG.SubWidget")

function tbSuitSkill:Construct()
    
    self.tbSubAttrSys = {
        {Click = self.CheckSkill,Page = self.PanelSkill,DesTxt = self.TxtLogisSkill},
        {Click = self.CheckSuit,Page = self.PanelSuit,DesTxt = self.TxtLogisSuitOn},
        {Click = self.CheckAffix,Page = self.PanelAffix,DesTxt = self.TxtLogisAffixOn},
    }

    for index, value in ipairs(self.tbSubAttrSys) do
        value.Click.OnCheckStateChanged:Add(
            self,
            function()
                self:SetSupportAttrSystem(index)
                value.Click:SetIsChecked(true)
                WidgetUtils.SelfHitTestInvisible(value.Page)
            end
        )
    end
    self:OnInit()
end

--- 初始化，默认显示两件套套装技能描述
function tbSuitSkill:OnInit()
    -- self:SuitState(self.CheckSuit2, 0)
    -- self:SuitState(self.CheckSuit3, 1)
    -- WidgetUtils.Hidden(self.TxtSuitIntro3)
    self:SetSupportAttrSystem(2)
end

function tbSuitSkill:OnActive(InCard)
    --- 套装技能
    self:InfoSuitSkillDes(InCard)
    --- 后勤卡技能描述
    self:SkillDesList(InCard)
    --- 后勤卡词缀
    self:AffixDesList(InCard)
end

--- 套装技能描述
---@param InSuitIndex integer 套装Id
---@param InSkillId integer 技能Id
function tbSuitSkill:SuitState(InCheckBox, nState)
    local colorshow = UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1)
    local colorhidd = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1)
    if nState==0  then
        InCheckBox:SetCheckedState(1)
        InCheckBox:GetChildAt(0):SetColorAndOpacity(colorhidd)
    else
        InCheckBox:SetCheckedState(0)
        InCheckBox:GetChildAt(0):SetColorAndOpacity(colorshow)
    end
end

--- 套装技能描述
function tbSuitSkill:InfoSuitSkillDes(InItem)
    local tbSuit = { self.TxtSuitDes1,self.TxtSuitDes2,}
    for index, value in ipairs(tbSuit) do
        local SuitSkillId = UE4.TArray(UE4.int32)
        InItem:GetSuitFirstSkills(2, SuitSkillId)
        InItem:GetSuitFirstSkills(3, SuitSkillId)
        value:SetContent(SkillDesc(SuitSkillId:Get(index)))
        self.TxtSuitName:SetText(SkillName(SuitSkillId:Get(index))) 
    end
end

--- 技能描述
---@param InItem  UE4.UItem 后勤卡
function tbSuitSkill:SkillDesList(InItem)
    local SkillId = Logistics.GetSKill(InItem)
    if not SkillId then
        print("SuitSkillId_Error")
        return
    end
    self.TxtSkillLevel:SetText(Text("Lv")..99)
    self.TxtSkillName:SetText(SkillName(SkillId))
    self.TxtSkillDes1:SetContent(SkillDesc(SkillId))
end

function tbSuitSkill:SetSupportAttrSystem(InSys)
    for index, value in ipairs(self.tbSubAttrSys) do
        WidgetUtils.Collapsed(value.Page)
        value.Click:SetIsChecked(false)
        value.DesTxt:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1,1,1,1))
    end

    if InSys then
        WidgetUtils.SelfHitTestInvisible(self.tbSubAttrSys[InSys].Page)
        self.tbSubAttrSys[InSys].Click:SetIsChecked(true)
        self.tbSubAttrSys[InSys].DesTxt:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0,0,0,1))
    end
   
end

--- 词缀描述
---@param InItem  UE4.UItem 后勤卡
function tbSuitSkill:AffixDesList(InItem)
    for i = 1, 3 do
        local affixs = InItem:GetAffix(i)
        self["TxtAffixDes"..i]:SetContent(Logistics.GetAffixShowNameByTarray(affixs))
    end
end
return tbSuitSkill