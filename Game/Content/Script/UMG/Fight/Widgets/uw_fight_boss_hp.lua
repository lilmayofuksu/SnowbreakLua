-- ========================================================
-- @File    : uw_fight_boss_hp.lua
-- @Brief   : boss 血条
-- @Author  :
-- @Date    :
-- ========================================================
local BossHp = Class("UMG.SubWidget")

function BossHp:Construct()
    self:DoClearListItems(self.ListBuff)
    self:DoClearListItems(self.List_Skill)
    self:DoClearListItems(self.ListElement)
end

return BossHp
