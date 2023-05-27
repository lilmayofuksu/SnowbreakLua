-- ========================================================
-- @File    : uw_fight_cross.lua
-- @Brief   : 十字准心
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_collimation = Class("UMG.SubWidget")

local CrossHair = uw_fight_collimation

local CrossHairType={
    Normal=1,       --默认
    Hit=2,          --击中
    Shield=3,       --护盾
    Vital=4,        --击中要害
    Kill=5,         --死亡
}


function CrossHair:Construct()
    self:Clear()
    self:ChangeType(CrossHairType.Normal)
    self:RegisterEvent(
        Event.CharacterFlyHP,
        function(InDamage)
            local Owner = self:GetOwningPlayerPawn()
            if Owner ~= InDamage.Launcher then
                return
            end
            self:SetType(InDamage)
        end
    )

end

function CrossHair:Tick(MyGeometry, InDeltaTime)
  
end

function CrossHair:ChangeType(InType)
    local OwnerPlayer = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    local CurCrossType=OwnerPlayer:GetWeapon().WeaponInfo.WeaponType

end

function CrossHair:SetType(InDamage)
    local OwnerPlayer = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if not OwnerPlayer then
       return
    end
    self:Clear()
    local CheckModifyResultFlag = UE4.UAbilityComponentBase.CheckModifyResultFlag
    local ModifyResult=InDamage.ModifyResult
    if InDamage.Target:IsDead() then                                    --击杀   
        self:PlayAnim(self.GroupDie,self.Animation_Hit)
        --Audio.PlaySounds(self.KillSound)
        return
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Weakness) then                    --弱点，要害
        self:PlayAnim(self.Group_Aim,self.KeyAim) 
        return
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.ReduceDamage) then                    --减伤
        self:PlayAnim(self.Group_Inefficiency,self.Inefficiency)
        return
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Destructible_Accessory) then          --可破坏
        self:PlayAnim(self.Group_Destructible,self.Aim_Destructible)
        return
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Miss) then                           --护盾
        self:PlayAnim(self.Group_Inefficiency,self.Inefficiency)
        return
    elseif CheckModifyResultFlag(ModifyResult, UE4.EModifyHPResult.Hit) then                          --击中
        self:PlayAnim(self.Group_Hit_1,self.Animhit)
        Audio.PlaySounds(self.HitSound)
        return  
    end

end

---@param InWidget UCanvasPanel
function CrossHair:GetChildrens(InWidget)
    local AllChilds= InWidget:GetAllChildren()
    return AllChilds
end

function CrossHair:Clear()
    self:StopAllAnimations()
    WidgetUtils.Collapsed(self.GroupDie)                   --击杀
    WidgetUtils.Collapsed(self.Group_Aim)               --击中要害
    WidgetUtils.Collapsed(self.Group_Hit_1)               --击中
    WidgetUtils.Collapsed(self.Group_Inefficiency)      --击中护盾
    WidgetUtils.Collapsed(self.Group_Destructible)

end

function CrossHair:PlayAnim(InNode, InAnim)
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

return CrossHair