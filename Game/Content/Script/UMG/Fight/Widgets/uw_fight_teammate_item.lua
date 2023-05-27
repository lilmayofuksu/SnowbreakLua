-- ========================================================
-- @File    : uw_fight_teammate_item.lua
-- @Brief   : 战斗界面 联机战斗队伍信息
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:NotifyOnlineStateChange(true);
    self:NotifyLowHpStateChanged(false)
    self:NotifyAliveStateChange(true)
end

function tbClass:InitPlayer(roleId)
    self:SetPlayerRoleId(roleId)
end

--- 通知存活状态发生变化
function tbClass:NotifyAliveStateChange(InIsAlive)
    print("NotifyAliveStateChange", InIsAlive);
    self.Role:SetDesaturate(not InIsAlive);
end

--- 通知Ping值发生变化
function tbClass:NotifyPingValueChange(InPing)
    print("NotifyPingValueChange", InIsAlive);
end

--- 通知出战妹子发生变化
function tbClass:NotifyCharacterChange(InCharacter)
    if not InCharacter then return end
    local card = InCharacter:K2_GetPlayerMember()
    if card then
        SetTexture(self.Role, card:Icon())
    end
    print("NotifyCharacterChange", InCharacter, card);
end

--- 通知在线状态发生变化
function tbClass:NotifyOnlineStateChange(InIsOnline)
    print("NotifyOnlineStateChange", InIsOnline);
    if InIsOnline then
        self.PanelOffline:SetVisibility(UE4.ESlateVisibility.Hidden);
    else
        self.PanelOffline:SetVisibility(UE4.ESlateVisibility.HitTestInvisible);
    end
end

--- 通知低血量状态变化
function tbClass:NotifyLowHpStateChanged(InIsLowHP)
    print("NotifyLowHpStateChanged", InIsLowHP);
    if InIsLowHP then
         self.PanelLowHp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible);
    else
         self.PanelLowHp:SetVisibility(UE4.ESlateVisibility.Hidden);
    end
end

return tbClass
