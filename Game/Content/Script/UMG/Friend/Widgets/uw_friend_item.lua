-- ========================================================
-- @File    : uw_friend_item.lua
-- @Brief   : 好友界面右侧列表元素
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)

    self.tbHandle = {}
    self.tbHandle[1] = function(tbData)
        return self:ShowFriend(tbData)
    end
    self.tbHandle[2] = function(tbData)
        return self:ShowRequest(tbData)
    end
    self.tbHandle[3] = function(tbData)
        return self:ShowFindResult(tbData)
    end
    self.tbHandle[4] = function(tbData)
        return self:ShowBlacklist(tbData)
    end
end

---@param pObj ModelInstance
function tbClass:OnListItemObjectSet(pObj)
    self:DoClearListItems(self.BtnList)
    local tbBtnList = self.tbHandle[pObj.Data.nType](pObj.Data)
    for _, tbData in ipairs(tbBtnList) do
        self.BtnList:AddItem(self.Factory:Create(tbData))
    end
end

function tbClass:ShowBase(tbData)
    ---@type PlayerProfile
    local tbProfile = tbData.tbProfile
    if tbProfile.nLogoutTime > 0 then
        WidgetUtils.Collapsed(self.online)
        WidgetUtils.Visible(self.offline)
        local nDay, nHour, _, _ = TimeDiff(GetTime(), tbProfile.nLogoutTime)
        if nDay > 0 then
            self.TxtOffline:SetText(string.format(Text("ui.TxtFriendtab14"), nDay))
        elseif nHour > 0 then
            self.TxtOffline:SetText(string.format(Text("ui.TxtFriendtab13"), nHour))
        else
            self.TxtOffline:SetText(Text("ui.TxtFriendtab19"))
        end
    elseif not tbProfile.bActive then -- 失联玩家
        WidgetUtils.Collapsed(self.online)
        WidgetUtils.Visible(self.offline)
        self.TxtOffline:SetText(Text("ui.TxtFriendtab20"))
    else
        WidgetUtils.Visible(self.online)
        WidgetUtils.Collapsed(self.offline)
    end

    if tbProfile.bActive then
        WidgetUtils.Visible(self.Level)
        self.TxtLevel:SetText(tostring(tbProfile.nLevel))
    else
        WidgetUtils.Collapsed(self.Level)
    end

    self.TxSign:SetText(tbProfile.sSign)

    if #tbProfile.sName > 0 then
        self.TxtName:SetText(tbProfile.sName)
    else
        self.TxtName:SetText(tostring(tbProfile.nPid))
    end

    local nFace = 0
    local tbFaceCard = tbProfile.tbShowItems[Profile.SHOWITEM_CARD]
    if tbFaceCard then
        local pTemp =
            UE4.UItem.FindTemplate(tbFaceCard.nGenre, tbFaceCard.nDetail, tbFaceCard.nParticular, tbFaceCard.nLevel)
        if pTemp then
            nFace = pTemp.Icon
        end
    end
    self.ImgFace:Set(
        nFace,
        function()
            UI.Open("FriendAccount", tbProfile)
        end
    )
end

function tbClass:ShowFriend(tbData)
    self:ShowBase(tbData)
    ---@type PlayerProfile
    local tbProfile = tbData.tbProfile
    local tbBtn = {}
    if tbProfile.bHaveVigor and (not tbProfile.bVigorGot) then
        tbBtn.bVigorGet = true
        tbBtn.funcClick = function()
            Friend.RecvFriendVigor(
                tbProfile.nPid,
                true,
                function(nFriend)
                    if nFriend == tbProfile.nPid then
                        tbData.funcUpdate()
                        if tbProfile.bVigorReturned then
                            UI.ShowTip("tip.friend_EnergyGet")
                        elseif Friend.VigorFull() then
                            UI.ShowTip("tip.FriendVigorMax")
                        else
                            UI.ShowTip("tip.friend_EnergyBoth")
                        end
                    end
                end
            )
        end
    elseif not tbProfile.bVigorReturned then
        tbBtn.bVigorSend = true
        tbBtn.funcClick = function()
            Friend.GiveFriendVigor(
                tbProfile.nPid,
                function(nFriend)
                    if nFriend == tbProfile.nPid then
                        tbData.funcUpdate()
                        UI.ShowTip("tip.friend_EnergyGive")
                    end
                end
            )
        end
    else
        tbBtn.bVigorGot = true
        tbBtn.funcClick = function()
            UI.ShowTip("tip.GiveFriendVigorDuplicated")
        end
    end
    return {tbBtn}
end

function tbClass:ShowRequest(tbData)
    self:ShowBase(tbData)

    --- 好友申请不需要显示在线状态
    WidgetUtils.Collapsed(self.offline)
    WidgetUtils.Collapsed(self.online)

    local tbBtnList = {
        {
            bDisagreeFriend = true,
            funcClick = function()
                Friend.RefuseFriendRequest(
                    tbData.tbProfile.nPid,
                    function(nPid)
                        if nPid ~= tbData.tbProfile.nPid then
                            return
                        end
                        tbData.funcUpdate(tbData.tbProfile.nPid)
                        UI.ShowTip("tip.friend_RefuseOther")
                    end
                )
            end
        },
        {
            bAgreeFriend = true,
            funcClick = function()
                if Friend.FriendCount() >= Player.GetMaxFriends(me:Level()) then
                    UI.ShowTip("tip.friend_FullMe")
                    return
                end
                Friend.AgreeFriendRequest(
                    tbData.tbProfile.nPid,
                    function(nPid)
                        if nPid ~= tbData.tbProfile.nPid then
                            return
                        end
                        tbData.funcUpdate(tbData.tbProfile.nPid)
                        UI.ShowTip("tip.friend_AgreeOther")
                    end
                )
            end
        }
    }
    return tbBtnList
end

function tbClass:ShowFindResult(tbData)
    self:ShowBase(tbData)
    local bCanAdd = tbData.tbProfile.nPid ~= me:Id()
    bCanAdd = bCanAdd and (not Friend.IsFriend(tbData.tbProfile.nPid))
    bCanAdd = bCanAdd and tbData.tbProfile.bActive
    if not bCanAdd then
        return {}
    end
    return {
        {
            bAddFriend = true,
            funcClick = function()
                Friend.SendFriendRequest(
                    tbData.tbProfile.nPid,
                    function(nPid)
                        if nPid == tbData.tbProfile.nPid then
                            tbData.funcUpdate(tbData.tbProfile.nPid)
                            UI.ShowTip("tip.friend_AddOther")
                        end
                    end
                )
            end
        }
    }
end

function tbClass:ShowBlacklist(tbData)
    self:ShowBase(tbData)
    return {
        {
            bDelFriend = true,
            funcClick = function()
                Friend.DelBlacklist(
                    tbData.tbProfile.nPid,
                    function(nPid)
                        if nPid == tbData.tbProfile.nPid then
                            tbData.funcUpdate(tbData.tbProfile.nPid)
                            UI.ShowTip("tip.friend_del_blacklist")
                        end
                    end
                )
            end
        }
    }
end

return tbClass
