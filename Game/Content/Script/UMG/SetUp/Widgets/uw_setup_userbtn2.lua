-- ========================================================
-- @File    : uw_setup_userbtn2.lua
-- @Brief   : 设置
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(InObj)
end

function tbClass:Set(tbData)
    self.tbCfg = tbData.Cfg;
    self.ClickFunc = tbData.pFunc

    local text = Text('setting.'..self.tbCfg.sText)
    --self.TxtUserName:SetText(text)
    SetTexture(self.Logo, tonumber(self.tbCfg.nIconId))
end

return tbClass
