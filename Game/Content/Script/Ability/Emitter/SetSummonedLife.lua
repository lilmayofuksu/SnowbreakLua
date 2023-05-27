-- ========================================================
-- @File    : SetSummonedLife.lua
-- @Brief   : 设置召唤物生存时间
-- @Author  : Xiong
-- @Date    : 2020-07-13
-- ========================================================

---@class USkillEmitter_SetSummonedLife:USkillEmitter
local SetSummonedLife = Class()

function SetSummonedLife:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function SetSummonedLife:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end


function SetSummonedLife:OnEmit()
    --- Param1 : 召唤物类型(0:陷阱 , 1:AI , 2:两者)
    --- Param2 : 召唤物生存时间操作方式(0: 覆写 , 1:增加)
    --- Param3 : 操作值
    local SummonedType = self:GetParamintValue(0)
    local LifeType = self:GetParamintValue(1)
    local Value = self:GetParamfloatValue(2)

    local Length = self.QueryResults:Length()
    for i = 1, Length do
        if SummonedType == 0 then
            self:OnSetTrapLife(self.QueryResults:Get(i).QueryTarget , LifeType , Value);
        end

        if SummonedType == 1 then
            self:OnSetAILife(self.QueryResults:Get(i).QueryTarget , LifeType , Value);
        end

        if SummonedType == 2 then
            self:OnSetTrapLife(self.QueryResults:Get(i).QueryTarget , LifeType , Value);
            self:OnSetAILife(self.QueryResults:Get(i).QueryTarget , LifeType , Value);
        end

        self:ApplyEffect(self.QueryResults:Get(i).QueryTarget:K2_GetActorLocation() , self.QueryResults:Get(i).QueryTarget:K2_GetActorRotation());
    end
    return UE4.EEmitterResult.Finish
end


function SetSummonedLife:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

---@param Target AActor
---@param LifeType int32
---@param Value float
function SetSummonedLife:OnSetTrapLife(Target , LifeType , Value)
    local Trap = Target:Cast(UE4.ATrap);
    if Trap ~= nil then
        
        if LifeType == 0 then
            Trap:SetLifeSpan(Value);
        end
        if LifeType == 1 then
            local Remaining = Trap:GetLifeSpan();
            Remaining = Remaining + Value;
            Trap:SetLifeSpan(Remaining);
        end
    end
end


---@param Target AActor
---@param LifeType int32
---@param Value float
function SetSummonedLife:OnSetAILife(Target , LifeType , Value)
    local AI = Target:Cast(UE4.AGameCharacter);
    if AI ~= nil and AI.SummonedOwner ~= nil then
        
        if LifeType == 0 then
            AI:SetLifeSpan(Value);
        end
        if LifeType == 1 then
            local Remaining = AI:GetLifeSpan();
            Remaining = Remaining + Value;
            AI:SetLifeSpan(Remaining);
        end
    end
end

function SetSummonedLife:EmitterDestroyLua()
    self:Destroy()
end

return SetSummonedLife;
