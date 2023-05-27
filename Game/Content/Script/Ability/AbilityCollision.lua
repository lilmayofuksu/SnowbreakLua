-- ========================================================
-- @File    : AbilityCollision.lua
-- @Brief   : AbilityCollision的Lua接口
-- @Author  : Xiong
-- @Date    : 2020-08-25
-- ========================================================

---@class AbilityCollision 定义类
AbilityCollision = {}


function AbilityCollision:GetAvoidNoticeParticle(CollisionRef)
    local ParticlePath = UE4.FString("/Game/Effects/UI/e_ui_yujin/e_common_selectpostion_06_p.e_common_selectpostion_06_p");
    return ParticlePath;
end

function AbilityCollision:GetAvoidNoticeSocket(CollisionRef)

    return UE4.FString("");
end