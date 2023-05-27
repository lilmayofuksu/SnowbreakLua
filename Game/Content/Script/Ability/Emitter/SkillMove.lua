-- ========================================================
-- @File    : SkillMove.lua
-- @Brief   : 使用技能特殊移动
-- @Author  : XiongHongJi
-- @Date    : 2020-05-07
-- ========================================================

---@class USkillEmitter_SkillMove:USkillEmitter
local SkillMove = Class()

function SkillMove:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function SkillMove:OnEmitBegin()
    local EmitterInfo = self:GetEmitterInfo()

    --- Param1 : 移动蓝图名字
    print("Create Skill Move")
    local MoveName = self:GetParamValue(0)
    -- local path = string.format("/Game/Blueprints/Ability/SkillMove/%s.%s_C" , MoveName , MoveName);
    -- local MoveClass = UE4.UClass.Load(path)

    self.bKeepRunning = true
    
    local CTs = EmitterSearcher:GetCenterTransform(self)
    local length = CTs:Length()
    for i = 1, length do
        local CT = CTs:Get(i)
        self:ApplyEffect(CT.Translation, CT.Rotation);
    end
    
    local QueryResultTarget = UE4.FQueryResult();
    if length > 0 then
        QueryResultTarget.QueryPoint = CTs:Get(1).Translation;
    end

    QueryResultTarget = self:GetNextApplyResultByEffectPriority();

    UE4.USkillMove.CreateSkillMove(QueryResultTarget ,self:GetInstigator(), self, EmitterInfo, MoveName, self.DurationOnMontage)
end

function SkillMove:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function SkillMove:OnEmitTick()
    local CT = EmitterSearcher:GetCenterTransform(self);
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    if CT:Length() > 0 then
        UE4.USkillEmitter.EmitterAnchorEffectFresh(self:GetSkillLauncher(),self:GetEmitterInfo(),CT:Get(1).Translation,CT:Get(1).Rotation,HashIndex);
    end
end

function SkillMove:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
    UE4.USkillMove.CancleSkillMove(self:GetInstigator(), self:GetSkillMove());
    self:Destroy()
end

function SkillMove:OnEmitterInterrupt()
    UE4.USkillMove.CancleSkillMove(self:GetInstigator(), self:GetSkillMove());
end


function SkillMove:EmitterDestroyLua()
    self:Destroy()
end

return SkillMove
