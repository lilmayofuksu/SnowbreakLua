-- ========================================================
-- @File    : MultiTraceLineLaser.lua
-- @Brief   : 射线的发生器,表现和一般发生器区别较大
-- @Author  : XiongHongJi
-- @Date    : 2020-06-8
-- ========================================================


---@class USkillEmitter_MultiTraceLineLaser:USkillEmitter
local MultiTraceLineLaser = Class();

function MultiTraceLineLaser:GetAimLocation(StartTransform)
    local AimLocation = UE4.UKismetMathLibrary.Conv_RotatorToVector(StartTransform.Rotation:ToRotator()) * 10000.0 + StartTransform.Translation;

    if self:GetNextApplyResultByEffectPriority().bValid then
        AimLocation = self:GetNextApplyResultByEffectPriority().QueryPoint;
        AimLocation = AimLocation + UE4.UKismetMathLibrary.Multiply_VectorFloat(AimLocation - StartTransform.Translation , 100);
    end

    return AimLocation;
end

function MultiTraceLineLaser:OnEmitBegin()
    if self:GetEmitterInfo().BulletSettings:Length() > 0 then
        UE4.UAbilityComponentBase.LoadBulletInfoStatic(self:GetEmitterInfo().BulletSettings:Get(1).BulletID , self.RayInfo, self:GetAbilityOwner());
        self:CreateRayParticle();
    end
end


function MultiTraceLineLaser:OnEmitTick()

    local Results = UE4.TArray(UE4.FQueryResult);
    UE4.USkillEmitter.SearchTargetsWithEmitterInfo(self.QueryResults, self:GetEmitterInfo(), self:GetAbilityOwner(), self:GetGameSkillOwner(), self, self:GetGameSkillOwner():GetLauncher())

    local LineTraceShape = self.RayInfo.TraceShape;
    local TraceWidth = LineTraceShape.X;
    local TraceHeight = LineTraceShape.Y;
    local LineWidthNum = self.RayInfo.WidthTraceNum;
    local LineHeightNum = self.RayInfo.WidthHeightNum;
    local TraceType = self:GetParamintValue(0)
    local MaxDistance = self:GetParamfloatValue(1)

    local EmitterInfo = self:GetEmitterInfo()
    local CT = EmitterSearcher:GetCenterTransform(self);
    if CT:Length() > 0 then
        local StartTransform = CT:Get(1);
        local SpawnSocketName = EmitterInfo.BulletSettings:Get(1).BulletSocket
        if not UE4.UKismetStringLibrary.IsEmpty(SpawnSocketName) then
            local SocketTransform = UE4.FTransform()
            local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
            if bHasSocket then
                StartTransform.Translation = SocketTransform.Translation
                StartTransform.Rotation = SocketTransform.Rotation
            end
        end
    
    
        local Loc = StartTransform.Translation
        local Rotator = StartTransform.Rotation
        -- local AimLoc = self:MultiLineTrace(false,StartTransform);
        local AimLoc = UE4.UAbilityFunctionLibrary.MultiLIneTraceToBlockLocation(self, false, StartTransform, self.RayInfo, MaxDistance);

        self:EmitterTickRayToLoc(StartTransform, self.RayInfo, AimLoc);
    end

end

function MultiTraceLineLaser:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

---@param Skill USkill
function MultiTraceLineLaser:OnEmit()
    local LineTraceShape = self.RayInfo.TraceShape;
    local TraceWidth = LineTraceShape.X;
    local TraceHeight = LineTraceShape.Y;
    local LineWidthNum = self.RayInfo.WidthTraceNum;
    local LineHeightNum = self.RayInfo.WidthHeightNum;
    local TraceType = self:GetParamintValue(0)
    local MaxDistance = self:GetParamfloatValue(1)

    local EmitterInfo = self:GetEmitterInfo()
    local CT = EmitterSearcher:GetCenterTransform(self);
    if CT:Length() > 0 then
        local StartTransform = UE4.FTransform();
        StartTransform = CT:Get(1);
        local SpawnSocketName = EmitterInfo.BulletSettings:Get(1).BulletSocket
        if SpawnSocketName ~= nil then
            local SocketTransform = UE4.FTransform()
            local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
            if bHasSocket then
                StartTransform.Translation = SocketTransform.Translation
                StartTransform.Rotation = SocketTransform.Rotation
            end
        end
    
        local Loc = StartTransform.Translation
        local Rotator = StartTransform.Rotation
        local AimLoc = UE4.UAbilityFunctionLibrary.MultiLIneTraceToBlockLocation(self, true, StartTransform, self.RayInfo, MaxDistance);
    end

    return UE4.EEmitterResult.Finish;
end

function MultiTraceLineLaser:EmitterDestroyLua()
    self:Destroy()
end
return MultiTraceLineLaser;

