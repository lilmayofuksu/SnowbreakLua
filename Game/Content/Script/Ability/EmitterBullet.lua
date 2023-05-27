-- ========================================================
-- @File    : EmitterBullet.lua
-- @Brief   : Emitter用于子弹生成接口
-- @Author  : 
-- @Date    : 
-- ========================================================

---@class EmitterBullet 定义类
EmitterBullet = {}

function EmitterBullet:BulletSpawn(Emitter, CenterTransform)
    ---获取发射点位置
    local SpawnTransform = CenterTransform
    Emitter:ApplyEffect(SpawnTransform.Translation, SpawnTransform.Rotation);
    return UE4.USkillEmitter.EmitterSpawnBullet(Emitter:GetAbilityOwner(), Emitter:GetEmitterInfo(), Emitter.QueryResults, Emitter.ActiveTimes, SpawnTransform, Emitter, Emitter:GetSkillLevel());
end
