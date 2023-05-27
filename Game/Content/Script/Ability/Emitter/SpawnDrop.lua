-- ========================================================
-- @File    : SpawnDrop.lua
-- @Brief   : 生成掉落物
-- @Author  : cms
-- @Date    : 2022/2/24
-- ========================================================

---@class USkillEmitter_SpawnDrop:USkillEmitter
local SpawnDrop = Class()

function SpawnDrop:OnEmit()
    --- Param1 : 掉落物ID
    local DropID = self:GetParamintValue(0)
    self.QueryResults:Append(self.InheritResults);

    if self.QueryResults:Length() > 0 then
        local SpawnTransform =  UE4.FTransform()
        SpawnTransform.Translation =self.QueryResults:Get(1).QueryPoint
        local pDropSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelDropsManager)
        if pDropSubSys then
            local DropItem = pDropSubSys:SpawnDropWithOwner(self,DropID,SpawnTransform,1,true)
            if DropItem then
                DropItem.DropLevel = self:GetSkillLevel()
            end
        end
    end

    return UE4.EEmitterResult.Finish
end

function SpawnDrop:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function SpawnDrop:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex);
end

function SpawnDrop:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end


function SpawnDrop:EmitterDestroyLua()
    self:Destroy()
end

return SpawnDrop
