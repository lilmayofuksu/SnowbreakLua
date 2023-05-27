local tbClass = Class()

function tbClass:OnTrigger()
	local TaskActor = self:GetGameTaskActor()
    if IsValid(TaskActor) and TaskActor.LevelType == UE4.ELevelType.Defend and IsValid(TaskActor.TaskDataComponent) then
        local MonsWave = TaskActor.TaskDataComponent:GetOrAddValue('MonsterWave')
        local LeftTime = TaskActor.TaskDataComponent:GetOrAddValue('WaveLeftTime')
        DefendLogic:WaveLeftTimeCacheLog(MonsWave,LeftTime)
    end
end

return tbClass