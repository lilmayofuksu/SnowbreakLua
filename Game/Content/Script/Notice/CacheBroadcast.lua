-- ========================================================
-- @File    : CacheBroadcast.lua
-- @Brief   : 跑马灯
-- ========================================================

---@class CacheBroadcast 跑马灯信息
CacheBroadcast = {tbBroadcast = {}, tbTimer = {} ,nPlayIndex = nil, nIncreaseIndex = 0}

local cbc = CacheBroadcast

function cbc.NewIndex()
    cbc.nIncreaseIndex = cbc.nIncreaseIndex + 1
    return cbc.nIncreaseIndex
end

function cbc.Add(newBroadcast)
    local nIndex = cbc.NewIndex()
    cbc.tbBroadcast[nIndex] = newBroadcast

    local nNowTime = GetTime()

    local nDelayTimer = newBroadcast.nStart - nNowTime

    ---立即显示
    if nDelayTimer <= 0 then
        cbc.Play(nIndex)
    else
        cbc.tbTimer[nIndex] = UE4.Timer.Add(nDelayTimer, function() cbc.Play(nIndex) end)
    end
end

function cbc.Get(nIndex)
    return cbc.tbBroadcast[nIndex]
end

function cbc.Remove(nIndex)
    if not nIndex then return end
    cbc.tbBroadcast[nIndex] = nil

    if cbc.tbTimer[nIndex] then
        UE4.Timer.Cancel(cbc.tbTimer[nIndex])
        cbc.tbTimer[nIndex] = nil
    end
end

function cbc.RemoveAll()
    for _, timer in pairs(cbc.tbTimer or {}) do
        if timer then UE4.Timer.Cancel(timer) end
    end
    cbc.tbTimer = {}
    cbc.tbBroadcast = {}
    cbc.nPlayIndex = nil
    cbc.nIncreaseIndex = 0
end

function cbc.Stop()
    if cbc.nPlayIndex then
        cbc.Remove(cbc.nPlayIndex)
        cbc.nPlayIndex = nil
    end
end

function cbc.Play(nIndex)
    if not nIndex then return end

    if cbc.nPlayIndex == nIndex then
        return
    end

    if cbc.nPlayIndex then
        cbc.Remove(cbc.nPlayIndex)
        cbc.nPlayIndex = nil
    end

    if not cbc.tbBroadcast[nIndex] then return end

    cbc.nPlayIndex = nIndex

    cbc.TryPlay()
end

function cbc.TryPlay()
    if cbc.bWait then
        return
    end
    cbc.bWait = true

    UE4.Timer.Add(1, function()
        cbc.bWait = false

        local nIndex = cbc.nPlayIndex
        if not nIndex then return end
    
        ---登录界面不显示
        if Map.GetCurrentID() == 1 then return end
    
        ---设置战斗不显示
        local pSubSystem = UE4.UUIGameInstanceSubsystem.Get()
        if pSubSystem and pSubSystem:IsFight() then
            local nValue = PlayerSetting.GetOne(PlayerSetting.SSID_OTHER, OtherType.FIGHT_SHOW_BROADCAST)
            if nValue ~= 1 then
                return
            end
        end
    
        if UI.IsOpen('HealthTip') then
            return
        end

        local pUI = UI.GetUI('Broadcast')
        if pUI then
            pUI:RecivePlay(nIndex)
        else
            UI.Open('Broadcast', nIndex)
        end
    end)
end

function cbc.OnSettingChange(bShow)
    if not Map.InFight() then
        return
    end

    if bShow then
        if not UI.IsOpen('Broadcast') then
            cbc.TryPlay()
        end
    else
       UI.CloseByName('Broadcast')
    end
end

---跑马灯更新监听
EventSystem.On(Event.UpdateBroadcast, function(nStart, nEnd, sContent, nInterval)
    print('Event.UpdateBroadcast:',GetTime(), nStart, nEnd, sContent, nInterval)
    cbc.Add({ nStart = nStart,  nEnd = nEnd, sContent = sContent,  nInterval = nInterval})
end)

---清除跑马灯事件监听
EventSystem.On(Event.CleanBroadcast, function()
    print('Event.CleanBroadcast')
    cbc.RemoveAll()
    UI.CloseByName('Broadcast')
end)

EventSystem.On(Event.LanguageChange, function()
    local pNotification = UI.GetUI('Broadcast')
    if pNotification then
        UI.Close(pNotification)
        CacheBroadcast.TryPlay()
    end
end)

function cbc.Print()
    print('=============================================')
    print(cbc.nPlayIndex, cbc.nIncreaseIndex)
    Dump(cbc.tbBroadcast)
    print('=============================================')
end

function cbc.Test(nDelay, str)
    local nStart = GetTime() + nDelay or 0
    local nEnd = nStart + 30000
    local sContent = str or 'Test Broadcast'
    local nInterval = 2
    EventSystem.Trigger(Event.UpdateBroadcast, nStart, nEnd, sContent, nInterval)
end