-- ========================================================
-- @File    : Guide.lua
-- @Brief   : 新手指引逻辑
-- @Author  :
-- @Date    :
-- ========================================================

GuideLogic = GuideLogic or {}

---键盘按键操作指引类型
GuideLogic.EPCKeyboardType = {
    Fire            = 0,    --开火
    Aim             = 1,    --瞄准
    Skill_1         = 2,    --技能1
    SupperSkill     = 3,    --大招
    Dodge           = 4,    --闪避
    Rush            = 5,    --疾跑
    Reload          = 6,    --换弹
    SwitchPre       = 7,    --换人(E)
    SwitchNext      = 8,    --换人(Q)
    Switch1         = 9,    --换人(第一个)
    Switch2         = 10,   --换人(第二个)
    Switch3         = 11,   --换人(第三个)
    Move            = 12,   --移动
    Rot             = 13,   --旋转
    OpenBox         = 14,   --操作
    MapWay          = 15,   --地图路线
    ExhaleMouse     = 16,   --呼出鼠标
    PauseGame       = 17,   --暂停游戏
    BackSkill1      = 18,   --后台技能(第一个)
    BackSkill2      = 19,   --后台技能(第二个)
    BackSkill3      = 20,   --后台技能(第三个)
    BackSuperSkill1 = 21,   --后台大招技能(第一个)
    BackSuperSkill2 = 22,   --后台大招技能(第二个)
    BackSuperSkill3 = 23,   --后台大招技能(第三个)
    Jump            = 24,   --跳跃
};
GuideLogic.tbControlButton = {}

GuideLogic.GroupId = 4
---战斗教学指引id最大值
GuideLogic.MaxTeachId = 100
---序章教学关卡ID
GuideLogic.PrologueMapID = 10100
---加载配置文件
function GuideLogic.LoadConf()
    GuideLogic.nGuideId = 0             --- 当前指引id
    GuideLogic.nStepId = 0              --- 当前指引步骤
    GuideLogic.tbConfig = {}            --- 指引配置
    GuideLogic.tbLevelList = {}         --- 序章指引列表
    GuideLogic.tbForceList = {}         --- 强制指引列表
    GuideLogic.tbNonForceList = {}      --- 非强制指引列表
    GuideLogic.tbWidgetIsGuide = {}     --- 所有需要检测指引的界面
    GuideLogic.tbMapID = {}             --- 所有通过NotifyUI触发指引的地图ID和指引ID
    local nLastGuide = 0
    local isEligible = false

    local tbFile = LoadCsv('guide/guide.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nGroup    = tonumber(tbLine.Group) or 0
        local nID       = tonumber(tbLine.ID)
        local nStepId   = tonumber(tbLine.StepId) or 0
        if nID then
            isEligible = GuideLogic.CheckGroup(nGroup)
        end
        if (nID or nStepId > 0) and isEligible then
            if nID then
                local tmp = {}
                tmp.nID         = nID                           -- 任务变量ID
                tmp.sType       = tbLine.Type or ""             -- 指引类型
                tmp.nGroup      = nGroup                        -- 移动端还是PC端指引
                tmp.nMapID      = tonumber(tbLine.MapID)        -- 地图ID(关卡内通过NotifyUI触发的指引才配)
                if tmp.nMapID then
                    GuideLogic.tbMapID[tmp.nMapID] = GuideLogic.tbMapID[tmp.nMapID] or {}
                    table.insert(GuideLogic.tbMapID[tmp.nMapID], nID)
                end
                tmp.bSkip       = tonumber(tbLine.Skip or 0) > 0-- 是否可以跳过
                tmp.bRepeat     = tonumber(tbLine.Repeat or 0) > 0-- 是否重复触发
                tmp.tbSkipID    = Eval(tbLine.SkipID)           -- 跳过的话顺带完成的指引ID
                tmp.PreGuide    = tonumber(tbLine.PreGuide)     -- 前置指引
                tmp.nLevelId    = tonumber(tbLine.Level)        -- 指引完成条件
                tmp.tbCheckEx   = GuideLogic.GetCheckExList(tbLine.CheckEx)   -- 检测是否能开启指引 可以是多个条件，以;区分
                tmp.tbCheckCompleteEx   = GuideLogic.GetCheckExList(tbLine.CheckCompleteEx)   -- 检测是否能直接完成指引 可以是多个条件，以;区分
                tmp.nRestart    = tonumber(tbLine.Restart)      -- 重复开启
                tmp.sRefresh    = tbLine.Refresh                -- 完成后检查是否触发新的指引
                tmp.tbStep      = {}
                nLastGuide = nID
                GuideLogic.tbConfig[nID] = tmp
                if nID <= GuideLogic.MaxTeachId then
                    table.insert(GuideLogic.tbLevelList, nID)
                else
                    if tmp.sType == "Force" then
                        table.insert(GuideLogic.tbForceList, nID)
                    elseif tmp.sType == "NonForce" then
                        table.insert(GuideLogic.tbNonForceList, nID)
                    end
                end
            else
                local step = {}
                step.nID = nLastGuide
                step.nStepId = nStepId
                step.PCKey   = tbLine.PCKey                                 -- PC端指引按键
                step.sWindow = string.lower(tbLine.Window or "")            -- 指引窗口名
                GuideLogic.tbWidgetIsGuide[step.sWindow] = true
                step.nTime   = tonumber(tbLine.Time) or 0.6                 -- 指引出现时间
                step.Path = Split(tbLine.Path or "", "/")                   -- 目标按钮路径
                step.nReleaseInput = tonumber(tbLine.ReleaseInput)          -- 目标按钮路径
                step.WidgetPath = Split(tbLine.WidgetPath or "", "/")       -- 控件路径
                step.bNoFunction = (tonumber(tbLine.NoFunction) or 0) > 0   -- 是否为不响应类型指引
                step.Panel3DPath = Split(tbLine.Panel3DPath or "", "/")     -- 3DPane路径
                step.sTargetActor = tbLine.TargetActor                      -- 目标Actor名
                step.TargetSize = Eval(tbLine.TargetSize)                   -- 目标区域大小
                step.ShadowSize = tonumber(tbLine.ShadowSize) or 370        -- 阴影显示大小
                step.Tips = tbLine.Tips                                     -- 文本控件文字
                step.KeyBoard = Eval(tbLine.KeyBoard)                       -- 键盘按键文字
                step.HandleTips = tbLine.HandleTips                         -- 文本控件文字-手柄
                step.HandleKeyBoard = Eval(tbLine.HandleKeyBoard)           -- 键盘按键文字-手柄
                step.TxtPos = Eval(tbLine.TxtPos) or {}                     -- 文本控件位置
                step.TxtIcon = tbLine.TxtIcon                               -- 文本控件Icon
                step.TxtTitle = tbLine.TxtTitle                             -- 文本控件标题
                step.nTxtDelay = tonumber(tbLine.TxtDelay)                  -- 文字提示消失延迟（秒）
                step.nShowMask = tonumber(tbLine.ShowMask) or 0             -- 是否显示黑色遮罩
                step.nPressContinue = tonumber(tbLine.PressContinue) or 0   -- 是否按下任意位置完成
                step.nAutoComplete = tonumber(tbLine.AutoComplete)          -- 倒计时自动结束步骤
                step.tbCheck    = Split(string.sub(tbLine.Check or '', 2, -2), ",")            -- 指引检测（当指引中断时，再次进行指引会使用到）
                step.tbCheckEx  = Eval(tbLine.CheckEx or "")                -- 指引检测扩展（当指引中断时，再次进行指引会使用到）
                step.tbShowList = Split(tbLine.ShowList or "", ",")         -- 显示的控件列表
                step.tbHideList = Split(tbLine.HideList or "", ",")         -- 隐藏的控件列表
                step.OnWindowOpen  = GuideLogic.GetCheckExList(tbLine.OnWindowOpen)     -- 指引功能扩展，目标界面打开时调用一次
                step.StepBegin  = GuideLogic.GetCheckExList(tbLine.StepBegin)           -- 指引功能扩展，开始当前步骤时调用一次
                step.StepEnd    = GuideLogic.GetCheckExList(tbLine.StepEnd)             -- 指引功能扩展，结束当前步骤时调用一次
                step.sCompleteMode = tbLine.CompleteMode                    -- 步骤结束模式(Click,Down...)
                step.sTextureUI = tbLine.TextureUI                          -- 图片指引UI
                step.sTexturePath = tonumber(tbLine.TexturePath)            -- 图片路径
                step.nDelay = tonumber(tbLine.Delay)                        -- 步骤结束延迟进入下一步
                GuideLogic.tbConfig[nLastGuide].tbStep[nStepId] = step
            end
        end
    end
    GuideLogic.SetCanBeginGuide(true)
    print('guide/guide.txt')
end

--- 暂停或继续指引
function GuideLogic.SetGuidePaused(bPaused)
    local ui = UI.GetUI("guide")
    if not ui then return end

    if bPaused then
        ui:SetGuidePaused(true)
    else
        ui:SetGuidePaused(false)
    end
end

--- 移动端或者PC端
function GuideLogic.CheckGroup(nGroup)
    if nGroup == 0 then
        return true
    end
    if nGroup == 1 then
        return IsMobile()
    end
    if nGroup == 2 then
        return not IsMobile()
    end
end

--- UI打开事件
function GuideLogic.UIOpenCall(widget)
    if widget.sName == "fight" then
        return GuideLogic.RecoveryGuide()
    end
    if GuideLogic.tbWidgetIsGuide[widget.sName] then
        GuideLogic.CheckGuide(widget.sName)
    end
end

--- 打开其他界面时暂停指引 只在序章使用
function GuideLogic.PauseGuide(widgetName)
    if Map.GetCurrentID() ~= GuideLogic.PrologueMapID then
        return
    end
    if not GuideLogic.IsGuiding() or not GuideLogic.IsTeach(GuideLogic.nGuideId) then
        return
    end

    local step = GuideLogic.tbConfig[GuideLogic.nGuideId].tbStep[GuideLogic.nStepId]
    if step.sWindow == widgetName then
        return
    end
    GuideLogic.RecordNowStep = step
    GuideLogic.EndGuide()
    return true
end
--- 关闭其他界面时恢复指引 只在序章使用
function GuideLogic.RecoveryGuide()
    if Map.GetCurrentID() ~= GuideLogic.PrologueMapID then
        return
    end
    if GuideLogic.IsGuiding() or not GuideLogic.RecordNowStep then
        return
    end

    local GuideUI = UI.GetUI("Guide")
    if GuideUI and GuideUI:IsOpen() then
        GuideUI:BeginGuide(GuideLogic.RecordNowStep.nID, GuideLogic.RecordNowStep.nStepId)
    else
        UI.Open("Guide", {GuideLogic.RecordNowStep.nID, GuideLogic.RecordNowStep.nStepId})
    end
    GuideLogic.RecordNowStep = nil
end

--- 指引触发条件  可以是多个条件，以;区分
function GuideLogic.GetCheckExList(CheckExStr)
    local tbCheckEx = {}
    local tbFunc = Split(CheckExStr or "", ";");
    if tbFunc then
        for _, value in pairs(tbFunc) do
            table.insert(tbCheckEx, Eval(value or ""));
        end
    end
    return tbCheckEx
end

--- 得到指引配置信息
function GuideLogic.GetConfig(nID)
    if not nID then return nil end
    return GuideLogic.tbConfig[nID]
end

--- private: 得到指引进度
local function GetTask(nGuideId)
    return me:GetAttribute(GuideLogic.GroupId, nGuideId)
end

--- private: 设置指引进度
local function SetTask(nGuideId, nStepId)
    if (GetTask(nGuideId) < nStepId) then
        me:SetAttribute(GuideLogic.GroupId, nGuideId, nStepId)
    end
end

--- 得到指引进度
function GuideLogic.GetTask(nGuideId)
    return GetTask(nGuideId)
end

--- 更新当前所处指引步骤
function GuideLogic.UpdateStep(nGuideId, nStepId)
    if GuideLogic.nGuideId == nGuideId and GuideLogic.nStepId == nStepId then
        return
    end
    GuideLogic.nGuideId = nGuideId
    GuideLogic.nStepId = nStepId
    if nStepId > GetTask(nGuideId) then
        SetTask(nGuideId, nStepId)
    end
end

--- 关卡蓝图通知完成一个步骤
function GuideLogic.CompleteStep(guideId, stepId)
    if GuideLogic.nGuideId == guideId and GuideLogic.nStepId == stepId then
        local GuideUI = UI.GetUI("Guide")
        if GuideUI and GuideUI:IsOpen() then
            GuideUI:GotoNextStep()
        end
    end
end

--- 得到是否可以开始指引
function GuideLogic.GetCanBeginGuide()
    return GuideLogic.isCanBeginGuide
end

--- 设置是否可以开始指引
function GuideLogic.SetCanBeginGuide(bCan)
    GuideLogic.isCanBeginGuide = bCan
    if bCan then
        if not GuideLogic.EventUIOpenId then
            GuideLogic.EventUIOpenId = EventSystem.On(Event.UIOpen, function(widget)
                GuideLogic.UIOpenCall(widget)
            end)
        end
    else
        GuideLogic.EndGuide()
        if GuideLogic.EventUIOpenId then
            EventSystem.Remove(GuideLogic.EventUIOpenId)
            GuideLogic.EventUIOpenId = nil
        end
    end
end

--- 特定时刻执行扩展
function GuideLogic.ExecuteExtension(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    for _, v in ipairs(tbParam) do
        if type(v) == "table" then
            GuideLogic.CheckFunction(v[1], v[2])
        end
    end
end

--- 界面关闭时检查是否关闭指引
function GuideLogic.CheckCloseGuide(widgetName)
    if GuideLogic.IsGuiding() then
        local step = GuideLogic.tbConfig[GuideLogic.nGuideId].tbStep[GuideLogic.nStepId]
        if step and step.sWindow == widgetName then
            if step.Path and (step.Path[#step.Path] == "ReturnMainBtn" or step.Path[#step.Path] == "BackBtn") then
                return
            end
            GuideLogic.EndGuide()
        end
    end
end

--- 界面打开时检查是否开始新手指引
function GuideLogic.CheckGuide(widgetName)
    if not widgetName then return end
    if widgetName == "main" and Activity.IsHaveOpen() then
        return
    end

    if GuideLogic.IsGuiding() then
        if widgetName == "pausenew" and GuideLogic.PauseGuide(widgetName) then
            return
        end
        local step = GuideLogic.tbConfig[GuideLogic.nGuideId].tbStep[GuideLogic.nStepId]
        local uiguide = UI.GetUI("guide")
        if step and uiguide and uiguide:IsOpen() then
            if uiguide.IsInStep then
                return
            end
            if step.sWindow == widgetName then
                uiguide:DoBeginStep()
                return
            end
        end
        GuideLogic.EndGuide()
    end

    local nGuidID, nStepID = GuideLogic.GetActiveGuide(widgetName)
    if nGuidID then
        GuideLogic.BeginGuide(nGuidID, nStepID)
    end
end

---是否跳过刷新fight界面的按钮显示
function GuideLogic.SkipUpdate()
    local MapID = Map.GetCurrentID()
    if MapID == GuideLogic.PrologueMapID and GuideLogic.nNowStep and GuideLogic.nNowStep <= 5 then
        return true
    end
    if MapID == 10102 and not GuideLogic.IsGuideComplete(10031) and GuideLogic.CanOpenGuide(10031) then
        return true
    end
    return false
end

-- 隐藏战斗界面切换角色按钮或者部分技能按钮
function GuideLogic.HiddenSomeBtn(uifight)
    ---指引期间控制的按钮显示和隐藏
    GuideLogic.tbControlButton = {}
    local MapID = Map.GetCurrentID()
    if MapID == GuideLogic.PrologueMapID then
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.Dodge)
            controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.Rush)
        end
    elseif MapID == 10106 and GuideLogic.CanOpenGuide(10101) then
        --1-6引导大招
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SupperSkill)
        end
        WidgetUtils.Collapsed(uifight.SkillPanel.Skill3)
        GuideLogic.tbControlButton[uifight.SkillPanel.Skill3] = true
    elseif MapID == 10102 then
        local iscan10031 = GuideLogic.CanOpenGuide(10031)
        local iscan10041 = GuideLogic.CanOpenGuide(10041)
        if iscan10031 or iscan10041 then
            --如果是1-2芬妮E技能指引
            local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
            if controller then
                if iscan10031 then
                    controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.Skill_1)
                    controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.Fire)
                    controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.Dodge)
                    controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.Rush)
                end
                if iscan10041 then
                    controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SupperSkill)
                end
            end
            if iscan10031 then
                WidgetUtils.Collapsed(uifight.SkillPanel.Skill1)
                WidgetUtils.Collapsed(uifight.Center)
                GuideLogic.tbControlButton[uifight.SkillPanel.Skill1] = true
                GuideLogic.tbControlButton[uifight.Center] = true

                if uifight.SkillPanel.Fire then
                    WidgetUtils.Collapsed(uifight.SkillPanel.Fire)
                    GuideLogic.tbControlButton[uifight.SkillPanel.Fire] = true
                end
                if uifight.SkillPanel.AimFire then
                    WidgetUtils.Collapsed(uifight.SkillPanel.AimFire)
                    GuideLogic.tbControlButton[uifight.SkillPanel.AimFire] = true
                end
                UE4.Timer.Add(0.01, function()
                    if uifight.SkillPanel.Skill5 then
                        WidgetUtils.Collapsed(uifight.SkillPanel.Skill5)
                        GuideLogic.tbControlButton[uifight.SkillPanel.Skill5] = true
                    end
                end)
            end
            if iscan10041 then
                WidgetUtils.Collapsed(uifight.SkillPanel.Skill3)
                GuideLogic.tbControlButton[uifight.SkillPanel.Skill3] = true
            end
        end
    elseif MapID == 10103 and GuideLogic.CanOpenGuide(10061) then
        --如果是1-3芬妮后勤技
        if not IsMobile() then
            local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
            if controller then
                controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SwitchPre)
                controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SwitchNext)
                controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.BackSkill2)
            end
        end
        WidgetUtils.Collapsed(uifight.PlayerSelect)
        GuideLogic.tbControlButton[uifight.PlayerSelect] = true
    elseif MapID == 10104 and GuideLogic.CanOpenGuide(10081) then
        --如果是1-4星期三后勤技
        if not IsMobile() then
            local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
            if controller then
                controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SwitchPre)
                controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SwitchNext)
                controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.BackSkill2)
            end
        end
        WidgetUtils.Collapsed(uifight.PlayerSelect)
        GuideLogic.tbControlButton[uifight.PlayerSelect] = true
        -- elseif MapID == 10104 then
    --     --如果是QTE指引
    --     if GuideLogic.CanOpenGuide(105) then
    --         --PC端屏蔽换人和技能按键
    --         if not IsMobile() then
    --             local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    --             if controller then
    --                 controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SwitchNext)
    --                 controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType.SwitchPre)
    --             end
    --         end
    --         --隐藏界面按钮
    --         WidgetUtils.Collapsed(uifight.SkillPanel.Skill4)
    --         WidgetUtils.Collapsed(uifight.SkillPanel.Skill1)
    --         WidgetUtils.Collapsed(uifight.SkillPanel.Skill3)
    --         WidgetUtils.Collapsed(uifight.SkillPanel.Skill5)
    --         WidgetUtils.Collapsed(uifight.SkillPanel.Aim)
    --         --关闭自动开火
    --         GuideLogic.CheckFunction("SelectJoystic", {1})
    --         WidgetUtils.Collapsed(uifight.PlayerSelect)
    --     end
    end
end

--- 开始指引
function GuideLogic.BeginGuide(nGuideId, nStepId)
    if not GuideLogic.GetCanBeginGuide() then
        return GuideLogic.EndGuide()
    end

    nStepId = GuideLogic.GetNextStep(nGuideId, nStepId or 1 )
    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if not tbConfig or nStepId > #tbConfig.tbStep then
        GuideLogic.SetGuideComplete(nGuideId)
        return GuideLogic.EndGuide()
    end

    GuideLogic.nGuideId = nGuideId
    GuideLogic.nStepId = nStepId

    local GuideUI = UI.GetUI("Guide")
    if GuideUI and GuideUI:IsOpen() then
        GuideUI:BeginGuide(nGuideId, nStepId)
    else
        UI.Open("Guide", {nGuideId, nStepId})
    end
end

--- 检查是否需要添加关卡通知指引事件
function GuideLogic.AddNotifyEvent(isAdd)
    local isAddEvent = isAdd or false
    local levelId = Map.GetCurrentID()
    if levelId == GuideLogic.PrologueMapID then --- 操作教学指引关卡
        isAddEvent = true
    else
        local tbguideid = GuideLogic.tbMapID[levelId]
        if tbguideid and #tbguideid > 0 then
            isAddEvent = true
        end
    end

    GuideLogic.RemoveNotifyEvent()
    if isAddEvent then
        GuideLogic.GuideEventId = EventSystem.On(Event.OnLevelUINotify, function(id, stepId)
            print('OnLevelUINotify', id)
            if id == 0 then
                ---即将进入boss位置
                local uifight= UI.GetUI("fight")
                if uifight and uifight:IsOpen() then
                    WidgetUtils.Visible(uifight.SkillPanel.Fire)
                    WidgetUtils.Visible(uifight.SkillPanel.Skill1)
                    WidgetUtils.Visible(uifight.SkillPanel.Skill4)
                    WidgetUtils.Visible(uifight.SkillPanel.Skill5)
                    WidgetUtils.Visible(uifight.SkillPanel.Aim)
                    WidgetUtils.Visible(uifight.SkillPanel.AimFire)
                    WidgetUtils.Visible(uifight.SkillPanel.Reload)
                end
                GuideLogic.bCanSetUp = true
                local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
                if controller then
                    controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Dodge)
                    controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Rush)
                end
            else
                if stepId and stepId > 0 then
                    GuideLogic.CompleteStep(id, stepId)
                else
                    if id == 1 then
                        --序章入场动画是否结束
                        GuideLogic.bPrologueAnimationEnd = true
                    end
                    GuideLogic.BeginLevelNotifyGuide(id)
                end
            end
        end)
    end
end

--是否正在指引level界面的返回按钮
function GuideLogic.IsLevelReturn()
    if not GuideLogic.IsGuiding() then
        return false
    end
    local step = GuideLogic.tbConfig[GuideLogic.nGuideId].tbStep[GuideLogic.nStepId]
    if step.sWindow == "level" and step.Path[1] == "Title" then
        return true
    end
    return false
end

--- 检查是否需要删除关卡通知指引事件
function GuideLogic.RemoveNotifyEvent()
    if GuideLogic.GuideEventId then
        EventSystem.Remove(GuideLogic.GuideEventId)
        GuideLogic.GuideEventId = nil
    end
end

--- 开始关卡通知开始的指引
function GuideLogic.BeginLevelNotifyGuide(nGuideId)
    local cfg = GuideLogic.GetConfig(nGuideId)
    if not cfg then return end

    if not GuideLogic.IsTeach(nGuideId) then
        if not GuideLogic.CanOpenGuide(nGuideId) then
            return
        end
    end

    --打开设置功能
    if Map.GetCurrentID() == GuideLogic.PrologueMapID and nGuideId==12 then
        ---序章暂停指引之前 隐藏设置按钮
        GuideLogic.bCanSetUp = true
    end


    if GuideLogic.IsGuiding() then
        local nowcfg = GuideLogic.GetConfig(GuideLogic.nGuideId)
        if nowcfg then
            GuideLogic.WriteGuideLog(string.format("%d|%d|%s|1", GuideLogic.nGuideId, GuideLogic.nStepId, nowcfg.sType))
        end
        GuideLogic.EndGuide(true)
    end

    GuideLogic.nGuideId = nGuideId
    GuideLogic.nStepId = 1

    if UI.IsOpen("DialogueRecord") then
        return GuideLogic.PauseGuide("DialogueRecord")
    end

    local GuideUI = UI.GetUI("Guide")
    if GuideUI and GuideUI:IsOpen() then
        GuideUI:BeginGuide(nGuideId, GuideLogic.nStepId)
    else
        UI.Open("Guide", {nGuideId, GuideLogic.nStepId})
    end
end

--- 得到指定界面激活的指引ID
function GuideLogic.GetActiveGuide(widgetName)
    GuideLogic.RefreshGuideStatus()
    if GuideLogic.IsGuiding() then
        local step = GuideLogic.tbConfig[GuideLogic.nGuideId].tbStep[GuideLogic.nStepId]
        if not step or step.sWindow ~= widgetName then
            return
        end
        return GuideLogic.nGuideId, GuideLogic.nStepId
    else
        for _, nId in ipairs(GuideLogic.tbForceList) do
            local tbConfig = GuideLogic.GetConfig(nId)
            -- 如果指引能被触发，且当前窗口为指引第一步目标窗口
            if tbConfig.tbStep[1].sWindow == widgetName and GuideLogic.CanOpenGuide(nId) then
                return nId
            end
        end
    end

    --- 如果Force类型的指引不能触发, 检查NonForce类型
    for _, nId in ipairs(GuideLogic.tbNonForceList) do
        local tbConfig = GuideLogic.GetConfig(nId)
        if tbConfig.tbStep[1].sWindow == widgetName and GuideLogic.CanOpenGuide(nId) then
            return nId
        end
    end
end

--- 得到指引是否能开启
function GuideLogic.CanOpenGuide(nGuideId)
    ---跳过的指引 不在重复触发
    if GuideLogic.GetTask(nGuideId) == 999 then
        return false
    end

    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if not tbConfig or not GuideLogic.IsGuideComplete(tbConfig.PreGuide) then
        return false
    end

    if tbConfig.bRepeat then
        return true
    end

    if nGuideId == 10061 or nGuideId == 10081 then
        return GuideLogic.CanOpenGuideSpecial(nGuideId)
    end

    if tbConfig.tbCheckEx and #tbConfig.tbCheckEx > 0 then
        local bResult = true
        for _, value in pairs(tbConfig.tbCheckEx) do
            if type(value) == "table" then
                bResult = bResult and GuideLogic.CheckFunction(value[1], value[2])
            end
        end
        if not bResult then
            return false
        end
    end

    if GuideLogic.IsGuideComplete(nGuideId) then   --已经完成过
        -- 如果配置了没通关再次触发，判断是否通关
        if not tbConfig.nRestart then
            return false
        end
        local levelCfg = ChapterLevel.Get(tbConfig.nRestart)
        if not levelCfg then
            return false
        end
        return levelCfg:GetPassTime() <= 0
    else
        -- 如果对应的关卡已经通关，则认为指引已经完成
        if tbConfig.nLevelId then
            local levelCfg = ChapterLevel.Get(tbConfig.nLevelId)
            if levelCfg and levelCfg:IsPass() then
                GuideLogic.SetGuideComplete(nGuideId)
                return false
            end
        end
        -- 如果满足特定的条件，则认为指引已经完成
        if tbConfig.tbCheckCompleteEx and #tbConfig.tbCheckCompleteEx > 0 then
            local bComplete = true
            for _, value in pairs(tbConfig.tbCheckCompleteEx) do
                if type(value) == "table" then
                    bComplete = bComplete and GuideLogic.CheckFunction(value[1], value[2])
                end
            end
            if bComplete then
                GuideLogic.SetGuideComplete(nGuideId)
                return false
            end
        end
    end

    return true
end

--- 得到指引10061、10081是否能开启
function GuideLogic.CanOpenGuideSpecial(nGuideId)
    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if not tbConfig then
        return false
    end

    if nGuideId == 10061 and not GuideLogic.CheckFunction("CheckCard", {{0,1,2,1,1}, {1,1,8,1,1}}) then
        return false
    end
    if nGuideId == 10081 and not GuideLogic.CheckFunction("CheckCard", {{0,1,8,1,1}, {1,1,2,1,1}}) then
        return false
    end

    if GuideLogic.IsGuideComplete(nGuideId) then
        -- 如果配置了没通关再次触发，判断是否通关
        if not tbConfig.nRestart then
            return false
        end
        local levelCfg = ChapterLevel.Get(tbConfig.nRestart)
        if not levelCfg then
            return false
        end
        return levelCfg:GetPassTime() <= 0
    else
        -- 如果对应的关卡已经通关，则认为指引已经完成
        if tbConfig.nLevelId then
            local levelCfg = ChapterLevel.Get(tbConfig.nLevelId)
            if levelCfg and levelCfg:IsPass() then
                GuideLogic.SetGuideComplete(nGuideId)
                return false
            end
        end
    end

    return true
end

--- 刷新当前指引完成状态
function GuideLogic.RefreshGuideStatus(nGuideId)
    nGuideId = nGuideId or GuideLogic.nGuideId
    if not nGuideId or nGuideId == 0 then return end
    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if not tbConfig then return end
    local nStepId = GetTask(tbConfig.nID)
    local nMaxKeyIndex = 0

    for i = #tbConfig.tbStep, 1, -1 do
        if #tbConfig.tbStep[i].tbCheck > 0 then
            nMaxKeyIndex = tbConfig.tbStep[i].tbCheck[1]
            break
        end
    end

    local bComplete = false
    if nStepId > #tbConfig.tbStep then
        bComplete = true
    elseif nMaxKeyIndex > 0 and nStepId > nMaxKeyIndex then
        bComplete = true
    else
        -- 如果对应的关卡已经通关，则认为指引已经完成
        if tbConfig.nLevelId then
            local levelCfg = ChapterLevel.Get(tbConfig.nLevelId)
            if levelCfg and levelCfg:IsPass() then
                bComplete = true
            end
        end
    end

    if bComplete then
        GuideLogic.SetGuideComplete(nGuideId)
    end
end

--- 判断是不是非强制指引
function GuideLogic.IsNonForce(nID)
    local tbConfig = GuideLogic.GetConfig(nID)
    return tbConfig.sType == "NonForce"
end

--- 判断是不是战斗教学指引
function GuideLogic.IsTeach(nID)
    return nID <= GuideLogic.MaxTeachId
end

--- 是否能编辑编队
--- @return boolean 是否能编辑编队
function GuideLogic.IsCanEditFormation()
    local levelCfg = ChapterLevel.Get(10102)
    if levelCfg and levelCfg:IsPass() then
        return true
    end
    -- if GuideLogic.IsGuideComplete(105) then
    --     return true
    -- end
    return false
end

--- 指引是否完成
--- @param nGuideId integer 指引ID
--- @return boolean 返回指引是否完成
function GuideLogic.IsGuideComplete(nGuideId)
    if not me then
        return true
    end

    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if not tbConfig then
        return true
    end
    if (GetTask(tbConfig.nID) <= #tbConfig.tbStep) then
        if GuideLogic.LastCompleteID == nGuideId then
            return true
        else
            return false
        end
    else
        return true
    end
end

--- 设置指引完成(跳过指引,永远不会再次触发)
function GuideLogic.SetCompleteSkipGuide(nGuideId)
    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if tbConfig then
        SetTask(tbConfig.nID, 999)
    end
end

--- 设置指引完成
function GuideLogic.SetGuideComplete(nGuideId)
    if not GuideLogic.IsGuideComplete(nGuideId) then
        --暂存刚完成的ID 避免因为检测太快还没记录上完成而再次触发
        GuideLogic.LastCompleteID = nGuideId
        GuideLogic.SetGuideTaskComplete(nGuideId)
    end
end

--- 设置指引标志为完成
function GuideLogic.SetGuideTaskComplete(nGuideId)
    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if tbConfig then
        SetTask(tbConfig.nID, #tbConfig.tbStep + 1)
    end
end

--- 结束当前指引
--- @param setComplete boolean 是否直接设置指引完成
function GuideLogic.EndGuide(setComplete)
    if GuideLogic.bResetInput then
        --恢复按键操作
        local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if Controller then
            Controller:RestoreAllKeyboardInput()
        end
        GuideLogic.bResetInput = nil
    end

    if setComplete and GuideLogic.IsGuiding() then
        GuideLogic.SetGuideComplete(GuideLogic.nGuideId)
    end
    GuideLogic.nGuideId = 0
    GuideLogic.nStepId = 0
    local sUI = UI.GetUI("Guide")
    if sUI then
        sUI:ReleaseEvent()
        if sUI:IsOpen() then
            UI.Close(sUI)
        end
    end
end

--- 是否正处于指引中
function GuideLogic.IsGuiding()
    if GuideLogic.nGuideId and GuideLogic.nGuideId > 0 then
        return true
    else
        return false
    end
end

--- 是否正处于教学图指引中
function GuideLogic.IsHelpGuiding()
    if GuideLogic.nGuideId and GuideLogic.nGuideId > 0 then
        local cfg = GuideLogic.tbConfig[GuideLogic.nGuideId]
        if cfg and cfg.tbStep[GuideLogic.nStepId] and cfg.tbStep[GuideLogic.nStepId].sTextureUI == "HelpPop" then
            return true
        end
    end
    return false
end

--- 得到下个指引步骤
function GuideLogic.GetNextStep(nGuideId, nStepId)
    local tbConfig = GuideLogic.GetConfig(nGuideId)
    if not tbConfig or not tbConfig.tbStep[nStepId] or GuideLogic.IsTeach(tbConfig.nID) then
        return nStepId
    end

    local nMaxId = GetTask(tbConfig.nID)  -- 历史最高指引进度
    local i = nStepId
    while(i <= #tbConfig.tbStep)
    do
        local step = tbConfig.tbStep[i]
        if #step.tbCheck == 0 and type(step.tbCheckEx) ~= "table" then
            return i
        end

        if type(step.tbCheckEx) == "table" and GuideLogic.CheckFunction(step.tbCheckEx[2], step.tbCheckEx[3]) then  -- 自定义检测函数
            i = step.tbCheckEx[1]
        elseif #step.tbCheck == 2 and step.tbCheck[1] < nMaxId then                 -- 如果step.Check[1]已经完成，则跳转到第step.Check[2]步
            i = step.tbCheck[2]
        else
            return i
        end
    end
    return i
end

--- 增加一条日志准备记录
function GuideLogic.WriteGuideLog(logstr)
    if not me then
        return
    end
    if not logstr or logstr == "" then
        return
    end
    GuideLogic.tbLog = GuideLogic.tbLog or {}
    table.insert(GuideLogic.tbLog, logstr)
    GuideLogic.ChackGuideLog()
end
--- 检查是否能记录日志
function GuideLogic.ChackGuideLog()
    if GuideLogic.NowRecordingLog then
        return
    end
    if not GuideLogic.tbLog or #GuideLogic.tbLog <= 0 then
        return
    end
    --- 当前正在记录的日志
    GuideLogic.NowRecordingLog = GuideLogic.tbLog[1]
    me:CallGS("GuideLogic_WriteGuideLog", json.encode({logstr = GuideLogic.tbLog[1]}))
end
--- 服务器记录日志后刷新
s2c.Register('GuideLogic_WriteGuideLog', function(tbParam)
    if tbParam.error then
            table.remove(GuideLogic.tbLog, 1)
    else
        for i, v in pairs(GuideLogic.tbLog) do
            if v == tbParam.logstr then
                table.remove(GuideLogic.tbLog, i)
            end
        end
    end
    GuideLogic.NowRecordingLog = nil
    GuideLogic.ChackGuideLog()
end)
--- 收到服务器指令
s2c.Register('GuideLogic_GuideGM', function(tbParam)
    if not tbParam or not tbParam.type then
        return
    end
    local type = tonumber(tbParam.type)
    if type == 0 then
        GuideLogic.ResetAllGuide()
    elseif type == 1 then
        GuideLogic.SkipAllGuide(tbParam.openGuideID)
    elseif type == 2 then
        GuideLogic.SkipNowGuide()
    elseif type == 3 then
        GuideLogic.SkipLevelGuide()
    end
end)

--- 新手序章指引是否完成(1动画-2教学-3剧情-4取名-5剧情)
function GuideLogic.IsCanMapGuide()
    return GuideLogic.GetCanBeginGuide() and (me:GetAttribute(GuideLogic.GroupId, 0) < 5)
end

--- 登录界面调用，开始新手序章指引
---@param bNeedRename boolean 教学结束后是否重命名
function GuideLogic.BeginMapGuide(bNeedRename)
    --- 序章指引当前进行的步骤
    GuideLogic.nNowStep = me:GetAttribute(GuideLogic.GroupId, 0) + 1
    GuideLogic.EnterGuideMap()
end

EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    GuideLogic.LastCompleteID = nil
    if GuideLogic.nNowStep and bReconnected then
        local lastStep = GuideLogic.nNowStep - 1
        if me:GetAttribute(GuideLogic.GroupId, 0) < lastStep then
            me:SetAttribute(GuideLogic.GroupId, 0, lastStep)
        end
    end
end)

--- 记录当前步骤完成 即将进入下一个
---@param nextStep integer 下一个步骤
function GuideLogic.RecordStep(nextStep)
    if not GuideLogic.nNowStep then
        GuideLogic.nNowStep = 1
    end
    me:SetAttribute(GuideLogic.GroupId, 0, GuideLogic.nNowStep)
    GuideLogic.nNowStep = nextStep or (GuideLogic.nNowStep + 1)
end

--- 进入序章指引地图
function GuideLogic.EnterGuideMap()
    if not GuideLogic.nNowStep or GuideLogic.nNowStep > 5 then --全部完成了
        if IsValid(GuideLogic.WwiseComponent) then
            GuideLogic.WwiseComponent:Stop()
            GuideLogic.WwiseComponent = nil
        end
        Launch.End()
    else
        Launch.SetType(LaunchType.GUIDE)
        if GuideLogic.nNowStep <= 3 then -- 第一步 播第一步剧情
            local tbLevelCfg = ChapterLevel.Get(50100)
            if tbLevelCfg then
               Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
            end
        elseif GuideLogic.nNowStep == 4 then --进关卡
            Loading.AppointPicture(1501038)
            if Map.GetCurrentID() ~= GuideLogic.PrologueMapID then
                GuideLogic.bCanSetUp = false
                Launch.SetType(LaunchType.GUIDE)
                Formation.SetCurLineupIndex(1)
                if Formation.CanFight() then
                    Launch.Start()
                    Adjust.DoRecord("qv2eh8");
                elseif not Formation.SetMemberByLineup1(Launch.Start) then
                    GuideLogic.RecordStep(5)
                    GuideLogic.EnterGuideMap()
                end
            end
        elseif GuideLogic.nNowStep == 5 then --播放第五步剧情
            Loading.AppointPicture(nil)
            -- UE4.ULevelLibrary.ShowMouseCursorInLevel(GetGameIns(), true)  --强行显示鼠标
            -- UE4.UUMGLibrary.PlayPlot(GetGameIns(), 1003, {GetGameIns(), function(lication, CompleteType)
            --     if CompleteType ~= UE4.EPlotCompleteType.Close then GuideLogic.RecordStep(6) end
            --     GuideLogic.EnterGuideMap()
            -- end})
            -- if not GuideLogic.WwiseComponent then
            --     GuideLogic.WwiseComponent = UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), "Play_BGM_Story_001")
            -- end
            --- 改为在关卡中去播
            local tbLevelCfg = ChapterLevel.Get(50100)
            if tbLevelCfg then
               Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
            end
        end
    end
end

GuideLogic.LoadConf()

-------------------------------------------指令----------------------------------------------
--- 指令重置所有指引
function GuideLogic.ResetAllGuide()
    for _, v in pairs(GuideLogic.tbConfig) do
        me:SetAttribute(GuideLogic.GroupId, v.nID, 0)
    end
    me:SetAttribute(GuideLogic.GroupId, 0, 0)
    me:SetAttribute(40, 1500, 0)
    if not GuideLogic.GetCanBeginGuide()then
        GuideLogic.SetCanBeginGuide(true)
    end
end
--- 指令完成所有指引
function GuideLogic.SkipAllGuide(tbOpenGuideID)
    local tbOpenID = {}
    for _, ID in pairs(tbOpenGuideID or {}) do
        tbOpenID[ID] = true
    end
    for _, v in pairs(GuideLogic.tbConfig) do
        if not tbOpenID[v.nID] then
            GuideLogic.SetGuideComplete(v.nID)
        end
    end
    GuideLogic.EndGuide()
    GuideLogic.SkipLevelGuide()
    if not tbOpenGuideID or #tbOpenGuideID==0 then
        GuideLogic.SetCanBeginGuide(false)
    end
end
--- 指令完成当前指引
function GuideLogic.SkipNowGuide()
    if GuideLogic.nNowStep then
        if UI.IsOpen("Guide") then
            UI.Close("Guide")
        end
        GuideLogic.RecordStep()
        GuideLogic.EnterGuideMap()
    else
        GuideLogic.EndGuide(true)
    end
end
--- 指令完成新手序章指引
function GuideLogic.SkipLevelGuide()
    if GuideLogic.IsCanMapGuide() then
        me:SetAttribute(GuideLogic.GroupId, 0, 5)
    end
    if GuideLogic.nNowStep then
        GuideLogic.nNowStep = nil
        Launch.End()
    end
end
--- 打开指定指引
function GuideLogic.OpenAppointGuide(guideid)
    local id = tonumber(guideid) or 0
    me:SetAttribute(GuideLogic.GroupId, id, 0)
    if GuideLogic.IsGuiding() then
        GuideLogic.EndGuide()
    end
    if id > 0 and GuideLogic.tbConfig[id] then
        local step = GuideLogic.tbConfig[id].tbStep[1]
        if (UI.IsOpen(step.sWindow)) then
            GuideLogic.BeginGuide(id, 1)
        end
    end
    if not GuideLogic.GetCanBeginGuide()then
        GuideLogic.SetCanBeginGuide(true)
    end
end

-------------------------------------------------------------------------------------------
-------------------------------------注册自定义检测函数--------------------------------------
GuideLogic.tbCheckFun = {}
--- 注册自定义检测函数
local RegisterCheckFun = function(szName, pFun)
    GuideLogic.tbCheckFun[szName] = pFun
end

--- 自定义检测函数
function GuideLogic.CheckFunction(szFunName, tbParams)
    if szFunName and GuideLogic.tbCheckFun[szFunName] then
        return GuideLogic.tbCheckFun[szFunName](tbParams or {})
    end
    return false
end

--- 检查是否能出战
RegisterCheckFun("CanFight", function()
    return Formation.CanFight()
end)

--- 检查关卡id
RegisterCheckFun("CheckLevelId", function(tbParam)
    if not tbParam or #tbParam <= 0 then return false end
    return Chapter.GetLevelID() == tbParam[1]
end)
--- 检查关卡是否能前往
RegisterCheckFun("CheckCanLevel", function(tbParam)
    if not tbParam or #tbParam <= 0 then return false end
    local cfg = ChapterLevel.Get(tbParam[1])
    return Condition.Check(cfg.tbCondition)
end)

--- 检查关卡是否已经首通
RegisterCheckFun("CheckLevelIsPass", function(tbParam)
    if not tbParam or #tbParam <= 0 then return false end
    local cfg =  ChapterLevel.Get(tbParam[1])
    return cfg and cfg:IsPass()
end)

--- Role界面选择角色卡时隐藏其他角色卡
RegisterCheckFun("HideOtherCard", function(tbParam)
    local sUI = UI.GetUI("Role")
    if not sUI or not sUI:IsOpen() or not sUI.LeftList then
        return
    end
    local tbcard = {}
    for i = 1, sUI.LeftList:GetNumItems() do
        local card = sUI.LeftList:GetItemAt(i-1)
        local isshow = false
        for _, v in pairs(tbParam) do
            if v[1] == card.Template.Genre and v[2] == card.Template.Detail and v[3] == card.Template.Particular and v[4] == card.Template.Level then
                isshow = true
            end
        end
        if not isshow then
            table.insert(tbcard, card)
        end
    end
    for _, card in ipairs(tbcard) do
        sUI.LeftList:RemoveItem(card)
    end
    for i = 1, sUI.LeftList:GetNumItems() do
        sUI.LeftList:GetItemAt(i-1).ShowPos = i
    end
end)

--- Role界面将指定角色卡滚动到视图中
RegisterCheckFun("ScrollCardIntoView", function(tbParam)
    if not tbParam or #tbParam < 4 then return end
    local sUI = UI.GetUI("Role")
    if not sUI or not sUI:IsOpen() or not sUI.LeftList then
        return
    end
    for i = 1, sUI.LeftList:GetNumItems() do
        local card = sUI.LeftList:GetItemAt(i-1)
        if tbParam[1] == card.Template.Genre and tbParam[2] == card.Template.Detail and tbParam[3] == card.Template.Particular and tbParam[4] == card.Template.Level then
            sUI.LeftList:NavigateToIndex(i-1)
            break
        end
    end
end)

--- Role界面将指定武器滚动到视图中
RegisterCheckFun("ScrollWeaponIntoView", function(tbParam)
    if not tbParam or #tbParam < 4 then return end
    local sUI = UI.GetUI("Role")
    if not sUI or not sUI:IsOpen() or not sUI.LeftList then
        return
    end
    local UIWeapon = sUI:GetSwitcherWidget("Weapon")
    if UIWeapon then
        for i = 1, UIWeapon.WeaponList:GetNumItems() do
            local weapon = UIWeapon.WeaponList:GetItemAt(i-1).Data.pItem
            if weapon and tbParam[1] == weapon:Genre() and tbParam[2] == weapon:Detail() and tbParam[3] == weapon:Particular() and tbParam[4] == weapon:Level() then
                UIWeapon.WeaponList:NavigateToIndex(i-1)
                break
            end
        end
    end
end)

--- 主线章节选择界面设置LevelScrollBox滑动值
RegisterCheckFun("SetChapterScrollOffset", function(tbParam)
    if not tbParam or not tonumber(tbParam[1]) then return end
    local sUI = UI.GetUI("Chapter")
    if not sUI or not sUI:IsOpen() or not sUI.LevelScrollBox then
        return
    end
    local value = tonumber(tbParam[1])
    if value < 0 then value = 0 end
    if value > 1 then value = 1 end
    local OffsetOfEnd = sUI.LevelScrollBox:GetScrollOffsetOfEnd()
    sUI.LevelScrollBox:SetScrollOffset(Lerp(0, OffsetOfEnd, value))
end)

--- 常规活动章节选择界面将指定资源本到视图中
RegisterCheckFun("ScrollResourseIntoView", function(tbParam)
    if not tbParam or not tonumber(tbParam[1]) then return end
    local sUI = UI.GetUI("DungeonsResourse")
    if not sUI or not sUI:IsOpen() or not sUI.CustListView_66 then
        return
    end
    local index = tonumber(tbParam[1])
    local num = sUI.CustListView_66:GetNumItems()
    if index < 1 then index = 1 end
    if index > num then index = num end
    sUI.CustListView_66:NavigateToIndex(index)
end)

--- Level界面将指引的目标Level选中并滚动到试图中
RegisterCheckFun("ScrollIntoView", function(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    local sUI = UI.GetUI("Level")
    if not sUI or not sUI:IsOpen() or not sUI.LevelContent then return end
    local widget = sUI.LevelContent:ScrollIntoView(tbParam[1])
    if widget then
        sUI.LevelScrollBox:ScrollWidgetIntoView(widget, true, UE4.EDescendantScrollDestination.Center, 0)
    end
end)

--- Level界面关卡列表禁止滑动，暂时通过将水平方向滑动设置为竖直方向滑动实现
RegisterCheckFun("NoScroll", function(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    local sUI = UI.GetUI("Level")
    if not sUI or not sUI:IsOpen() or not sUI.LevelScrollBox then return end
    sUI.LevelScrollBox:SetOrientation(tbParam[1])
    sUI.LevelScrollBox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end)

--- 主线章节选择界面列表禁止滑动，暂时通过将水平方向滑动设置为竖直方向滑动实现
RegisterCheckFun("ChapterNoScroll", function(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    local sUI = UI.GetUI("Chapter")
    if not sUI or not sUI:IsOpen() or not sUI.LevelScrollBox then return end
    sUI.LevelScrollBox:SetOrientation(tbParam[1])
    sUI.LevelScrollBox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end)

--- 暂停或继续
RegisterCheckFun("SetGamePaused", function(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    UE4.UGameplayStatics.SetGamePaused(GetGameIns(), tbParam[1] > 0)
end)

--- 检查编队的指定位置是不是指定角色
RegisterCheckFun("CheckCard", function(tbParam)
    if not tbParam or #tbParam <= 0 then return false end
    --只检查一号编队
    local Lineup = Formation.GetLineup(1)
    if not Lineup then return false end
    for _, v in ipairs(tbParam) do
        if #v >= 5 and Lineup:GetMember(v[1]) then
            local card = Lineup:GetMember(v[1]):GetCard()
            if not card or v[2] ~= card:Genre() or v[3] ~= card:Detail() or v[4] ~= card:Particular() or v[5] ~= card:Level() then
                return false
            end
        else
            return false
        end
    end
    return true
end)

--- 检查编队的角色数量
RegisterCheckFun("CheckCardNum", function(tbParam)
    if not tbParam or not tbParam[1] then return false end
    --只检查一号编队
    local Lineup = Formation.GetLineup(1)
    if not Lineup then return false end
    return Lineup:GetCards():Length() >= tbParam[1]
end)

--- 打开或关闭编队编辑功能
RegisterCheckFun("SetCanEditFormation", function(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    local sUI = UI.GetUI("formation")
    if not sUI or not sUI:IsOpen() then return end
    sUI:SetCanEditFormation(tbParam[1] > 0)
end)

--- 检查指定界面是否打开
RegisterCheckFun("UINotOpen", function(tbParam)
    if not tbParam or #tbParam <= 0 then return false end
    return not UI.IsOpen(tbParam[1])
end)

-- 进入下一步
RegisterCheckFun("GoToNextStep", function(tbParam)
    local ui = UI.GetUI("Guide")
    if ui and ui:IsOpen() then
        ui:GotoNextStep()
    end
end)

-- 设置是否自动开火
RegisterCheckFun("SelectJoystic", function(tbParam)
    if not tbParam or #tbParam <= 0 then return end
    local SHOOT_AUTO = PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.SHOOT_AUTO)
    if SHOOT_AUTO ~= tbParam[1] then
        PlayerSetting.Set(PlayerSetting.SSID_OPERATION, OperationType.SHOOT_AUTO, {tbParam[1]})
        PlayerSetting.Save()
        GuideLogic.SHOOT_AUTO = SHOOT_AUTO
    end
end)
-- 恢复之前的设置
RegisterCheckFun("RecoveryJoystic", function(tbParam)
    if not GuideLogic.SHOOT_AUTO then
        return
    end
    local SHOOT_AUTO = PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.SHOOT_AUTO)
    if SHOOT_AUTO ~= GuideLogic.SHOOT_AUTO then
        PlayerSetting.Set(PlayerSetting.SSID_OPERATION, OperationType.SHOOT_AUTO, {GuideLogic.SHOOT_AUTO})
        PlayerSetting.Save()
        GuideLogic.SHOOT_AUTO = nil
    end
end)

--- 显示切换角色按钮
RegisterCheckFun("ShowPlayerSelect", function(tbParam)
    local uifight = UI.GetUI("fight")
    if uifight then
        WidgetUtils.Visible(uifight.PlayerSelect)
    end
end)

--- 判断编队指定位置是否有角色
RegisterCheckFun("IsMemberByPos", function(tbParam)
    if not tbParam or #tbParam <= 0 then return false end
    local Lineup = Formation.GetCurrentLineup()
    if not Lineup then return false end
    local member = Lineup:GetMember(tbParam[1])
    if not member then return false end
    return not member:IsNone()
end)

---角色是否在队伍，是否能出战
RegisterCheckFun("IsInFormation", function(tbParam)
    if not tbParam or #tbParam < 4 then return false end
    local Lineup = Formation.GetCurrentLineup()
    if not Lineup then return false end
    for _, member in pairs(Lineup:GetMembers()) do
        local card = member:GetCard()
        if card and tbParam[1] == card:Genre() and tbParam[2] == card:Detail() and tbParam[3] == card:Particular() and tbParam[4] == card:Level() then
            return Formation.CanFight()
        end
    end
    return false
end)

---检查货币是否达到指定数量
RegisterCheckFun("CheckMoney", function(tbParam)
    if not tbParam or #tbParam < 2 then return false end
    return Cash.GetMoneyCount(tbParam[1]) >= tbParam[2]
end)
---检查道具是否达到指定数量
RegisterCheckFun("CheckItemCount", function(tbParam)
    if not tbParam or #tbParam < 4 then return false end
    return me:GetItemCount(tbParam[1], tbParam[2], tbParam[3], tbParam[4]) >= (tbParam[5] or 1)
end)


---检查角色是否达到指定等级
RegisterCheckFun("CheckCardLevel", function(tbParam)
    if not tbParam or #tbParam < 5 then return false end
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:Genre() == tbParam[1] and card:Detail() == tbParam[2] and card:Particular() == tbParam[3] and card:Level() == tbParam[4] then
            return card:EnhanceLevel() >= tbParam[5]
        end
    end
    return false
end)

---检查角色的后勤卡槽是否为空
RegisterCheckFun("CheckupporterCard", function(tbParam)
    if not tbParam then return false end
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        for _, param in pairs(tbParam) do
            if #param >= 4 then
                local card = Cards:Get(i)
                if card:Genre() == param[1] and card:Detail() == param[2] and card:Particular() == param[3] and card:Level() == param[4] then
                    local tbItem = UE4.TArray(UE4.USupporterCard)
                    card:GetSupporterCards(tbItem)
                    if tbItem:Length() > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end)

--- 设置指引完成
RegisterCheckFun("SetGuideComplete", function(tbParam)
    if not tbParam or #tbParam < 1 then return end
    for _, ID in pairs(tbParam) do
        GuideLogic.SetGuideComplete(ID)
    end
end)

--- 设置鼠标显示
RegisterCheckFun("ExhaleMouse", function(tbParam)
    if not tbParam or #tbParam < 1 then return end
    --if IsMobile() then return end
    RuntimeState.ChangeInputMode(tbParam[1] ~= 0)
end)

---检查是否没有解锁某神经
RegisterCheckFun("CheckNerve", function(tbParam)
    if not tbParam or #tbParam < 4 then return true end
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:Genre() == tbParam[1] and card:Detail() == tbParam[2] and card:Particular() == tbParam[3] and card:Level() == tbParam[4] then
            return not card:GetSpine(1, 1)
        end
    end
    return true
end)

---检查是否没有大于一级的武器
RegisterCheckFun("CheckWeaponLevel", function()
    local Weapons = UE4.TArray(UE4.UWeaponItem)
    me:GetWeaponItems(Weapons)
    for i = 1, Weapons:Length() do
        if Weapons:Get(i):EnhanceLevel() > 1 then
            return false
        end
    end
    return true
end)

---检查是否未签到
RegisterCheckFun("CheckSignIn", function()
    return Sign.CheckOpen(false)
end)

---检查是否有角色同步率解锁了
RegisterCheckFun("CheckProLevel", function()
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:ProLevel() > 0 then
            return false
        end
    end
    return true
end)

--判断指定角色是否佩戴指定武器
RegisterCheckFun("CheckCardWeapon", function(tbParam)
    if not tbParam or #tbParam < 2 then return false end
    local cardgdpl = tbParam[1]
    local weapongdpl = tbParam[2]
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:Genre() == cardgdpl[1] and card:Detail() == cardgdpl[2] and card:Particular() == cardgdpl[3] and card:Level() == cardgdpl[4] then
            local Weapon = card:GetSlotWeapon()
            if Weapon and Weapon:Genre() == weapongdpl[1] and Weapon:Detail() == weapongdpl[2] and Weapon:Particular() == weapongdpl[3] and Weapon:Level() == weapongdpl[4] then
                return true
            end
        end
    end
    return false
end)

---选择指定的蛋池
RegisterCheckFun("SelectGacha", function(tbParam)
    if not tbParam or #tbParam < 1 then return end
    local ID = tbParam[1]
    local ui = UI.GetUI("gacha")
    if ui and ui:IsOpen() then
        ui.nCacheID = ID
        if ui.tbCache[ID] then
            ui:OnSelectChange(ui.tbCache[ID])
        end
    end
end)

---屏蔽或打开键盘操作
RegisterCheckFun("SetKeyboardInput", function(tbParam)
    if not tbParam or #tbParam < 2 then return end
    local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    if controller then
        for i = 2, #tbParam do
            local v = tonumber(tbParam[i])
            if v then
                if v == GuideLogic.EPCKeyboardType.PauseGame then
                    ---有些指引进行时不能按暂停
                    GuideLogic.CanPauseGame = tbParam[1]
                else
                    if tbParam[1] == 0 then
                        controller:ClearKeyboardInput(v)
                    elseif tbParam[1] == 1 then
                        controller:SetKeyboardInput(v)
                    end
                end
            end
        end
    end
end)

---倒计时自动设置当前步骤完成
RegisterCheckFun("AutoComplete", function(tbParam)
    if not tbParam or #tbParam < 1 then return end
    local time = tonumber(tbParam[1])
    if time and time > 0 then
        UE4.Timer.Add(time, function()
            if GuideLogic.IsGuiding() then
                local sUI = UI.GetUI("Guide")
                if sUI and sUI:IsOpen() then
                    sUI:GotoNextStep()
                end
            end
        end)
    end
end)

---设置跳弹显示
RegisterCheckFun("SetDeflection", function(tbParam)
    if not tbParam or type(tbParam[1]) ~= "number" then return end
    local v = tonumber(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.DAMAGE_SHOW)) or 0
    local bOn = tbParam[1] > 1
    local bOld = v >= 10 and math.floor(v/10)%10 >= 1
    local new = v
    if bOld and not bOn then
        new = new - 10
    elseif not bOld and bOn then
        new = new + 10
    end
    if new ~= v then
        PlayerSetting.Set(PlayerSetting.SSID_OPERATION, OperationType.DAMAGE_SHOW, {new})
        PlayerSetting.Save()
    end
end)

RegisterCheckFun("SetKeyInput", function(tbParam)
    if not tbParam or #tbParam < 2 or not GuideLogic.EPCKeyboardType[tbParam[1]] then return end
    local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    if controller then
        if tbParam[2] == 0 then
            controller:ClearKeyboardInput(GuideLogic.EPCKeyboardType[tbParam[1]])
        elseif tbParam[2] == 1 then
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType[tbParam[1]])
        end
    end
end)

------------------------------------------------------------------------------------------
