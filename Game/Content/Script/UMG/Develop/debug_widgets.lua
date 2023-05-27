-- ========================================================
-- @File    : umg_develop.lua
-- @Brief   : 开发调试界面
-- @Author  :
-- @Date    :
-- ========================================================

local debug_widgets = Class("UMG.SubWidget")

function debug_widgets:Construct()
    if self.BtnGM then
        self.BtnGM.OnClicked:Add(self, function() GoToMainLevel(self) end);
    end
end

return debug_widgets
