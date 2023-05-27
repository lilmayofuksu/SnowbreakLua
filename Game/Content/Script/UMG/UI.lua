-- ========================================================
-- @File    : UI.lua
-- @Brief   : UI管理器
-- ========================================================
---@class UI
---@field tbWidget table    所有UI
---@field tbStack table 所有进栈的UI
---@field tbConfig table    UI配置信息
UI = { tbWidget = {}, tbStack = {}, tbConfig = {}, tbRecover = {}, tbLoadingQueue = {}, nPriorityIndex = nil}
UI.pIndex = 0
UI.GCIndex = 0
UI.GCThreshold = 8

if IsIOS() then
    UI.GCThreshold = 3
end

local OpenIndex = function() return UI.pIndex + 1 end
local ActiveIndex = function()  UI.pIndex = UI.pIndex + 1 return UI.pIndex end
local EnquireExit = false;


local function OpenInner(InName, OnWidgetCreated, nOpenType,  ...)
    if EnquireExit and InName ~= "MessageBox" then return end

    printf("UI.OpenInner InName:%s Start", InName)

    InName = string.lower(InName)

    if UI.tbLoadingQueue[InName] then
        print('UI.Open ' .. InName ..  '   in the open') 
        return 
    end

    local sPlatformName = IsMobile() and InName or (InName .. 'pc')

    local cfg = UI.tbConfig[sPlatformName] or UI.tbConfig[InName]
    if cfg == nil then
        cfg = UI.tbConfig[InName]
    end
    if not cfg then
        print("UI.Open " .. InName .. " failed. Missing config.")
        return
    end

    ---显示优先级处理
    local nPriority = cfg.Priority
    if nPriority > 0 then
        if UI.nPriorityIndex then
            local pPriorityWidget = UI.tbWidget[UI.nPriorityIndex]
            if pPriorityWidget then
                local prioritycfg = UI.GetConfig(pPriorityWidget.sName)
                if prioritycfg then
                    if nPriority < prioritycfg.Priority then
                        return
                    else
                        UI.Close(pPriorityWidget)
                    end
                end
            end
        end
    end


    local Index = OpenIndex()
    local widget = UI.tbWidget[Index]
    if widget ~= nil then
        error("UI.Open " .. InName .. " Index exist.  " .. Index)
        return
    end

    UI.tbLoadingQueue[InName] = InName

    local Params = { ... }

    local OnUIClassLoadFinished = function(UIClass)
        UI.tbLoadingQueue[InName] = nil
        widget = LoadUI(cfg.UIWidgetClass)
        if not widget then
            error("UI.Open " .. InName .. " failed. Missing widget.")
            return
        end

        if widget.PreOpen and not widget:PreOpen(table.unpack(Params)) then
            print("UI.Open " .. InName .. " PreOpen-> false.")
            return
        end

        Index = ActiveIndex()

        if nPriority > 0 then
            UI.nPriorityIndex = Index
        end

        nOpenType = nOpenType or cfg.Type

        widget.tbChild = {}
        widget.sName = InName
        widget.pIndex = Index
        widget.pOrder = cfg.Order
        widget.nRuntimeOpenType = nOpenType

        UI.tbWidget[Index] = widget

        local top = UI.GetTop()
        if nOpenType == UE4.EUIType.Stack then
            if top then
                top:DoDisable()
            end

            table.insert(UI.tbStack, widget.sName)
            widget:DoOpen(table.unpack(Params))

        elseif nOpenType == UE4.EUIType.Top then
            widget:DoOpen(table.unpack(Params))
        else
            if top then
                top:OpenChild(widget, table.unpack(Params))
            else
                widget:DoOpen(table.unpack(Params))
            end
        end

        printf("UI.OpenInner InName:%s End", InName)

        if (OnWidgetCreated ~= nil) then
            OnWidgetCreated(widget)
        end
    end
    if OnWidgetCreated then
        UE4.UGameAssetManager.GameAsyncLoadAsset(cfg.UIWidgetClass, { GetGameIns(), OnUIClassLoadFinished } )
    else
        local pLoadWidget = UE4.UGameAssetManager.GameLoadAsset(cfg.UIWidgetClass)
        OnUIClassLoadFinished(pLoadWidget)
        return widget
    end
end

---打开UI
---@param InName string 界面名称（配置表中配置的）
------@param OnWidgetCreated function 创建UI对象的回调
function UI.OpenWithCallback(InName, OnWidgetCreated, ...) OpenInner(InName, OnWidgetCreated, nil , ...) end

---打开UI
---@param InName string 界面名称（配置表中配置的）
function UI.Open(InName, ...) return OpenInner(InName, nil, nil,...) end

---指定类型打开UI
---@param InName string 界面名称
---@param nOpenType UE4.EUIType 打开类型
function UI.OpenByType(InName, nOpenType, ...) return OpenInner(InName, nil, nOpenType,...) end

---安全打开UI，如果已经打开了，就关闭之前的
---@param InName string 界面名称（配置表中配置的）
function UI.SafeOpen(InName, ...)
    if UI.IsOpen(InName) then
        UI.Close(InName)
    end
    return OpenInner(InName, nil, nil, ...)
end

--- 关闭UI
---@param InWidget UMG 界面
---@param pCallBack function 关闭回调
---@param bOnlyClose boolean 仅仅关闭
function UI.Close(InWidget, pCallBack, bOnlyClose)
    local widget = InWidget
    if type(widget) == 'string' then widget = UI.GetUI(InWidget) end
    
    if not widget then return end
    if not widget.sName then
        print("UI Close filed:  widget.sName is  nil.ShowDebug", debug.traceback())
        Dump(InWidget)
        return
    end
    local sPlatformName = IsMobile() and widget.sName or (widget.sName .. 'pc')

    print('UI.Close :', widget.sName)

    local cfg = UI.tbConfig[sPlatformName] or UI.tbConfig[widget.sName]
    if not cfg then
       print('not find cfg :', sPlatformName)
       return
    end

    if cfg.Priority > 0 then
        UI.nPriorityIndex = nil
    end

    local nOpenType = widget.nRuntimeOpenType

    if nOpenType == UE4.EUIType.Stack then
        widget:DoClose(pCallBack)
        UI.PopUI(widget)
        UI.tbWidget[widget.pIndex] = nil
        if not bOnlyClose then
            UI.bPoping = true;
            UI.ActiveTop()
            UI.bPoping = false;
        end
    elseif nOpenType == UE4.EUIType.Top then
        widget:DoClose(pCallBack)
    else
        local parent = UI.tbWidget[widget.pParentIndex]
        if not parent then
            widget:DoClose(pCallBack)
        else
            parent:CloseChild(widget, pCallBack)
        end
    end
    UI.tbWidget[widget.pIndex] = nil
end

---根据界面名称关闭
---@param InName string
---@param pCallBack function 关闭回调
---@param bOnlyClose boolean 仅仅关闭
function UI.CloseByName(InName, pCallBack, bOnlyClose)
    InName = string.lower(InName)
    local w = UI.GetUI(InName)
    if w then  UI.Close(w, pCallBack, bOnlyClose) else  print("close ui by name   fail", InName) end
end

---关闭栈顶UI 直到需要的UI
---@param InName string UI名称
function UI.CloseUntil(InName, bOnlyClose)
    local nNum = #UI.tbStack
    if nNum <= 0 then return end
    local sTop = UI.tbStack[nNum]
    local pTop = UI.GetUI(sTop)
    if pTop and sTop ~= string.lower(InName) then  UI.Close(pTop, nil, bOnlyClose or false) UI.CloseUntil(InName) end
end

---关闭最上层子UI
function UI.CloseTopChild()
    local pTop = UI.GetTop()
    if not pTop then return end
    local nIndex = -1
    local tbChild = pTop.tbChild
    for nIdx, pChild in pairs(tbChild) do if nIdx > nIndex then  nIndex = nIdx end end
    if nIndex ~= -1 then 
        UI.Close(tbChild[nIndex])
        return true 
    end
    return false
end

---关闭栈顶界面
function UI.CloseTop(tbParam)
    tbParam = tbParam or {}
    local top = UI.GetTop()
    if top then
        UI.LastTop = top.sName
        UI.Close(top, tbParam.fCallback, tbParam.bOnlyClose)
    end
end

---激活栈顶界面
function UI.ActiveTop()
    local top = UI.GetTop()
    if top then
        print('UI.ActiveTop ***********************:', top, top.sName)
        top:DoActive()
    elseif #UI.tbStack > 0 then
        print('UI.ActiveTop Warning *****************************', UI.tbStack[1])
        UI.Open(table.remove(UI.tbStack, #UI.tbStack))
    end
end

---回主界面
function UI.OpenMainUI()
    local pMainUI = UI.GetUI('main')
    if GuideLogic.IsGuiding() then
        pMainUI = nil
        UI.GuideCloseAll()
    else
        if pMainUI and #UI.tbStack > 1 then
            local tbClose = Copy(UI.tbStack)
            for _, name in pairs(tbClose or {}) do
                if name ~= pMainUI.sName then
                    UI.Close(name, nil, true)
                end
            end
        else
            pMainUI = nil
            UI.CloseAll(true)
        end
    end
    Online.DoRealExit()
    if pMainUI == nil then
        UI.Open("Main")
    else
        pMainUI:DoOpen()
    end
    GM.TryOpenAdin()

    CacheBroadcast.TryPlay()
end

---回宿舍主界面
function UI.OpenDormMainUI()
    UI.CloseAll(false)
    UI.Open("Dorm")
end

--- 关闭所有所有UI
---@param bIncludeTop boolean 是否包含Top类型界面  NOTE默认不包含
function UI.CloseAll(bIncludeTop)
    bIncludeTop = bIncludeTop or false
    local fExe = function(w) if w then UI.Close(w, nil, true) end end
    for _, pWidget in pairs(UI.tbWidget) do
        local cfg = UI.GetConfig(pWidget.sName)
        if cfg.Type == UE4.EUIType.Top  then  if bIncludeTop then fExe(pWidget) end  else fExe(pWidget)   end
    end
    UI.tbStack = {}
    if bIncludeTop then
        UI.tbWidget = {}
        UI.pIndex = 0
    end
end

--- 关闭除指引界面的所有所有UI 如果有水印不关水印
function UI.GuideCloseAll()
    local WatermarkUI = nil
    local guideUI = nil
    for _, pWidget in pairs(UI.tbWidget) do
        if pWidget.sName == "guide" then
            guideUI = pWidget
        elseif pWidget.sName == "watermark" then
            WatermarkUI = pWidget
        else
            UI.Close(pWidget, nil, true)
        end
    end

    UI.tbStack = {}
    UI.tbWidget = {}
    UI.pIndex = 0
    if WatermarkUI then
        local Index = ActiveIndex()
        WatermarkUI.pIndex = Index
        UI.tbWidget[Index] = WatermarkUI
    end
    if guideUI then
        local Index = ActiveIndex()
        guideUI.pIndex = Index
        UI.tbWidget[Index] = guideUI
    end
end

--- 联机邀请关闭所有UI 固定界面堆栈
function UI.OnlineCloseAll()
    local bGM = false
    if UI.IsOpen("adingm") then
        bGM = true
    end

    UI.CloseAll(true)
    local tbRecover = {'main', 'dungeons', 'dungeonsonline'}
    for _, sName in ipairs(tbRecover) do
        table.insert(UI.tbStack, sName)
    end

    if bGM then
        UI.Open('adingm')
    end

    if WaterMarkLogic.IsShowWaterMark() then
        ---显示水印
        UI.Open("WaterMark")
    end
end

--- 恢复UI
---@param bTest boolean 测试使用
function UI.RecoverUI(bTest)
    if bTest then   UI.tbRecover = {'main', 'dungeons', 'dungeonsresourse', 'dungeonssmap', 'formation'} end
    if UI.tbRecover == nil or #UI.tbRecover == 0 then  return false end
    for _, sName in ipairs(UI.tbRecover) do
        table.insert(UI.tbStack, sName)
    end
    UI.tbRecover = nil
    UI.bRecover = true
    UI.Open(table.remove(UI.tbStack, #UI.tbStack))
    UI.bRecover = false
    return true
end

--- 得到栈顶UI
function UI.GetTop()
    return #UI.tbStack > 0 and UI.GetUI(UI.tbStack[#UI.tbStack]) or nil
end

--- 是否打开了
function UI.IsOpen(InName)
    local sUI = UI.GetUI(InName)
    return sUI and sUI:IsOpen() or false
end

--- 得到UI
---@param InName string 界面名称
function UI.GetUI(InName)
    InName = string.lower(InName)
    local tbFind = {}
    for _, w in pairs(UI.tbWidget) do
        if w.sName == InName then table.insert(tbFind, w) end
    end
    table.sort(tbFind, function(a, b) return a.pIndex > b.pIndex end)
    return tbFind[1]
end
---获取UI配置
---@param InName string 名称
function UI.GetConfig(InName)  return UI.tbConfig[InName] end

---播放背景音乐
---@param InWidget ULuaWidget
function UI.PlayMusic(InWidget)
    local Config = UI.GetConfig(InWidget.sName)
    if Config and Config.Music ~= '' then   UE4.UWwiseLibrary.SetStateGroup(Config.Music)  end
end

---UI保存索引
function UI.SnapShoot(tbExclude)
    if Map.GetCurrentID() ~= 2 then 
        return
    end
    UI.tbRecover = {}
    for nIdx, sName in ipairs(UI.tbStack) do
        local bContain = false
        for _, sExNmae in ipairs(tbExclude or {}) do
            if sName == string.lower(sExNmae) then  bContain = true break end
        end
        if not bContain then  table.insert(UI.tbRecover, sName)  end
    end
end

---重新打开UI
function UI.ReOpen()
    UI.SnapShoot({})
    UI.CloseAll(false)
    UI.RecoverUI()
end

---通过提示消息（错误码）
function UI.ShowError(nErrCode)
    ---有错误直接关闭
    UI.CloseConnection()
    if not Error.Handled(nErrCode) then   UI.ShowTip('error.'.. nErrCode)   end
end

---提示消息
function UI.ShowMessage(sMsg)
    EventSystem.Trigger(Event.ShowPlayerMessage)
    UI.ShowTip(sMsg)
end

---上次提示信息
 UI.sCacheLastTip = nil

---显示提示信息
function UI.ShowTip(sTip)
    if SERVER_ONLY then return end
    UI.CloseConnection()

    if UI.IsOpen('MessageTip') then
        if  UI.sCacheLastTip == sTip then 
            return 
        end 
    end
    UI.sCacheLastTip = sTip
    local value = Text(sTip)
    UI.Open("MessageTip", value)
end

--- 显示战斗提示信息
function UI.ShowFightTip(Type, sTip, bShowUIAnim, bCheckIsPlaying)
    local Desc = Localization.Get(sTip)
    EventSystem.Trigger(Event.FightTip, {Type = Type, Msg = Desc, bShowUIAnim = bShowUIAnim, bShowCompleteTip = true, bCheckIsPlaying = bCheckIsPlaying})
end

---显示联网提示
function UI.ShowConnection()
    if UI.bOpenConnection then return end
    UI.bOpenConnection = true
    UI.Open("Connection")
end

---关闭联网提示
function UI.CloseConnection()
    if not UI.bOpenConnection then return end
    UI.bOpenConnection = false
    UI.CloseByName('Connection')
end

---fClose fOkEvent fCancel 只执行其一
---fCancel为"Hide"时会只显示确定按钮
---@param bCanClickBG boolean 背景是否可以点击
function UI.OpenMessageBox(bCanClickBG, sMsg, fOkEvent, fCancel, bPause, bClose, fClose, sTxtOk, sTxtClose, sMsgTips)
    local pMsgWidget = UI.Open("MessageBox", sMsg, fOkEvent, fCancel, bPause, bClose, fClose, sTxtOk, sTxtClose, sMsgTips)
    if pMsgWidget and not bCanClickBG then
        WidgetUtils.HitTestInvisible(pMsgWidget.BG) 
    end
end

---统一服务器跨天弹窗
function UI.ServerNextDay()
    local funBackMain = function()  UI.OpenMainUI()  end
    UI.Open("MessageBox", Text("tip.time_refresh"), funBackMain, "Hide", nil, false)
end

--------------------内部调用方法------------------------------------

---加载UI配置文件
function UI.LoadConfig()
    local config = UE4.TMap(UE4.FString, UE4.FUIInfo)
    UE4.UUMGLibrary.LoadUIConfig(config)
    local tbKey = config:Keys()
    for i = 1, tbKey:Length() do
        local sName = string.lower(tbKey:Get(i))
        UI.tbConfig[sName] = config:Find(tbKey:Get(i))
    end
end

---栈中移除
---@param InWidget ULuaWidget
function UI.PopUI(InWidget)
    local nIndex = -1
    for nIdx, sName in ipairs(UI.tbStack) do
        if sName== InWidget.sName then nIndex = nIdx  end
    end
    if nIndex ~= -1 then  return table.remove(UI.tbStack, nIndex) end
    return nil
end

---调用UI的方法
---@param sUIName string 界面名称
---@param sFunName string 函数名称
function UI.Call(sUIName, sFunName, ...)
    local pUI = UI.GetUI(sUIName)
    if not pUI then return end
    if pUI[sFunName] then  pUI[sFunName](...)  end
end

---调用UI的方法
---@param sUIName string 界面名称
---@param sFunName string 函数名称
function UI.Call2(sUIName, sFunName, ...)
    local pUI = UI.GetUI(sUIName)
    if not pUI then return end
    if pUI[sFunName] then  pUI[sFunName](pUI, ...)  end
end


--- 现有的 【菜单】键，不再提供返回、关闭等功能，仅提供： 在主界面时，弹出【是否退出游戏】的确认弹窗
function UI.GamepadExitGame()
    if EnquireExit then return end

    if me:IsLogined() then
        if GuideLogic.IsGuiding() or Reconnect.isShowReconnectBox then return end
    end

    local Top = UI.GetTop()
    print('UI.GamepadExitGame :', Top and Top.sName or '')
    if Top and Top.sName == 'main' then
        UI.OpenExitUI()
    end
end

--[[
    在系统界面中，所有非主界面的界面，在点击【返回】功能键时，则会将当前界面关闭。若有跳转形式的逻辑，则变更为：返回上一级 在主界面时此功能无效
]]
function UI.GamepadDeviceBack()
    if me:IsLogined() then
        if GuideLogic.IsGuiding() or Reconnect.isShowReconnectBox then return end
    end

    local Top = UI.GetTop()
    print('UI.GamepadDeviceBack :', Top and Top.sName or '')
    if Top and Top.sName == 'main' then
        local topChid = Top:GetTopChild()
        if topChid then
            UI.OnDeviceBack()
        end
    else
        UI.OnDeviceBack()
    end
end


---设备Back键（Android）等
function UI.OnDeviceBack()
    if EnquireExit then return end

    ---屏蔽剧情
    local tbBlockUI = {'Dialogue', 'MessageBox'}

    for _, sBlockUI in ipairs(tbBlockUI) do
        if UI.GetUI(sBlockUI) then return end
    end

    if UI.bInSequenceWidget then return end

    if UI.bOpenConnection then return end

    EventSystem.Trigger(Event.DeviceBack)

    local fExit = function()
        local top = UI.GetTop()

        if top and top:CanEsc() == false then return end
        
        if top then
           local pChild = top:GetTopChild()
           if pChild and pChild:CanEsc() == false then  return end
        end

        if top and top:CloseTopChild() then return end

        if top and top.sName == "formation" and Online.GetOnlineId() > 0  then --联机编队中
            top:DoKickOut()
            return
        else
            if #UI.tbStack > 1 then   UI.CloseTop(); return end
        end

        --退出恢复推送
        LocalNotification.resume()
        UE4.UGameLibrary.RequestExit();
    end
    if me:IsLogined() then
        if GuideLogic.IsGuiding() or Reconnect.isShowReconnectBox then  return end
    end
    fExit()
end

function UI.OpenExitUI()
    EnquireExit = true;
    UI.Open("MessageBox", Text('tip.exit_game'), function()
        UE4.UGameLibrary.QuitGameWithLog("UI Exit Game")
        EnquireExit = false 
    end, function() EnquireExit = false  end)
end

---栈中是否存在了
---@param InName string 界面名称
function UI.__IsExist(InName)
    for _, v in pairs(UI.tbStack) do
        if v == string.lower(InName) then return true end
    end
    if (UI.tbLoadingQueue[InName]) then
       return true
    end
    return false
end

---输出UI 信息
function UI.Debug()
    print('=====================================')
    print('-------------所有UI---------------')
    for k, v in pairs(UI.tbWidget or {}) do
        print("UI Info = ", k, v.sName)
    end
    print('-------------栈中UI---------------')
    for k, v in pairs(UI.tbStack or {}) do
        print("UI Info = ", k, v)
    end
    print('-------------需要恢复的UI---------------')
    for k, v in pairs(UI.tbRecover or {}) do
        print("UI Info = ", k, v)
    end
    print('=====================================')
end

---尝试三次后执行GC
local nDelayGCHandle = nil
function UI.TryGC()
    UI.GCIndex = UI.GCIndex + 1
    if UI.GCIndex >= UI.GCThreshold then
        if nDelayGCHandle then
            UE4.Timer.Cancel(nDelayGCHandle)
            nDelayGCHandle = nil
        end
        UE4.Timer.Add(0.5, function()
            nDelayGCHandle = nil
            UI.GC()
       end)
    end
end

local nTryGCByObjectsCount = 3
function UI.TryGCByObjectsCount()
    if nTryGCByObjectsCount > 0 then
        nTryGCByObjectsCount = nTryGCByObjectsCount - 1
        return
    else
        nTryGCByObjectsCount = 3
    end

    local NeedGCNum = UE4.UGameLibrary.GetMaxObjectsCount() * 0.7
    local NowObjNum = UE4.UGameLibrary.GetObjectArrayNumMinusAvailable()
   
    print('UI.TryGCByObjectsCount() :', NeedGCNum, NowObjNum)

    if NowObjNum >= NeedGCNum then
        UI.GC();
    end
end

---强制GC
function UI.GC(bTest)
    collectgarbage("collect")
    UE4.UGameLibrary.CollectGarbage()
    UI.GCIndex = 0

    if bTest then
        local tbClass = {
            'umg_bag_C',
            'umg_logistics_C'
        }
        local sInfo = ''
        for _, sClass in ipairs(tbClass) do
             sInfo = sInfo .. "---------------------ui debug UUMGLibrary " .. sClass .. '         ' .. UE4.UUMGLibrary.GetUserWidgetCount(sClass) .. '\n'
        end
        PrintScreen(sInfo, nil, 2)
    end
end

---窗口分辨率变化
function UI.OnViewportSizeChange()
    if GuideLogic.IsGuiding() then
        local GuideUI = UI.GetUI("Guide")
        if GuideUI and GuideUI:IsOpen() and GuideUI.UpdateUIPos then
            GuideUI:UpdateUIPos()
        end
    end

end

------------------内部调用方法结束-----------------------------------
---加载配置

if not SERVER_ONLY then
    UI.LoadConfig()
end

--UMG FIGHT 架构原因，全局放在这里了 by ZhangGuangYu
function UI.BPShow(InName)
    local sUI = UI.GetUI(InName)
    if sUI and sUI:IsOpen() then
        WidgetUtils.SelfHitTestInvisible(sUI)
        return true
    end
    return false
end

function UI.BPHide(InName)
    local sUI = UI.GetUI(InName)
    if sUI and sUI:IsOpen() then
        WidgetUtils.Collapsed(sUI)
        return true
    end
    return false
end

function UI.GetTips()
    local sUI = UI.GetUI("Fight")
    if sUI and sUI:IsOpen() then
        return sUI.Tips
    end
end