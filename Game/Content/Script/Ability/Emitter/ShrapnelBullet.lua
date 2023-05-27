-- ========================================================
-- @File    : ShrapnelBullet.lua
-- @Brief   : 散射弹片发生器
-- @Author  : Xiong
-- @Date    : 2020-09-09
-- ========================================================

---@class USkillEmitter_ShrapnelBullet:USkillEmitter
local ShrapnelBullet = Class()

function ShrapnelBullet:BulletSpawn(CenterTransform)
    local EmitterInfo = self:GetEmitterInfo()
    self:BulletSpawn_SelfData(CenterTransform)
end

function ShrapnelBullet:ShrapnelDirCalc(ShootDirection, Index)
    ---散射角度
    local Angle = self:GetParamfloatValue(0); 
    ---子弹数量
    local BulletNum = self:GetParamintValue(1);
    ---方差
    local ParamsLength = self:GetParamLength()
    local dVariance = 1;
    if ParamsLength > 2 then
        dVariance = self:GetParamintValue(2);
    end

    local GaussRange = 1;
    if ParamsLength > 3 then
    GaussRange = self:GetParamintValue(3);
    end


    local fStep = 1.0/BulletNum;
    local ResultDirection = UE4.APlayerWeapon.LimitVRandCone(ShootDirection, Angle, dVariance, GaussRange);
    return ResultDirection;
end

function ShrapnelBullet:BulletSpawn_SelfData(CenterTransform)
    local EmitterInfo = self:GetEmitterInfo()
    ---散射角度
    local Angle = self:GetParamfloatValue(0); 
    ---子弹数量
    local BulletNum = self:GetParamintValue(1);

    ---获取发射点位置
    local SpawnTransform = CenterTransform
    ---读取发射点
    local SpawnSocketName = EmitterInfo.BulletSettings:Get(1).BulletSocket
    if SpawnSocketName ~= nil then
        local SocketTransform = UE4.FTransform()
        local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
        if bHasSocket then
            SpawnTransform.Translation = SocketTransform.Translation
            SpawnTransform.Rotation = SocketTransform.Rotation
        end
    end

    local AimLocation = UE4.FVector()
    AimLocation = UE4.UKismetMathLibrary.Quat_GetAxisX(SpawnTransform.Rotation) * 10000.0 + SpawnTransform.Translation
    local HomingTarget
    local QueryTarget
    QueryTarget = self:GetNextApplyResultByEffectPriority();
    if QueryTarget.QueryTarget ~= nil then
        HomingTarget = QueryTarget.QueryTarget;
        AimLocation =  QueryTarget.QueryPoint;
    end

    for i = 1, BulletNum do
    local Direction = AimLocation - CenterTransform.Translation;
    local ResultDir = self:ShrapnelDirCalc(UE4.UKismetMathLibrary.Vector_NormalUnsafe(Direction), i - 1);
    SpawnTransform.Rotation = UE4.UKismetMathLibrary.Conv_VectorToQuaternion(ResultDir);

    local Bullet = UE4.ABullet.SpawnDeferred(self:GetInstigator(), SpawnTransform, self:GetAbilityOwner(), self:GetSkillLevel(), EmitterInfo.BulletID, EmitterInfo.ID)
    if not Bullet then
        return UE4.EEmitterResult.Fail
    end
    Bullet:SetLauncherEmitter(self);
    if self:IsTargetCanApply(HomingTarget) == false then
        HomingTarget = nil
    end

    Bullet:SetTarget(QueryTarget)
    self:AddTargetApplyNum(HomingTarget)
    end
end

function ShrapnelBullet:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function ShrapnelBullet:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end


function ShrapnelBullet:OnEmit()
    local CTs = EmitterSearcher:GetCenterTransform(self)

    if CTs:Length() > 0 then
        for i = 1,CTs:Length() do
            self:BulletSpawn(CTs:Get(i))
        end
    end
end

function ShrapnelBullet:EmitterDestroyLua()
    self:Destroy()
end

return ShrapnelBullet
