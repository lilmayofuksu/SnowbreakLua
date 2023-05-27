-- ========================================================
-- @File    : BulletScreen_410402.lua
-- @Brief   : 弹幕发射器
-- @Author  : 
-- @Date    : 
-- ========================================================

---@class ABulletScreenEditor
local ScreenEditor = Class()
function ScreenEditor.RandomFloat(m, n)
    return m + (n-m) * math.random()
end
function ScreenEditor:OnCalcBulletLocAndRot()
    if self.OwnerActor then
        local OwnerCharacter = self.OwnerActor:Cast(UE4.AGameCharacter)
        if OwnerCharacter then
            self.GenerateLocation = OwnerCharacter.Mesh:GetSocketLocation("FireSocket02")
        end
    end
    if self.Target then
        self:CalcRot(self.OwnerActor, self.Target, self.GenerateLocation)
    end
    self.GenerateScale = UE4.FVector(1.0, 1.0, 1.0)
    self.GenerateTransform = UE4.UKismetMathLibrary.MakeTransform(self.GenerateLocation, self.GenerateRotation, self.GenerateScale)
end

function ScreenEditor:CalcRot(Owner, Target, Loc)
    local ZeroVector = UE4.FVector(0, 0, 0)
    local OwnerCharacter = Owner:Cast(UE4.AGameAICharacter)
    if OwnerCharacter and OwnerCharacter.Ability then
        local SkillId = OwnerCharacter.Ability:GetCastingSkillIDInAnim()
        if SkillId == 4104201 or SkillId == 4104203 or SkillId == 4104204 or SkillId == 4104401 or SkillId == 4104402 then
            self.LeftRight = true
        elseif SkillId == 4104202 or SkillId == 4104205 or SkillId == 4104206 then
            self.LeftRight = false
        end
    end    
    if self.GenerateCount >= (self.TotalCount/2) then
        self.GenerateRotation = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UE4.UKismetMathLibrary.RandomUnitVectorInConeInDegrees(UE4.FVector(1, 0, 0), 90))
    else
        local TargetLoc = Target:K2_GetActorLocation()
        
        local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UE4.UKismetMathLibrary.Normal(TargetLoc - Loc))
        local RightVector = UE4.UKismetMathLibrary.GetRightVector(Rot)
        local lerp = self.GenerateCount/4.0    
        local r = self.LeftRight and UE4.UKismetMathLibrary.Lerp(-50, 50, lerp) or UE4.UKismetMathLibrary.Lerp(50, -50, lerp)
        local Vec = TargetLoc + RightVector * r + UE4.UKismetMathLibrary.GetUpVector(Rot) * self.RandomFloat(-100, 100)
        self.GenerateRotation = UE4.UKismetMathLibrary.FindLookAtRotation(Loc, Vec)
    end
end

return ScreenEditor
