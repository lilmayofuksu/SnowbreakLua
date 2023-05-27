-- ========================================================
-- @File    : EmitterRay.lua
-- @Brief   : 射线的发生器,表现和一般发生器区别较大
-- @Author  : XiongHongJi
-- @Date    : 2020-06-8
-- ========================================================


---@class USkillEmitter_EmitterRay:USkillEmitter
local EmitterRay = Class();

function EmitterRay:GetAimLocation(StartTransform)
    local AimLocation = UE4.UKismetMathLibrary.Conv_RotatorToVector(StartTransform.Rotation:ToRotator()) * 10000.0 + StartTransform.Translation;
    -- if self.QueryResults:Length() > 0 then
    --     local Num = self.ActiveTimes % self.QueryResults:Length() + 1
    --     AimLocation = self.QueryResults:Get(Num).QueryPoint;
    --     -- AimLocation = AimLocation + UE4.UKismetMathLibrary.Multiply_VectorFloat(AimLocation - StartTransform.Translation , 100);
    -- end

    -- if self.InheritResults:Length() > 0 then
    --     local Num = self.ActiveTimes % self.InheritResults:Length() + 1
    --     AimLocation = self.InheritResults:Get(Num).QueryPoint;
    --     AimLocation = AimLocation + UE4.UKismetMathLibrary.Multiply_VectorFloat(AimLocation - StartTransform.Translation , 100);
    -- end
    
    if self:GetNextApplyResultByEffectPriority().bValid == true then
        AimLocation = self:GetNextApplyResultByEffectPriority().QueryPoint;
        AimLocation = AimLocation + UE4.UKismetMathLibrary.Multiply_VectorFloat(AimLocation - StartTransform.Translation , 100);
    end

    return AimLocation;
end

function EmitterRay:OnEmitBegin()
    local RayDistance = -1.0
    local ParamsLength = self:GetParamLength()
    if ParamsLength > 0 then
        RayDistance = self:GetParamfloatValue(0)
    end

    local BulletID = 0
    if self:GetEmitterInfo().BulletSettings:Length() > 0 then
        BulletID = self:GetEmitterInfo().BulletSettings:Get(1).BulletID
    end
    UE4.UAbilityComponentBase.LoadBulletInfoStatic(BulletID, self.RayInfo, self:GetAbilityOwner());
    self:CreateRayParticle();
    local CT = EmitterSearcher:GetCenterTransform(self);
    self:EmitTickRay(CT, self.RayInfo, false, RayDistance);
end

function EmitterRay:OnEmitTick()
    local RayDistance = -1.0
    local ParamsLength = self:GetParamLength()
    if ParamsLength > 0 then
        RayDistance = self:GetParamfloatValue(0)
    end

    local CT = EmitterSearcher:GetCenterTransform(self);
    self:EmitTickRay(CT, self.RayInfo, false, RayDistance);
end

function EmitterRay:OnEmitSearch()
end

function EmitterRay:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

---@param Skill USkill
function EmitterRay:OnEmit()
    local EmitterInfo = self:GetEmitterInfo()
    local CT = EmitterSearcher:GetCenterTransform(self);
    local StartTransform = UE4.FTransform();
    if CT:Length() > 0 then
        StartTransform = CT:Get(1);
    end

    local SpawnSocketName = EmitterInfo.BulletSettings:Get(1).BulletSocket
    if SpawnSocketName ~= nil then
        local SocketTransform = UE4.FTransform()
        local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
        if bHasSocket then
            StartTransform = SocketTransform
        end
    end
    local AimLocation = self:GetAimLocation(StartTransform);
    local HitResult =
    UE4.UAbilityFunctionLibrary.LineTraceSingle(
    StartTransform.Translation,
    AimLocation,
    self.RayInfo.BulletChannel,
    self:GetInstigator())
    if HitResult.bBlockingHit and HitResult.Actor ~= nil then
        self:AddQueryResult(HitResult.Actor,HitResult.ImpactPoint);
        local Result = UE4.UAbilityFunctionLibrary.MakeQueryResult_SpecificLocation(HitResult.Actor, HitResult.ImpactPoint);
        UE4.ABullet.BulletApplyEffect(self:GetAbilityOwner(), StartTransform.Translation, self.RayInfo, HitResult.Actor, HitResult, self:GetSkillLevel(), self, nil);
    else
        self:AddQueryResult(nil,AimLocation);
    end


    return UE4.EEmitterResult.Finish;
end

function EmitterRay:EmitterDestroyLua()
    self:Destroy()
end
return EmitterRay;

