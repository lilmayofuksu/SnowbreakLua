-- ========================================================
-- @File    : uw_fight_warning
-- @Brief   : Tip状态
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_warning = Class("UMG.SubWidget")

local WarnTip=uw_fight_warning
WarnTip.bOver=false
WarnTip.bUnShild=false
function WarnTip:Construct()
    self:Init()
    local CurPawn = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if CurPawn then
    CurPawn.OnReloadWeapon:Add(
        self,
        function(Target,bIsReload,TotalTime)
            self:Init()
            self:SetShow(bIsReload,self.Reload)
        end
    )
    end


end

function WarnTip:Tick(MyGeometry, InDeltaTime)
   local PlayerPawn = self:GetOwningPlayerPawn()
    if not PlayerPawn then return end

    local OwnPawn = PlayerPawn:Cast(UE4.AGameCharacter)

    if not OwnPawn then return end
    local CurCross=OwnPawn:GetWeapon()
   
    
    if OwnPawn and OwnPawn.Ability then
         --overload tip
        local Shield = OwnPawn.Ability:GetRolePropertieValue(UE4.EAttributeType.Shield)
        if  Shield<=0 then
            -- self:PlayAnim(self.GroupUnShield,self.UnShieldAnim)
            -- self:SetShow(true,self.Imgbg_fill)
            -- if not self.bUnShild then
            --     UE4.UWwiseLibrary.PostEvent2D(self,'Play_Sound_girl004_overload')
            --     self.bUnShild=true
            --     print('Sound bUnShild')
            -- end
        else
            self:SetShow(false,self.Imgbg_fill)
            self:SetShow(false,self.GroupUnShield)
            self:StopAnimation(self.UnShieldAnim)
            self.bUnShild=false
        end

        --UnShiled Tip
        if not CurCross.bActive then
            if CurCross.m_fOverloadValue>0 then
                self:PlayAnim(self.GroupUnoverload,self.UnoverloadAnim)
                if not self.bOver then
                    UE4.UWwiseLibrary.PostEvent2D(self,'Play_Sound_girl004_overload')
                    self.bOver=true
                    print('Sound bOver')
                end
            end
           
        else
            self:SetShow(false,self.GroupUnoverload)
            self:StopAnimation(self.UnoverloadAnim)
            self.bOver=false
        end
    end

end


function WarnTip:Init()
    self:SetShow(false,self.GroupUnShield)
    self:SetShow(false,self.GroupUnoverload)
    self:SetShow(false,self.Reload)
    self:SetShow(false, self.Imgbg_fill)
end

function WarnTip:SetShow(bValue,InObj)
    if bValue then
        WidgetUtils.SelfHitTestInvisible(InObj)
    else
        WidgetUtils.Collapsed(InObj)
    end
end

function WarnTip:PlayAnim(InNode,InAnim)
    InNode:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:UnbindAllFromAnimationFinished(InAnim)
    if not self:IsAnimationPlaying(InAnim) then
        self:PlayAnimation(InAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end




return WarnTip
