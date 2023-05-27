-- ========================================================
-- @File    : uw_rolebreak_skill.lua
-- @Brief   : 突破提示属性
-- @Author  :
-- @Date    :
-- ========================================================


local DesSkill=Class("UMG.SubWidget")
DesSkill.tbBreakLvDes = {
    {nPercent   = 0,    nAngle  = -130 },
    {nPercent   = 0.12, nAngle  = -89  },
    {nPercent   = 0.24, nAngle  = -48  },
    {nPercent   = 0.36, nAngle  = -7   },
    {nPercent   = 0.48, nAngle  = 34   },
    {nPercent   = 0.6,  nAngle  = 75   },
    {nPercent   = 0.72, nAngle  = 116  },
    {nPercent   = 0.84, nAngle  = 170  },
}
DesSkill.OnClick="ON_CLICK"
function  DesSkill:Construct()
    WidgetUtils.Hidden(self.On)
    self.ImgBg.OnMouseButtonDownEvent:Bind(self, DesSkill.DownFun)
    self.ImgNot.OnMouseButtonDownEvent:Bind(self, DesSkill.DownFun)

    self.BtnSelect.OnClicked:Add(
        self,
        function()
            if self.ClickDetail then
                self.ClickDetail(self.SkillId,self.SkillState)
            end
        end
    )

    --- 初始化被动技能名
    self:SetSkillName(1001)
end

function DesSkill:DownFun()
    EventSystem.TriggerTarget(self,self.OnClick)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

--- 技能详情入口
function DesSkill:OnOpen(InParam)
    self.ClickDetail = InParam.Click
    self.SkillId = InParam.SkillId
    self.SkillState = InParam.SkillState
    self.pCard = InParam.pRole
    self.bPreBreak = InParam.bPreBreak
    self.nIdx = InParam.Idx
    self:SetSkillName(self.SkillId)
    self:SetSkillIcon(self.SkillId)
    self:ShowSkillState(self.SkillState)
    -- self:BreakLv(2)
end

--- 技能名称
---@param InName string 技能名
function DesSkill:SetSkillName(InId)
    if not InId then
        self.TxtSkillName:SetText('')
        return
    end
    self.SkillId = InId
    self.TxtSkillName:SetText(SkillName(InId))
end

---设置技能Icon
---@param InTexture UTexture2D 技能Icon资源
function DesSkill:SetSkillIcon(InId)
    -- self.ImgSkill:SetBrushFromTexture(InTexture)
    local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(InId)
    SetTexture(self.ImgSkillOn,sIcon)
    SetTexture(self.ImgSkill,sIcon)
end

--- 技能的三种状态激活，预览，锁定
function DesSkill:ShowSkillState(InState)
    local nBreakLv = 1
    WidgetUtils.Collapsed(self.Not)
    WidgetUtils.Collapsed(self.On)
    WidgetUtils.Collapsed(self.Next)
    WidgetUtils.Hidden(self.Phase8)
    WidgetUtils.Collapsed(self.Phase9)
    WidgetUtils.Collapsed(self.Num)
    WidgetUtils.Collapsed(self.ImgSkill1On)
    WidgetUtils.SelfHitTestInvisible(self.ImgRound)

    -- if self.nIdx == 1 then
    --     WidgetUtils.Collapsed(self.ImgRound)
    --     if InState == BreakState.Actived then
    --         WidgetUtils.SelfHitTestInvisible(self.ImgSkill1On)
    --         WidgetUtils.SelfHitTestInvisible(self.On)
    --     else
    --         WidgetUtils.SelfHitTestInvisible(self.Not)
    --     end
    --     return
    -- end

    --- 激活
    if self.pCard then
        nBreakLv = self.pCard:Break()%RBreak.NBreakLv
        self:BreakLv(nBreakLv+1)
        self:BreakLvDes(nBreakLv)
    end

    if InState == RBreak.BreakState.Actived then
        WidgetUtils.SelfHitTestInvisible(self.On)
    end

    if InState == RBreak.BreakState.InActivated then
        WidgetUtils.SelfHitTestInvisible(self.Num)
        WidgetUtils.SelfHitTestInvisible(self.Next)
        WidgetUtils.SelfHitTestInvisible(self.Not)
        if nBreakLv < RBreak.NBreakLv-1 then
            WidgetUtils.SelfHitTestInvisible(self.Phase8)
        end
        if nBreakLv == RBreak.NBreakLv-1 then
            WidgetUtils.SelfHitTestInvisible(self.Phase9)
            self:PlayAnimation(self.AllLoop, 0, 9999, UE4.EUMGSequencePlayMode.Forward, 1, true)
        end
    end

    --- 预览
    if InState == RBreak.BreakState.PreActive then
        WidgetUtils.SelfHitTestInvisible(self.Not)
    end

    --- 锁定
    if InState == RBreak.BreakState.UnActive then
        WidgetUtils.SelfHitTestInvisible(self.Not)
    end

end


--- 走统一入口(OnOpen)
function DesSkill:ShowBreakSkill(InState)
end

--- 相位表现
function DesSkill:BreakLv(InLv)
    if self.tbBreakLvDes[InLv] then
        self.CurrentRound:SetRenderTransformAngle(self.tbBreakLvDes[InLv].nAngle)
        self:Percent(self.YellowRound,self.tbBreakLvDes[InLv].nPercent)
    end
end

--- Break等级表现
function DesSkill:BreakLvDes(InLv)
    self.TxtNum:SetText(InLv.."/"..RBreak.NBreakLv)
end

function DesSkill:OnDestruct()
    EventSystem.RemoveAllByTarget(self)
end

return DesSkill