-- ========================================================
-- @File    : PlaceTrapInBullet.lua
-- @Brief   : 防止陷阱并Attack到子弹上
-- @Author  : 
-- @Date    : 
-- ========================================================

---@class USkillEmitter_Trap:USkillEmitter
local PlaceTrapInBulletEmitter = Class();

function PlaceTrapInBulletEmitter:OnEmit()
   

    --- Param1 : 陷阱名
    --- Param2 : 陷阱持续时间
    --- Param3 : 进入陷阱触发技能
    --- Param4 : 陷阱持续触发技能
    --- Param5 : 离开陷阱触发技能
    --- Param6 : 是否放置在地面上
    local EmitterInfo = self:GetEmitterInfo()
    local CTs = EmitterSearcher:GetCenterTransform(self);
    if CTs:Length() > 0 then
        local CT = CTs:Get(1);
        local Center = CT.Translation
        local BulletScreenEditorClassPath = UE4.UTaskLibrary.GetSoftPath(EmitterInfo.BulletScreenEditorClass)
        if EmitterInfo.BulletID <= 0  then
            return
        end
            
        local Bullets = EmitterBullet:BulletSpawn(self, CT)
        if Bullets:Length() > 0 then 
            return
        end    

        for i = 1, Bullets:Length() do
            local Bullet = Bullets:Get(i);
            local TrapName = self:GetParamValue(0)
            local TrapLife = self:GetParamfloatValue(1); 
            local TrapEnterSkill = self:GetParamintValue(2); 
            local TrapKeepSkill = self:GetParamintValue(3);
            local TrapLeaveSkill = self:GetParamintValue(4);
            -- local TraceOnLand = self:GetParamboolValue(5);
            -- local TrapMaxNum = 0;
            -- if Params:Length() >= 7 then
            --     TrapMaxNum = self:GetParamintValue(6);
            -- end
    
            local path = string.format("/Game/Blueprints/Ability/Trap/%s.%s_C" , TrapName , TrapName);
            local TrapClass = UE4.UKismetSystemLibrary.MakeSoftClassPath(path)
    
            local TrapInfo = UE4.FTrapSpawnInfo();
            TrapInfo.ID = 1;
            TrapInfo.TrapType = TrapClass;
            TrapInfo.LifeTime:Add(1, TrapLife);
            TrapInfo.bRemoveOnLeave = false;
            TrapInfo.EnterSubSkill = TrapEnterSkill;
            TrapInfo.KeepingSubSkill = TrapKeepSkill;
            TrapInfo.LeaveSubSkill = TrapLeaveSkill;
            local Trap = UE4.ATrap.SpawnTrapDeferred(self:GetInstigator() , TrapInfo , CT ,self);
            if Trap ~= nil then
                local Result = UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(Trap, EmitterInfo.ApplyLocationType);
                self:ApplyMagicToActor(Result , Result.QueryPoint ,Trap:K2_GetActorLocation() , 1);
                -- if TrapMaxNum > 0 then
                --     UE4.ATrap.LimitTrapMaxNum(self:GetInstigator(), Trap, self:GetInstigator(), TrapMaxNum);
                -- end
    
                Trap:K2_AttachToActor(Bullet, "", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget)
                Trap:BindParentBulletRecycle(Bullet)
                -- Trap:K2_SetActorRelativeLocation(UE4.FVector(0,0,0))
                -- Trap:K2_SetActorRelativeRotation(UE4.FRotator(0,0,0))
            end
        end

        self:ApplyEffect(CT.Translation, CT.Rotation);
    end

    return UE4.EEmitterResult.Finish;
end

function PlaceTrapInBulletEmitter:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function PlaceTrapInBulletEmitter:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function PlaceTrapInBulletEmitter:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function PlaceTrapInBulletEmitter:EmitterDestroyLua()
    self:Destroy()
end

return PlaceTrapInBulletEmitter;

