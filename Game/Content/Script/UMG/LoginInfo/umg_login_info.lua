-- ========================================================
-- @File    : umg_login_info.lua
-- @Brief   : 登录信息
-- ========================================================
---@class tbClass
---@field Content UCanvasPanel
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function()
       UI.Close(self) 
    end)

    BtnAddEvent(self.BtnOK, function()
        UI.Close(self)
    end)

    self.Web.OnCommunicateWithGame:Add(
        self,
        function(_, sUrl)
            Web.Route(sUrl)
        end
    )

end

function tbClass:OnOpen()
    local sUrl = Login.GetContent() .. "maintain_notice?categoryId=6547&articleId=5"
    Download(sUrl, function(_, sData)
        self.Web:LoadString(LocalContent(sData), '/game/notice')
    end);
end


return tbClass