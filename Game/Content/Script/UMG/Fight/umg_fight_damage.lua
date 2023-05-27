-- ========================================================
-- @File    : umg_fight_Damage.lua
-- @Brief   : 战斗跳字界面
-- ========================================================

--- @class umg_fight_Damage : UI_Template
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnOpen()
    if self.Damage then
        self.Damage:FightUIClose(false, true)
    end
end

function tbClass:OnDisable()
    if self.Damage then
        self.Damage:FightUIClose(true, true)
    end
end

function tbClass:OnClose()
    if self.Damage then
        self.Damage:FightUIClose(true, true)
    end
end

-- 打开时不聚焦
function tbClass:DontFocus()
    return true;
end

return tbClass
