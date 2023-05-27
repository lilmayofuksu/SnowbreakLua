-- ========================================================
-- @File    : uw_rolebreak_all.lua
-- @Brief   : 角色突破详情展示
-- ========================================================

local tbBreakDetail = Class("UMG.BaseWidget")
function  tbBreakDetail:Construct()
    self.tbAttrs = {}
    local tbShowAttr = RBreak.GetAttrs()
    for i = 1, 8 do
        local tbCollect = {}
        tbCollect.pWidget = self["Attribute"..i]
        tbCollect.Attr = tbShowAttr[i]
        tbCollect.pPurple = self["Purple" .. i]

        table.insert(self.tbAttrs,tbCollect)
    end

    self.tbRound = {self.Image_18, self.Image_19, self.Image_20, self.Image_17}
    self.tbDot = {self.DotOriginal, self.Dot2, self.Dot4, self.Dot6}

    BtnAddEvent(self.BtnClose, function()
        UI.Close(self, self.clickCall)
    end)
end

function tbBreakDetail:OnOpen(tbParam)
    self.pCard = tbParam.Card
    if not self.pCard then
        return
    end
    self.skillId = tbParam.SkillId
    self.nIdx = tbParam.Idx or RBreak.GetProcess(self.pCard) + 1
    self.clickCall = tbParam.Click
    self:SkillDes(self.skillId)
    local InParam = {
        pRole = tbParam.Card,
        SkillId = tbParam.SkillId,
        SkillState =  tbParam.SkillState,
        bDetail = true,
    }
    self.Skill:OnOpen(InParam)
    self:ShowAttrLine(self.pCard)
    self:AttrDes(self.pCard)
end

function tbBreakDetail:SkillDes(InSkillId)
    local level = 1
    if self.nIdx == 4 then
        local MapLevelFix = UE4.UAbilityComponentBase.K2_GetSkillFixInfoStatic(InSkillId).SkillLevelFixMap
        local Keys = MapLevelFix:Keys()
        if Keys:Length()>0 then
            level = RoleCard.GetSkillLv(nil, Keys:Get(1), self.pCard)
        end
        if self.pCard:Break()/RBreak.NBreakLv < 4 then
            level = level + 1
        end
    end
    self.TxtSkillName:SetText(SkillName(InSkillId))
    self.TxtSkillIntro:SetContent(SkillDesc(InSkillId, nil, level))
    self.TxtSkillType:SetText(Text("ui.TxtPassiveSkill"))
end

-- 属性激活
function tbBreakDetail:AttrDes(InCard)
    local tbAttrs = RBreak.GetBreakAttrs(InCard, self.nIdx)
    for index, value in ipairs(tbAttrs) do
        local tbParam = {
            tbAtts = value,
            bActive = false,
        }
        if RBreak.GetProcess(InCard)>= self.nIdx then
            tbParam.bActive = true
        elseif RBreak.GetProcess(InCard)+1 == self.nIdx then
            if index<= (InCard:Break()%RBreak.NBreakLv) then
                tbParam.bActive = true
            else
                tbParam.bActive = false
            end
        else
            tbParam.bActive = false
        end
        self.tbAttrs[index].pWidget:Init(tbParam)
    end
end

--- 属性连线
function tbBreakDetail:ShowAttrLine(InCard)
    if not self.nIdx or not InCard then return end
    local nBreakLv = InCard:Break() % RBreak.NBreakLv
    local nPercent = 0
    local nProcess = RBreak.GetProcess(InCard)

    if nProcess >= self.nIdx then
        nPercent = 1
    else
        nPercent = 0.125 * nBreakLv
    end

    WidgetUtils.Collapsed(self.DotOriginal)
    if nProcess >= self.nIdx then
        for i = 1, 8 do
            ---解锁完成
            WidgetUtils.SelfHitTestInvisible(self.tbAttrs[i].pPurple)
        end
        for _, value in ipairs(self.tbRound) do
            WidgetUtils.Collapsed(value)
        end
        for _, value in ipairs(self.tbDot) do
            WidgetUtils.Collapsed(value)
        end
    elseif nBreakLv == 0 or nProcess+1 < self.nIdx then
        for i = 1, 8 do
            WidgetUtils.Hidden(self.tbAttrs[i].pPurple)
        end
        for _, value in ipairs(self.tbRound) do
            WidgetUtils.SelfHitTestInvisible(value)
        end
        for _, value in ipairs(self.tbDot) do
            WidgetUtils.Hidden(value)
        end
    else
        for i = 1, 8 do
            WidgetUtils.Collapsed(self.tbAttrs[i].pPurple)
            if i < nBreakLv then
                WidgetUtils.SelfHitTestInvisible(self.tbAttrs[i].pPurple)
            elseif i == nBreakLv then
                WidgetUtils.SelfHitTestInvisible(self.DotOriginal)
                WidgetUtils.SelfHitTestInvisible(self.tbAttrs[i].pPurple)
            end
        end
        WidgetUtils.SelfHitTestInvisible(self.tbDot[1])
        WidgetUtils.Collapsed(self.tbRound[1])
        for i = 1, 3 do
            if nBreakLv <= i*2 then
                WidgetUtils.SelfHitTestInvisible(self.tbDot[i+1])
                WidgetUtils.SelfHitTestInvisible(self.tbRound[i+1])
            else
                WidgetUtils.Collapsed(self.tbDot[i+1])
                WidgetUtils.Collapsed(self.tbRound[i+1])
            end
        end
    end

    if self.RoundWhite then
        local dynamicMat = self.RoundWhite:GetDynamicMaterial()
        if dynamicMat then
             dynamicMat:SetScalarParameterValue("Percent", nPercent)
        end
    end
end

return tbBreakDetail