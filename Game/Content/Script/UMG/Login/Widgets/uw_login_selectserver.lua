-- ========================================================
-- @File    : uw_login_selectserver.lua
-- @Brief   : 海外服务器条目
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.ServerList)

    BtnAddEvent(self.BtnClose, function()
        self:DoSelect()
    end)
    self.selectData = nil
end

function tbClass:OnOpen()
    Login.GetAreaList()
    self:ShowServerList()
    if self.Bg and self.Bg.Init then
        self.Bg:Init(function()
            self:DoSelect()
        end)
    end
end

function tbClass:ShowServerList()
    self:DoClearListItems(self.ServerList)
    local tbCfg,sSelect = Login.GetShowAreaList()
    if not tbCfg then
        self.selectData = {tbData = {}}
        return
    end

     --显示服务器列表
    local fClick = function(InData)
        self:SelectChange(InData)
    end
    for k, v in ipairs(tbCfg) do
        local tbInfo = {sName = v[1] or ''}
        local bSelect = (tbInfo.sName == sSelect)
        local tbParam = { tbData = tbInfo, bSelect = bSelect, fClick = fClick, OnSelectChange = function(pSelf, bSelect)
            pSelf.bSelect = bSelect
            EventSystem.TriggerTarget(pSelf, 'SELECT_CHANGE', bSelect)
        end}
        local pObj = self.ListFactory:Create(tbParam)
        if bSelect then
            self.selectData = tbParam
        end
        self.ServerList:AddItem(pObj)
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
        --self:DoSelect()
    end
end

function tbClass:GetStringKey(InKey)
    return UE4.UUserSetting.GetString(InKey) 
end

function tbClass:DoSelect()
    if self.selectData then
        Login.SetServer(nil)
        Login.OnSetArea(self.selectData.tbData)
        --打点
        Adjust.DoRecord("1n0lwa");

        local loginUI = UI.GetUI("Login")
        if loginUI and loginUI:IsOpen() then
            --loginUI:DownloadServer(function() end)
        end
    end
    WidgetUtils.Collapsed(self)
    UE4.UUserSetting.Save()
end

return tbClass