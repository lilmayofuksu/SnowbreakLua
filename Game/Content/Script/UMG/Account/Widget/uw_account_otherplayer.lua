
-- ========================================================
-- @File    : uw_account_otherplayer.lua
-- @Brief   : 账号界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnBlock,function()
        self:PullBlack()
    end)

    BtnAddEvent(self.btnAdd,function()
        self:AddFirend()
    end)
end

function tbClass:OnOpen(...)
    
end

function tbClass:PullBlack()
    
end

function tbClass:AddFirend()
    
end

return tbClass