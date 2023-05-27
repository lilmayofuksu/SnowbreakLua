-- ========================================================
-- @File    : umg_notice.lua
-- @Brief   : 公告界面
-- ========================================================
---@class tbClass
---@field ListName UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClick,function()  UI.Close(self)  end )
    self.Web.OnCommunicateWithGame:Add(   self, function(_, sUrl)  Web.Route(sUrl)  end)
    BtnAddEvent( self.BtnMask,   function()    UI.Close(self) end)
    self.ListName:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    BtnAddEvent(self.BtnEvent, function() if self.nType == NOTICE_TYPE.ACTIVE then return end  self:ChangeType(NOTICE_TYPE.ACTIVE) end)
    BtnAddEvent(self.BtnSystem, function() if self.nType == NOTICE_TYPE.SYSTEM then return end self:ChangeType(NOTICE_TYPE.SYSTEM)  end)
    self.ListFactory = Model.Use(self)
    self.tbPosts = {}

    self.tbCacheRed = {[1] = self.NewEvent, [0] = self.NewSystem}

    self.SID = PlayerSetting.SSID_OTHER

    BtnAddEvent(self.BtnSelect, function ()
        PlayerSetting.Set(self.SID, OtherType.NOTICE_DISTURB, {not self.IsCheck and 1 or 0})
        PlayerSetting.Save()
        self:UpdateSettingCheck()
    end)
end

function tbClass:OnClose()
    UI.Call2('Main', 'BindNoticeTimer', true)
    UE4.UUserSetting.Save()

    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(false)
    else
        if UI.IsOpen("Main") then
            GuideLogic.CheckGuide("main")
        end
    end
end

---打开UI
---@param nType NOTICE_TYPE 公告类型
function tbClass:OnOpen(nType)
    self.nType = nType or NOTICE_TYPE.ACTIVE
    self:ChangeType(self.nType)
    self:UpdateSettingCheck()
    Notice.Opened = true
    Notice.PullNotice()
    me:SetAttribute(PlayerSetting.GID, PlayerSetting.SID_NOTICE, 1)
    UI.Call2('Main', 'BindNoticeTimer', false)

    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(true)
    end
    UI.CloseByName("FileCheckRet")
end

function tbClass:UpdateSettingCheck()
    self.IsCheck = PlayerSetting.GetOne(PlayerSetting.SSID_OTHER, OtherType.NOTICE_DISTURB) == 1
    if self.IsCheck then
        WidgetUtils.HitTestInvisible(self.Check)
        --WidgetUtils.Collapsed(self.UnCheck)
    else
        --WidgetUtils.HitTestInvisible(self.UnCheck)
        WidgetUtils.Collapsed(self.Check)
    end
end

---类型切换
---@param nType NOTICE_TYPE 公告类型
function tbClass:ChangeType(nType)
    print('change type:', nType)
    self.nType = nType
    if nType == NOTICE_TYPE.ACTIVE then
        WidgetUtils.HitTestInvisible(self.EventCheck)
        WidgetUtils.Collapsed(self.SystemCheck)
    else
        WidgetUtils.Collapsed(self.EventCheck)
        WidgetUtils.HitTestInvisible(self.SystemCheck)
    end
    
    self:UpdateDisplay()
end

---刷新公告
function tbClass:Refresh(tbPosts)
    self.tbPosts = {}
    for _, tbInfo in ipairs(tbPosts or {}) do
        local nType = tbInfo.type
        self.tbPosts[nType] = self.tbPosts[nType] or {}
        table.insert(self.tbPosts[nType], tbInfo)
    end
    self:ChangeType(self.nType)
    self:UpdateRedInfo()
end

function tbClass:UpdateRedInfo()
    for _, pw in pairs(self.tbCacheRed or {}) do
        WidgetUtils.Collapsed(pw)
    end
    local tbTip = {[0] = false, [1] = false, [2] = false}
    for nType, items in pairs(self.tbPosts or {}) do
        for _, info in ipairs(items or {}) do
            if tbTip[nType] == false and not Notice.IsRead(info) then
                local pw = self.tbCacheRed[nType]
                if pw then
                    WidgetUtils.HitTestInvisible(pw)
                end
            end
        end
    end
end

---更新公告显示信息
function tbClass:UpdateDisplay()
    if not self.nType then return end
    local tbDisplay = self.tbPosts[self.nType] or {}
    self:DoClearListItems(self.ListName)
    table.sort(tbDisplay, function(a, b)
        if a.weight > b.weight then
            return true
        else
            if a.weight == b.weight then
                return a.start_time > b.start_time
            end
        end
        return false
    end)

    self.currentSelect = nil
    local fItemClick = function(param)
        if self.currentSelect == param then return end
        self:ItemSelectChange(param)
    end
    for _, tbInfo in ipairs(tbDisplay) do

        local tbParam = {tbInfo = tbInfo, bSelect = false, fClick = fItemClick, fOnSelectChange = function(pSelf, bSelect)
            pSelf.bSelect = bSelect
            EventSystem.TriggerTarget(pSelf, 'SELECT_CHANGE', bSelect)
        end}
        if self.currentSelect == nil then
            self.currentSelect = tbParam
            tbParam.bSelect = true
        end
        self.ListName:AddItem(self.ListFactory:Create(tbParam))
    end
    if self.currentSelect then
        self:ItemSelectChange(self.currentSelect)
        WidgetUtils.Visible(self.Web)
    else
        WidgetUtils.Collapsed(self.Web)
    end
end

---公告条目选择变化
function tbClass:ItemSelectChange(param)
    if self.currentSelect then  self.currentSelect:fOnSelectChange(false) end
    self.currentSelect = param
    self.currentSelect:fOnSelectChange(true)
    self.Web:LoadString(string.gsub(LocalContent(param.tbInfo.content), "HYZHENGYUAN45WBASE64DATA", NOTICE_TTF), '/game/notice')
    --print('web load :', param.tbInfo.content)
end

return tbClass
