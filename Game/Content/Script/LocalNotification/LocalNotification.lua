-- ========================================================
-- @File    : LocalNotification/LocalNotification.lua
-- @Brief   : 本地推送相关
-- ========================================================
---@class LocalNotification 本地推送
---@field tbGameNotifications table<string, GameNotification> 游戏推送管理
---@field bResumed boolean 重起推送后的标记
LocalNotification = LocalNotification or {
    tbGameNotifications = {},
}

---------------------------------------------------- 底层接口封装 ---------------------------------------------

---发起推送，重复设定则会覆盖之前的同名推送
---@param sTitle string 标题
---@param sBody string 内容
---@param nSecondsFromNow number|nil 多少秒后推送，不传则为1，即刻推送
---@return number|nil 返回推送的唯一ID，其值为一个非负整数，失败则返回nil
function LocalNotification.Schedule(sTitle, sBody, nSecondsFromNow)
    local nID = UE4.UBlueprintPlatformLibrary.ScheduleLocalNotificationFromNow(nSecondsFromNow, sTitle, sBody, "", "")
    if nID < 0 then
        return nil
    end
    return nID
end

---取消推送
---@param nID number 发起推送时返回的ID
function LocalNotification.Cancel(nID)
    UE4.UBlueprintPlatformLibrary.CancelLocalNotificationById(nID)
end

---清空所有发起过的推送
function LocalNotification.Clean()
    UE4.UBlueprintPlatformLibrary.ClearAllLocalNotifications()
end


----------------------------------------------- 公共接口 ---------------------------------------------------

---@class NotificatioInfo 设定过的推送记录
---@field nID number 推送ID
---@field nDateTime number 触发时间

---@class GameNotification 游戏推送类
---@field sName string 名称，全局唯一
---@field nSettingType number 设置类型，同名称全局唯一
---@field tbInfo NotificatioInfo 设定过的推送记录
local GameNotification = {
    
    ---生成推送内容的方法，默认空实现
    ---@param self GameNotification
    ---@return string 标题
    ---@return string 内容
    ---@return number 多少秒后推送
    Gen = function(self) return "", "", 0 end,

    ---是否开启
    ---@param self GameNotification
    ---@return boolean
    IsEnable = function(self)
        return PlayerSetting.GetOne(PlayerSetting.SSID_NOTIFICATION, self.nSettingType) > 0
    end,

    ---开启/关闭
    ---@param self GameNotification
    ---@param bEnable boolean
    SetEnable = function(self, bEnable)
        if bEnable then
            PlayerSetting.Set(PlayerSetting.SSID_NOTIFICATION, self.nSettingType, {1})
        else
            PlayerSetting.Set(PlayerSetting.SSID_NOTIFICATION, self.nSettingType, {0})
        end
    end,
}

---获取、创建游戏推送类
---@param sName string 名称，需全局唯一
---@param nSettingType number|nil 创建时传递，对应PlayerSetting的nType，同名称全局唯一
---@return GameNotification|nil 返回推送类对象，找不到或创建失败则返回nil
function LocalNotification.GameNotification(sName, nSettingType)
    local tbExist = LocalNotification.tbGameNotifications[sName]
    if not nSettingType then
        --获取请求直接返回
        return tbExist
    elseif tbExist then
        --已存在不可创建
        return nil
    end

    ---@type GameNotification
    local tbNew = Inherit(GameNotification)

    tbNew.sName =sName
    tbNew.nSettingType = nSettingType
    tbNew.tbInfo = {}
    LocalNotification.tbGameNotifications[sName] = tbNew

    return tbNew
end

---推送功能是否开启
function LocalNotification.IsEnable()
    local bEnable = Login.IsOversea() and IsMobile() -- 目前只有海外的移动端才能有推送
    bEnable = bEnable or UE4.UGMLibrary.IsEditor() -- 编辑器也要显示
    bEnable = bEnable and PlayerSetting.GetOne(PlayerSetting.SSID_NOTIFICATION, 99) > 0 -- 玩家的设置
    return bEnable and bPlayerSetting
end

---开启/关闭推送功能
---@param bEnable boolean
function LocalNotification.SetEnable(bEnable)
    if bEnable then
        PlayerSetting.Set(PlayerSetting.SSID_NOTIFICATION, 99, {1})
    else
        PlayerSetting.Set(PlayerSetting.SSID_NOTIFICATION, 99, {0})
    end
end

----------------------------------------------- 内部逻辑 ---------------------------------------------------

--不需要显示推送
function LocalNotification.collapse()
    LocalNotification.Clean()
    LocalNotification.bResumed = false
end

--恢复推送
function LocalNotification.resume()
    if (not LocalNotification.IsEnable()) or LocalNotification.bResumed then return end --不可重复恢复
    for _, notification in pairs(LocalNotification.tbGameNotifications) do
        if notification:IsEnable() then
            local sTitle, sBody, nDelay = notification:Gen()
            if sTitle and sBody and nDelay and nDelay > 0 then
                notification.tbInfo.nID = LocalNotification.Schedule(sTitle, sBody, nDelay)
                notification.tbInfo.nDateTime = GetTime() + nDelay
            end
        end
    end
    LocalNotification.bResumed = true
end

----------------------------------------------- 一些全局推送 ---------------------------------------------------

---体力推送
local EnergyNotify = LocalNotification.GameNotification("ENERGY_RECOVER", 1)

function EnergyNotify:Gen()
    local nHave = me:Vigor()
    local nMax = Player.GetMaxVigor(me:Level())
    if nHave >= nMax then return end
    local nRecoverTime = me:LastVigorTime() + (360 * (nMax - nHave))
    local nTime = GetTime()
    local nResult = nRecoverTime - nTime
    if nResult < 0 then
        nResult = nTime + (300 * (nMax - nHave))
    end
    return Text("notification.vigor_recover_title"), Text("notification.vigor_recover_body"), nResult
end

----------------------------------------------- 逻辑埋点 ---------------------------------------------------

-- 进游戏
LocalNotification.collapse()

-- 回到台前
GetGameIns().ApplicationHasEnteredForegroundDelegate:Add(GetGameIns(), function() LocalNotification.collapse() end)

-- 调到后台
GetGameIns().ApplicationWillEnterBackgroundDelegate:Add(GetGameIns(), function() LocalNotification.resume() end)

-- 失活
GetGameIns().ApplicationWillDeactivateDelegate:Add(GetGameIns(), function() LocalNotification.resume() end)

-- 结束进程
GetGameIns().ApplicationWillTerminateDelegate:Add(GetGameIns(), function() LocalNotification.resume() end)
