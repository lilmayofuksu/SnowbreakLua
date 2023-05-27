-- ========================================================
-- @File    : GMCommandRegister.lua
-- @Brief   : GM指令注册
-- ========================================================

----------------------------GM指令基类------------------------
local GMCommandBase = {}

do
    local tbClass = GMCommandBase

    --注册指令参数
    function tbClass:RegisterParam(nType, nParamName, defaultStringValue, desc, tbOtherParam)
        if not self.Params then
            self.Params = {}
        end
        if not nType or not nParamName then
            return self
        end
        self.Params[nParamName] = {nType = nType, stringValue = defaultStringValue or ''}
        if not self.Params_sort then
            self.Params_sort = {}
        end
        self.Params_sort[#self.Params_sort + 1] = {nType = nType, name = nParamName, stringValue = defaultStringValue or '', desc = desc, param = tbOtherParam}
        return self;
    end

    --保存指令参数
    function tbClass:SaveParam()
        if not self.Category or not self.CommandName then
            return
        end
        for nParamName,param in pairs(self.Params) do
            UE4.UUserSetting.SetString('GM.'..self.Category..'.'..self.CommandName..'.'..nParamName, param.stringValue)
        end
        UE4.UUserSetting.Save()
        return self;
    end

    --设置指令参数
    function tbClass:SetParam(nParamName,stringValue)
        if not self.Params[nParamName] then
            return
        end
        self.Params[nParamName].stringValue = stringValue;
        for i,v in ipairs(self.Params_sort) do
            if v.name == nParamName then
                v.stringValue = stringValue;
            end
        end
        return self;
    end


    local switchFuncTb = {
        number = function (str)
            return tonumber(str) or 0
        end,
        string = function (str)
            return (str)
        end,
        tbNum = function (str)
            return Eval(str)
        end
    }

    --根据param的type把stringValue解析出来
    function tbClass:GetParam(nParamName)
        if not self.Params[nParamName] then
            return
        end
        local str = self.Params[nParamName].stringValue
        local nType = self.Params[nParamName].nType

        return switchFuncTb[nType] and switchFuncTb[nType](str) or switchFuncTb['number'](str)
    end

    --注册指令执行函数
    function tbClass:RegisterFunc(func)
        self.Func = func
        return self
    end
end

--------------------------------------------------------------

---------------------------分配一个基类------------------------
--example: Fight.KillAll => category = Fight, name = KillAll  
local RegisterCommand = function (category, name, introKey)
    local newTB = Inherit(GMCommandBase)
    newTB.Params = {}
    newTB.Params_sort = {}
    newTB.Category = category
    newTB.CommandName = name
    newTB.introKey = introKey
    GMCommand:AddCommand(category, name, newTB)
    return newTB
end

--- 关闭所有UI
local CloseUIGM = function() 
    local ui = UI.GetUI("AdinGM")
    if ui then return ui:ApplyClose() end
end

--- 得到本地玩家
local GetOwningPlayer = function() 
    local ui = UI.GetUI("AdinGM")
    if ui then 
        return ui:GetOwningPlayer()
    end
end

--- 发送代码到GM网站执行
local SendCodeToHttp = function(code, target)
    local tbServer = Login.GetServer()
    local url = string.format("http://%s:1234/gm/script", tbServer.sAddr)
    print(string.format("http://%s:1234/gm/script", tbServer.sAddr))
    local tbParam = {
        code = code;
        target = target or 1;
        pid = me:Id();
    }
    UE4.UGMLibrary.SendJsonToHttp(url, json.encode(tbParam))
end

--------------------------------------------------------------
--- 开放世界GM指令注册
local RegisterOpenWorldCommand = function() 
    --- 开放世界相关GM指令
    RegisterCommand('OpenWorld', 'TestRevive', '测试死亡复活')
        :RegisterFunc(function (self)
            print("准备复活");
            UI.Open("OpenWorldPlayerDeath")
            CloseUIGM();
    end)   

    --- 自杀
    RegisterCommand('OpenWorld', 'KillSelf','自杀')
        :RegisterFunc(function (self)
            local PlayerController = GetOwningPlayer()
            local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
            if Character then 
                Character:ApplyKillSelf();
            end
        --    CloseUIGM();
    end)    

    --- 清空所有变量，并重新开启活动
    RegisterCommand('OpenWorld', '清空数据', '清空所有变量并重新开启活动')
        :RegisterFunc(function (self)
            SendCodeToHttp("OpenWorldServer.Debug_ClearAllData()")
            UI.ShowTip("执行成功") 
    end)   

    --- 完成所有主线
    RegisterCommand('OpenWorld', '完成所有主线', '完成所有主线任务')
        :RegisterFunc(function (self)
            SendCodeToHttp("OpenWorldServer.Debug_CompleteAllTaskMain()")
            UI.ShowTip("执行成功") 
    end)   

    --- 完成所有支线
    RegisterCommand('OpenWorld', '完成所有支线', '完成所有支线任务')
        :RegisterFunc(function (self)
            SendCodeToHttp("OpenWorldServer.Debug_CompleteAllTaskBranch()")
            UI.ShowTip("执行成功") 
    end)   

    --- 完成当前主线
    RegisterCommand('OpenWorld', '完成当前主线', '完成当前主线任务')
        :RegisterFunc(function (self)
            SendCodeToHttp("OpenWorldServer.Debug_CompleteCurrentTaskMain()")
            UI.ShowTip("执行成功") 
    end)   

    --- 完成当前支线
    RegisterCommand('OpenWorld', '完成当前支线', '完成当前支线任务')
        :RegisterFunc(function (self)
            SendCodeToHttp("OpenWorldServer.Debug_CompleteCurrentTaskBranch()")
            UI.ShowTip("执行成功") 
    end)   

    --- 前往下一天
    RegisterCommand('OpenWorld', '下一天', '前往下一天(用于测试数据刷新)')
        :RegisterFunc(function (self)
            SendCodeToHttp("OpenWorldServer.Debug_GotoNextDay()")
            UI.ShowTip("执行成功") 
    end)   

    --- 测试开放世界消息提示
    RegisterCommand('OpenWorld', '消息提示', '消息提示')
        :RegisterParam('string','msg','测试消息提示')
        :RegisterFunc(function (self)
            local msg = self:GetParam('msg')
            EventSystem.Trigger(Event.ShowFightTip, msg)
    end)   
end

-- 常用GM指令注册
local RegisterCommonCommand = function() 
    ---返回登录界面
    RegisterCommand('常用类', '返回登录界面', '返回登录界面')
        :RegisterFunc(function (self)
            me:Logout()
            GoToLoginLevel()
    end) 


    ---关闭界面
    RegisterCommand('常用类', '关闭GM界面', '关闭GM界面')
        :RegisterFunc(function (self)
            UI.Close("AdinGM")
    end)

    ---打开GM后台
    RegisterCommand('常用类', '打开GM后台', '打开GM后台')
        :RegisterFunc(function (self)
            local tbServerInfo = Login.GetServer()
            if tbServerInfo then
                UE4.UKismetSystemLibrary.LaunchURL(string.format("http://10.128.16.221:2234/?ip=%s&gmport=1234", tbServerInfo.sAddr))
            end
    end)

    ---打开服务器面板
    RegisterCommand('常用类', '打开服务器面板', '打开服务器面板')
        :RegisterFunc(function (self)
            local tbServerInfo = Login.GetServer()
            if tbServerInfo then
                UE4.UKismetSystemLibrary.LaunchURL(string.format("http://%s:8088", tbServerInfo.sAddr))
            end
    end)

    ---关闭界面
    RegisterCommand('常用类', '显示服务器列表', '显示服务器列表')
        :RegisterFunc(function (self)
            local ui = UI.GetUI("Login")
            if ui then 
                ui:ShowBtnServer()
            end
            CloseUIGM()
    end)
        
    ---进入联机关卡
    RegisterCommand("常用类","进入联机关卡","进入联机关卡")
    :RegisterFunc(function(self)
        UI.Open("DungeonsOnline")
    end)

    --账号升级
    RegisterCommand('常用类', '一键升级', '一键升级')
        :RegisterParam("number", 'AccountLevel', '80')
        :RegisterFunc(function (self)
            GuideLogic.SkipAllGuide()
            local AccountLevel = self:GetParam("AccountLevel")
            SendCodeToHttp(string.format("GM.GMOneKeyAddItem(%s)", AccountLevel))
    end)

    --一键配号
    RegisterCommand('常用类', '一键战斗配号', '一键战斗配号')
        :RegisterParam("number", 'AccountLevel', '80')
        :RegisterParam("string", "TargetRole", "G-D-P-L")
        :RegisterParam("number", 'SetSpine', '5') --神经节点 (1-5) 
        :RegisterParam("number", 'SetBreak', '45') --天启节点 (1-45)
        :RegisterParam("number", 'OpenProLevel', '0') --开放同步率 0不开放 1 开放
        :RegisterParam("number", 'WeaponSkill', '1') --武器技能等级 1-4级
        :RegisterFunc(function (self)
            GuideLogic.SkipAllGuide()
            local AccountLevel = self:GetParam("AccountLevel")
            local sTargetRole = self:GetParam("TargetRole")
            local nSpineNode = self:GetParam("SetSpine")
            local nBreakNode = self:GetParam("SetBreak")
            local bOpenProLevel = self:GetParam("OpenProLevel")
            local nWeaponSkill = self:GetParam("WeaponSkill") - 1
            local tbGDPL = Split(sTargetRole, "-")
            if #tbGDPL ~= 4 or tbGDPL[1] == 'G' then
                sTargetRole = ""
            end
            --根据等级判断SpineNode 是否可开  to-do
            local nSpineFrameId
            for key,config in pairs(Spine.tbKeyId) do
                nSpineFrameId = config[nSpineNode].SpcondId
            end
            local tbSpineCond = Spine.tbSpineNodeCond[nSpineFrameId][1].NodeCondition
                --- 等级检查
            if tbSpineCond[1][2] > AccountLevel then
                UI.ShowTip('tip.lv_lower')
                return
            end
            -- print("GMOneKeyForBattle ",AccountLevel,sTargetRole,nSpineNode,nBreakNode,bOpenProLevel,nWeaponSkill)
            SendCodeToHttp(string.format("GM.GMOneKeyForBattle({%s,\"%s\",%d,%d,%d,%d})", AccountLevel,sTargetRole,nSpineNode,nBreakNode,bOpenProLevel,nWeaponSkill))
    end)

        --战斗测试配号
    RegisterCommand('常用类', '战斗测试配号', '战斗测试配号')
    :RegisterFunc(function (self)
        SendCodeToHttp(string.format("GM.GMInitFormation()"))
    end)

    --新号快速成长
    RegisterCommand('常用类', '新号快速长大', '完成指引+获得所有道具+解锁所有关卡')
        :RegisterFunc(function (self)
            SendCodeToHttp("GM.AddAllItem()")
            SendCodeToHttp("GM.UnLockAllLevel()")
            GuideLogic.SkipAllGuide()
            CloseUIGM()

            UE4.Timer.Add(1, function()
                if UI.IsOpen("Main") then 
                    UI.GetUI("Main"):RefreshUI()
                end
            end)
    end)
end

-- 客户端专用指令注册
local RegisterClientCommand = function()
    --进入序章关卡
    RegisterCommand('客户端', '进入序章关卡', '进入序章关卡')
        :RegisterFunc(function (self)
            if UE4.UGameplayStatics.GetCurrentLevelName(GetGameIns()) ~= "Level01_00" then
                Launch.SetType(LaunchType.GUIDE)
                Formation.SetCurLineupIndex(1)
                if Formation.CanFight() then
                    Launch.Start()
                end
            end
    end)  

    ---设置最大帧数
    RegisterCommand('客户端', '设置最大帧数', '为0则是默认帧数')
        :RegisterParam('string','SetMAXFPS','60')
        :RegisterFunc(function (self)
            print("123123123")
            local msg = self:GetParam('SetMAXFPS')
            print(msg)
            UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self,"t.maxFPS "..msg)
            local GraphicsSetting = UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
            if GraphicsSetting then
                GraphicsSetting:SetFramePace()
            end
    end) 

    ---显示当前帧数
    RegisterCommand('客户端', '显示当前帧数', '再次调用为隐藏')
        :RegisterFunc(function (self)
            UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self,"stat fps")
            UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self,"stat unit")
            print("显示当前FPS")
    end) 

    ---键位显示
    RegisterCommand('客户端', '键位显示', '键位显示')
        :RegisterFunc(function (self)
        UI.GetUI('AdinGM').KeyInput:SetVisibility(UE4.ESlateVisibility.Visible)
        UI.GetUI('AdinGM'):PlayAnimation(UI.GetUI('AdinGM').NewAnimation,UI.GetUI('AdinGM'):GetAnimationCurrentTime(UI.GetUI('AdinGM').NewAnimation),1,UE4.EUMGSequencePlayMode.Reverse,1,false)
    end) 


    ---查看Log
    RegisterCommand("客户端","查看Log","查看Log")
    :RegisterFunc(function(self)
        local Widget=UE4.UWidgetBlueprintLibrary.Create(GetOwningPlayer(),UE4.UClass.Load("/Game/UI/UMG/GM/Widget/uw_adingm_log"))
        if Widget then
            Widget:AddToViewport()
            CloseUIGM();
        end
    end)

    --清除同意协议缓存
    RegisterCommand('客户端', '清除同意协议缓存', '清除同意协议缓存')
        :RegisterFunc(function (self)
            UE4.UUserSetting.SetBool("ProtocolAgree",false)
            UE4.UUserSetting.Save()
    end)

    --Thread Info
    RegisterCommand('客户端', '线程信息', '线程信息')
    :RegisterFunc(function (self)
       if not UI.IsOpen('ThreadInfo') then
           UI.Open('ThreadInfo', 1)
        else
            UI.Call2('ThreadInfo', 'SetType', 2)
       end    
   end)

    RegisterCommand('客户端', 'ClaimedNum', 'ClaimedNum')
    :RegisterFunc(function (self)
        if not UI.IsOpen('ThreadInfo') then
            UI.Open('ThreadInfo', 2)
        else
            UI.Call2('ThreadInfo', 'SetType', 2)
        end
    end)  

    RegisterCommand('客户端', '怪物数量', '显示活着的怪物数量')
    :RegisterFunc(function (self)
        if not UI.IsOpen('ThreadInfo') then
            UI.Open('ThreadInfo', 3)
        else
            UI.Call2('ThreadInfo', 'SetType', 3)
        end
    end)

    RegisterCommand('客户端', '隐藏所有UI', '隐藏所有UI')
    :RegisterParam('string', 'showTip', '1', "是否显示tip")
    :RegisterFunc(function (self)
        local show = self:GetParam('showTip')
        UI.GetUI("AdinGM"):HideAllUI(show == "1")
    end)
end

-- 指引指令注册
local RegisterGuideCommand = function()
    --完成新手序章指引
    RegisterCommand('新手指引', '完成新手序章指引', '完成新手序章指引')
        :RegisterFunc(function (self)
        GuideLogic.SkipLevelGuide()
        UE4.UUMGLibrary.ShowFlagForPlot(GetGameIns(), false)
    end) 

    --完成当前指引
    RegisterCommand('新手指引', '完成当前指引', '完成当前指引')
        :RegisterFunc(function (self)
        GuideLogic.SkipNowGuide()
    end) 
    
    --完成所有指引
    RegisterCommand('新手指引', '完成所有指引', '完成所有指引')
        :RegisterFunc(function (self)
        GuideLogic.SkipAllGuide()
        UE4.UUMGLibrary.ShowFlagForPlot(GetGameIns(), false)
    end)
    
    --重置所有指引
    RegisterCommand('新手指引', '重置所有指引', '重置所有指引')
        :RegisterFunc(function (self)
        GuideLogic.ResetAllGuide()
    end)

    ---打开指定指引
    RegisterCommand('新手指引', '打开指定指引', '打开指定指引')
        :RegisterParam('string','OpenAppointGuide','60')
        :RegisterFunc(function (self)
            local msg=self:GetParam('OpenAppointGuide')
            GuideLogic.OpenAppointGuide(msg)
    end)

    ---添加测试指引事件
    RegisterCommand('新手指引', '添加测试指引事件', '添加测试指引事件')
        :RegisterFunc(function (self)
            GuideLogic.AddNotifyEvent(true)
    end)
end

-- 战斗流程
local RegisterFightFlowCommand = function()
    --停止计时 
    RegisterCommand("战斗流程","停止计时","停止计时")
    :RegisterFunc(function(self)
        local PlayerController = GetOwningPlayer()
        PlayerController:ApplyClearLevelCountDownTimer()
    end)

    --直接关卡胜利
    RegisterCommand("战斗流程","直接关卡胜利","直接关卡胜利")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("LevelVictory");
        end
        CloseUIGM()
        --- 如果直接进入单机关卡，就直接跳转到结算
        -- if IsEditor and not RunFromEntry then
        --     UI.Open("Success")
        -- end
    end)

    --直接关卡失败
    RegisterCommand("战斗流程","直接关卡失败","直接关卡失败")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("LevelFailed");
        end
        CloseUIGM()
    end)

    --直接关卡重载
    RegisterCommand("战斗流程","关卡重启","关卡重启")
    :RegisterFunc(function(self)
        local ins = GetGameIns()
        UE4.ULevelLibrary.KillActorByTag(ins, 'Target')
        UE4.ULevelLibrary.ResetPlayerToStartPoint(ins)
        local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(ins)
        if TaskActor then
            TaskActor:RestartGameTask()
        end
        CloseUIGM()
    end)

    --单机设置角色卡等级
    RegisterCommand("战斗流程","替换角色","单机设置替换角色")
    :RegisterParam("string", "FormationSite1", "1-1-1-1-1-1-1")
    :RegisterParam("string", "Weapon1", "")
    :RegisterParam("string", "FormationSite2", "")
    :RegisterParam("string", "Weapon2", "")
    :RegisterParam("string", "FormationSite3", "")
    :RegisterParam("string", "Weapon3", "")
    :RegisterFunc(function(self)
        local Items = UE4.TArray(UE4.UCharacterCard)
        for i = 1, 3 do
            local strGDPL = self:GetParam("FormationSite" .. i)
            local tbGDPL = Split(strGDPL, "-")
            local nNum = #tbGDPL;
            local lpCard = nil
            if nNum >= 4 then
                local nLevel = nNum >= 5 and tonumber(tbGDPL[5]) or 1
                local nNerve = nNum >= 6 and tonumber(tbGDPL[6]) or 1
                local nBreak = nNum >= 7 and tonumber(tbGDPL[7]) or 1
                lpCard = me:CreateItem(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]), tonumber(tbGDPL[4]), nLevel, true)       
                if lpCard then
                    lpCard:SetSpineNode(nNerve)
                    lpCard:SetBreak(nBreak)
                end            
            end

            local strWeaponGDPL = self:GetParam('Weapon' .. i)
            tbGDPL = Split(strWeaponGDPL, "-")
            nNum = #tbGDPL;
            local lpWeapon = nil
            if nNum >= 4 then
                local nLevel = nNum >= 5 and tonumber(tbGDPL[5]) or 1
                local nSkill = nNum >= 6 and tonumber(tbGDPL[6]) or 1
                lpWeapon = me:CreateItem(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]), tonumber(tbGDPL[4]), nLevel, true)      
                if lpWeapon then
                    lpWeapon:SetBreak(nSkill)
                    lpCard:AddSlotItem(4, lpWeapon)
                end    
            end
            

            if lpCard then
                Items:Add(lpCard)
            end
            

        end
        local PlayerController = GetOwningPlayer()
        if PlayerController and Items:Length() > 0 then
            PlayerController:GM_ReplacePlayer(Items)
            local ui_fight = UI.GetUI("Fight")
            if ui_fight then 
                return ui_fight.PlayerSelect:ResetChracter()
            end
        end
        CloseUIGM()
    end)

    --预览相机
    RegisterCommand("战斗流程","预览相机","在次调用取消")
    :RegisterFunc(function(self)
        local Widget = UI.GetUI("AdinGM")
        if UE4.UKismetSystemLibrary.GetOuterObject(Widget,Widget) then
            if self.ActiveShow then
                UE4.UKismetSystemLibrary.GetOuterObject(UE4.UKismetSystemLibrary.GetOuterObject(Widget)).CameraOpration:SetVisibility(UE4.ESlateVisibility.Collapsed)
                GetOwningPlayer().SetActiveShow(false)
                self.ActiveShow=false
            else
                UE4.UKismetSystemLibrary.GetOuterObject(UE4.UKismetSystemLibrary.GetOuterObject(Widget)).CameraOpration:SetVisibility(UE4.ESlateVisibility.Visible)
                GetOwningPlayer().SetActiveShow(true)
                self.ActiveShow=true
            end
        end
    end)

    --自由视角
    RegisterCommand("战斗流程","自由视角","自由视角")
    :RegisterFunc(function(self)
        if self.bFreedomCamera then
            UE4.UGMLibrary.StopFreedomCameraMode(GetOwningPlayer())
            self.bFreedomCamera=false
            print("开启自由视角")
        else
            UE4.UGMLibrary.StartFreedomCameraMode(GetOwningPlayer())
            self.bFreedomCamera=true
            print("关闭自由视角")
        end
    end)

    ----显示关卡名称
    RegisterCommand("战斗流程","显示关卡名称","会显示在输出日志中不会显示在屏幕上请注意")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("ShowLevel");
        end
    end)

    ---重置关卡锁
    RegisterCommand("战斗流程","重置关卡锁","重置关卡锁")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("TaskUnlock");
        end
    end)

    ---输出当前关卡ID
    RegisterCommand("战斗流程","输出关卡ID","输出当前关卡ID")
    :RegisterFunc(function(self)
        UI.ShowTip(string.format("当前关卡ID为：%d", Map.GetCurrentLevelId()))
    end)

    ---输出当前地图ID
    RegisterCommand("战斗流程","输出地图ID","输出当前地图ID")
    :RegisterFunc(function(self)
        UI.ShowTip(string.format("当前地图ID为：%d", Map.GetCurrentID()))
    end)

    ---忽略刷怪
    RegisterCommand("战斗流程","忽略刷怪","忽略刷怪")
    :RegisterFunc(function(self)
        GlobalDisableSpawnNpc = not GlobalDisableSpawnNpc;
        UI.ShowTip(GlobalDisableSpawnNpc and "开启功能：忽略刷怪" or "关闭功能：忽略刷怪")
    end)

    ---是否禁用动画播放
    RegisterCommand("战斗流程","禁用动画播放","是否禁用动画播放")
    :RegisterParam("number","OpenOrClose","1")
    :RegisterFunc(function(self)
        local nOpen = self:GetParam('OpenOrClose')
        UE4.UUMGLibrary.SetDisablePlayAnimation(nOpen == 1 and true or false)
    end)

    ---是否开启武器开火点光源
    RegisterCommand("战斗流程","开启武器开火点光源","是否开启")
    :RegisterParam("number","OpenOrClose","0")
    :RegisterFunc(function(self)
        local nOpen = self:GetParam('OpenOrClose')
        UE4.APlayerWeapon.SetNotShowFireLight(nOpen == 1 and true or false)
    end)
end

-- 星级条件
local RegisterStarTaskCommand = function ()
    
    --重置星级
    RegisterCommand("星级条件","重置当前星级(关卡内)","重置当前星级(关卡内)")
    :RegisterFunc(function (self)
        local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
        if pSubSys then
            pSubSys:GM_ResetStarTasks()
        end
    end)

    --完成某个星级
    RegisterCommand("星级条件","完成某个星级","完成某个星级")
    :RegisterParam('number','Index','1')
    :RegisterFunc(function (self)
        local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
        if pSubSys then
            local Index = self:GetParam('Index')
            pSubSys:GM_ResetStarTasks(Index,"-1",true)
        end
    end)

    --修改星级参数
    RegisterCommand("星级条件","修改星级参数","修改星级参数")
    :RegisterParam('number','Index','1')
    :RegisterParam('string','ParamStr','1')
    :RegisterFunc(function (self)
        local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
        if pSubSys then
            local Index = self:GetParam('Index')
            local ParamStr = self:GetParam('ParamStr')
            pSubSys:GM_ResetStarTasks(Index,ParamStr,false)
        end
    end)

    --替换星级任务
    RegisterCommand("星级条件","替换星级任务","替换星级任务")
    :RegisterParam('number','Index','1')
    :RegisterParam('string','TaskStr','{9}')
    :RegisterFunc(function (self)
        local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
        if pSubSys then
            local Index = self:GetParam('Index')
            local ParamStr = self:GetParam('TaskStr')
            pSubSys:GM_ChangeStarTask(Index,ParamStr)
        end
    end)
end

-- 修改设置指令注册
local RegisterSettingCommand = function()

    -- 修改疾跑区域参数
    RegisterCommand("设置","修改疾跑区域参数","修改疾跑区域参数")
    :RegisterParam("number", "BtnIndex", "0")
    :RegisterParam("number", "PositionX", "0")
    :RegisterParam("number", "PositionY", "0")
    :RegisterParam("number", "SizeX", "0")
    :RegisterParam("number", "SizeY", "0")
    :RegisterParam("number", "Visible", "0")
    :RegisterFunc(function (self)
        local BtnIndex = self:GetParam('BtnIndex')
        local PositionX = self:GetParam('PositionX')
        local PositionY = self:GetParam('PositionY')
        local SizeX = self:GetParam('SizeX')
        local SizeY = self:GetParam('SizeY')
        local Visible = self:GetParam('Visible')
        local FightUI = UI.GetUI("Fight")
        local JoyStick = FightUI.Joystick
        if JoyStick ~= nil then 
            local vector = UE4.FVector2D(PositionX, PositionY)
            local size = UE4.FVector2D(SizeX, SizeY)
            if BtnIndex == 0 then
                JoyStick.BtnMoveFast:SetRenderTranslation(vector)
                JoyStick.BtnMoveFast.Slot:SetSize(size)
            elseif BtnIndex == 1 then
                JoyStick.BtnNotClock:SetRenderTranslation(vector)
                JoyStick.BtnNotClock.Slot:SetSize(size)
            end
            if Visible == 0 then
                if BtnIndex == 0 then
                    JoyStick.MoveFastTemp:SetVisibility(UE4.ESlateVisibility.Collapsed)
                elseif BtnIndex == 1 then
                    JoyStick.NotClockTemp:SetVisibility(UE4.ESlateVisibility.Collapsed) 
                end
            elseif Visible == 1 then
                if BtnIndex == 0 then
                    JoyStick.MoveFastTemp:SetVisibility(UE4.ESlateVisibility.Visible)
                elseif BtnIndex == 1 then
                    JoyStick.NotClockTemp:SetVisibility(UE4.ESlateVisibility.Visible) 
                end
            end
        end
        CloseUIGM()
    end)

    -- 修改疾跑区域参数
    RegisterCommand("设置","重置摄像机区域参数","重置摄像机区域参数")
        :RegisterParam("number", "PositionX", "-860.0")
        :RegisterParam("number", "PositionY", "70.0") 
        :RegisterParam("number", "SizeX", "400.0")
        :RegisterParam("number", "SizeY", "270.0")
        :RegisterParam("number", "Alpha", "0")
        :RegisterParam("number", "IntervalDist", "50")
        :RegisterFunc(
            function (self)
                local PositionX = self:GetParam('PositionX')
                local PositionY = self:GetParam('PositionY')
                local SizeX = self:GetParam('SizeX')
                local SizeY = self:GetParam('SizeY')
                local Alpha = self:GetParam('Alpha')
                local IntervalDist = self:GetParam('IntervalDist')
                local FightUI = UI.GetUI("Fight")
                local ResetCameraArea = FightUI.Joystick.ResetCameraArea
                if ResetCameraArea then
                    ResetCameraArea.Slot:SetPosition(UE4.FVector2D(PositionX, PositionY))
                    ResetCameraArea.Slot:SetSize(UE4.FVector2D(SizeX, SizeY))
                    ResetCameraArea:SetBrushColor(UE.FLinearColor(1, 1, 1, Alpha))
                    FightUI.Joystick.MaxResetCameraIntervalDist = IntervalDist
                end
                CloseUIGM()
            end)
end

-- 战斗GM指令注册
local RegisterFightCommand = function() 

    --显示或者隐藏战斗GM
    RegisterCommand("战斗","显/隐战斗GM","显/隐战斗GM")
    :RegisterFunc(function (self)
        local FightUI = UI.GetUI("Fight")
        if FightUI and FightUI.BtnGM then
            local Visibility = FightUI.BtnGM:GetVisibility()
            if Visibility == UE4.ESlateVisibility.Collapsed or Visibility == UE4.ESlateVisibility.Hidden then
                WidgetUtils.Visible(FightUI.BtnGM)
                return
            end

            if Visibility == UE4.ESlateVisibility.Visible then
                WidgetUtils.Collapsed(FightUI.BtnGM)
            end
        end
    end)

    --战斗属性预览
    RegisterCommand("战斗","战斗属性预览","战斗属性预览")
    :RegisterFunc(function(self)
        UI.GetUI("AdinGM"):SetAttributePreviewShow(true)
        CloseUIGM()
    end)

    --单机设置角色卡等级
    RegisterCommand("战斗","单机设置角色等级","单机设置角色卡等级")
    :RegisterParam("number", "FormationSite1", "1")
    :RegisterParam("number", "FormationSite2", "1")
    :RegisterParam("number", "FormationSite3", "1")
    :RegisterFunc(function(self)
        local Level1 = self:GetParam('FormationSite1')
        local Level2 = self:GetParam('FormationSite2')
        local Level3 = self:GetParam('FormationSite3')
        UE4.ULevelLibrary.ForceSetPlayersLevel(GetGameIns(), Level1, Level2, Level3)
        CloseUIGM()
    end)

    --编队界面升级
    RegisterCommand("战斗", "提升编队等级", "0全1卡2武器3后勤")
    :RegisterParam("number", "TargerType", "0")
    :RegisterParam("number", "nLevel", "80")
    :RegisterParam("number", "nSkillLevel", "5")
    :RegisterParam("number", "nSpineLevel", "5")
    :RegisterFunc(function(self)
        local FormationUI = UI.GetUI('Formation')
        if not FormationUI then
            UI.ShowTip("执行失败,只能在编队界面执行")
            return
        end
        local Type = self:GetParam('TargerType')
        local Level = self:GetParam('nLevel')
        local nSkillLevel = self:GetParam('nSkillLevel')
        local nSpineLevel = self:GetParam('nSpineLevel')
        local Lineup = Formation.GetLineup(Formation.GetCurLineupIndex() or 1)
        if not Lineup then 
            UI.ShowTip("编队信息错误");
            return
        end

        local tbCards = Lineup:GetCards()
        for i = 1, tbCards:Length() do
            local Card = tbCards:Get(i)
            if Type == 0 or Type == 1 then
                SendCodeToHttp(string.format("GM.GMUpdateItem(%d, %d, %d, %d)", Card:Id(), Level, nSkillLevel, nSpineLevel))
            end
            if Type == 0 or Type == 2 then
                local pWeapon = Card:GetSlotWeapon()
                SendCodeToHttp(string.format("GM.GMUpdateItem(%d, %d, %d)", pWeapon:Id(), Level, nSkillLevel))
            end
            if Type == 0 or Type == 3 then
                local SupportCards = UE4.TArray(UE4.USupporterCard)
                Card:GetSupporterCards(SupportCards)
                for i = 1, SupportCards:Length() do
                    local support = SupportCards:Get(i)
                    SendCodeToHttp(string.format("GM.GMUpdateItem(%d, %d, %d)", support:Id(), Level, nSkillLevel))
                end
            end
        end
    end)

    --生成靶子
    RegisterCommand("战斗","生成靶子","生成靶子")
    :RegisterFunc(function(self)
        local Params=UE4.FSpawnNpcParams()
        Params.Location=UE4.UGameplayStatics.GetPlayerCharacter(UI.GetUI("AdinGM"),0):K2_GetActorLocation()+UE4.UGameplayStatics.GetPlayerController(GetOwningPlayer(),0):GetActorForwardVector()*500
        Params.Rotation=UE4.FRotator(0,0,0)
        Params.PlayEnterAnimIndex=1;
        Params.ID=9999999
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_SpawnNpc(Params)
        end
        -- UE4.ULevelLibrary.SpawnNpcAtLocation(UI.GetUI("AdinGM"),Params)
    end)

    --QTE测试
    RegisterCommand("战斗","QTE测试","QTE测试")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("StartTestQTE");
        end
    end)

    --DOT循环测试
    RegisterCommand("战斗","DOT循环测试","DOT循环测试")
    :RegisterFunc(function(self)
        local Value=UE4.UGameplayStatics.GetPlayerCharacter(UI.GetUI("AdinGM"),0).Ability
        if DotCount==0 then
        Value:K2_FindOrAddSkill(9000002,0,false)
        Value:CastSkill(9000002)
        print("燃烧")
        DotCount=1
        elseif DotCount==1 then
        Value:K2_FindOrAddSkill(9000003,0,false)
        Value:CastSkill(9000003)
        print("中毒")
        DotCount=2
        elseif DotCount==2 then
        Value:K2_FindOrAddSkill(9000004,0,false)
        Value:CastSkill(9000004)
        print("流血")
        DotCount=3
        elseif DotCount==3 then
        Value:K2_FindOrAddSkill(9000005,0,false)
        Value:CastSkill(9000005)
        print("冰冻")
        DotCount=0
        end
    end)

    --清屏
    RegisterCommand("战斗","清屏","清屏")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("ClearAllMonster");
        end
    end)

    --开启无敌
    RegisterCommand("战斗","开启无敌","开启无敌")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("StateGod");
            CloseUIGM();
        end
    end)

    --关闭无敌
    RegisterCommand("战斗","关闭无敌","关闭无敌")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("EndGod");
            CloseUIGM();
        end
    end)

    RegisterCommand("战斗","忽略伤害","忽略伤害")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("StateIgnoreDamage");
            CloseUIGM();
        end
    end)

    ----充能  +100蓝量
    RegisterCommand("战斗","充能","充能")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("AplliyEnergy");
        end
    end)

    ----一枪999 开启
    RegisterCommand("战斗","开启一枪999","开启一枪999")
    :RegisterParam('float','DamageRate','999')
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            local value = self:GetParam('DamageRate')
            GetOwningPlayer():GMServerCall("OneShot999", tostring(value));
        end
    end)

    ----一枪999 关闭
    RegisterCommand("战斗","关闭一枪999","关闭一枪999")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("OneShot999", "");
        end
    end)
end

local RegisterFight2Command = function()
    ----开启自动战斗(DS自动化测试)
    RegisterCommand("战斗2","开启自动战斗","开启自动战斗")
    :RegisterFunc(function(self)
        if UE4.UDsProfileFunctionLib then
            UE4.UDsProfileFunctionLib.SpawnBehaviorActor()
        else
            UI.ShowTip("执行失败，因为当前打包没有开启DSProfileTest插件")
        end
    end)

    ----关闭自动战斗(DS自动化测试)
    RegisterCommand("战斗2","关闭自动战斗","关闭自动战斗")
    :RegisterFunc(function(self)
        if UE4.UDsProfileFunctionLib then
            UE4.UDsProfileFunctionLib.RemoveBehaviorActor()
        else
            UI.ShowTip("执行失败，因为当前打包没有开启DSProfileTest插件")
        end
    end)

    ----怪物暂停
    RegisterCommand("战斗2","怪物暂停","怪物暂停")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("SuspendAllMonster");
        end
    end)

    ----刷新技能CD
    RegisterCommand("战斗2","刷新技能CD","刷新技能CD")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("FreshCD");
        end
    end)

    ---血量回满
    RegisterCommand("战斗2","血量回满","血量回满")
    :RegisterFunc(function(self)
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("HealSelf");
        end
    end)

    --同步等级
    RegisterCommand("战斗2","同步等级","同步等级")
    :RegisterFunc(function(self)
        UE4.ULevelLibrary.SyncPlayersLevel(GetOwningPlayer(),GetOwningPlayer())
        print("等级同步")
    end)

    --时间流逝
    RegisterCommand("战斗","时间流逝","设置时间流逝倍率")
    :RegisterParam('float','value','1')
    :RegisterFunc(function(self)
        local value = self:GetParam('value')
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_ExecuteConsoleCommand("Slomo " .. value)
        end

        UE4.UGameplayStatics.SetGlobalTimeDilation(GetOwningPlayer(), value)
        UI.ShowTip("当前时间流逝倍率: " .. UE4.UGameplayStatics.GetGlobalTimeDilation(GetOwningPlayer()) .. ", 切换场景重置" )
        CloseUIGM()
    end)

    --百分比扣除
    RegisterCommand("战斗2","扣除自己血量","伤害百分比(0~100)")
    :RegisterParam('float','PlayerHealth','0')
    :RegisterFunc(function(self)
        local PlayerHealth = math.max(0, math.min(self:GetParam('PlayerHealth'), 100))
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("DecPlayerHealth", PlayerHealth)
            CloseUIGM();
        end
    end)

    --百分比扣除
    RegisterCommand("战斗2","扣除怪物血量","伤害百分比(0~100)")
    :RegisterParam('float','MonsterHealth','0')
    :RegisterParam('float','MonsterSheild','0')
    :RegisterFunc(function(self)
        local MonsterHealth = math.max(0, math.min(self:GetParam('MonsterHealth'), 100))
        local MonsterSheild = math.max(0, math.min(self:GetParam('MonsterSheild'), 100))
        local GamePlayer = UE4.UGameplayStatics.GetPlayerCharacter(GetOwningPlayer(), 0)
        local GamePlayerAbility = GamePlayer and GamePlayer.Ability
        if (not GamePlayer) or (not GamePlayerAbility) then
            return
        end
        
        -- 扣除怪物
        local TargetArray = UE4.UAbilityFunctionLibrary.QueryTargetsWithEmitterInfo(GamePlayerAbility, GamePlayer, GamePlayer, 900000001)
        for i = 1, TargetArray:Length() do
            local Target = TargetArray:Get(i).QueryTarget
            local MonsterAbility = Target and Target.Ability
            if Target and MonsterAbility then
                -- 怪物血量
                local MaxHealth = MonsterAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
                local NowHealth = MonsterAbility:GetRolePropertieValue(UE4.EAttributeType.Health)

                -- 怪物护盾
                local MaxSheild = MonsterAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Shield)
                local NowSheild = MonsterAbility:GetRolePropertieValue(UE4.EAttributeType.Shield)

                local TargetHealth = math.ceil(NowHealth - (MonsterHealth / 100) * MaxHealth)
                -- 直接设置血量时不能设置0 所以直接杀死
                if TargetHealth <= 0 then
                    local HealthChangeValue = UE4.FHealthChangeValue()
                    HealthChangeValue.Value = MaxHealth + MaxSheild
                    HealthChangeValue.HealthChangeType = UE4.EModifyHPType.Pure
                    MonsterAbility:ModifyHealth(GamePlayerAbility, HealthChangeValue)
                else
                    MonsterAbility:SetPropertieValueFromString("Health", TargetHealth)
                
                    if NowSheild > 0 then
                        local SubSheild = math.ceil((MonsterSheild / 100) * MaxSheild)
                        local HealthChangeValue = UE4.FHealthChangeValue()
                        HealthChangeValue.Value = math.min(SubSheild, NowSheild)
                        HealthChangeValue.HealthChangeType = UE4.EModifyHPType.Pure
                        MonsterAbility:ModifyHealth(GamePlayerAbility, HealthChangeValue)
                    end
                end
            end
        end
        CloseUIGM()
    end)

    --显示怪物数量
    RegisterCommand("战斗2","显示怪物数量","显示怪物数量")
    :RegisterParam('number','NowNum','0')
    :RegisterFunc(function (self)
        local MonsterNum = 0
        local Actors = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(),UE4.AGameCharacter)
        for i=1,Actors:Length() do
            local A = Actors:Get(i)
            if IsAI(A) then
                MonsterNum = MonsterNum + 1
            end
        end
        self:SetParam('NowNum',MonsterNum)
        EventSystem.Trigger('RefreshGMParams')
    end)

    RegisterCommand("战斗2","血条显示修改","是否使用Fight血条")
    :RegisterParam("number","OpenOrClose","1")
    :RegisterFunc(function (self)
        local nOpen = self:GetParam('OpenOrClose')
        UE4.UGameLibrary.SetEnableFightMonBloodBar(nOpen == 1 and true or false)
    end)
end

-- 战斗call怪物
local RegisterFightCallCommand = function()
    ---召唤NPC
    RegisterCommand('召唤', '召唤NPC', '召唤NPC')
        :RegisterParam('number','NPCID','9501001')
        :RegisterParam('number','NPCNum','1')
        :RegisterParam('number','NPCLevel','1')
        :RegisterParam('number','NPCSkill1','5000012')
        :RegisterParam('number','NPCSkill2','5000011')
        :RegisterParam('number','SpecialProperties ','1001')
        :RegisterFunc(function (self)
        local msg=self:GetParam('OpenAppointGuide')
        local NPCLocation=GetOwningPlayer():K2_GetPawn():K2_GetActorLocation()+GetOwningPlayer():K2_GetPawn():GetActorForwardVector()*400
        local SkilsArr=UE4.TArray(UE4.int32)
        local Params= UE4.FSpawnNpcParams()
        Params.Id=self:GetParam('NPCID')
        Params.AI=self:GetParam('NPCID')
        Params.Location=NPCLocation
        Params.Rotation=nil
        Params.PlayEnterAnimIndex=1
        Params.Level=self:GetParam('NPCLevel')
        Params.Team="1"
        Params.Type=UE4.ECharacterType.AI
        Params.AIEvents=nil
        Params.AIEventID=0
        Params.bIsTeamCaptain=false
        Params.PatrolPoint=""
        Params.SpecializedSkillsConfig.MinNum=2
        Params.SpecializedSkillsConfig.MaxNum=2
        SkilsArr:Add(self:GetParam('NPCSkill1'))
        SkilsArr:Add(self:GetParam('NPCSkill2'))
        Params.SpecializedSkillsConfig.SpecializedSkillIDs= SkilsArr;
        Params.SpecializedSkillsConfig.SpecializedPropertyID = self:GetParam('SpecialProperties ')
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_SpawnNpc(Params)
        end
        -- UE4.ULevelLibrary.SpawnNpcAtLocation(GetOwningPlayer(),Params,GetOwningPlayer())
    end)
end

-- 活动GM指令注册
local RegisterActivityCommand = function()
    ---角色碎片本自定义解锁进度
    RegisterCommand('活动', '碎片本解锁', '角色碎片本自定义解锁进度')
        :RegisterParam('string','G','1')
        :RegisterParam('string','D','1')
        :RegisterParam('string','P','1')
        :RegisterParam('string','L','1')
        :RegisterParam('string','diff','1')
        :RegisterParam('string','Progress','1')
        :RegisterFunc(function (self)
            local G = self:GetParam('G')
            local D = self:GetParam('D')
            local P = self:GetParam('P')
            local L = self:GetParam('L')
            local diff = self:GetParam('diff')
            local progress = self:GetParam('Progress')
            SendCodeToHttp(string.format("Role.SetProgress(%d,%d,%d,%d,%d,%d)", G,D,P,L,diff,progress))
    end)

    ---角色碎片本指定记忆嵌片数量
    RegisterCommand('活动', '碎片本记忆嵌片', '角色碎片本指定记忆嵌片数量')
        :RegisterParam('string','Role_UseNum','0')
        :RegisterFunc(function (self)
            local num = self:GetParam('Role_UseNum')
            SendCodeToHttp(string.format("Role.SetUseNum(%d)", num))
    end)

    ---角色碎片本重置本SSR挑战次数
    RegisterCommand('活动', '碎片本SSR次数', '角色碎片本重置SSR挑战次数')
        :RegisterParam('number','chapterID','0')
        :RegisterFunc(function (self)
            local num = self:GetParam('chapterID') or 0
            if num == 0 and Role.GetLevelID() > 0 then
                num = Role.GetLevelID()
            end
            SendCodeToHttp(string.format("GM.Role.ResetRoleLevelNum(%d)", num))
    end)

    ---曜日解锁关卡
    RegisterCommand('活动', '解锁所有曜日本', '解锁所有难度的曜日本')
        :RegisterFunc(function (self)
            SendCodeToHttp("GM.Daily.GMUnlockAllLevel()")
    end)

    ---开放所有曜日本
    RegisterCommand('活动', '开放所有曜日本', '强制开放所有曜日本')
        :RegisterFunc(function (self)
            Daily.GMOpenDaily()
            SendCodeToHttp("GM.Daily.GMOpenAllLevel()")
    end)

    ---设置曜日本保底值
    RegisterCommand('活动', '设置曜日本保底值', '设置曜日本保底值')
        :RegisterParam('number','Guarantee','500')
        :RegisterFunc(function (self)
            local Guarantee = self:GetParam("Guarantee")
            SendCodeToHttp(string.format("GM.Daily.GMSetGuarantee(%d)", Guarantee))
    end)

    ---指定商店刷新次数
    RegisterCommand('活动', '商店刷新次数', '指定商店刷新次数')
        :RegisterParam('string','Shop_ShopID','0')
        :RegisterParam('string','Shop_RefreshNum','0')
        :RegisterFunc(function (self)
            local ShopID = self:GetParam('Shop_ShopID')
            if not ShopLogic.GetShopInfo(tonumber(ShopID)) then
                return
            end
            local RefreshNum = self:GetParam('Shop_RefreshNum')
            SendCodeToHttp(string.format("ShopLogic.SetShopRefreshNum(%d, %d)", ShopID, RefreshNum))
    end)

    ---战术考核解锁关卡
    RegisterCommand('活动', '战术考核解锁关卡', '战术考核解锁关卡')
        :RegisterParam('string','TowerEvent_num','1')
        :RegisterFunc(function (self)
            local num = self:GetParam('TowerEvent_num')
            SendCodeToHttp(string.format("TowerEventChapter.GMUnlockLevel(%d)", num))
    end)

    ---boss挑战打开指定期数
    RegisterCommand('BOSS挑战', 'boss指定期数', 'boss挑战指定期数')
        :RegisterParam('string','Boss_Level_Time','0')
        :RegisterFunc(function (self)
            local id = self:GetParam('Boss_Level_Time')
            SendCodeToHttp(string.format("BossLogic.GMOpenChallenge(%d)", id))
    end)
    ---boss挑战解锁指定难度
    RegisterCommand('BOSS挑战', 'boss指定难度', 'boss挑战解锁指定难度')
        :RegisterParam('string','Boss_Level_Diff','1')
        :RegisterFunc(function (self)
            local diff = self:GetParam('Boss_Level_Diff')
            SendCodeToHttp(string.format("BossLogic.GMOpenDiff(%d)", diff))
    end)
    ---boss挑战获得指定分数
    RegisterCommand('BOSS挑战', 'boss指定分数', 'boss挑战指定分数')
        :RegisterParam('string','Boss_Level_Id','0')
        :RegisterParam('string','Boss_Level_Integral','0')
        :RegisterFunc(function (self)
            local id = self:GetParam('Boss_Level_Id')
            local integral = self:GetParam('Boss_Level_Integral')
            SendCodeToHttp(string.format("BossLogic.GMOpenDiff(%d,%d)", id, integral))
    end)

    ---指定爬塔周期并重置奖励
    RegisterCommand('爬塔挑战', '爬塔指定周期', '指定爬塔周期并重置奖励')
        :RegisterParam('string','Tower_Time','0')
        :RegisterFunc(function (self)
            local ID = self:GetParam('Tower_Time')
            SendCodeToHttp(string.format("ClimbTowerLogic.GMResetLevel(%d)", ID))
    end)

    ---爬塔解锁关卡
    RegisterCommand('爬塔挑战', '爬塔解锁关卡', '爬塔解锁关卡并满星级完成')
        :RegisterParam('string','Tower_Type','1')
        :RegisterParam('string','Tower_Layer','0')
        :RegisterFunc(function (self)
            local Type = self:GetParam('Tower_Type')
            local Layer = self:GetParam('Tower_Layer')
            SendCodeToHttp(string.format("ClimbTowerLogic.GMCompleteLevel(%d, %d)", Type, Layer))
    end)

    --爬塔完成当前层
    RegisterCommand("爬塔挑战","爬塔完成当前层","爬塔完成当前层")
    :RegisterFunc(function(self)
        if Launch.GetType() == LaunchType.TOWER and UI.IsOpen("fight") then
            local nTowerID = ClimbTowerLogic.GetLevelID()
            SendCodeToHttp(string.format("ClimbTowerLogic.TowerVictory(%d)", nTowerID))
        end
    end)
end

-- 蛋池GM指令注册
local RegisterGachaCommand = function() 
    RegisterCommand("蛋池","设置保底计数","设置保底计数")
    :RegisterParam('number','PoolID','1')
    :RegisterParam('number','nTime','79')
    :RegisterFunc(function(self)
        local PoolID = self:GetParam('PoolID')
        local nTime = self:GetParam('nTime')
        SendCodeToHttp(string.format("Gacha.GmSetTime(%d, %d)", PoolID, nTime))
        UI.ShowTip("执行成功") 
    end)

    RegisterCommand("蛋池","设置十抽保底计数", "设置十抽保底计数")
    :RegisterParam('number','PoolID','1')
    :RegisterParam('number','nTime','9')
    :RegisterFunc(function(self)
        local PoolID = self:GetParam('PoolID')
        local nTime = self:GetParam('nTime')
        SendCodeToHttp(string.format("Gacha.GmSetTenTime(%d, %d)", PoolID, nTime))
        UI.ShowTip("执行成功") 
    end)

    RegisterCommand("蛋池","模拟抽奖", "模拟抽奖")
    :RegisterParam('number','PoolID','1')
    :RegisterParam('number','nLaunchCount','100')
    :RegisterParam('number','nTenFlag','1')
    :RegisterFunc(function(self)
        local PoolID = self:GetParam('PoolID')
        local nLaunchCount = self:GetParam('nLaunchCount')
        local nTenFlag = self:GetParam('nTenFlag')
        SendCodeToHttp(string.format("Gacha.GmTest(%d, %d, %d)", PoolID, nLaunchCount, nTenFlag))
        UI.ShowTip("执行成功") 
    end)


    RegisterCommand("蛋池","权重", "权重")
    :RegisterParam('number','PoolID','1')
    :RegisterParam('number','nTenTime','1')
    :RegisterParam('number','nTotalTime','1')
    :RegisterFunc(function(self)
        local PoolID = self:GetParam('PoolID')
        local nTenTime = self:GetParam('nTenTime')
        local nTotalTime = self:GetParam('nTotalTime')
        SendCodeToHttp(string.format("Gacha.PrintWeight(%d, %d, %d)", PoolID, nTenTime, nTotalTime))
        UI.ShowTip("执行成功") 
    end)
end

-- 联机GM指令注册
local RegisterOnlineCommand = function()
    --- 指定关卡
    RegisterCommand('联机', '指定关卡','指定进入某个关卡(先开启后创建房间)')
    :RegisterParam('number','OnlineLevel_Id','0')
    :RegisterFunc(function (self)
        local nLevelId = self:GetParam('OnlineLevel_Id')
        if nLevelId == 0 or OnlineLevel.GetConfig(nLevelId) then
            SendCodeToHttp(string.format("Online.GmSetLevel(%d)", nLevelId))
            UI.ShowTip("执行成功") 
        end
    end)

    --- 开启某个玩法 
    RegisterCommand('联机', '开启玩法','开启某个玩法')
    :RegisterParam('number','Online_Id','0')
    :RegisterFunc(function (self)
        local ID = self:GetParam('Online_Id')
        if Online.GmOpenOne(ID) then
            SendCodeToHttp(string.format("Online.GmOpenOne(%d)", ID))
            UI.ShowTip("执行成功") 
        end
    end)

    --- 增加精神协作值
    RegisterCommand('联机', '增加精神协作值','增加精神协作值')
    :RegisterParam('number','Online_Value','0')
    :RegisterFunc(function (self)
        local nValue = self:GetParam('Online_Value')
        if nValue > 0 then
            SendCodeToHttp(string.format("Online.AddWeeklyPoint(%d)", nValue))
            UI.ShowTip("执行成功") 
        elseif nValue == 0 then
            SendCodeToHttp(string.format("Online.SetWeeklyPoint(%d)", nValue))
            UI.ShowTip("执行成功") 
        end
    end)

    --- 自己自杀
    RegisterCommand('联机', '自己自杀','自己自杀')
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
        if Character then 
            Character:ApplyKillSelf();
        end
        --CloseUIGM();
    end)   

    --- 队友自杀 测试复活救助等
    RegisterCommand('联机', '队友自杀','所有队友自杀')
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
        if Character then 
            Character:ApplyKillTeamMember();
        end
        --CloseUIGM();
    end)   

    --- 所有敌人自杀 测试流程
    RegisterCommand('联机', '怪物自杀','所有怪物自杀')
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
        if Character then 
            Character:ApplyKillAllEnemy();
        end
        --CloseUIGM();
    end)   

    --- 获取关卡金币 测试流程
    RegisterCommand("联机", "获取关卡金币", "获取关卡金币")
    :RegisterParam("number", "LevelMoney", "1000")
    :RegisterFunc(
        function(self)
            local nLevelMoney = self:GetParam('LevelMoney')
            local pawn = GetOwningPlayer():K2_GetPawn()
            if pawn and pawn.PlayerState then
                pawn.PlayerState:ApplyaAddLevelMoney(nLevelMoney)
            end
        end
    )

    --- 设置复活币数量
    RegisterCommand("联机", "设置复活次数", "设置复活次数")
    :RegisterParam("number", "Count", "10")
    :RegisterFunc(
        function(self)
            local Count = self:GetParam('Count')
            local PlayerController = GetOwningPlayer()
            if PlayerController then
                PlayerController:Server_DebugSetReviveCount(Count)
            end
        end
    )

    --- 添加联机buff
    RegisterCommand("联机","添加buff","添加buff")
    :RegisterParam("number","BuffId","0")
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            local id = self:GetParam('BuffId')
            PlayerController:Server_GM_AddBuffById(id)
        end
    end)

    --- 进入性能测试模式
    RegisterCommand("联机","性能测试模式","进入性能测试模式")
    :RegisterParam("number","OpenOrClose","0")
    :RegisterFunc(function (self)
        local nOpen = self:GetParam('OpenOrClose')
        UE4.UGameLibrary.SetPerformanceMode(nOpen == 1 and true or false)
    end)
    
    --- 开启Profile
    RegisterCommand("联机","netprofile enable","netprofile enable")
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_ExecuteConsoleCommand("netprofile enable: start recording if not already recording")
        end
    end)

    --- 关闭Profile
    RegisterCommand("联机","netprofile disable","netprofile disable")
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_ExecuteConsoleCommand("netprofile disable: stop recording if currently recording")
        end
    end)

    --- 内存导出
    RegisterCommand("联机","MemReport","MemReport")
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_ExecuteConsoleCommand("MemReport -full")
        end
    end)

    --- 执行输入指令
    RegisterCommand("联机","执行输入指令","执行输入指令")
    :RegisterParam("string", "CommandLine", "")
    :RegisterFunc(function (self)
        local CmdLine = self:GetParam("CommandLine")
        local PlayerController = GetOwningPlayer()
        if PlayerController then
            PlayerController:Server_GM_ExecuteConsoleCommand(CmdLine)
        end
    end)

    --百分比扣除
    RegisterCommand("联机","扣除怪物血量","伤害百分比(0~100)")
    :RegisterParam('float','MonsterHealth','0')
    :RegisterParam('float','MonsterSheild','0')
    :RegisterFunc(function(self)
        local MonsterHealth = math.max(0, math.min(self:GetParam('MonsterHealth'), 100))
        local MonsterSheild = math.max(0, math.min(self:GetParam('MonsterSheild'), 100))
        if GetOwningPlayer() then
            GetOwningPlayer():GMServerCall("DecMonsterHealth", json.encode({MonsterHealth = MonsterHealth, MonsterSheild = MonsterSheild}))
            CloseUIGM();
        end
    end)

    RegisterCommand('联机', '立即复活自己','立即复活自己')
    :RegisterFunc(function (self)
        local PlayerController = GetOwningPlayer()
        local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
        if Character then
            local isAlive = Character:IsAlive()
            print('Revive isAlive', isAlive)
            if isAlive then return end
            local count = PlayerController:GetReviveCount();
            print('Revive count', count)
            if count <= 0 then
                return
            end
            print('Revive CanUseReviveCoin', Character:CanUseReviveCoin())
            if not Character:CanUseReviveCoin() then return end 
            if not isAlive then 
                PlayerController:Server_ApplyReviveImmediately(Character)
                print('Revive Server_ApplyReviveImmediately', Character)
            end
        end
        --CloseUIGM();
    end)
end

-- 服务器指令
local RegisterServerCommand = function() 
    -- 我全要
    RegisterCommand("服务器","我全都要","我全都要")
    :RegisterFunc(function(self)
        SendCodeToHttp("GM.AddAllItem()")
        SendCodeToHttp("GM.UnLockAllLevel()")
        CloseUIGM()

        UE4.Timer.Add(1, function()
            if UI.IsOpen("Main") then 
                UI.GetUI("Main"):RefreshUI()
            end
        end)
    end)

    -- 解锁所有关卡
    RegisterCommand("服务器","解锁所有关卡","解锁所有关卡")
    :RegisterFunc(function(self)
        SendCodeToHttp("GM.UnLockAllLevel()")
    end)

    -- 解锁指定关卡
    RegisterCommand("服务器","解锁指定关卡","解锁指定关卡")
    :RegisterParam("number", "chapter", "1")
    :RegisterParam("number", "diff", "1")
    :RegisterParam("number", "chapterID", "1107")
    :RegisterFunc(function(self)
        local chapter = self:GetParam("chapter")
        local diff = self:GetParam("diff")
        local chapterID = self:GetParam("chapterID")
        SendCodeToHttp(string.format("GM.UnLockLevel(%s, %s, %s)", chapter, diff, chapterID))
    end)

    -- 添加比特金
    RegisterCommand("服务器","添加比特金","添加比特金")
    :RegisterParam("number", "Count", "0")
    :RegisterFunc(function(self)
        local Count = self:GetParam("Count")
        SendCodeToHttp(string.format("GM.Add(GM.AddMoney, {%s, %s})", 1, Count))
    end)

    -- 添加数据金
    RegisterCommand("服务器","添加数据金","添加数据金")
    :RegisterParam("number", "Count", "0")
    :RegisterFunc(function(self)
        local Count = self:GetParam("Count")
        SendCodeToHttp(string.format("GM.Add(GM.AddMoney, {%s, %s})", 2, Count))
    end)

    -- 添加体力
    RegisterCommand("服务器","添加体力","添加体力")
    :RegisterParam("number", "Count", "0")
    :RegisterFunc(function(self)
        local Count = self:GetParam("Count")
            SendCodeToHttp(string.format("GM.Add(GM.AddVigor, %s)", Count))
    end)

    -- 添加通用银
    RegisterCommand("服务器","添加通用银","添加通用银")
    :RegisterParam("number", "Count", "0")
    :RegisterFunc(function(self)
        local Count = self:GetParam("Count")
        SendCodeToHttp(string.format("GM.Add(GM.AddMoney, {%s, %s})", 3, Count))
    end)

    -- 添加账号经验
    RegisterCommand("服务器","添加账号经验","添加账号经验")
    :RegisterParam("number", "Exp", "0")
    :RegisterFunc(function(self)
        local Exp = self:GetParam("Exp")
        SendCodeToHttp(string.format("GM.Add(GM.AddExp, %s)", Exp))
    end)


    -- 添加道具
    RegisterCommand("服务器","添加道具","添加道具")
    :RegisterParam("number", "G", "0")
    :RegisterParam("number", "D", "0")
    :RegisterParam("number", "P", "0")
    :RegisterParam("number", "L", "0")
    :RegisterParam("number", "Count", "1")
    :RegisterFunc(function(self)
        local G = self:GetParam("G")
        local D = self:GetParam("D")
        local P = self:GetParam("P")
        local L = self:GetParam("L")
        local Count = self:GetParam("Count")
        SendCodeToHttp(string.format("GM.Add(GM.AddItem, {%s, %s, %s, %s, %s})", G, D, P, L, Count))
    end)

    -- 添加月卡
    RegisterCommand("服务器","增减月卡天数","增减月卡天数")
    :RegisterParam("number", "Days", "0")
    :RegisterFunc(function(self)
        local nDays = self:GetParam("Days")
        SendCodeToHttp(string.format("GM.MonthlyCard.GMOperDays(%s)", nDays))
    end)

    -- 重置角色卡
    RegisterCommand("服务器","重置角色卡","重置角色卡")
    :RegisterParam("number", "G", "0")
    :RegisterParam("number", "D", "0")
    :RegisterParam("number", "P", "0")
    :RegisterParam("number", "L", "0")
    :RegisterFunc(function(self)
        local G = self:GetParam("G")
        local D = self:GetParam("D")
        local P = self:GetParam("P")
        local L = self:GetParam("L")
        SendCodeToHttp(string.format("GM.ResetGirlCard({%s, %s, %s, %s})", G, D, P, L))
    end)

    -- 重置拥有的所有角色卡
    RegisterCommand("服务器","重置所有角色卡","重置所有角色卡")
    :RegisterFunc(function(self)
        SendCodeToHttp(string.format("GM.ResetAllGirlCard()"))
    end)
end


-- 多语言
local RegisterLocalizeCommand = function() 
    -- 显示隐藏语言切换
    RegisterCommand("多语言","显示/隐藏语言切换","显示/隐藏语言切换")
    :RegisterFunc(function(self)
        Localization.bForceShowLanguageSelect = (not Localization.bForceShowLanguageSelect)
    end)

    ---强制设置语言
    RegisterCommand("多语言","语言切换","语言切换")
    :RegisterParam("string", "language", "简体中文-zh_CN", "选择语言", {type = "combo", value = Localization.GetGMLangTable()})
    :RegisterParam("string", "language_str", "", "手动输入语言\n优先级更高")
    :RegisterFunc(function(self)
        local sLan = self:GetParam("language_str")
        if sLan and #sLan > 0 then 
            Localization.SwitchLanguage(sLan)
        else 
            local sLan = self:GetParam("language")
            local tb = Split(sLan, "-");
            Localization.SwitchLanguage(tb[#tb])
        end
    end)

    ---强制开关年龄限制
    RegisterCommand("多语言","开启/关闭年龄限制","开启/关闭年龄限制")
    :RegisterFunc(function(self)
        IBLogic.GMOpenAgeLimit()
        if IBLogic.GMSkipAgeLimit then
            UI.ShowTip("关闭年龄限制成功")
        else
            UI.ShowTip("开启年龄限制成功")
        end
    end)
end

-- 宿舍指令注册
local RegisterHouseCommand = function ()
    RegisterCommand("宿舍","预览家具送礼演绎","预览家具送礼演绎")
    :RegisterParam("number","FurTmpId","0")
    :RegisterFunc(function (self)
        local TmpId = self:GetParam('FurTmpId')

        local Furs = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(),UE4.AHouseFurnitureBase)
        for i = 1, Furs:Length() do
            local Fur = Furs:Get(i);
            if IsValid(Fur) then
                if Fur:K2_GetTemplate().Id == TmpId then
                    Fur:PlayCameraAnim()
                end
            end
        end
    end)

    RegisterCommand("宿舍","清空所有角色的所有家具","清空所有角色的所有家具")
    :RegisterFunc(function (self)
        SendCodeToHttp(string.format("GM.House.ResetAllFurniture()"))
    end)

    RegisterCommand("宿舍","清空角色所有家具","清空角色所有家具")
    :RegisterParam("number", "GirlId", "2")
    :RegisterFunc(function (self)
        local GirlId = self:GetParam('GirlId')
        SendCodeToHttp(string.format("GM.House.ResetGirlFurniture(%s)", GirlId))
    end)

    RegisterCommand("宿舍","清空角色指定家具","清空角色指定家具")
    :RegisterParam("number", "AreaId", "1")
    :RegisterParam("number", "GirlId", "2")
    :RegisterFunc(function (self)
        local GirlId = self:GetParam('GirlId')
        local AreaId = self:GetParam('AreaId')
        SendCodeToHttp(string.format("GM.House.ResetFurniture(%s, %s)", AreaId, GirlId))
    end)

    RegisterCommand("宿舍","增加少女信赖度","增加少女信赖度")
    :RegisterParam("number", "GirlId", "1")
    :RegisterParam("number", "Num", "1000")
    :RegisterFunc(function (self)
        local GirlId = self:GetParam('GirlId')
        local Num = self:GetParam('Num')
        SendCodeToHttp(string.format("GM.House.AddGirlLoveNum(%s, %s)", GirlId, Num))
    end)

    RegisterCommand("宿舍","增加所有少女信赖度","增加所有少女信赖度")
    :RegisterParam("number", "Num", "1000")
    :RegisterFunc(function (self)
        local Num = self:GetParam('Num')
        SendCodeToHttp(string.format("GM.House.AddAllGirlLoveNum(%s)", Num))
    end)

    RegisterCommand("宿舍","重置房间入住","重置房间入住")
    :RegisterFunc(function (self)
        SendCodeToHttp(string.format("GM.House.ResetAllRegisterState()"))
    end)

    RegisterCommand("宿舍","清空角色好感度","清空角色好感度")
    :RegisterParam("number", "GirlId", "2")
    :RegisterFunc(function (self)
        local GirlId = self:GetParam('GirlId')
        if GirlId == -1 then
            SendCodeToHttp(string.format("GM.House.ResetAllFavor()"))
        else
            SendCodeToHttp(string.format("GM.House.ResetFavor(%s)", GirlId))
        end
    end)

    RegisterCommand("宿舍","清空角色Task","清空角色Task")
    :RegisterParam("number", "GirlId", "2")
    :RegisterFunc(function (self)
        local GirlId = self:GetParam('GirlId')
        if GirlId == -1 then
            SendCodeToHttp(string.format("GM.House.ResetAllTask()"))
        else
            SendCodeToHttp(string.format("GM.House.ResetTask(%s)", GirlId))
        end
    end)

    RegisterCommand("宿舍","随机每日对话","随机每日对话")
    :RegisterFunc(function (self)
        SendCodeToHttp(string.format("GM.House.RandomDailyTakl()"))
    end)

    RegisterCommand("宿舍","随机入住少女","随机入住少女")
    :RegisterFunc(function (self)
        SendCodeToHttp(string.format("GM.House.UnLockRoomAndGrilsLiveIn()"))
    end)

    RegisterCommand("宿舍","一键满配(入住+家具)","一键满配(入住+家具)")
    :RegisterFunc(function (self)
        SendCodeToHttp(string.format("GM.House.UnLockRoomAndGrilsLiveInAndAddFurniture()"))
    end)

    RegisterCommand("宿舍","区域获得家具","区域获得家具")
    :RegisterParam("number", "AreaId", "0")
    :RegisterParam("number", "FurnitureId", "0")
    :RegisterFunc(function (self)
        local AreaId = self:GetParam('AreaId')
        local FurnitureId = self:GetParam('FurnitureId')
        SendCodeToHttp(string.format("GM.House.AddAreaFurniture(%s,%s)",AreaId,FurnitureId))
    end)

    RegisterCommand("宿舍","主角行走","主角行走")
    :RegisterParam("number", "IsRun", "0")
    :RegisterFunc(function (self)
        local Player = UE4.UGameplayStatics.GetActorOfClass(GetGameIns(),UE4.AHousePlayerCharacter)
        if Player then
            Player:SetAnimIsRun(self:GetParam('IsRun'))
        end
    end)

    RegisterCommand("宿舍","播放3d剧情","播放3d剧情")
    :RegisterParam("string", "StoryKey", "0")
    :RegisterFunc(function (self)
        local key = self:GetParam('StoryKey')
        local ui = UI.GetTop()
        local tbUI = {}
        if ui then
            local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
            for i = 1, Widgets:Length() do
                WidgetUtils.Hidden(Widgets:Get(i))
                table.insert(tbUI, Widgets:Get(i))
            end
        end
        CartoonMgr:Play(key, function(CompleteType)
            for _, widget in ipairs(tbUI) do 
                WidgetUtils.Visible(widget)
            end
        end);
        CloseUIGM()
    end)

    RegisterCommand("宿舍","播放少女随机事件","播放少女随机事件")
    :RegisterParam("number", "GirlID", "0")
    :RegisterParam("number", "EventId", "0")
    :RegisterFunc(function (self)
        local GirlID = self:GetParam('GirlID')
        local EventId = self:GetParam('EventId')
        local StoryKey = HouseTalk:GetDailyStoryKey(GirlID, EventId)
        if StoryKey then
            local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
            if Mode then
                local BedRoomMgr = Mode:GetBedRoomMgr()
                local func = function()
                    HouseGirlLove:Play3DStory(StoryKey.key,nil,function ()
                        local ui = UI.GetUI('DormDialogue')
                        if ui then
                            ui:OnOpen()
                        end
                        local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
                        if Mode then
                            local brm = Mode:GetBedRoomMgr()
                            if brm then
                                brm:On3DStoryPlayEnd()
                            end
                        end
                    end)
                end
                if BedRoomMgr then
                    BedRoomMgr:Before3DStoryPlay(StoryKey.areaId,{GetGameIns(),func})
                end
            end
        end
        CloseUIGM()
    end)


    RegisterCommand("宿舍","打开拼图界面","打开拼图界面")
    :RegisterParam("number","MapId","1")
    :RegisterFunc(function (self)
        local MapId = self:GetParam('MapId')
        UI.Open('HousePuzzle',MapId)
    end)
end


-- 其他GM指令注册
local RegisterOtherCommand = function() 
    -- 内存导出
    RegisterCommand("调试","MemReport","MemReport")
    :RegisterFunc(function(self)
        UE4.UKismetSystemLibrary.ExecuteConsoleCommand(GetGameIns(), "MemReport -full")
        CloseUIGM()
        UI.ShowTip("内存导出成功，请在Save目录下查看")
    end)

    --RemoteDebuger
    RegisterCommand('调试', 'RemoteDebug', 'RemoteDebug')
        :RegisterFunc(function (self)
            UE4.UGameLibrary.RequestOpenRemoteDebug()
    end)

    --RemoteDebuger
    RegisterCommand('调试', 'Auto PSO', '自动跑PSO')
        :RegisterFunc(function (self)
            local system = UE4.UGameLibrary.GetAutoPSOSystem(GetOwningPlayer());
            if system then 
                Map.Open(14)
            else 
                UI.ShowTip("执行失败，因为当前打包参数里面没有添加：-logPSO -PSOCache")
            end
            
    end)

    -- AutoStatCapture
    RegisterCommand('调试', 'Auto Stat Capture', 'Auto Stat Capture')
        :RegisterParam('number','Frame','20')
        :RegisterParam('number','AngleCount','4')
        :RegisterFunc(function (self)
            local task = UE4.UGameplayStatics.GetActorOfClass(GetGameIns(), UE4.AGameTaskActor)
            if task then
                task:ClearLevelCountDownTimer()
            end
            UE4.UAutoStatCaptureBP.Start(
            self:GetParam('Frame'),
            self:GetParam('AngleCount'))
            CloseUIGM();
    end)
    
    RegisterCommand('调试', 'Skill Test', 'Skill Test')
        :RegisterParam('number','skillTimesLimit','2')
        :RegisterParam("string","Version","0001")
        :RegisterFunc(function (self)
            if GetOwningPlayer() then
                UE4.USkillTestBP.Start(
                self:GetParam('skillTimesLimit'),
                self:GetParam('Version'))
                CloseUIGM();
            end
    end)

    RegisterCommand('调试','进入测试关卡','测试关')
        :RegisterFunc(function (self)
            if not me or not RunFromEntry then
                UI.ShowTip('请登陆后执行')
                return
            end
            if UE4.UMapManager.GetCurrentID() ~= 10 then
                Formation.SetCurLineupIndex(1)
                local tbteam = Formation.GetCurrentLineup()
                if tbteam then UE4.UUMGLibrary.SetTeamCharacters(tbteam:GetCards()) end
                UE4.UMapManager.Open(10, sOption or '')
            else
                GoToMainLevel()
            end
    end)

    RegisterCommand('调试','测试怪物击杀','测试怪物击杀')
        :RegisterParam('number','MonsterId1','-1')
        :RegisterParam('number','MonsterId2','-1')
        :RegisterParam('number','MonsterId3','-1')
        :RegisterParam('number','MonsLevel','1')
        --:RegisterParam('number','FireInterel','0.25')
        :RegisterFunc(function (self)
            if GMCommand and GMCommand.IsInGMKillTest then
                GMCommand.IsInGMKillTest = nil;
                UE4.Timer.Cancel(GMCommand.GMKillTestFireTimer)
                GMCommand:RemoveEventHandle(Event.CharacterDeath)
                GMCommand.GMKillTestFireTimer = nil

                UI.GC()

                return
            end
            GMCommand.IsInGMKillTest = true

            local SpawnIndex = 0;
            local Player = UE4.UGameplayStatics.GetPlayerController(GetGameIns(),0)
            local Level = self:GetParam('MonsLevel')
            local SpawnParam = UE4.FSpawnNpcParams();
            SpawnParam.Location = Player:K2_GetActorLocation() + Player:GetActorForwardVector() * 500
            SpawnParam.Rotation = Player:K2_GetActorRotation()
            SpawnParam.Level = Level

            local tbMonsId = {}
            for i=1,3 do
                local MonId = self:GetParam('MonsterId'..i);
                if MonId > 0 then
                    table.insert(tbMonsId,MonId)
                end
            end

            local func = function ()
                SpawnIndex = SpawnIndex + 1

                if SpawnIndex > #tbMonsId then
                    SpawnIndex = 1
                end

                SpawnParam.Id = tbMonsId[SpawnIndex]--self:GetParam('MonsterId'..SpawnIndex)
                SpawnParam.AI = UE4.ULevelLibrary.GetCharacterTemplate(SpawnParam.Id).AI

                Player:Server_GM_SpawnNpc(SpawnParam)

                UE4.Timer.Add(0.2,function ()
                    local MonsArray = UE4.TArray(UE4.AGameAICharacter)
                    UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(), UE4.AGameAICharacter,MonsArray)
                    for j = 1,MonsArray:Length() do
                        if IsValid(MonsArray:Get(j)) then
                            MonsArray:Get(j):PauseLogic(1)
                            --MonsArray:Get(j):GetMovementComponent():StopMovementImmediately()
                        end
                    end
                end)
            end
            func()
            local SpawnHandle = GMCommand:AddEventHandle(Event.CharacterDeath,function ( InMonster, killer )
                if IsAI(InMonster) then
                    func()
                end
            end)

            TaskCommon.AddHandle(SpawnHandle)

            if IsValid(Player) then
                local FireFunc;
                FireFunc = function()
                    local MonsArray2 = UE4.TArray(UE4.AGameAICharacter)
                    UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(), UE4.AGameAICharacter,MonsArray2)
                    if MonsArray2:Length() >= 1 and IsValid(MonsArray2:Get(1)) then
                        local MonsCap = MonsArray2:Get(1):GetComponentByClass(UE4.UCapsuleComponent)
                        local MonsOffset = UE4.FVector(0,0,0)
                        if IsValid(MonsCap) then
                            MonsOffset.Z = MonsCap:GetScaledCapsuleHalfHeight() * 0.5
                        end
                        local Pawn = Player:K2_GetPawn()
                        --local MonsMesh = MonsArray2:Get(1):GetComponentByClass(UE4.USkeletalMeshComponent)
                        --local TargetPos = MonsMesh and MonsMesh:GetSocketLocation('Bip001-Pelvis')
                        local PlayerCameraOffset = Pawn.CurrentCameraInfo.CameraSocketOffset
                        --这样算会差一个玩家与摄影机朝向的默认偏移
                        local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(Player:K2_GetActorLocation() + PlayerCameraOffset,MonsArray2:Get(1):K2_GetActorLocation() + MonsOffset)
                        Player:SetControlRotation(Rot)
                        --LookLockTarget算法应该是错的
                        --Player:LookLockTarget(MonsArray2:Get(1),TargetPos,0.1)
                    end

                    Player:UseSkill(0, UE4.ESkillCastType.Press);
                    GMCommand.GMKillTestFireTimer = UE4.Timer.Add(2,FireFunc)
                end
                GMCommand.GMKillTestFireTimer = UE4.Timer.Add(2,FireFunc)
            end
    end)

    RegisterCommand('调试', '强行禁用PSO采集', '强行禁用PSO采集')
        :RegisterFunc(function (self)
            local isDisable = UE4.UUserSetting.GetBool("DisablePSOCache", false)
            if isDisable then 
                UE4.UUserSetting.SetBool("DisablePSOCache", false)
                UE4.UGMLibrary.ShowDialog("PSO采集", "PSO可以正常采集了，但是得下次启动游戏才会生效。");
            else 
                UE4.UPSOUtilities.Shutdown();
                UE4.UUserSetting.SetBool("DisablePSOCache", true)
                UE4.UGMLibrary.ShowDialog("PSO采集", "注意：PSO采集功能已经被强行禁用（下次启动依然被禁用）。");
            end
            UE4.UUserSetting.Save()
    end)    

    RegisterCommand('调试', '禁用日志', '本次游戏运行期间不再产生任何日志')
        :RegisterFunc(function (self)
            UE4.UKismetSystemLibrary.ExecuteConsoleCommand(GetGameIns(), "Log abc only")
            UI.ShowTip("禁用日志成功")
    end)   
    
    RegisterCommand('调试', '禁用声音', '禁用声音')
        :RegisterFunc(function (self)
            local value = not UE4.UWwiseLibrary.IsDisable();
            if value then 
                UE4.UWwiseLibrary.SetDisable(true)
            else 
                UE4.UWwiseLibrary.SetDisable(false)
            end
            UI.ShowTip(value and "声音已被禁用，接下来不会再产生新的声音。" or "声音已恢复")
    end)  

    RegisterCommand('调试', '禁用技能位移', '禁用技能位移')
        :RegisterFunc(function (self)
            local value = UE4.UGameLibrary.ToggleDisableSkillMove();
            UI.ShowTip("技能位移已经 " .. (value and "被禁用" or "开启"))
    end)  

    RegisterCommand('调试', '禁用受击物理动画', '禁用怪物受击物理动画')
        :RegisterFunc(function (self)
            local value = UE4.UGameLibrary.ToggleEnableMonPhysicalAnim();
            UI.ShowTip("怪物受击物理动画已 " .. (value and "开启" or "被禁用"))
    end)  

    RegisterCommand('调试', '禁用死亡物理动画', '禁用怪物死亡物理动画')
        :RegisterFunc(function (self)
            local value = UE4.UGameLibrary.ToggleEnableMonDeadPhysicalAnim();
            UI.ShowTip("怪物死亡物理动画已 " .. (value and "开启" or "被禁用"))
    end)  

    RegisterCommand('调试', '禁用死亡力大小限制', '禁用怪物死亡力大小限制')
    :RegisterFunc(function (self)
        local value = UE4.UGameLibrary.ToggleEnableDeadImpulseLimit();
        UI.ShowTip("怪物死亡力大小限制已 " .. (value and "开启" or "被禁用"))
    end)  

    RegisterCommand('调试', '修改移动迭代次数', '修改移动组件迭代次数')
    :RegisterFunc(function (self)
        local value = UE4.UGameLibrary.ToggleEnableCustomMovementIteration();
        UI.ShowTip("移动组件迭代次数 " .. (value and "开启" or "被禁用"))
    end)  

    
    RegisterCommand('调试', '获取开启物理角色数目', '获取物理组件生效的角色数目')
        :RegisterFunc(function (self)
            local Num = UE4.UGameLibrary.GetEnablePhysicalCharacterNum(GetOwningPlayer());
            UI.ShowTip(string.format("物理组件生效的角色数目 : %d", Num))
    end)  
    
    RegisterCommand('调试', '打开资源预载', '打开资源预加载')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.PreLoadGameAssetEnabled(true)
    end)

    RegisterCommand('调试', '关闭资源预载', '关闭资源预加载')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.PreLoadGameAssetEnabled(false)
    end)

    RegisterCommand('调试', '异步加载预载资源', '异步加载预载资源')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.PreLoadGameAssetMode(true)
    end)

    RegisterCommand('调试', '同步加载预载资源', '同步加载预载资源')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.PreLoadGameAssetMode(false)
    end)

    RegisterCommand('调试', '打开预载资源MemReport', '打开预载资源MemReport')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.EnabledUnLoadMemReport(true)
    end)

    RegisterCommand('调试', '关闭预载资源MemReport', '关闭预载资源MemReport')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.EnabledUnLoadMemReport(false)
    end)

    RegisterCommand('调试', '立刻宕机', '立刻宕机')
    :RegisterFunc(function (self)
        UE4.UGMLibrary.CrashEyeError();
    end)

    RegisterCommand('调试', '禁用粒子内存池', '禁用粒子内存池')
    :RegisterParam("number", "bBan", "1")
    :RegisterFunc(function (self)
        local bBan = self:GetParam('bBan')
        local ParticleManager = UE.UParticleSystemManager.GetPtr()
        if ParticleManager then
            ParticleManager.bForcePoolMethodNone = bBan == 1
        end
    end)

    RegisterCommand('调试', '查看渠道号', '查看渠道号')
    :RegisterFunc(function (self)
        UI.ShowTip("channel-subchannel:" .. (me:Channel()) .. "-" .. me:SubChannel())
    end)

    RegisterCommand('调试', '开启LUAARRAY日志', '开启LUAARRAY日志')
    :RegisterFunc(function (self)
        UE4.UUnLuaSettings.EnablePrintLogCallArrayGet(not UE4.UUnLuaSettings.IsPrintLogCallArrayGet())
        UI.ShowTip(UE4.UUnLuaSettings.IsPrintLogCallArrayGet() and "opened LUAARRAY_GET Log." or "closed LUARARRAY_GET log.")
    end)

    RegisterCommand('调试', '开启LUACallUFunction日志', '开启LUACallUFunction日志')
    :RegisterFunc(function (self)
        UE4.UUnLuaSettings.EnablePrintLogCallUFuntion(not UE4.UUnLuaSettings.IsPrintLogCallUFuntion())
        UI.ShowTip(UE4.UUnLuaSettings.IsPrintLogCallUFuntion() and "opened LUACallUFuntion Log." or "closed LUACallUFuntion log.")
    end)
end


--运营活动指令注册
local RegisterOperationCommand = function ()
    RegisterCommand('运营活动', '设置BP等级', '设置BP当前开到某一级')
        :RegisterParam('string','Target_Level','0')
        :RegisterFunc(function (self)
            local level = self:GetParam('Target_Level')
            SendCodeToHttp(string.format("BattlePassLogic.GMSetLevel(%d)", level))
    end)

    RegisterCommand('运营活动', '开/关付费', '设置BP高档或低档状态(0:普通、1:付费、2:高级付费)')
        :RegisterParam('string','BP_Status','0')
        :RegisterFunc(function (self)
            local status = self:GetParam('BP_Status')
            SendCodeToHttp(string.format("BattlePassLogic.GMSetBPStatus(%d)", status))
    end)

    RegisterCommand('运营活动', '重置当前BP', '重置当前BP')
        :RegisterFunc(function (self)
            SendCodeToHttp(string.format("BattlePassLogic.GMRefresh()"))
    end)

    RegisterCommand('运营活动', '完成BP的指定任务', '指定questID')
        :RegisterParam('string','Quest_ID','0')
        :RegisterFunc(function (self)
            local id = self:GetParam('Quest_ID')
            SendCodeToHttp(string.format("BattlePassLogic.GMFinishQuest(%d)", id))
    end)

    RegisterCommand('运营活动', '增加BP经验', '要增加的经验值（只能为正）')
        :RegisterParam('string','AddExp','0')
        :RegisterFunc(function (self)
            local nAddExp = self:GetParam('AddExp')
            SendCodeToHttp(string.format("GM.BattlePass.AddExp(%d)", nAddExp))
    end)
end

--- 图鉴指令
local RegisterRikiCommand = function()
    RegisterCommand('图鉴', '解锁图鉴', '解锁图鉴')
        :RegisterParam('string','Number','0')
        :RegisterFunc(function (self)
            local id = tonumber(self:GetParam('Number')) or 0;
            SendCodeToHttp(string.format("GM.Riki.GMUnLockRiki(%d)", id))
    end)
end

--- 评分引导指令
local RegisterSurveyCommand = function()
    RegisterCommand('评分引导', '重置时间', '重置时间')
        :RegisterFunc(function (self)
            SurveyLogic.ResetLastTime()
    end)
    RegisterCommand('评分引导', '重置首通/开限制', '重置首通/开限制')
        :RegisterFunc(function (self)
            SurveyLogic.ResetTaskFlag();
    end)
    RegisterCommand('评分引导', '重置评分不成功次数', '重置评分不成功次数')
        :RegisterFunc(function (self)
            SurveyLogic.ResetFailedCount();
    end)
    RegisterCommand('评分引导', '打开评分引导界面', '重打开评分引导界面')
        :RegisterFunc(function (self)
            UI.Open("SurveyGrade", "Chapter")
            SurveyLogic.AddSumCount(1)
    end)
    RegisterCommand('评分引导', '进入后台', '进入后台')
        :RegisterFunc(function (self)
            Survey.GOTO_APPSTORE = true
            EventSystem.Trigger(Event.AppWillDeactivate)
    end)
    RegisterCommand('评分引导', 'APP唤醒', 'APP唤醒')
        :RegisterFunc(function (self)
            EventSystem.Trigger(Event.AppHasReactivated)
    end)
end

---棋盘活动指令注册
local RegisterChessCommand = function() 
    RegisterCommand('棋盘活动', '进入活动', '进入指定期数活动')
        :RegisterParam('string', 'Boss_Level_Time', '1')
        :RegisterFunc(function(self)
            local nActId = tonumber(self:GetParam('Boss_Level_Time')) or 0
            SendCodeToHttp(string.format('ChessLogic.GMEnter(%d)', nActId))
            CloseUIGM()
    end)

    RegisterCommand('棋盘活动', '解锁地图', '解锁当前所有地图')
        :RegisterFunc(function (self)
            ChessLogic.GMOpenAllMap()
            SendCodeToHttp(string.format('ChessLogic.GMOpenAllMap()'))
            CloseUIGM()
    end)

    RegisterCommand('棋盘活动', '清空当前地图存档', '清空当前地图存档')
        :RegisterFunc(function (self)
            ChessData:Debug_ClearCurrentMapSave()
            ChessEditor:RunFromLastRegion()
            CloseUIGM()
    end)

    RegisterCommand('棋盘活动', '清空当前活动存档', '清空当前活动存档')
        :RegisterFunc(function (self)
            SendCodeToHttp(string.format('ChessLogic.ClearData()'))
            CloseUIGM()
    end)

    RegisterCommand('棋盘活动', '进入战斗', '进入战斗关卡')
        :RegisterParam('string', 'chapterID', '0')
        :RegisterFunc(function(self)
            local fightId = tonumber(self:GetParam('chapterID')) or 0
            local actId = ChessLogic.GetOpenID()
            if fightId ~= 0 and actId ~= 0 then
                ChessClient:BeginFight(fightId)
            end
            CloseUIGM()
    end)

    RegisterCommand('棋盘活动', '进入剧情', '进入剧情')
        :RegisterParam('string', 'PlotID', '0')
        :RegisterFunc(function(self)
            local plotId = tonumber(self:GetParam('PlotID')) or 0
            local actId = ChessLogic.GetOpenID()
            local cfg = ChessConfig:GetPlotDefineByModuleName(ChessClient.moduleName).tbId2Data[plotId]
            if cfg and actId ~= 0 then
                local ui = UI.GetUI("ChessMain")
                if ui then ui:SetShowOrHide(false) end
                UE4.UUMGLibrary.PlayPlot(GetGameIns(), cfg.PlotId, {GetGameIns(), function(lication, CompleteType)
                    if ui then
                        UE4.Timer.Add(0.01, function() ui:SetShowOrHide(true) end)
                    end
                end})
            end
            CloseUIGM()
    end)

    RegisterCommand('棋盘活动', '开启/关闭UI的点击判断', '开启/关闭UI的点击判断')
    :RegisterFunc(function(self)
        local ui = UI.GetUI("ChessMain")
        if ui then
            ui:SwitchChessInteractionState()
        end
    end)

    RegisterCommand('棋盘活动', '点击测试切换', '点击测试切换')
    :RegisterFunc(function(self)
        local ui = UI.GetUI("ChessMain")
        if ui then
            ui:ChangeTouchWidget()
        end
    end)
end

local RegisterDefendCommand = function()
    RegisterCommand('死斗活动', '死斗解锁难度', '解锁至指定难度')
        :RegisterParam('string', 'diff', '1')
        :RegisterFunc(function(self)
            local nDiff = self:GetParam('diff')
            SendCodeToHttp(string.format('DefendLogic.GMSetMaxDiff(%d)', tonumber(nDiff)))
    end)

    RegisterCommand('死斗活动', '死斗重置难度选择', '清空当前难度数据')
        :RegisterFunc(function(self)
            SendCodeToHttp('DefendLogic.ClearData()')
    end)

    RegisterCommand('死斗活动', '死斗指定期数', '死斗指定期数')
        :RegisterParam('string', 'Boss_Level_Time', '0')
        :RegisterFunc(function(self)
            local nActId = tonumber(self:GetParam('Boss_Level_Time'))
            DefendLogic.GMOpenActive(nActId)
            SendCodeToHttp(string.format('DefendLogic.GMOpenActive(%d)', nActId))
    end)

    RegisterCommand('死斗活动', '死斗增加时间', '增加死斗关卡时间')
        :RegisterParam('string', 'AddLevelTime', '100')
        :RegisterFunc(function(self)
            DefendLogic.GMAddLevelTime(tonumber(self:GetParam('AddLevelTime')))
    end)

    RegisterCommand('死斗活动', '死斗修改怪物波次', '死斗修改怪物波次')
        :RegisterParam('number', 'MonsterWave', '2')
        :RegisterFunc(function(self)
            local Wave = self:GetParam('MonsterWave')
            DefendLogic.GMSetWave(Wave)
    end)

    RegisterCommand('死斗活动', '死斗修改金钱', '死斗修改金钱')
        :RegisterParam('number', 'Money', '1000')
        :RegisterFunc(function(self)
            local Money = self:GetParam('Money')
            local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
            if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
                TaskActor.TaskDataComponent:SetValue('Money',Money)
            end
    end)

    RegisterCommand('死斗活动', '死斗重置炸药桶', '死斗重置炸药桶')
        :RegisterParam('string', 'Tag', 'Bomb')
        :RegisterFunc(function(self)
            local Tag = self:GetParam('Tag')
            local DeviceArray = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(GetGameIns(),UE4.AItemSpawner_CanSave,Tag)
            for i = 1, DeviceArray:Length() do
                local Device = DeviceArray:Get(i)
                if IsValid(Device) then
                    Device:CheckNeedDestroy();
                end
            end
            for i = 1, DeviceArray:Length() do
                local Device = DeviceArray:Get(i)
                if IsValid(Device) then
                    Device:ReSpawn(true);
                end
            end
    end)
end

local RegisterDlc1Command = function()
    RegisterCommand('DLC1活动', '解锁所有关卡', '解锁所有关卡')
        :RegisterFunc(function(self)
            local nFlag = DLC_Chapter.GetChapterID() or 1
            SendCodeToHttp(string.format('GM.Dlc1.GMUnLockLevel(%d)', tonumber(nFlag)))
    end)

    RegisterCommand('DLC1活动', '3星完成', '3星完成')
        :RegisterFunc(function(self)
            SendCodeToHttp('GM.Dlc1.GMAddStars(1)')
    end)

    RegisterCommand('DLC1活动', '肉鸽强制跳转', '强制跳转到后续节点')
        :RegisterParam('number', 'NodeID', '0')
        :RegisterFunc(function(self)
            local nTargetNodeID = self:GetParam('NodeID')
            SendCodeToHttp(string.format('GM.Dlc1.GMForceMoveTo(%d)', nTargetNodeID))
        end)

    RegisterCommand('DLC1活动', '肉鸽强制移动', '强制移动到后继第i节点')
        :RegisterParam('number', 'index', '1')
        :RegisterFunc(function(self)
            local nIndex = self:GetParam('index')
            SendCodeToHttp(string.format('GM.Dlc1.GMForceToNextNode(%d)', nIndex))
        end)

    RegisterCommand('DLC1活动', '肉鸽代币变化', '正数增加负数减少')
        :RegisterParam('number', 'ChangeNum', '1')
        :RegisterFunc(function(self)
            local nChangeNum = self:GetParam('ChangeNum')
            SendCodeToHttp(string.format('GM.Dlc1.GMChangeRogueCoin(%d)', nChangeNum))
        end)

    RegisterCommand('DLC1活动', '添加支援角色', 'Del填1为删除，不填为添加')
    :RegisterParam('number', 'TrialID', '1')
    :RegisterParam('number', 'Del', '0')
        :RegisterFunc(function(self)
            local nTrialID = self:GetParam('TrialID')
            local nDel = self:GetParam('Del')
            SendCodeToHttp(string.format('GM.Dlc1.GMAddTrial(%d,%d)', nTrialID,nDel))
        end)    

    RegisterCommand('DLC1活动', '行动次数变化', '正数增加负数减少')
    :RegisterParam('number', 'ChangeNum', '1')
        :RegisterFunc(function(self)
            local nChangeNum = self:GetParam('ChangeNum')
            SendCodeToHttp(string.format('GM.Dlc1.GMChangeActTimes(%d)', nChangeNum))
        end)  

    RegisterCommand('DLC1活动', '完成指定任务', '指定questID')
        :RegisterParam('string','Quest_ID','0')
        :RegisterFunc(function (self)
            local id = self:GetParam('Quest_ID')
            SendCodeToHttp(string.format("GM.Dlc1.GMFinishQuest(%d)", id))
    end)    
    RegisterCommand('DLC1活动', '购买指定商品', '指定商品ID')
        :RegisterParam('string','Goods_ID','0')
        :RegisterFunc(function (self)
            local id = self:GetParam('Goods_ID')
            SendCodeToHttp(string.format("GM.Dlc1.GMBuyGoods(%d)", id))
    end)   
    RegisterCommand('DLC1活动', '获得指定buff', 'buff.txt')
        :RegisterParam('string','Buff_ID','0')
        :RegisterFunc(function (self)
            local id = self:GetParam('Buff_ID')
            SendCodeToHttp(string.format("GM.Dlc1.GMGetBuff(%d)", id))
    end)   
end


local RegisterDlc2Command = function()
    RegisterCommand('DLC2活动', '清空暗区数据', '清空暗区数据')
        :RegisterFunc(function(self)
            SendCodeToHttp('GM.Dlc2.GMClearDarkZone()')
    end)

    RegisterCommand('DLC2活动', '进入指定暗区关卡', '指定关卡ID')
        :RegisterParam('number', 'LevelID', '11')
        :RegisterFunc(function(self)
            local levelId = self:GetParam('LevelID')
            local levelConf = DarkZone.GetLevelConf(levelId)
            if not levelConf then
                UI.ShowTip('没有关卡配置！')
            else
                Launch.SetType(LaunchType.DARKZONE)
                local tbteam = Formation.GetCurrentLineup()
                if tbteam then UE4.UUMGLibrary.SetTeamCharacters(tbteam:GetCards()) end
                Map.Open(levelConf.nMapID)
            end
    end)
end

local RegisterLevelCommand = function ( ... )
    RegisterCommand('关卡', '根据Id进入指定关卡', '根据LevelId')
    :RegisterParam('number','LevelId','-1')
    :RegisterFunc(function (self)
        local LevelId = self:GetParam('LevelId')
        local MapId = -1;
        if ChapterLevel.Get(LevelId,true) then
            MapId = ChapterLevel.Get(LevelId).nMapID
        end
        if DailyLevel.Get(LevelId) then
            MapId = DailyLevel.Get(LevelId).nMapID
        end
        if DLCLevel.Get(LevelId) then
            MapId = DLCLevel.Get(LevelId).nMapID
        end
        if OnlineLevel.GetConfig(LevelId) then
            MapId = OnlineLevel.GetConfig(LevelId).nMapID
        end
        if RogueLevel.Get(LevelId) then
            MapId = RogueLevel.Get(LevelId).nMapID
        end
        if RoleLevel.Get(LevelId) then
            MapId = RoleLevel.Get(LevelId).nMapID
        end
        if TowerLevel.Get(LevelId) then
            MapId = TowerLevel.Get(LevelId).nMapID
        end

        if DefendLogic.GetLevel(LevelId) then
            MapId = DefendLogic.GetLevel(LevelId).nMapID
        end

        if TowerEventLevel.Get(LevelId) then
            MapId = TowerEventLevel.Get(LevelId).nMapID
        end

        for BossId,BossInfo in pairs(BossLogic.tbBossLevelCfg) do
            if BossInfo.nLevelID == LevelId then
                MapId = BossLogic.GetMapID(BossId)
            end
        end

        if GachaTry.GetLevelConf(LevelId) then
            MapId = GachaTry.GetLevelConf(LevelId).nMapID
        end

        if MapId < 0 then
            MapId = LevelId;
        end

        if MapId >= 0 then
            Formation.SetCurLineupIndex(1)
            local tbteam = Formation.GetCurrentLineup()
            if tbteam then UE4.UUMGLibrary.SetTeamCharacters(tbteam:GetCards()) end
            UE4.UMapManager.Open(MapId, sOption or '')
        end
    end)

    RegisterCommand('关卡', '清空碎片化叙事', '清空碎片化叙事')
        :RegisterFunc(function(self)
            FragmentStory.ClearAllTaskValue()
            CloseUIGM()
    end)
end

-----------------------------------    具体指令注册   ------------------------------------
do
    ----------------------------------- 功能相关指令 -----------------------------------
    GMCommand:SetType("Func")
    do 
        -- 常用指令注册
        RegisterCommonCommand();

        -- 新手指引相关
        RegisterGuideCommand();

        -- 客户端指令
        RegisterClientCommand()

        -- 服务器指令
        RegisterServerCommand()

         -- 其他指令注册
        RegisterOtherCommand()

        RegisterLocalizeCommand()
    end
   
    ----------------------------------- 系统相关指令 -----------------------------------
    GMCommand:SetType("System")
    do 
        -- 蛋池指令注册
        RegisterGachaCommand()

        -- 宿舍指令注册
        RegisterHouseCommand()

        -- 图鉴 
        RegisterRikiCommand()
        
        --评分引导
        RegisterSurveyCommand()
    end

    ----------------------------------- 活动相关指令 -----------------------------------
    GMCommand:SetType("Activity")
    do 
        -- 活动指令注册
        RegisterActivityCommand()

        --运营活动指令注册
        RegisterOperationCommand()

        --棋盘指令注册
        RegisterChessCommand()

        --死斗指令注册
        RegisterDefendCommand()

        --DLC1活动
        RegisterDlc1Command()
    end

    ----------------------------------- 战斗相关指令 -----------------------------------
    GMCommand:SetType("Fight")
    do 
        -- 战斗流程
        RegisterFightFlowCommand();
        
        -- 战斗指令注册
        RegisterFightCommand();
        RegisterFight2Command();

        -- 战斗call npc 
        RegisterFightCallCommand();

        -- 联机指令注册
        RegisterOnlineCommand()

        -- 开放世界GM指令注册
        RegisterOpenWorldCommand();

        -- 星级条件相关指令注册
        RegisterStarTaskCommand();

        -- 动态修改设置参数
        RegisterSettingCommand();
    end

    -- --example
    -- RegisterCommand('Fight','KillAll','gm.KillAll')
    --     :RegisterParam('number','level','0')
    --     :RegisterFunc(function (self)
    --         local level = self:GetParam('level')--根据名字和注册时该参数的类型，返回该参数当前值
    --         print('Fight.KillAll',level)--执行函数
    --     end)

    -- RegisterCommand('Mission','SkipGuide','gm.SkipGuide')
    --     :RegisterFunc(function (self)
        
    -- end)

    ---------------------------------- 关卡相关指令 -----------------------------------------

    GMCommand:SetType("Level")
    do
        RegisterLevelCommand();
    end

    ----------------------------------------------------------------------------------------

end
--------------------------------------------------------------
