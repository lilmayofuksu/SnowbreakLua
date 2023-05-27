-- ========================================================
-- @File    : uw_widgets_logistics_suitinfo.lua
-- @Brief   : 角色后勤套装技能列表
-- @Author  :
-- @Date    :
-- ========================================================

local  tbSuitInfo = Class("UMG.SubWidget")

function tbSuitInfo:Construct()
    self.tbSuitSkill = {
        {Widget = self.PanelSuit2, ActiveWidget = {self.Activity, self.NoActivity}, DesWidget = {self.TxtSuitInfo2, self.TxtSuitInfo2_1}},
        {Widget = self.PanelSuit3, ActiveWidget = {self.Activity2, self.NoActivity2}, DesWidget = {self.TxtSuitInfo3, self.TxtSuitInfo3_1}},
    }
end

--- 套装技能激活
---@param IntbSuit table 套装技能对应ID
---@param InFrom Interge 父级UI 1:角色Page页签,2:详情页签,3:后勤列表界面
function tbSuitInfo:OnActive(IntbSuit, InFrom, nEquipNum)
    --- 角色Page页签
    if InFrom and InFrom == 1 then
        self:Init()
        self:ShowSuitSkill(IntbSuit)
    end

    if InFrom and InFrom == 2 then
        WidgetUtils.Collapsed(self.PanelSuitEmpty)
        self:ShowUnActiveSuitSkill(IntbSuit)
    end

    --- 参数为卡
    if InFrom and InFrom == 3 then
        WidgetUtils.Collapsed(self.PanelSuitEmpty)
        self:ShowAllSuitSkill(IntbSuit, nEquipNum)
    end
    self:PlayAnimation(self.AllEnter)
end

--- 初始化关闭显示
function tbSuitInfo:Init()
    for index, value in ipairs(self.tbSuitSkill) do
        WidgetUtils.Collapsed(value.Widget)
        for _, Widget in pairs(value.ActiveWidget) do
            WidgetUtils.Collapsed(Widget)
        end
        WidgetUtils.Collapsed(self.PanelSuitEmpty)
        WidgetUtils.Collapsed(self.TxtSuitName)
    end
end

function tbSuitInfo:SuitTitle(InStr)
    self.TxtSuitName:SetText(InStr)
end

--- 显示所有套装技能，切换激活状态
function tbSuitInfo:ShowDetailSuitSkill(InSuit)
    for index, value in ipairs(self.tbSuitSkill) do
        WidgetUtils.SelfHitTestInvisible(value.Widget)
        WidgetUtils.SelfHitTestInvisible(value.ActiveWidget[1])
        value.DesWidget[1]:SetText('InSkillId'..InSuit[index])
    end
end

--- 显示激活套装技能
---@param InType Enum AttrSign
function tbSuitInfo:ShowSuitSkill(IntbSuit)
    for index, value in ipairs(IntbSuit) do
        if self.tbSuitSkill[index] then
            WidgetUtils.SelfHitTestInvisible(self.tbSuitSkill[index].Widget)
            WidgetUtils.SelfHitTestInvisible(self.tbSuitSkill[index].ActiveWidget[1])
            self.tbSuitSkill[index].DesWidget[1]:SetContent(SkillDesc(value))
            self:SuitTitle(SkillName(value))
        end
        WidgetUtils.SelfHitTestInvisible(self.TxtSuitName)
    end

    local nSuit = #IntbSuit
    self.TxtNum:SetText(string.format("(%d/3)", nSuit == 0 and 0 or nSuit + 1))

    if nSuit == 0 then
        WidgetUtils.Collapsed(self.PanelSuitBox)
        WidgetUtils.SelfHitTestInvisible(self.PanelSuitEmpty)
    else
        WidgetUtils.Collapsed(self.PanelSuitEmpty)
        WidgetUtils.SelfHitTestInvisible(self.PanelSuitBox)
    end
end

---未激活套装显示
---@param InType Enum AttrSign
function tbSuitInfo:ShowUnActiveSuitSkill(InSupportCard)
    local SuitSkillId = UE4.TArray(UE4.int32)
    InSupportCard:GetSuitFirstSkills(2, SuitSkillId)
    InSupportCard:GetSuitFirstSkills(3, SuitSkillId)
    for index, value in ipairs(self.tbSuitSkill) do
        WidgetUtils.Collapsed(value.ActiveWidget[1])
        WidgetUtils.SelfHitTestInvisible(value.ActiveWidget[2])
        value.DesWidget[2]:SetContent(SkillDesc(SuitSkillId:Get(index)))
        self:SuitTitle(SkillName(SuitSkillId:Get(index)))
    end
end

function tbSuitInfo:ShowAllSuitSkill(InCard, tbInParam)
    local nEquipNum = 0
    local EquipSelect = false
    if type(tbInParam) == "table" and tbInParam.EquipSuitNum then
        nEquipNum = tbInParam.EquipSuitNum
    end
    if type(tbInParam) == "table" and tbInParam.EquipSelect then
        EquipSelect = tbInParam.EquipSelect
    end
    local SuitSkillId = UE4.TArray(UE4.int32)
    self.TxtNum:SetText(string.format("(%d/3)", nEquipNum))

    InCard:GetSuitFirstSkills(2, SuitSkillId)
    InCard:GetSuitFirstSkills(3, SuitSkillId)

    for index, value in ipairs(self.tbSuitSkill) do
        WidgetUtils.Collapsed(value.ActiveWidget[1])
        WidgetUtils.SelfHitTestInvisible(value.ActiveWidget[2])
        value.DesWidget[2]:SetContent(SkillDesc(SuitSkillId:Get(index)))
        self:SuitTitle(SkillName(SuitSkillId:Get(index)))

        if index <= nEquipNum - 1 then
            WidgetUtils.SelfHitTestInvisible(value.ActiveWidget[1])
            WidgetUtils.Collapsed(value.ActiveWidget[2])
            value.DesWidget[1]:SetContent(SkillDesc(SuitSkillId:Get(index)))
        else
            if not EquipSelect and nEquipNum >= 1 then
                WidgetUtils.Collapsed(value.ActiveWidget[1])
                WidgetUtils.SelfHitTestInvisible(value.ActiveWidget[2])
                EquipSelect = true
            end
        end
    end
end

return tbSuitInfo
