-- ========================================================
-- @File    : uw_setup_userpopup.lua
-- @Brief   : 协议
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function ()
        UI.Close(self)
    end)
    BtnAddEvent(self.BtnOK, function ()
        UI.Close(self)
    end)
    self.Web.OnCommunicateWithGame:Add(   self, function(_, sUrl)  Web.Route(sUrl)  end)
end

function tbClass:OnOpen(tbCfg)
    self.TxtName:SetText(Text('setting.' .. tbCfg.sName))
    Web.LoadUrl(tbCfg.sUrl, self.Image_11, self.Web)
end

function tbClass:OnClose()
    
end

return tbClass