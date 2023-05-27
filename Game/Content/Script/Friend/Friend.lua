-- ========================================================
-- @File    : Friend.lua
-- @Brief   : 好友相关接口
-- ========================================================
---好友相关
---@class Friend
Friend = {}

---赠送好友体力
---@param nFriend number 好友的Pid
---@param funcCallback fun(nFriend: number) 完成时的回调
function Friend.GiveFriendVigor(nFriend, funcCallback)
    local pProfile = me:GetFriend(nFriend)
    if not pProfile then
        UI.ShowTip("tip.friend_not_exist")
        return
    end
    if pProfile:VigorReturned() then
        UI.ShowTip("tip.GiveFriendVigorDuplicated")
        return
    end
    me:GiveFriendVigor(nFriend)
    if funcCallback then
        EventSystem.On(Event.OnGiveFriendVigor, funcCallback, true)
    end
end

---收取好友体力
---@param nFriend number 好友的Pid
---@param bReturn bool 是否回赠
---@param funcCallback fun(nFriend: number) 完成时的回调
function Friend.RecvFriendVigor(nFriend, bReturn, funcCallback)
    local pProfile = me:GetFriend(nFriend)
    if not pProfile then
        UI.ShowTip("tip.friend_not_exist")
        return
    end
    if pProfile:VigorGot() then
        UI.ShowTip("tip.GainFriendVigorDuplicated")
        return
    end
    me:RecvFriendVigor(nFriend)

    if (not pProfile:VigorReturned()) and bReturn then
        EventSystem.On(Event.OnRecvFriendVigor, function(nFriend)
            if nFriend and nFriend > 0 then
                Friend.GiveFriendVigor(nFriend, funcCallback)
            elseif funcCallback then
                funcCallback(false)
            end
        end, true)
        return
    end

    if funcCallback then
        EventSystem.On(Event.OnRecvFriendVigor, funcCallback, true)
    end
end

---收赠所有好友体力
---@param funcCallback fun(bSuccess: boolean) 完成时的回调
function Friend.DealAllFriendVigor(funcCallback)
    UI.ShowConnection()

    local handleOnce = function(nRetPid)
        local bEventSuccess = (nRetPid ~= nil) and (nRetPid ~= 0)

        if bEventSuccess then
            local tbFriends = Friend.GetFriends()
            if #tbFriends > 0 then
                for _, tbFriend in ipairs(tbFriends) do
                    if tbFriend.nPid ~= nRetPid then
                        if tbFriend.bHaveVigor and (not tbFriend.bVigorGot) then
                            me:RecvFriendVigor(tbFriend.nPid)
                            return
                        end
                        if not tbFriend.bVigorReturned then
                            me:GiveFriendVigor(tbFriend.nPid)
                            return
                        end
                    end
                end
            end
        end

        EventSystem.Remove(Friend.nEventRecvAllFriendVigor)
        EventSystem.Remove(Friend.nEventGiveAllFriendVigor)
        UI.CloseConnection()
        funcCallback(bEventSuccess)
        return
    end

    EventSystem.Remove(Friend.nEventRecvAllFriendVigor)
    Friend.nEventRecvAllFriendVigor = EventSystem.On(Event.OnRecvFriendVigor, handleOnce)
    EventSystem.Remove(Friend.nEventGiveAllFriendVigor)
    Friend.nEventGiveAllFriendVigor = EventSystem.On(Event.OnGiveFriendVigor, handleOnce)
    handleOnce(-1) -- 开始事件循环
end

---判断是不是好友
---@param nPid number 玩家ID
---@return boolean
function Friend.IsFriend(nPid)
    if me:GetFriend(nPid) then
        return true
    else
        return false
    end
end

---获取好友
---@param nPid number 玩家ID
---@return PlayerProfile|nil
function Friend.GetFriend(nPid) return Profile.Trans(me:GetFriend(nPid)) end

---获取好友列表
---@return PlayerProfile[]
function Friend.GetFriends()
    local pOutList = UE4.TArray(UE4.UPlayerProfile)
    me:GetFriends(pOutList)
    local tbList = {}
    for i = 1, pOutList:Length() do
        table.insert(tbList, Profile.Trans(pOutList:Get(i)))
    end
    return tbList
end

---删除好友
---@param nFriend number 好友ID
---@param funcCallback fun(nFriend: number)|nil 删除后的回调
function Friend.RemoveFriend(nFriend, funcCallback)
    if not Friend.IsFriend(nFriend) then return end
    me:RemoveFriend(nFriend)
    if funcCallback then
        EventSystem.On(Event.OnRemoveFriend, funcCallback, true)
    end
end

---好友个数
---@return number
function Friend.FriendCount() return me:FriendCount() end

---获取好友申请列表
---@return PlayerProfile[]
function Friend.GetRequests()
    local pOutList = UE4.TArray(UE4.UPlayerProfile)
    me:GetFriendRequests(pOutList)
    local tbList = {}
    for i = 1, pOutList:Length() do
        local pProfile = Profile.Trans(pOutList:Get(i))
        if pProfile.bActive then table.insert(tbList, pProfile) end
    end
    return tbList
end

---发送好友申请
---@param nPid number 玩家Pid
---@param funcCallback fun(nPlayer: number) 完成时的回调
function Friend.SendFriendRequest(nPid, funcCallback)
    if Friend.FriendCount() >= Player.GetMaxFriends(me:Level()) then
        UI.ShowTip("tip.friend_FullMe")
        return
    end

    ---如果在黑名单中则先从黑名单中删除
    if Friend.BlacklistCheck(nPid) then
        Friend.DelBlacklist(nPid, function(nPlayer)
            if nPlayer == 0 then funcCallback(0) end
            if nPlayer == nPid then
                Friend.SendFriendRequest(nPid, funcCallback)
            end
        end)
        return
    end

    me:RequestAddFriend(nPid)
    if funcCallback then
        EventSystem.On(Event.OnSendFriendReq, funcCallback, true)
    end
end

---同意好友申请
---@param nPid number 好友的Pid
---@param funcCallback fun(nPlayer: number) 完成时的回调
function Friend.AgreeFriendRequest(nPid, funcCallback)
    local pProfile = me:GetFriendRequest(nPid)
    if not pProfile then return end
    me:DealFriendRequest(nPid, true)
    if funcCallback then
        EventSystem.Remove(Friend.nAgreeFriendEvent)
        Friend.nAgreeFriendEvent = EventSystem.On(Event.OnAgreeFriendReq,
                                                  funcCallback)
    end
end

---拒绝好友申请
---@param nPid number 好友的Pid
---@param funcCallback fun(nPlayer: number) 完成时的回调
function Friend.RefuseFriendRequest(nPid, funcCallback)
    local pProfile = me:GetFriendRequest(nPid)
    if not pProfile then return end
    me:DealFriendRequest(nPid, false)
    if funcCallback then
        EventSystem.Remove(Friend.nEventRefuseFriendRequest)
        Friend.nEventRefuseFriendRequest = EventSystem.On(Event.OnRefuseFriendReq, funcCallback)
    end
end

---处理所有申请
---@param bAgree boolean 是否同意
---@param funcCallback fun(bSuccess: boolean) 完成时的回调
function Friend.DealAllFriendRequest(bAgree, funcCallback)
    UI.ShowConnection()

    local tbList = Friend.GetRequests()
    local handleOnce = function(nDealedPid, nError)
        local bReturn = (nError and nError ~= 0 and nError ~= 420)
        bReturn = bReturn or #tbList == 0
        if bReturn then
            if bAgree then
                EventSystem.Remove(Friend.nEventAgreeAllFriendRequest)
            else
                EventSystem.Remove(Friend.nEventRefuseAllFriendRequest)
            end
            funcCallback(nDealedPid ~= 0)
            UI.CloseConnection()
            return
        end

        me:DealFriendRequest(tbList[1].nPid, bAgree)
        table.remove(tbList, 1)
    end

    if bAgree then
        EventSystem.Remove(Friend.nEventAgreeAllFriendRequest)
        Friend.nEventAgreeAllFriendRequest = EventSystem.On(Event.OnAgreeFriendReq, handleOnce)
    else
        EventSystem.Remove(Friend.nEventRefuseAllFriendRequest)
        Friend.nEventRefuseAllFriendRequest = EventSystem.On(Event.OnRefuseFriendReq, handleOnce)
    end
    handleOnce()
end

---获取好友推荐
---@param nCount number 希望能获取多少个推荐玩家
---@param funcRecv fun(tbPlayers: PlayerProfile[])|nil 获取推荐列表的回调
---@return number|nil 当回调时，返回监听的事件ID
function Friend.GetRecommend(nCount, funcRecv)
    me:GetRecommendPlayers(nCount)
    if not funcRecv then return end

    EventSystem.Remove(Friend.nEventGetRecommend)
    Friend.nEventGetRecommend = EventSystem.On(Event.GetFriendRecommend, function(pTArrayList)
        local tbPlayers = {}
        for i = 1, pTArrayList:Length() do
            local tbProfile = Profile.Trans(pTArrayList:Get(i))
            -- 剔除黑名单、低于5级的玩家
            if not (Friend.BlacklistCheck(tbProfile.nPid) or tbProfile.nLevel <
                5) then table.insert(tbPlayers, tbProfile) end
        end
        funcRecv(tbPlayers)
    end, true)
end

---获取黑名单
---@return PlayerProfile[]
function Friend.GetBlacklist()
    local pOutList = UE4.TArray(UE4.UPlayerProfile)
    me:GetBlacklist(pOutList)
    local tbList = {}
    for i = 1, pOutList:Length() do
        table.insert(tbList, Profile.Trans(pOutList:Get(i)))
    end
    return tbList
end

---检查是否在黑名单中
---@param nPid number 玩家ID
---@return boolean
function Friend.BlacklistCheck(nPid)
    if me:FindBlacklist(nPid) then
        return true
    else
        return false
    end
end

---拉黑
---@param nPid number 玩家ID
---@param funcCallback fun(nPlayer: number) 完成时的回调
function Friend.AddBlacklist(nPid, funcCallback)
    -- 拉黑前拒绝好友申请
    if me:GetFriendRequest(nPid) then
        Friend.RefuseFriendRequest(nPid, function(nFriend)
            if nFriend == nPid then
                Friend.AddBlacklist(nPid, funcCallback)
            elseif funcCallback then
                funcCallback(nFriend)
            end
        end)
        return
    end

    if Friend.BlacklistCheck(nPid) then
        UI.ShowTip("tip.blacklist_exist")
        return
    end
    me:AddBlacklist(nPid)
    if funcCallback then
        EventSystem.On(Event.OnAddBlackList, funcCallback, true)
    end
end

---解除黑名单
---@param nPid number 玩家ID
---@param funcCallback fun(nPlayer: number) 完成时的回调
function Friend.DelBlacklist(nPid, funcCallback)
    if not Friend.BlacklistCheck(nPid) then
        UI.ShowTip("tip.blacklist_not_exist")
        return
    end
    me:RemoveBlacklist(nPid)
    if funcCallback then
        EventSystem.On(Event.OnDelBlackList, funcCallback, true)
    end
end

---清空黑名单
---@param funcCallback fun(bSuccess: bool) 完成时的回调
function Friend.ClearBlacklist(funcCallback)
    UI.ShowConnection()

    local handleOnce = function()
        local pOutList = UE4.TArray(UE4.UPlayerProfile)
        me:GetBlacklist(pOutList)
        if pOutList:Length() <= 0 then
            EventSystem.Remove(Friend.nEventClearBlacklist)
            funcCallback(true)
            UI.CloseConnection()
            return
        end
        local pFst = pOutList:Get(1)
        me:RemoveBlacklist(pFst:Id())
    end

    EventSystem.Remove(Friend.nEventClearBlacklist)
    Friend.nEventClearBlacklist = EventSystem.On(Event.OnDelBlackList, handleOnce)
    handleOnce()
end

---搜索玩家
---@param nPid number 玩家ID
---@param funcOnFound fun(pProfile: PlayerProfile) 获取搜索结果的回调
function Friend.FindPlayer(nPid, funcOnFound)
    me:FindPlayer(nPid)
    if funcOnFound then
        EventSystem.On(Event.OnFindPlayer, function(pProfile)
            funcOnFound(Profile.Trans(pProfile))
        end, true)
    end
end

---是否有待领取的体力
---@param bCheckReturned boolean 是否检查有没有可以送的体力
---@return boolean
function Friend.PendingVigor(bCheckReturned)
    -- 当不关注是否可送且好友体力领取次数已满则不返回可领取
    if me:GetAttribute(71, 1) >= 20 and (not bCheckReturned) then
        return false
    end

    local pOutList = UE4.TArray(UE4.UPlayerProfile)
    me:GetFriends(pOutList)
    for i = 1, pOutList:Length() do
        local pProfile = pOutList:Get(i)
        if pProfile:HaveVigor() and (not pProfile:VigorGot()) then
            return true
        end
        if bCheckReturned and (not pProfile:VigorReturned()) then
            return true
        end
    end
    return false
end

---好友体力是否已满
---@return boolean
function Friend.VigorFull()
    return me:GetAttribute(71, 1) >= 20
end

---是否有待处理的请求
---@return boolean
function Friend.PendingRequest()
    local pList = UE4.TArray(UE4.UPlayerProfile)
    me:GetFriendRequests(pList)
    return pList:Length() > 0
end

---是否有未处理事件
---@return boolean
function Friend.Pending()
    if Friend.PendingVigor() then return true end

    local pList = UE4.TArray(UE4.UPlayerProfile)
    me:GetFriendRequests(pList)
    if pList:Length() > 0 then return true end

    return false
end

---清楚好友相关事件
function Friend.ClearEvent()
    EventSystem.Remove(Friend.nEventRecvAllFriendVigor)
    EventSystem.Remove(Friend.nEventGiveAllFriendVigor)
    EventSystem.Remove(Friend.nAgreeFriendEvent)
    EventSystem.Remove(Friend.nEventRefuseFriendRequest)
    EventSystem.Remove(Friend.nEventAgreeAllFriendRequest)
    EventSystem.Remove(Friend.nEventRefuseAllFriendRequest)
    EventSystem.Remove(Friend.nEventGetRecommend)
    EventSystem.Remove(Friend.nEventClearBlacklist)
end