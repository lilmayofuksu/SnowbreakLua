-- ========================================================
-- @File    : uw_dungeonsonline_player.lua
-- @Brief   : 联机界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")
tbClass.Panel_Friend = 1
tbClass.Panel_Recent = 2
tbClass.Panel_Recommend = 3

tbClass.TableList = {
    "ui.TxtOnlineListFriend", "ui.TxtOnlineRecent", "ui.TxtOnlineRecommend",
}

function tbClass:Construct()
    self.Factory = Model.Use(self)

    if self.Popup and self.Popup.BtnClose then
        BtnAddEvent(self.Popup.BtnClose, function()        
            WidgetUtils.Collapsed(self)
        end)
    end

    BtnAddEvent(self.BtnQuick, function()
            self:DoInviteAll()
    end)

    BtnAddEvent(self.BtnFriend, function()
            self:ShowFriend()
    end)

    BtnAddEvent(self.BtnRecent, function()
            self:ShowRecent()
    end)

    BtnAddEvent(self.BtnRecommend, function()
            self:ShowRecommend()
    end)
    self:DoClearListItems(self.ListPlayer)
    self.ListPlayer:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:DoClearListItems(self.ListSystem)
    self.ListSystem:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

--打开界面
function tbClass:OnOpen()
    if not self.nShowType then
        self.nShowType = self.Panel_Friend
    end

    self:ShowMain()
    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnDestruct()
    self.nShowType = nil
    self.pSelectTab = nil
end

--显示主要界面
function tbClass:ShowMain()
    WidgetUtils.Collapsed(self.BtnQuick)

    self:ShowLeftList()
    if self.nShowType == self.Panel_Friend then
        self:ShowFriend()
    elseif self.nShowType == self.Panel_Recent then
        self:ShowRecent()
    elseif self.nShowType == self.Panel_Recommend then
        self:ShowRecommend()
    end
end

--显示左侧列表
function tbClass:ShowLeftList()
    self:DoClearListItems(self.ListSystem)
    for i, sTitle in ipairs(self.TableList) do
            local tbParam = { tbData = {sName = sTitle}, nIdx = i, bSelect = false , fClick = function(pObj)
                self:OnSwitch(pObj)
            end}

            local pObj = self.Factory:Create(tbParam)
            if not self.pSelectTab  then
                self.pSelectTab = pObj
                tbParam.bSelect = true
            elseif self.pSelectTab.Data.nIdx == i then
                self.pSelectTab = pObj
                tbParam.bSelect = true
            end

            self.ListSystem:AddItem(pObj)
    end
end

function tbClass:OnSwitch(pObj)
    if self.pSelectTab == pObj then
        return
    end

    if self.pSelectTab then
        self.pSelectTab.pUI:OnSelectChange(false)
    end

    self.pSelectTab = pObj
    if pObj.Data.nIdx == self.Panel_Friend then
        self:ShowFriend()
    elseif pObj.Data.nIdx == self.Panel_Recent then
        self:ShowRecent()
    elseif pObj.Data.nIdx == self.Panel_Recommend then
        self:ShowRecommend()
    end
    self.pSelectTab.pUI:OnSelectChange(true)
end

--显示好友
function tbClass:ShowFriend()
    self.nShowType = self.Panel_Friend

    WidgetUtils.SelfHitTestInvisible(self.FriendCheck)
    WidgetUtils.Collapsed(self.RecentCheck)
    WidgetUtils.Collapsed(self.RecommendCheck)

    WidgetUtils.SelfHitTestInvisible(self.RecentBg)
    WidgetUtils.SelfHitTestInvisible(self.RecommendBg)
    WidgetUtils.Collapsed(self.FriendBg)

    local tbList = Friend.GetFriends()
    self:ShowPlayerList(tbList)
end

--显示近期
function tbClass:ShowRecent()
    self.nShowType = self.Panel_Recent
    WidgetUtils.SelfHitTestInvisible(self.RecentCheck)
    WidgetUtils.Collapsed(self.FriendCheck)
    WidgetUtils.Collapsed(self.RecommendCheck)

    WidgetUtils.SelfHitTestInvisible(self.FriendBg)
    WidgetUtils.SelfHitTestInvisible(self.RecommendBg)
    WidgetUtils.Collapsed(self.RecentBg)


    Online.GetRecentListProfile(function(tbPlayers)
            if self.nShowType and self.nShowType == self.Panel_Recent then
                self:ShowPlayerList(tbPlayers)
            end
        end)
end

--显示推荐
function tbClass:ShowRecommend()
    self.nShowType = self.Panel_Recommend
    WidgetUtils.SelfHitTestInvisible(self.RecommendCheck)
    WidgetUtils.Collapsed(self.RecentCheck)
    WidgetUtils.Collapsed(self.FriendCheck)

    WidgetUtils.SelfHitTestInvisible(self.FriendBg)
    WidgetUtils.SelfHitTestInvisible(self.RecentBg)
    WidgetUtils.Collapsed(self.RecommendBg)

    Online.GetRecommendListProfile(function(tbPlayers)
        if self.nShowType and self.nShowType == self.Panel_Recommend then
            self:ShowPlayerList(tbPlayers)
        end
    end)
end

--添加角色信息
function tbClass:ShowPlayerList(tbList)
    self:DoClearListItems(self.ListPlayer)
    self.tbCurList = {}

    if (not tbList) or #tbList == 0 then
        self:ShowEmpty()
        return
    end

    --筛选排序
    local tbSorted = {}
    local tbId = Online.GetRoomOthers()
    for _, tbFriendProfile in ipairs(tbList) do
        if tbFriendProfile.bOnline and not Friend.BlacklistCheck(tbFriendProfile.nPid) and not tbId[tbFriendProfile.nPid] then
            table.insert(tbSorted, tbFriendProfile)
        end
    end

    table.sort(
        tbSorted,
        function(tbLeft, tbRight)
            return tbLeft.nLevel > tbRight.nLevel
        end
    )

    --房间队员
    for _, tbFriendProfile in ipairs(tbSorted) do
         local tbData = {
            nType = self.nShowType,
            tbProfile = tbFriendProfile
        }
        local pObj = self.Factory:Create(tbData)
        self.ListPlayer:AddItem(pObj)
        self.tbCurList[tbFriendProfile.nPid] = pObj
    end
    self:ShowEmpty()
end

--一键邀请 沟通后 暂时取消
function tbClass:DoInviteAll()
    if not self.tbCurList then return end
end

--显示空白文本
function tbClass:ShowEmpty()
    if next(self.tbCurList) then
        WidgetUtils.Collapsed(self.TxtOnlinePlayer)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.TxtOnlinePlayer)
    if self.nShowType == self.Panel_Recent then
        self.TxtOnlinePlayer:SetText(Text("ui.TXTOnlineNoPlayer"))
    elseif self.nShowType == self.Panel_Friend then
        self.TxtOnlinePlayer:SetText(Text("ui.TXTOnlineFriend"))
    else
        WidgetUtils.Collapsed(self.TxtOnlinePlayer)
    end
end

return tbClass
