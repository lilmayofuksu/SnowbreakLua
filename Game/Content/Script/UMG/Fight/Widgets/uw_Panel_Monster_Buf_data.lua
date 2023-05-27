-- ========================================================
-- @File    : uw_Panel_Monster_Buf_data.lua
-- @Brief   : 小怪属性Buf
-- @Author  :
-- @Date    :
-- ========================================================
local uw_Panel_Monster_Buf_data = Class("UMG.SubWidget")

local Buf = uw_Panel_Monster_Buf_data

Buf.Index = 0

Buf.Select="ON_SELECT"

function Buf:Init(InIndex)
    self.Index = InIndex
end
return Buf
