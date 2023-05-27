-- ========================================================
-- @File    : uw_fight_aim_shadow.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:PlayAnim(false)
end

---播放动画
function tbClass:PlayAnim(bInAiming)
    if bInAiming then
        self:PlayAnimFromAnimation(self.Aim)
    else
        self:PlayAnimFromAnimation(self.Aim, 0, 1, UE4.EUMGSequencePlayMode.Reverse)
    end
end

return tbClass
