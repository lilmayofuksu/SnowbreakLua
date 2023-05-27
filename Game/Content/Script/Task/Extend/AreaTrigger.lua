-- ========================================================
-- @File    : AreaTrigger.lua
-- @Brief   : 区域触发器
-- @Author  :
-- @Date    :
-- ========================================================

---@class AreaTrigger : ATriggerBox
local AreaTrigger = Class()

---是否激活
AreaTrigger.bActive = false
AreaTrigger.TaskTrigger = nil
AreaTrigger.bCheckPlayer = true
AreaTrigger.bCheckMonster = false
---进入
function AreaTrigger:ReceiveActorBeginOverlap(OtherActor)
    if IsValid(self.TaskTrigger) then
        if (IsPlayer(OtherActor) and self.bCheckPlayer) or (IsAI(OtherActor) and self.bCheckMonster) or (IsSummon(OtherActor) and self:IsFrindly(OtherActor) and self.bCheckFrindlySummon) then
            self.TaskTrigger:BeginOverlap()
        end
    end
end

function AreaTrigger:IsFrindly(OtherActor)
    local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    local All = Controller:GetPlayerCharacters() 
    for i=1,All:Length() do
        local one = All:Get(i)
        return UE4.UAbilityFunctionLibrary:GetRelation(one, OtherActor) == UE4.ECampRelation.Friendly
    end
end

---离开
function AreaTrigger:ReceiveActorEndOverlap(OtherActor)
    if IsPlayer(OtherActor) and IsValid(self.TaskTrigger) then
        self.TaskTrigger:EndOverlap()
    end
end

---绑定任务条目
---@param InTrigger AGameCharacter
function AreaTrigger:BindTaskItem(InTrigger, CheckPlayer, CheckMonster, CheckFrindlySummon)
    self:ActiveEffect(true);
    self.bActive = true
    self.TaskTrigger = InTrigger
    self.bCheckPlayer = CheckPlayer
    self.bCheckMonster = CheckMonster
    self.bCheckFrindlySummon = CheckFrindlySummon
    --处理人物SpawnInCollision的情况
    UE4.Timer.Add(0.1, function ( ... )
        self:UpdateOverlap()
        local bOverlap = self:IsOverlap()
        if bOverlap and self.TaskTrigger then
            self.TaskTrigger:BeginOverlap()
        end
    end)
end

---清理
function AreaTrigger:Clear()
    self.TaskTrigger = nil
    self:ActiveEffect(false);
end

return AreaTrigger
