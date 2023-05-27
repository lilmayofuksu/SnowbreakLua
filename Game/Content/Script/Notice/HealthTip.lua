-- ========================================================
-- @File    : HealthTip.lua
-- @Brief   : 健康提示
-- ========================================================


---@Class HealthTip
HealthTip = HealthTip or {tbCfg = {}}

local n5Timer = nil
local n2Timer = nil
local nSaveTimer = nil

local bRequestTip = false


---缓存显示提示的标志
local bCanTip = false


---触发提示的时间
HealthTip.nTriggerTipTime = 0


local function mylog(...)
    --print('HealthTip :---------------->', ...)
end


local function getSaveInfo()
    return json.decode(me:GetStrAttribute(PlayerSetting.SGID, PlayerSetting.SSID_PLAY_TIME)) or {}
end

local function setSaveInfo(tbInfo)
    me:SetStrAttribute(PlayerSetting.SGID, PlayerSetting.SSID_PLAY_TIME, json.encode(tbInfo or {}))

    HealthTip.StartSaveTimer()
end


function HealthTip.TryTip()
    if bCanTip == false then return end

    if bRequestTip == false then return end

    local cfg = HealthTip.Get(1)
    if not cfg then
        return
    end

    mylog('TryTip', bRequestTip, GetTime() - HealthTip.nTriggerTipTime)

    if GetTime() - HealthTip.nTriggerTipTime > cfg.duration then
        bRequestTip = false
        mylog('持续时间结束')
        return
    end


    if UI.IsOpen('HealthTip') then
        mylog('已经在提示中了')
        return
    end

    if UI.IsOpen('Broadcast') then
        UI.CloseByName('Broadcast')
    end

    UI.Open('HealthTip', cfg)
end


function HealthTip.Start5Timer(nPreTime)
    local cfg = HealthTip.Get(1)
    if not cfg then
        return
    end

    if n5Timer then
        UE4.Timer.Cancel(n5Timer)
        n5Timer = nil
    end

    n5Timer = UE4.Timer.Add(cfg.triggerTime - nPreTime, function()
        n5Timer = nil

        local saveInfo = getSaveInfo()
        saveInfo[1] = 0
        saveInfo[2] = true
        setSaveInfo(saveInfo)

        HealthTip.RequestTip()
        mylog('HealthTip.Start5Timer trigger :')

        HealthTip.Start2Timer(0)

    end)
    mylog('HealthTip.Start5Timer：', cfg.triggerTime, nPreTime, cfg.triggerTime - nPreTime)
end


function HealthTip.Start2Timer(nPreTime)
    local cfg = HealthTip.Get(1)
    if not cfg then
        return
    end

    if n2Timer then
        UE4.Timer.Cancel(n2Timer)
        n2Timer = nil
    end

    n2Timer = UE4.Timer.Add(cfg.time - nPreTime, function()
        n2Timer = nil

        local saveInfo = getSaveInfo()
        saveInfo[1] = 0
        saveInfo[2] = true
        setSaveInfo(saveInfo)

        HealthTip.RequestTip()
        mylog('HealthTip.Start2Timer trigger :')

        HealthTip.Start2Timer(0)

    end)
    mylog('HealthTip.Start2Timer', cfg.time, nPreTime, cfg.time - nPreTime)
end


local nSaveRate = 60

function HealthTip.StartSaveTimer()
    if nSaveTimer then
        UE4.Timer.Cancel(nSaveTimer)
        nSaveTimer = nil
    end

    nSaveTimer = UE4.Timer.Add(nSaveRate, function()
        nSaveTimer = nil
        
        local saveInfo = getSaveInfo()
        saveInfo[1] = GetTime() - HealthTip.nTriggerTipTime
        setSaveInfo(saveInfo)

        mylog('HealthTip.StartSaveTimer()', saveInfo[1])
    end)
end

function HealthTip.RequestTip()
    bRequestTip = true
    HealthTip.nTriggerTipTime = GetTime()

    mylog('HealthTip.RequestTip', HealthTip.nTriggerTipTime)

    HealthTip.TryTip()
end

function HealthTip.End()
    bRequestTip = false
    mylog('HealthTip.End()')
end


function HealthTip.Clear()
    if n5Timer then
        UE4.Timer.Cancel(n5Timer)
    end
    if n2Timer then
        UE4.Timer.Cancel(n2Timer)
    end
    if nSaveTimer then
        UE4.Timer.Cancel(nSaveTimer)
    end
    n5Timer = nil
    n2Timer = nil
    nSaveTimer = nil
end



function HealthTip.InitTimer()
    if bCanTip == false then return end

    HealthTip.Clear()
    local cfg = HealthTip.Get(1)
    if not cfg then
        return
    end
    
    local saveInfo = getSaveInfo()

    local nPlayTime = saveInfo[1] or 0
    local bHaveTip = saveInfo[2] or false

    mylog('HealthTip.InitTimer()', nPlayTime, bHaveTip)

    ---第一次登录
    if nPlayTime <= 0 then
        ---启动在线五小时倒计时
        HealthTip.Start5Timer(0)
        HealthTip.nTriggerTipTime = GetTime()
    else
        ---是否已经触发过健康提示
        if bHaveTip then
           HealthTip.Start2Timer(nPlayTime)
        else
            HealthTip.Start5Timer(nPlayTime)
        end
        HealthTip.nTriggerTipTime = GetTime() - nPlayTime
    end

    HealthTip.StartSaveTimer()
end

function HealthTip.InitCondition()
    bCanTip = false
    if IsMobile() then return end
    if not me then return end
    local lan = Localization.GetCurrentLanguage()
    print('HealthTip.InitTimer : language = ', lan)
    if lan ~= 'ko_KR' then return end
    bCanTip = true
end


function HealthTip.Get(id)
    return HealthTip.tbCfg[id]
end

---加载配置信息
function HealthTip.LoadCfg()
    local tbInfo = LoadCsv("notice/health_tip.txt", 1)

    for _, tbLine in ipairs(tbInfo) do
        local id = tonumber(tbLine.id)
        if id then
            local tbInfo = {
                txtkey = tbLine.txtkey or '',
                triggerTime = tonumber(tbLine.triggerTime) or 18000,
                time = tonumber(tbLine.time) or 120,
                duration = tonumber(tbLine.duration) or 1,
            }

            HealthTip.tbCfg[id] = tbInfo
        end
    end
end

if not SERVER_ONLY then
    HealthTip.LoadCfg()
end


EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if bReconnected then return end
    HealthTip.InitCondition()

    if not bCanTip then return end
    HealthTip.InitTimer()
end)

EventSystem.On(Event.ServerNextDay, function()
    if not bCanTip then return end

    UI.CloseByName('HealthTip')

    setSaveInfo({0, false})
    HealthTip.InitTimer()
end)



--[[
    调试代码
]]

---调试重置天数
function HealthTip.TestNextDay()
    UI.CloseByName('HealthTip')

    setSaveInfo({0, false})

    mylog('HealthTip.TestNextDay', me:GetStrAttribute(PlayerSetting.SGID, PlayerSetting.SSID_PLAY_TIME))

    UE4.Timer.Add(5, function()
        HealthTip.InitTimer()
    end)
   
end

---调试通知
function HealthTip.TestTip()
    bCanTip = true
    local cfg = HealthTip.Get(1)
    cfg.triggerTime = 120
    cfg.time = 60
    cfg.duration = 20

    nSaveRate = 5

    HealthTip.TestNextDay()
end

function HealthTip.TestTime()
    bCanTip = true
    setSaveInfo({1750, false})
    nSaveRate = 5
    UE4.Timer.Add(5, function()
        HealthTip.InitTimer()
    end)
end