-- ========================================================
-- @File    : umg_general_award.lua
-- @Brief   : 通用奖励
-- @Author  :
-- @Date    :
-- ========================================================

local umg_general_award = Class("UMG.BaseWidget")
local Award = umg_general_award

function Award:OnInit()
    self.CloseBtn.OnClicked:Add(
        self,
        function()
            UI.Close(self)
        end
    )
    self.BG.CloseBtn.OnClicked:Add(
        self,
        function()
            UI.Close(self)
        end
    )
end

return Award
