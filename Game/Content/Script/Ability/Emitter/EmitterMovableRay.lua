-- ========================================================
-- @File    : EmitterMovableRay.lua
-- @Brief   : 可连续移动射线的发生器
-- @Author  : AMu
-- @Date    : 2023-02-14
-- ========================================================

---@class USkillEmitter_EmitterMovableRay:USkillEmitter
local EmitterMovableRay = Class();

function EmitterMovableRay:GetAimLocation(StartTransform)
    local AimLocation = UE4.UKismetMathLibrary.Conv_RotatorToVector(StartTransform.Rotation:ToRotator()) * 10000.0 + StartTransform.Translation;
    local QueryResult = self:GetNextApplyResultByEffectPriority()
    if QueryResult.bValid == true then
        AimLocation = QueryResult.QueryPoint;
    end

    return AimLocation;
end

function EmitterMovableRay:CalcRayHitLocation()
    local ExistTime = (self.ActiveTimes - 1) * self.InfoTemplete.Interval + self.EmitTime;
    local LifeTime = (self.InfoTemplete.EffectiveTimes - 1) * self.InfoTemplete.Interval
    local LerpValue =  ExistTime / LifeTime;
    return UE4.UKismetMathLibrary.VLerp(self.RayHitStartPoint, self.RayHitEndPoint, LerpValue);
end

function EmitterMovableRay:GetRayStartTransform(CenterTransform)
    local RayStartTransform = CenterTransform
    local EmitterInfo = self:GetEmitterInfo()
    local SpawnSocketName = EmitterInfo.BulletSettings:Get(1).BulletSocket
    if SpawnSocketName ~= nil then
        local SocketTransform = UE4.FTransform()
        local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
        if bHasSocket then
            RayStartTransform = SocketTransform
        end
    end
    return RayStartTransform
end

function EmitterMovableRay:SpawnAndPlaceTrap(SpawnLocation)
    if(self.PlaceTrapInfo == nil or SpawnLocation == nil) then
        return
    end

    local Info = self.PlaceTrapInfo;
    local TrapName = Info.TrapName;
    local path = string.format("/Game/Blueprints/Ability/Trap/%s.%s_C" , TrapName , TrapName);
    local TrapClass = UE4.UKismetSystemLibrary.MakeSoftClassPath(path)
    local TrapInfo = UE4.FTrapSpawnInfo();
    TrapInfo.ID = 1;
    TrapInfo.TrapType = TrapClass;
    TrapInfo.LifeTime:Add(1, Info.TrapLife);
    TrapInfo.bRemoveOnLeave = false;
    TrapInfo.EnterSubSkill = Info.TrapEnterSkill;
    TrapInfo.KeepingSubSkill = Info.TrapKeepSkill;
    TrapInfo.LeaveSubSkill = Info.TrapLeaveSkill;

    local TrapTransform = UE4.FTransform();
    TrapTransform.Translation = SpawnLocation;
    local Trap = UE4.ATrap.SpawnTrapDeferred(self:GetInstigator() , TrapInfo , TrapTransform ,self);
    if Trap ~= nil then
        local EmitterInfo = self:GetEmitterInfo()
        if EmitterInfo.bMarkRunning then
            Trap:MarkRunning();
            local GameSkill = self:GetGameSkillOwner();
            if GameSkill then
                GameSkill:K2_MarkRunningObject(Trap);
            end
        end

        local Result = UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(Trap, EmitterInfo.ApplyLocationType);
        self:ApplyMagicToActor(Result , Result.QueryPoint ,Trap:K2_GetActorLocation() , 1);
        if Info.TrapMaxNum > 0 then
            UE4.ATrap.LimitTrapMaxNum(self:GetInstigator(), Trap, self:GetInstigator(), Info.TrapMaxNum, LimitAllSameClassTrapNum);
        end
    end

    self:ApplyEffect(TrapTransform.Translation, TrapTransform.Rotation);
end

function EmitterMovableRay:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

--- Param1 : 移动路径名
--- Param2 : 激光特效是否穿墙(跟命中无关)
--- Param3 : 陷阱名
--- Param4 : 陷阱持续时间
--- Param5 : 进入陷阱触发技能
--- Param6 : 陷阱持续触发技能
--- Param7 : 离开陷阱触发技能
--- Param8 : 陷阱最大数量
function EmitterMovableRay:OnEmitBegin()
    local BulletID = 0
    if self:GetEmitterInfo().BulletSettings:Length() > 0 then
        BulletID = self:GetEmitterInfo().BulletSettings:Get(1).BulletID;
    end
    UE4.UAbilityComponentBase.LoadBulletInfoStatic(BulletID, self.RayInfo, self:GetAbilityOwner());
    self:CreateRayParticle();

    local CTs = EmitterSearcher:GetCenterTransform(self);
    local length = CTs:Length();
    if length == 0 then
        return
    end

    local VectorCurvePath = self:GetParamValue(0)
    self.CanRayBlocked = self:GetParamintValue(1) == 1 and true or false;
    local pLoadCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(VectorCurvePath);
    if not pLoadCurve then 
        PrintScreen("Movable Ray Vector Curve Path Was Wrong!!! Check!!", nil, 5);
        return 
    end

    local CT = CTs:Get(1);
    local RayStartTransform = self:GetRayStartTransform(CT);
    local CoordinateDirection = CT.Translation - RayStartTransform.Translation;
    local CoordinateRot = UE4.UKismetMathLibrary.Conv_VectorToQuaternion(CoordinateDirection)
    local RotateDegree = CoordinateRot:ToRotator().Yaw;
    local HitRotator = UE4.FRotator(0,RotateDegree,0);
    local CurveVector = pLoadCurve:Cast(UE4.UCurveVector);
    if not CurveVector then
        PrintScreen("Please Use Vector Curve! Check Curve File!!!", nil, 5);
        return
    end

    local RayHitStartDirection = CurveVector:GetVectorValue(0);
    local RayHitEndDirection = CurveVector:GetVectorValue(1);
    RayHitStartDirection = UE4.UKismetMathLibrary.GreaterGreater_VectorRotator(RayHitStartDirection, HitRotator);
    RayHitEndDirection = UE4.UKismetMathLibrary.GreaterGreater_VectorRotator(RayHitEndDirection, HitRotator);
    local AimLocation = self:GetAimLocation(CT);
    self.RayHitStartPoint = AimLocation + RayHitStartDirection;
    self.RayHitEndPoint = AimLocation + RayHitEndDirection;
    local ParamsLength = self:GetParamLength()
    if ParamsLength < 3 then
       return;
    end
    local TrapName = self:GetParamValue(2)
    local path = string.format("/Game/Blueprints/Ability/Trap/%s.%s_C" , TrapName , TrapName);
    local TrapClass = UE4.UKismetSystemLibrary.MakeSoftClassPath(path)
    if TrapClass then
        self.PlaceTrapInfo = {};
        local Info = self.PlaceTrapInfo;
        Info.TrapName = TrapName;
        Info.TrapLife = self:GetParamfloatValue(3); 
        Info.TrapEnterSkill = self:GetParamintValue(4); 
        Info.TrapKeepSkill = self:GetParamintValue(5);
        Info.TrapLeaveSkill = self:GetParamintValue(6);
        Info.TrapMaxNum = 0;
        if ParamsLength >= 8 then
            Info.TrapMaxNum = self:GetParamintValue(7);
        end
    end
end

function EmitterMovableRay:OnEmitTick(DeltaTime)
    local CTs = EmitterSearcher:GetCenterTransform(self);
    local length = CTs:Length();
    if length == 0 then
        return
    end

    local CT = CTs:Get(1);
    local RayStartTransform = self:GetRayStartTransform(CT);
    local HitLocation = self:CalcRayHitLocation();
    self:EmitterTickRayToLoc(RayStartTransform, self.RayInfo, HitLocation, self.CanRayBlocked);
end

function EmitterMovableRay:OnEmit()
    local CTs = EmitterSearcher:GetCenterTransform(self);
    local length = CTs:Length();
    if length == 0 then
        return
    end

    local CT = CTs:Get(1);
    local RayStartTransform = self:GetRayStartTransform(CT);
    local HitLocation = self:CalcRayHitLocation();
    local HitResult =
    UE4.UAbilityFunctionLibrary.LineTraceSingle(
    RayStartTransform.Translation,
    HitLocation,
    self.RayInfo.BulletChannel,
    self:GetInstigator())
    if HitResult.bBlockingHit and HitResult.Actor ~= nil then
        UE4.ABullet.BulletApplyEffect(self:GetAbilityOwner(), RayStartTransform.Translation, self.RayInfo, HitResult.Actor, HitResult, self:GetSkillLevel(), self, nil);
    end

    self:SpawnAndPlaceTrap(HitLocation)
    return UE4.EEmitterResult.Finish;
end

function EmitterMovableRay:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function EmitterMovableRay:EmitterDestroyLua()
    self:Destroy();
end

return EmitterMovableRay