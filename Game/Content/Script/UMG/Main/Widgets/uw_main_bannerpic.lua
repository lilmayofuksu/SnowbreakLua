-- ========================================================
-- @File    : uw_main_bannerpic.lua
-- @Brief   : banner图
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    
end

function tbClass:OnListItemObjectSet(InObj)
    self:Set(InObj.Data)
end

function tbClass:Set(Data)
    SetTexture(self.ImgBanner, Data.nBg)
end

return tbClass
