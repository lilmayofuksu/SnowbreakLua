-- ========================================================
-- @File    : MultiEmitterRay.lua
-- @Brief   : 多重检测的射线发生器,表现和一般发生器区别较大
-- @Author  : XiongHongJi
-- @Date    : 2022-04-12
-- ========================================================


---@class USkillEmitter_MultiEmitterRay:USkillEmitter
local MultiEmitterRay = Class();

function MultiEmitterRay:GetAimLocation(StartTransform)
    local AimLocation = UE4.UKismetMathLibrary.Conv_RotatorToVector(StartTransform.Rotation:ToRotator()) * 10000.0 + StartTransform.Translation;

    if self:GetNextApplyResultByEffectPriority().bValid then
        AimLocation = self:GetNextApplyResultByEffectPriority().QueryPoint;
        AimLocation = AimLocation + UE4.UKismetMathLibrary.Multiply_VectorFloat(AimLocation - StartTransform.Translation , 100);
    end
    
    return AimLocation;
end

function MultiEmitterRay:OnEmitBegin()
    
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
    if CT:Length() > 0 then
        self:EmitTickRay(CT:Get(1), self.RayInfo, true, RayDistance);
    end
end

function MultiEmitterRay:OnEmitTick()
    local RayDistance = -1.0
    local ParamsLength = self:GetParamLength()
    if ParamsLength > 0 then
        RayDistance = self:GetParamfloatValue(0)
    end

    local CT = EmitterSearcher:GetCenterTransform(self);
    if CT:Length() > 0 then
        self:EmitTickRay(CT:Get(1), self.RayInfo, true, RayDistance);
    end
end

function MultiEmitterRay:OnEmitSearch()
end

function MultiEmitterRay:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function MultiEmitterRay:OnEmit()
    local EmitterInfo = self:GetEmitterInfo()
    local CT = EmitterSearcher:GetCenterTransform(self);
    if CT:Length() > 0 then
        local StartTransform = CT:Get(1);
        local SpawnSocketName = EmitterInfo.BulletSettings:Get(1).BulletSocket
        if SpawnSocketName ~= nil then
            local SocketTransform = UE4.FTransform()
            local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
            if bHasSocket then
                StartTransform.Translation = SocketTransform.Translation
                StartTransform.Rotation = SocketTransform.Rotation
            end
        end
        local AimLocation = self:GetAimLocation(StartTransform);
        local HitResults =
        UE4.UAbilityFunctionLibrary.LineTraceMulti(
        StartTransform.Translation,
        AimLocation,
        self.RayInfo.BulletChannel,
        self:GetInstigator())
    
        if HitResults:Length() > 0 then
            for i = 1, HitResults:Length() do
                local Result = HitResults:Get(i);
                if Result.bBlockingHit and Result.Actor ~= nil then
                    self:AddQueryResult(Result.Actor,Result.ImpactPoint);
                    -- local QueryResult = UE4.UAbilityFunctionLibrary.MakeQueryResult_SpecificLocation(Result.Actor, Result.ImpactPoint);
                    UE4.ABullet.BulletApplyEffect(self:GetAbilityOwner(), StartTransform.Translation, self.RayInfo, Result.Actor, Result, self:GetSkillLevel(), self, nil);
                end
            end
        end
    end

    return UE4.EEmitterResult.Finish;
end

function MultiEmitterRay:EmitterDestroyLua()
    self:Destroy()
end
return MultiEmitterRay;

