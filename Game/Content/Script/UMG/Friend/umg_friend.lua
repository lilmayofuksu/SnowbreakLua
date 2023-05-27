-- ========================================================
-- @File    : umg_friend.lua
-- @Brief   : 好友界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

-- 分类下标
tbClass.PANEL_FRIENDS = 1
tbClass.PANEL_REQUESTS = 2
tbClass.PANEL_FIND = 3
tbClass.PANEL_BLACKLIST = 4

function tbClass:OnInit()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.LeftList)

    -- 初始化左边栏
    self.tbLeftList = {}
    self.tbLeftList[self.PANEL_FRIENDS] = {
        sTitle = "ui.TxtFriendtab1",
        nIcon = 1701080,
        funcFlush = function(...)
            self:FlushFriends(...)
        end,
        funcNew = function()
            return Friend.PendingVigor()
        end
    }
    self.tbLeftList[self.PANEL_REQUESTS] = {
        sTitle = "ui.TxtFriendtab2",
        nIcon = 1701081,
        funcFlush = function(...)
            self:FlushRequest(...)
        end,
        funcNew = function()
            return Friend.PendingRequest()
        end
    }
    self.tbLeftList[self.PANEL_FIND] = {
        sTitle = "ui.TxtFriendtab3",
        nIcon = 1701082,
        funcFlush = function(...)
            self:FlushFind(...)
        end,
        funcNew = function()
            return false
        end,
        funcUpdate = function(nPid)
            if self.tbRecommand then
                local tbTmpList = {}
                for _, tbPlayer in ipairs(self.tbRecommand) do
                    if tbPlayer.nPid ~= nPid then
                        table.insert(tbTmpList, tbPlayer)
                    end
                end
                self.tbRecommand = tbTmpList
            end
            self:SetRightList(self.tbRecommand)
        end
    }
    self.tbLeftList[self.PANEL_BLACKLIST] = {
        sTitle = "ui.TxtFriendtab4",
        nIcon = 1701083,
        funcFlush = function(...)
            self:FlushBlacklist(...)
        end,
        funcNew = function()
            return false
        end
    }
    local funcNewTab = function(nIdx)
        local tbLeftList = self.tbLeftList[nIdx]
        local tbTab = {
            sTitle = Text(tbLeftList.sTitle),
            nIcon = tbLeftList.nIcon,
            bSelected = false,
            funcOnClick = function()
                self:SetPanel(nIdx)
            end
        }
        local pObj = self.Factory:Create(tbTab)
        pObj.ParentUI = self
        self.LeftList:AddItem(pObj)
        tbLeftList.pTab = pObj
    end
    funcNewTab(self.PANEL_FRIENDS)
    funcNewTab(self.PANEL_REQUESTS)
    funcNewTab(self.PANEL_FIND)
    funcNewTab(self.PANEL_BLACKLIST)

    self.TxtID:SetText(tostring(me:Id()))
    self.EditTxtSearch:SetHintText(Text("ui.TxtFriendtab18"))

    local funcFlushFriendCount = function()
        self.TxtFriendCount:SetText(string.format("%d/%d", me:FriendsCount(), Player.GetMaxFriends(me:Level())))
    end
    funcFlushFriendCount()
    self.nEventNewFriend = EventSystem.On(Event.OnNewFriend, funcFlushFriendCount)
    self.nEventDelFriend = EventSystem.On(Event.OnDelFriend, funcFlushFriendCount)
    self.nEventFlushPanel =
        EventSystem.OnTarget(
        self,
        "FLUSH_PANEL",
        function(_, ...)
            self:Update4Callback(self.nCurPanel, ...)
        end
    )
end

function tbClass:OnOpen(nPanel)
    self:FlushDot()
    self:SetPanel(nPanel or self.PANEL_FRIENDS)
    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnClose()
    EventSystem.Remove(self.nEventNewFriend)
    EventSystem.Remove(self.nEventDelFriend)
    EventSystem.Remove(self.nEventFlushPanel)
    Friend.ClearEvent()
end

---切换页面
function tbClass:SetPanel(nPanel, ...)
    if self.nCurPanel then
        self.tbLeftList[self.nCurPanel].pTab.Data.bSelected = false
        if self.tbLeftList[self.nCurPanel].pTab.Data.SubUI then
            self.tbLeftList[self.nCurPanel].pTab.Data.SubUI:SetSelected(false)
        end
    end
    self.tbLeftList[nPanel].pTab.Data.bSelected = true
    if self.tbLeftList[nPanel].pTab.Data.SubUI then
        self.tbLeftList[nPanel].pTab.Data.SubUI:SetSelected(true)
    end
    self.nCurPanel = nPanel

    self.tbLeftList[nPanel].funcFlush(...)
    self.RightList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    self:PlayAnimation(self.Enter)
    self.RightList:PlayAnimation(0)
end

---刷新红点
function tbClass:FlushDot()
    for i = self.PANEL_FRIENDS, self.PANEL_BLACKLIST do
        local tbPanel = self.tbLeftList[i]
        tbPanel.pTab.Data.bNew = tbPanel.funcNew()
        if tbPanel.pTab.Data.SubUI then
            tbPanel.pTab.Data.SubUI:SetNew()
        end
    end
end

---回调更新
---@param nPanel number 在哪个面板做回调
function tbClass:Update4Callback(nPanel, ...)
    if self.tbLeftList[nPanel].funcUpdate then
        self.tbLeftList[nPanel].funcUpdate(...)
    elseif self.nCurPanel == nPanel then
        self:FlushDot()
        self.tbLeftList[nPanel].funcFlush()
    end
end

---右侧列表排序规则
---@param tbList PlayerProfile[]
---@return PlayerProfile[]
function tbClass.SortRightList(tbList)
    local tbTmp = {}
    for _, tbPlayer in ipairs(tbList) do
        local tbCmp = {}
        if tbPlayer.bOnline then
            table.insert(tbCmp, 1)
        else
            table.insert(tbCmp, 0)
        end
        table.insert(tbCmp, tbPlayer.nLogoutTime)
        table.insert(tbCmp, tbPlayer.nLevel)
        if tbPlayer.bHaveVigor and (not tbPlayer.bVigorGot) then
            table.insert(tbCmp, 1)
        else
            table.insert(tbCmp, 0)
        end
        if tbPlayer.bVigorReturned then
            table.insert(tbCmp, 0)
        else
            table.insert(tbCmp, 1)
        end
        table.insert(tbTmp, {tbCmp = tbCmp, tbPlayer = tbPlayer})
    end
    table.sort(
        tbTmp,
        function(left, right)
            for i, nWeightA in ipairs(left.tbCmp) do
                local nWeightB = right.tbCmp[i]
                if nWeightA ~= nWeightB then
                    return nWeightA > nWeightB
                end
            end
            return false
        end
    )
    local tbList = {}
    for _, tbCmp in ipairs(tbTmp) do
        table.insert(tbList, tbCmp.tbPlayer)
    end
    return tbList
end

---生成右侧列表UI对象
---@param tbPlayer PlayerProfile
---@return ModelInstance
function tbClass:GenRightListItem(tbPlayer)
    local tbData = {
        Root = self,
        tbProfile = tbPlayer,
        nType = self.nCurPanel
    }
    tbData.funcUpdate = function(...)
        self:Update4Callback(tbData.nType, ...)
    end
    return self.Factory:Create(tbData)
end

---右侧列表空白效果
function tbClass:RightListEmpty(bEmpty)
    if bEmpty then
        self.TxtNone:SetText(Text("ui.TxtFriendNone" .. self.nCurPanel))
        WidgetUtils.Visible(self.PanelNone)
    else
        WidgetUtils.Collapsed(self.PanelNone)
    end
end

---设置右侧列表
---@param tbList PlayerProfile[]
function tbClass:SetRightList(tbList)
    self:RemoveRightList()
    if not tbList then
        return
    end
    for i, tbPlayer in ipairs(self.SortRightList(tbList)) do
        local pObj = self:GenRightListItem(tbPlayer)
        self.RightList:AddItem(pObj)
        self.tbRightList[tbPlayer.nPid] = pObj
        self.tbRightList.nSize = (self.tbRightList.nSize or 0) + 1
        self:RightListEmpty(false)
    end
end

---更新右侧列表
---@param tbPlayer PlayerProfile
function tbClass:UpdateRightList(tbPlayer)
    self.tbRightList = self.tbRightList or {}
    local tbList = {tbPlayer}
    for _, pObj in ipairs(self.tbRightList) do
        if pObj.tbPlayer.nPid ~= tbPlayer.nPid then
            table.insert(tbList, pObj.tbPlayer)
        end
    end
    self:RemoveRightList()
    for _, tbPlayer in ipairs(self.SortRightList(tbList)) do
        local pObj = self:GenRightListItem(tbPlayer)
        self.RightList:AddItem(pObj)
        self.tbRightList[tbPlayer.nPid] = pObj
        self.tbRightList.nSize = (self.tbRightList.nSize or 0) + 1
        self:RightListEmpty(false)
    end
end

---删除右侧列表
---@param nPid number|nil 玩家的PID，为空时清空列表
function tbClass:RemoveRightList(nPid)
    if not nPid then
        self:DoClearListItems(self.RightList)
        self.tbRightList = {}
        self:RightListEmpty(true)
        return
    end
    if self.tbRightList[nPid] then
        self.RightList:RemoveItem(self.tbRightList[nPid])
        self.tbRightList[nPid] = nil
        self.tbRightList.nSize = self.tbRightList.nSize - 1
    end
    self:RightListEmpty((not self.tbRightList.nSize) or self.tbRightList.nSize <= 0)
end

---设置下边栏
---@param tbLeft table|nil 左边按钮设置
---@param tbRight table|nil 右边按钮设置
---@param bMyid boolea|nil 是否显示ID
---@param bPanelSearch table|nil 搜索框设置
function tbClass:SetBottomBar(tbLeft, tbRight, bMyid, tbPanelSearch)
    local funcSetBtn = function(nIndex, tbCfg)
        local pBtn = self["Btn" .. nIndex]
        if not tbCfg then
            return WidgetUtils.Collapsed(pBtn)
        end
        WidgetUtils.Visible(pBtn)
        self["TxtBtn" .. nIndex .. "_1"]:SetText(tbCfg.sText)
        BtnClearEvent(pBtn)
        BtnAddEvent(pBtn, tbCfg.funcClick)
    end
    funcSetBtn(2, tbLeft)
    funcSetBtn(1, tbRight)

    if tbPanelSearch then
        WidgetUtils.Visible(self.PanelSearch)
        BtnClearEvent(self.BtnSearch)
        BtnAddEvent(self.BtnSearch, tbPanelSearch.funcClick)
    else
        WidgetUtils.Collapsed(self.PanelSearch)
    end

    if bMyid then
        WidgetUtils.Visible(self.Myid)
    else
        WidgetUtils.Collapsed(self.Myid)
    end

    WidgetUtils.Collapsed(self.BtnUnable) -- 默认不启用置灰
end

---刷新好友列表
function tbClass:FlushFriends()
    if not Friend.PendingVigor(true) then
        self:SetBottomBar()
    else
        local tbBtnRight = {
            sText = "ui.TxtFriendtab11",
            funcClick = function()
                Friend.DealAllFriendVigor(
                    function(bSuccess)
                        if Friend.VigorFull() then
                            UI.ShowTip("tip.FriendVigorMax")
                        elseif bSuccess then
                            UI.ShowTip("tip.friend_EnergyBoth")
                        end
                        self:Update4Callback(self.PANEL_FRIENDS)
                    end
                )
            end
        }
        self:SetBottomBar(nil, tbBtnRight)
    end

    self:SetRightList(Friend.GetFriends())
end

---刷新好友申请面板
function tbClass:FlushRequest()
    local tbList = Friend.GetRequests()
    self:SetRightList(tbList)
    if (not tbList) or (#tbList == 0) then
        return self:SetBottomBar()
    end

    local tbLeft = {
        sText = "ui.TxtFriendtab16",
        funcClick = function()
            Friend.DealAllFriendRequest(
                false,
                function(bSuccess)
                    if bSuccess then
                        UI.ShowTip("tip.friend_RefuseOther")
                    end
                    self:Update4Callback(self.PANEL_REQUESTS)
                end
            )
        end
    }
    local tbRight = {
        sText = "ui.TxtFriendtab17",
        funcClick = function()
            Friend.DealAllFriendRequest(
                true,
                function(bSuccess)
                    if bSuccess and self.RightList:GetNumItems() > 0 then
                        UI.ShowTip("tip.friend_AgreeOther")
                    end
                    self:Update4Callback(self.PANEL_REQUESTS)
                end
            )
        end
    }
    self:SetBottomBar(tbLeft, tbRight)
end

---刷新推荐功能的CD效果
function tbClass:UpdateRecommand()
    if self.bRecommandCD then
        WidgetUtils.Visible(self.BtnUnable)
        WidgetUtils.Collapsed(self.Btn1)
    else
        WidgetUtils.Collapsed(self.BtnUnable)
        WidgetUtils.Visible(self.Btn1)
    end
    if not self.funcBtnUnbale then
        self.funcBtnUnbale = function()
            UI.ShowTip("tip.friend_recommand_cd")
        end
        BtnClearEvent(self.BtnUnable)
        BtnAddEvent(self.BtnUnable, self.funcBtnUnbale)
    end
end

---刷新推荐
function tbClass:FlushRecommand()
    self:SetRightList({})
    if self.bRecommandCD then
        return
    end

    Friend.GetRecommend(
        10,
        function(tbPlayers)
            self:SetRightList(tbPlayers)
            self.tbRecommand = tbPlayers
        end
    )
    --冷却
    self.bRecommandCD = true
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                self.bRecommandCD = false
                if self.nCurPanel == self.PANEL_FIND then
                    self:UpdateRecommand()
                end
            end
        },
        5,
        false
    )
    self:UpdateRecommand()
end

---刷新发现面板
function tbClass:FlushFind()
    local tbSearch = {
        funcClick = function()
            local nPid = tonumber(self.EditTxtSearch:GetText())
            if (not nPid) or nPid <= 0 then
                return UI.ShowTip("ui.TxtEnterInvaildPid")
            end
            Friend.FindPlayer(
                nPid,
                function(tbProfile)
                    self:RemoveRightList()
                    if not tbProfile.bActive then
                        return UI.ShowTip("tip.friend_FindNone")
                    end
                    self:UpdateRightList(tbProfile)
                end
            )
        end
    }
    local tbBtnFlush = {
        sText = "ui.TxtFriendtab9",
        funcClick = function()
            self:FlushRecommand()
        end
    }
    local tbUnable = {}
    self:SetBottomBar(nil, tbBtnFlush, true, tbSearch, false)

    if (not self.tbRecommand) then
        self:FlushRecommand()
    else
        self:SetRightList(self.tbRecommand)
        self:UpdateRecommand()
    end
end

---刷新黑名单列表
function tbClass:FlushBlacklist()
    local tbBlackList = Friend.GetBlacklist()
    self:SetRightList(tbBlackList)
    if (not tbBlackList) or #tbBlackList <= 0 then
        return self:SetBottomBar()
    end
    local tbRecoverAll = {
        sText = "ui.TxtFriendtab12",
        funcClick = function()
            Friend.ClearBlacklist(
                function(bSuccess)
                    if bSuccess then
                        UI.ShowTip("tip.friend_del_blacklist")
                    end
                    self:Update4Callback(self.PANEL_BLACKLIST)
                end
            )
        end
    }
    self:SetBottomBar(nil, tbRecoverAll)
end

return tbClass
