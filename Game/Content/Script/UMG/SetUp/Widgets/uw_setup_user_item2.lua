-- ========================================================
-- @File    : uw_setup_user_item2.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")
local SID = PlayerSetting.SSID_OTHER

function tbClass:Construct()
    BtnClearEvent(self.BtnClick.BtnUser)
	BtnAddEvent(self.BtnClick.BtnUser, function ()
        if self.ClickFunc and self.tbCfg then
            self.ClickFunc(self.tbCfg)
        end
    end)
end

function tbClass:OnDestruct()
    BtnClearEvent(self.BtnClick.BtnUser)
end

function tbClass:Set(tbData)
    self.tbCfg = tbData.Cfg;
    self.ClickFunc = tbData.pFunc

    local label = Text('setting.' .. self.tbCfg.sName)
	self.TxtUser:SetText(label)
    self.BtnClick:Set(tbData)
end

return tbClass