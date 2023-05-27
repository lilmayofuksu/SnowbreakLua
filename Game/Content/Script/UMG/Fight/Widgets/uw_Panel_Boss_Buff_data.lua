-- ========================================================
-- @File    : uw_Panel_Monster_Buf_data.lua
-- @Brief   : boss属性Buf data
-- @Author  :
-- @Date    :
-- ========================================================
local uw_Panel_Boss_Buff_data = Class("UMG.SubWidget")

local Buf = uw_Panel_Boss_Buff_data

Buf.Index = 0
Buf.BufText = nil

Buf.Select = "ON_SELECT"

function Buf:Init(InIndex, InModifier, ImgIcon)
    self.Index = InIndex
    self.pModifier = InModifier
    self.ImgIcon = ImgIcon
end

return Buf
