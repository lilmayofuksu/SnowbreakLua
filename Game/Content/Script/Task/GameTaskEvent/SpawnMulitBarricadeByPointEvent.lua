-- ========================================================
-- @File    : SpawnMulitBarricadeByPointEvent.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

---@class SpawnMulitBarricadeByPointEvent : SpawnMonsterBaseEvent
local SpawnMulitBarricadeByPointEvent = Class()

SpawnMulitBarricadeByPointEvent.tbSpawn = nil
SpawnMulitBarricadeByPointEvent.NowSpawnIndex = 0

---执行事件
function SpawnMulitBarricadeByPointEvent:TrySpawn()
    self.tbSpawn = {}
    local Template = UE4.ULevelLibrary.GetActiveDestroyTemplate(self.TemplateID)
    if not Template then
        return false
    end

    table.insert(self.tbSpawn, Template)
    self.NowSpawnIndex = 1000
    self:Spawn()
    return true
end

function SpawnMulitBarricadeByPointEvent:Spawn()
    for _,v in pairs(self.tbSpawn) do
        self:Do(v)
    end
end

function SpawnMulitBarricadeByPointEvent:Do(InTemplate)
    local AllPointNum = InTemplate.Points:Length()
    if AllPointNum <= 0 then
        return
    end
    local TaskActor = self:GetGameTaskActor()

    for i = 1, AllPointNum do
        -- 这里根据任务区域的不同刷怪点位变化
        local pName = string.format("%s_%s", TaskActor.AreaId, TaskCommon.CheckGet(InTemplate.Points, i));
        local Tag = TaskCommon.CheckGet(InTemplate.Tags, i)
        
        local one = UE4.ULevelLibrary.SpawnBarricadeByPoint(
            self, 
            InTemplate, 
            pName, 
            {Tag, string.format("SpawnIndex_%s", self.NowSpawnIndex), self:GetGameTaskAsset():GetTaskTag()}
        )
        if one then
            print(" SpawnMulitBarricadeByPoint:  ", pName, one:GetName())
            ChallengeMgr.AddBarricade(TaskActor.AreaId, one:GetName())
        end
        self.NowSpawnIndex = self.NowSpawnIndex + 1
    end
end

return SpawnMulitBarricadeByPointEvent
