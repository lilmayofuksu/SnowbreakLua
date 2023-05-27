-- ========================================================
-- @File    : Profile.lua
-- @Brief   : 玩家名片相关接口
-- ========================================================

---名片接口
---@class Profile
Profile = {}

Profile.SHOWITEM_FIRST  = 1 ---第1个展示卡
Profile.SHOWITEM_SECOND = 2 ---第2个展示卡
Profile.SHOWITEM_THIRD  = 3 ---第3个展示卡
Profile.SHOWITEM_CARD   = 4 ---看板娘

---@class ShowItem 玩家展示物品信息
---@field nGenre number GDPL的G
---@field nDetail number GDPL的D
---@field nParticular number GDPL的P
---@field nLevel number GDPL的L
---@field nEnhanceLevel number 道具等级

---@class PlayerProfile 玩家名片
---@field nPid number 玩家ID
---@field nCreateTime number 创建时间
---@field bActive boolean 是否活跃
---@field bOnline boolean 是否在线
---@field nLogoutTime number 最近一次下线时间
---@field sName string 玩家名称
---@field nFace number 头像ID
---@field nFaceFrame number 头像框ID
---@field sSign string 个性签名
---@field nLevel number 玩家等级
---@field tbShowItems ShowItem[] 玩家展示物品
---@field tbShowAttrs number[] 玩家展示属性
---@field bHaveVigor boolean 存在好友体力
---@field bVigorGot boolean 已经领取好友体力
---@field bVigorReturned boolean 已经回赠好友体力

---将名片对象转化为Lua类
---@param pPlayerProfile UE4.UPlayerProfile
---@return PlayerProfile|nil
function Profile.Trans(pPlayerProfile)
    if not pPlayerProfile then
        return nil
    end

    ---@type PlayerProfile
    local tbProfile = {
        nPid = pPlayerProfile:Id(),
        nCreateTime = pPlayerProfile:CreateTime(),
        bActive = pPlayerProfile:Level() > 0,
        bOnline = pPlayerProfile:IsOnline(),
        nLogoutTime = pPlayerProfile:LogoutTime(),
        sName = pPlayerProfile:Nick(),
        nFace = pPlayerProfile:Face(),
        nFaceFrame = pPlayerProfile:FaceFrame(),
        sSign = pPlayerProfile:Sign(),
        nLevel = pPlayerProfile:Level(),
        bHaveVigor = pPlayerProfile:HaveVigor(),
        bVigorGot = pPlayerProfile:VigorGot(),
        bVigorReturned = pPlayerProfile:VigorReturned()
    }

    local pShowItemList = UE4.TArray(UE4.UItem)
    pPlayerProfile:GetShowItems(pShowItemList)
    tbProfile.tbShowItems = {}
    for i = 1, pShowItemList:Length() do
        local pItem = pShowItemList:Get(i)
        if pItem then
            local tbItem = Profile.ShowItem(pItem)
            table.insert(tbProfile.tbShowItems, tbItem)
        end
    end

    local pShowAttrList = UE4.TArray(UE4.int32)
    pPlayerProfile:GetShowAttrs(pShowAttrList)
    tbProfile.tbShowAttrs = {}
    for i = 1, pShowAttrList:Length() do
        table.insert(tbProfile.tbShowAttrs, pShowAttrList:Get(i))
    end

    return tbProfile
end

---转换ShowItem
---@param pItem UE4.UItem
---@return ShowItem
function Profile.ShowItem(pItem)
    return {
        nGenre = pItem:Genre(),
        nDetail = pItem:Detail(),
        nParticular = pItem:Particular(),
        nLevel = pItem:Level(),
        nEnhanceLevel = pItem:EnhanceLevel()
    }
end
