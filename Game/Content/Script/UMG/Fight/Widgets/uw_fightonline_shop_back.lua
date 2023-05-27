-- ========================================================
-- @File    : uw_fightonline_shop_back.lua
-- @Brief   : 
-- ========================================================


local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnBack, function()
        if self.fClick then
            self.fClick()
        end
    
    end)
end
	
function tbClass:Set(fClick)
    self.fClick = fClick
end

return tbClass