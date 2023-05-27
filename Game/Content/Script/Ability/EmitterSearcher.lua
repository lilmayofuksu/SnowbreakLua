-- ========================================================
-- @File    : EmitterSearcher.lua
-- @Brief   : Emitter用于检索目标的接口
-- @Author  : Xiong
-- @Date    : 2020-07-13
-- ========================================================

---@class EmitterSearcher 定义类
EmitterSearcher = {}

--获取技能释放位置
function EmitterSearcher:GetCenterTransform(Emitter)
    local CTs = Emitter:GetSkillAnchorTransform()
    return CTs
end

function EmitterSearcher:OnEmitSearch(Emitter)
    -- local Results = UE4.TArray(UE4.FQueryResult);
    -- Emitter.SearchAnchors = Emitter.SearchTargetsWithEmitterInfo(Emitter.QueryResults, Emitter:GetEmitterInfo(), Emitter:GetAbilityOwner(), Emitter:GetGameSkillOwner(), Emitter, Emitter:GetGameSkillOwner():GetLauncher())
end