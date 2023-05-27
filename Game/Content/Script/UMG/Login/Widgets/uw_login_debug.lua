-- ========================================================
-- @File    : uw_login_debug.lua
-- @Brief   : 服务器条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.List)
    self.ListFactory = Model.Use(self)
    BtnAddEvent(self.Offline,  function() 
        me:OffloginInit() 
        Login.bOffLine = true
        UE4.UUMGLibrary.Login()
        GoToMainLevel(GetGameIns()) 
    end)
    BtnAddEvent(self.BtnConfirm, function()
        if self.selectData then
            Login.SetServer(self.selectData.tbData)
        end
        WidgetUtils.Collapsed(self)
        UE4.UUserSetting.Save()
        local pLoginUI = UI.GetUI("Login") or UI.GetUI("LoginPC")
        if pLoginUI then
            pLoginUI:SetDebugLogin(self.selectData.tbData)
        end
    end)
    self.CheckCustServer.OnCheckStateChanged:Add(self.CheckCustServer,function(bIsChecked)
        if bIsChecked then
            if not self.selectData then 
                self.selectData = {tbData = {}}
            end

            self.selectData.tbData.sAddr=self.EditableServerIP:GetText()
            self.selectData.tbData.nPort=self.EditableServerPort:GetText()
            self.selectData.tbData.sName="手动IP"
        end
    end)
    self.selectData = nil

    self.EditableServerIP:SetText(self:GetStringKey("login_debug_server_ip"))
    self.EditableServerPort:SetText(self:GetStringKey("login_debug_server_port"))

    self:ShowServerList()
end

function tbClass:OnDestruct()
    if self.EditableServerIP:GetText() ~= self:GetStringKey("login_debug_server_ip") 
        or self.EditableServerPort:GetText() ~= self:GetStringKey("login_debug_server_port") then
        UE4.UUserSetting.SetString("login_debug_server_ip", self.EditableServerIP:GetText())
        UE4.UUserSetting.SetString("login_debug_server_port", self.EditableServerPort:GetText())
        UE4.UUserSetting.Save()
    end
end

function tbClass:ShowServerList()
    local tbCfg = Login.GetServers()
    if not tbCfg then 
        self.selectData = {tbData = {}}
        return 
    end

     --显示服务器列表
    local sServerName = Login.GetServer() and Login.GetServer().sName or ''
    local fClick = function(InData)
        self:SelectChange(InData)
    end
    for _, v in ipairs(tbCfg) do
        local bSelect = (v.sName == sServerName)
        local tbParam = { tbData = v, bSelect = bSelect, fClick = fClick, OnSelectChange = function(pSelf, bSelect)
            pSelf.bSelect = bSelect
            EventSystem.TriggerTarget(pSelf, 'SELECT_CHANGE', bSelect)
        end}
        local pObj = self.ListFactory:Create(tbParam)
        if bSelect or self.selectData == nil then
            self.selectData = tbParam
        end
        self.List:AddItem(pObj)
    end

     if self.selectData then
         self.selectData.bSelect = true
     end
end

function tbClass:SelectChange(InData)
    if self.selectData ~= InData then
        if self.selectData then
            self.selectData:OnSelectChange(false)
        end
        self.selectData = InData
        self.selectData:OnSelectChange(true)
    end
end

function tbClass:GetStringKey(InKey)
    return UE4.UUserSetting.GetString(InKey) 
end

return tbClass