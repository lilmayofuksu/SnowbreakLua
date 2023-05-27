-- ========================================================
-- @File    : DroneBomb.lua
-- @Brief   : 命令无人机轰炸
-- @Author  : Xiong
-- @Date    : 2020-04-27
-- ========================================================
---@class USkillEmitter_DroneBomb:USkillEmitter
local DroneBomb = Class()

function DroneBomb:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self);
end


function DroneBomb:OnEmit()
    --- Param1 : 命令类型(0: Bomb , 1: QTE Attack)
    local CommandType = self:GetParamintValue(0)
    --- Param2 : QTE或者Bomb技能ID
    local SkillId = self:GetParamintValue(1)

    --- Param3 : 目标Tag
    local ParamsLength = self:GetParamLength()
    local Tag = UE4.FString("");
    if ParamsLength >= 3 then
        Tag = self:GetParamValue(2)
    end
    
    --- Param4 : 释放技能时TemplateID筛选
    local FilterTemplateID = 0
    if ParamsLength >= 4 then
        FilterTemplateID = self:GetParamintValue(3)
    end

    local Launcher = self:GetSkillLauncher():Cast(UE4.AGameCharacter)
    local Team = nil
    local AllDrones
    if Launcher == nil then
        return UE4.EEmitterResult.Finish
    end
    local Team = Launcher.AIControlData.Team;
    if Team == nil then
        return UE4.EEmitterResult.Finish
    end
        AllDrones = Team:GetAllMembersPtr(true)

    if CommandType == 0 then
        for i = 1, AllDrones:Length() do
            if self:IsDrone(AllDrones:Get(i)) == true then
                local Target = nil
                local TargetLocation = UE4.FVector()
                if AllDrones:Get(i):ActorHasTag(Tag) or UE4.UKismetStringLibrary.IsEmpty(Tag) then
                    if self.InheritResults:Length() > 0 then
                        Target = self.InheritResults:Get(1).QueryTarget;
                        TargetLocation = self.InheritResults:Get(1).QueryPoint;
                    end
                    
                    local bNeedPitchRotator = false; 
                    local PitchRotator = 0;
                    if Target ~= nil then
                        bNeedPitchRotator = true;
                        if self:GetInstigator() ~= nil and self:GetInstigator():GetController() ~= nil then
                            PitchRotator = self:GetInstigator():GetController():GetControlRotation().Pitch;
                        end
                    end
                    if FilterTemplateID == 0 or FilterTemplateID == AllDrones:Get(i):GetTemplateID() then
                        AllDrones:Get(i):CastSkillImmediately(SkillId, self:GetSkillLevel())
                    end
                end
            end
        end
    end

    if CommandType == 1 then
        for i = 1, AllDrones:Length() do
            if self:IsDrone(AllDrones:Get(i)) == true then
                local Target = nil
                local TargetLocation = UE4.FVector()
                if AllDrones:Get(i):ActorHasTag(Tag) or UE4.UKismetStringLibrary.IsEmpty(Tag) then
                    if self.QueryResults:Length() > 0 then
                        Target = self.QueryResults:Get(1).QueryTarget;
                        TargetLocation = self.QueryResults:Get(1).QueryPoint;
                    end
        
                    if self.InheritResults:Length() > 0 then
                        Target = self.InheritResults:Get(1).QueryTarget
                        TargetLocation = self.InheritResults:Get(1).QueryPoint
                    end
        
                    local Dir = UE4.UKismetMathLibrary.MakeRotFromX(TargetLocation - AllDrones:Get(i):K2_GetActorLocation() );
                    AllDrones:Get(i):K2_SetActorRotation( UE4.FRotator(0,Dir.Yaw,0) );
                    if FilterTemplateID == 0 or FilterTemplateID == AllDrones:Get(i):GetTemplateID() then
                        AllDrones:Get(i):CastSkillImmediately(SkillId, self:GetSkillLevel(), Target, TargetLocation)
                    end
                end
            end
        end
    end

    return UE4.EEmitterResult.Finish
end

function DroneBomb:EmitterDestroyLua()
    self:Destroy()
end

return DroneBomb
