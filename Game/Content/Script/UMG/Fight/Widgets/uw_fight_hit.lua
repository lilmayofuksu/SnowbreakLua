-- ========================================================
-- @File    : uw_fight_joystick.lua
-- @Brief   : 战斗界面 命中表现
-- @Author  :
-- @Date    :
-- ========================================================

---@class uw_fight_hit :ULuaWidget
local uw_fight_hit = Class("UMG.SubWidget")

function uw_fight_hit:Construct()
    self:Clear()

    self:RegisterEvent(
        Event.CharacterFlyHP,
        function(InDamage)
            local Owner = self:GetOwningPlayerPawn()
            if Owner ~= InDamage.Launcher then
                return
            end
            self:Play(InDamage)
        end
    )
end

---@param InType EModifyHPResult
function uw_fight_hit:Play(InDamage)
    self:Clear()
    local CheckModifyResultFlag = UE4.UAbilityComponentBase.CheckModifyResultFlag
    local ModifyResult = InDamage.ModifyResult
    if CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Crit) then
        self:PlayAnim(self.Crit, self.Crit_Anim)    
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Heal) then
        self:PlayAnim(self.Hit, self.Hit_Anim)
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Miss) then
        self:PlayAnim(self.Hit, self.Hit_Anim)
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Hit) then
        self:PlayAnim(self.Hit, self.Hit_Anim)
    end
end

function uw_fight_hit:Clear()
    self:StopAllAnimations()
    --
    self.Hit:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Crit:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Kill:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Block:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

---播放动画
function uw_fight_hit:PlayAnim(InNode, InAnim)
    InNode:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:UnbindAllFromAnimationFinished(InAnim)

    self:BindToAnimationEvent(
        InAnim,
        {
            self,
            function()
                InNode:SetVisibility(UE4.ESlateVisibility.Collapsed)
            end
        },
        UE4.EWidgetAnimationEvent.Finished
    )

    self:PlayAnimation(InAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end

return uw_fight_hit
