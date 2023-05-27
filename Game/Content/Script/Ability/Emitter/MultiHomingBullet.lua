-- ========================================================
-- @File    : MultiHomingBullet.lua
-- @Brief   : 多端追踪子弹发生器
-- @Author  : Xiong
-- @Date    : 2020-05-14
-- ========================================================

---@class USkillEmitter_MultiHomingBullet:USkillEmitter
local MultiHomingBullet = Class()

function MultiHomingBullet:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self);
end

function MultiHomingBullet:OnEmit()
    local CTs = EmitterSearcher:GetCenterTransform(self)
    local CT = UE4.FTransform();
    if CTs:Length() > 0 then
        CT = CTs:Get(1);
    end

    if self:GetEmitterInfo().BulletSettings:Length() > 0 then
        self:BulletSpawn(CT)
    end
end

function MultiHomingBullet:BulletSpawn(CenterTransform)
    ---获取发射点位置
    local SpawnTransform = CenterTransform
    local EmitterInfo = self:GetEmitterInfo()
    ---读取发射点

    for i = 1, self:GetEmitterInfo().BulletSettings:Length() do
        local BulletSetting = self:GetEmitterInfo().BulletSettings:Get(1);
        local SpawnSocketName = BulletSetting.BulletSocket
        if SpawnSocketName ~= nil then
            local SocketTransform = UE4.FTransform()
            local bHasSocket = self.FindSocketTransformOnOwner(self:GetSkillLauncher(),SpawnSocketName, SocketTransform)
            if bHasSocket then
                SpawnTransform.Translation = SocketTransform.Translation
                SpawnTransform.Rotation = SocketTransform.Rotation
            end
        end
    
        local AimLocation = UE4.FVector()
        AimLocation = self:GetAbilityOwner():GetOwner():GetActorForwardVector() * 10000.0 + SpawnTransform.Translation
    
        local HomingTarget
        local QueryTarget
        QueryTarget = self:GetNextApplyResultByEffectPriority();
        HomingTarget = QueryTarget.QueryTarget;
        AimLocation =  QueryTarget.QueryPoint;
    
        local Bullet = UE4.ABullet.SpawnDeferred(self:GetInstigator(), SpawnTransform, self:GetAbilityOwner(), self:GetSkillLevel(), BulletSetting.BulletID, EmitterInfo.ID)
        if not Bullet then
            return UE4.EEmitterResult.Fail
        end
        Bullet:SetLauncherEmitter(self);
        if self:IsTargetCanApply(HomingTarget) == false then
            HomingTarget = nil
        end
    
        local HomingSocket = self:FindRandSocketAndRemove(self.AllSocket);
        Bullet:SetTarget(QueryTarget, HomingSocket)
        self:AddTargetApplyNum(HomingTarget)
    end


end


---@param CheckerInfo FEmitterDataInfo 发生器的信息数组
function MultiHomingBullet:OnEmitBegin()
    --- Param1 : 跟踪Socket名
    self.AllSocket = self:GetStringArrayValue(0); 
end

function MultiHomingBullet:EmitterDestroyLua()
    self:Destroy()
end
return MultiHomingBullet
