-- ========================================================
-- @File    : umg_common_disconnected.lua
-- @Brief   : 发生断线,准备重新连接,进入联机副本时，提示“online_Starting	意识环境链接中，请稍等片刻…"也会打开这个umg.
-- ========================================================

--- @class umg_common_disconnected : UI_Template
local umg_common_disconnected = Class("UMG.BaseWidget");

function umg_common_disconnected:OnInit()
    print("umg_common_disconnected:OnInit()")
    if (Online.AllowAutoConnection == false) then
        UI.Close(self)
        return
    end
    self:OnUpdate()
end

function umg_common_disconnected:OnClose()
    -- self:GetPlayerController():ExhaleMouse(false);
    -- print('umg_exhibition:Destruct');
    print("umg_common_disconnected:OnClose()")
    self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    self.pPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if self.IsOnlineClient and self.pPlayer then
        print("umg_common_disconnected:OnClose() - ReStoreAllInput()")
        self.pPlayer:RestoreAllInput()
    end
end

--进入游戏前借用界面
function umg_common_disconnected:OnOpen(nType, sUITxt)
    print("umg_common_disconnected:OnOpen()")
    self.TxtWarn:SetText(Text("ui.TxtConnectWarn"))
    self.TxtWait:SetText(Text("ui.TxtConnectWait"))
    if nType and nType == 1 then
        self:ShowEnterTip(sUITxt)
    else
        if (Online.AllowAutoConnection == false) then
            UI.Close(self)
            return
        end
    end

    self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    print("umg_common_disconnected:OnOpen() - Try StopAllInput:", self.IsOnlineClient)
    if self.IsOnlineClient then
        if Player.DSError then
            me:Logout()
            GoToLoginLevel()
        end
        -- 联机暂停界面锁主角输入
        self.pPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
        if self.pPlayer then
            print("umg_common_disconnected:OnOpen() - StopAllInput()")
            self.pPlayer:StopAllInput()
        end
    end
end

function umg_common_disconnected:ShowEnterTip(sUITxt)
    self.BtnClose:SetVisibility(UE4.ESlateVisibility.Collapsed);
    self.PanelWarn:SetVisibility(UE4.ESlateVisibility.Collapsed);
    self.ImgBg:SetVisibility(UE4.ESlateVisibility.Visible);
    self.PanelWait:SetVisibility(UE4.ESlateVisibility.Visible); 

    if sUITxt then
        self.TxtWait:SetText(Text(sUITxt))
    end
end

function umg_common_disconnected:OnUpdate()
    if (UE4.UTGameEngine.IsNetworkFailure()) then -- 网络建立连接过程中出现错误
        print("umg_common_disconnected:OnUpdate() - IsNetworkFailure true, ENetworkFailure::PendingConnectionFailure!")
        self.BtnClose.OnClicked:Add(self, function()
            UI.Close(self);
            Launch.End();
        end);
        self.BtnClose:SetVisibility(UE4.ESlateVisibility.Visible);
        self.PanelWarn:SetVisibility(UE4.ESlateVisibility.Visible);
        self.PanelWait:SetVisibility(UE4.ESlateVisibility.Collapsed);
    else
        print("umg_common_disconnected:OnUpdate() - IsNetworkFailure false, ENetworkFailure::ConnectionLost!")
        self.BtnClose:SetVisibility(UE4.ESlateVisibility.Collapsed);
        self.PanelWarn:SetVisibility(UE4.ESlateVisibility.Collapsed);
        self.PanelWait:SetVisibility(UE4.ESlateVisibility.Visible);
    end
end

function umg_common_disconnected:CanEsc()
    print("umg_common_disconnected:CanEsc() - false!")
    return false
end

return umg_common_disconnected;
