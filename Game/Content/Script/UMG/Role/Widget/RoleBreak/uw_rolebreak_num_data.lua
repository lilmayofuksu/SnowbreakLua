-- ========================================================
-- @File    : uw_rolebreak_tips.lua
-- @Brief   : 突破提示数据
-- @Author  :
-- @Date    :
-- ========================================================

local AttrNum = Class("UMG.SubWidget")
AttrNum.sName = "ttt"
AttrNum.nNow = 0
AttrNum.nNew = 0
function AttrNum:Construc()
    --body()
end

function AttrNum:OnInit(tbParam)
    self.sName  = tbParam.sName
    self.nNow   = tbParam.nNow
    self.nNew   = tbParam.nNew
end

return AttrNum
