-- ========================================================
-- @File    : umg_code_pc.lua
-- @Brief   : 登录扫码界面
-- ========================================================
---@class tbClass
---@field ImgCode UImage
local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    BtnAddEvent(self.BtnRefresh, function() UE4.UGameLibrary.FreshQRCode()  end)
    BtnAddEvent(self.BtnClose, function() 
        local pLoginUI = UI.GetUI('Login')
        if pLoginUI then
            WidgetUtils.Visible(pLoginUI.LoginBtn)
        end

        UI.Close(self) 
    end)
end

function tbClass:OnOpen()
    self.nHandleQRStatus = EventSystem.On(Event.QRCodeStatus, function(rspCode, status)
        self:UpdateState(status)
    end)
    self:UpdateCode()
end


---更新二维码
---@param pTexture UTexture2D 二维码
function tbClass:UpdateCode()
    local pTexture = UE4.UGameLibrary.LoadQRCodeTexture(self.ImgCode)
    if pTexture then
        self.ImgCode:SetBrushFromTexture(pTexture, true)
    end
    if self.StatusTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.StatusTimer)
    end
    self.StatusTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                UE4.UGameLibrary.QueryQRStatus()
            end
        },
        2.0,
        true
    )
    self:UpdateState(0)
end

--[[
        --status:
        --0: 初始化
        --1: 已扫码
        --2: 授权登录成功
        --11: 二维码过期，需要刷新
        --13: 授权登录失败
]]
---更新状态
---@param status Integer 状态码
function tbClass:UpdateState(status)
    WidgetUtils.Collapsed(self.PanelSuccess)
    WidgetUtils.Collapsed(self.PanelFail)
    WidgetUtils.Collapsed(self.PanelOverdue)
    self.ImgCode:SetRenderOpacity(1)
    WidgetUtils.Visible(self.BtnRefresh)
    print("QRStatus RSP", status)
    if status == "2" then
        UI.Close(self)
        local authInfo = UE4.UGameLibrary.GenAuthInfo()
        print("QR GenAuthInfo", authInfo)
        EventSystem.Trigger(Event.LoginParamReady, true, {Provider = "xgsdk", Token = authInfo})
    elseif status == "0" then
        --
    elseif status == "1" then
        self.ImgCode:SetRenderOpacity(0.1)
        WidgetUtils.HitTestInvisible(self.PanelSuccess)
        WidgetUtils.HitTestInvisible(self.BtnRefresh)
    elseif status == "11" then
        self.ImgCode:SetRenderOpacity(0.1)
        WidgetUtils.HitTestInvisible(self.PanelOverdue)
    elseif status == "13" then
        self.ImgCode:SetRenderOpacity(0.1)
        WidgetUtils.HitTestInvisible(self.PanelFail)
    end
end

function tbClass:OnClose()
    if self.StatusTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.StatusTimer)
        self.StatusTimer = nil
    end
    EventSystem.Remove(self.nHandleQRStatus)
end

return tbClass