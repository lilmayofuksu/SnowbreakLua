-- ========================================================
-- @File    : uw_spine_node_test.lua
-- @Brief   : 信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function()   print('click item')    end)
end

function tbClass:Set()

end


return tbClass