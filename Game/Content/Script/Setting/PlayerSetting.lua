-- ========================================================
-- @File    : PlayerSetting.lua
-- @Brief   : 设置
-- ========================================================

require('Setting.Keyboard')
require('Setting.Gamepad')

PlayerSetting = PlayerSetting or {}
PlayerSetting.GID               = 40    --- 组ID
PlayerSetting.SGID              = 40  --- 字符组ID

---SID
PlayerSetting.SSID_OPERATION    = 1
PlayerSetting.SSID_FRAME        = 2
PlayerSetting.SSID_SOUND        = 3
PlayerSetting.SSID_OTHER        = 4
PlayerSetting.SSID_KEYBOARD     = 5
PlayerSetting.SSID_NOTIFICATION = 6 --- 推送相关的设置，其内部具体分类在LocalNotification.lua中定义
PlayerSetting.SSID_LANGUAGE     = 7
PlayerSetting.SSID_HANDLE       = 8


PlayerSetting.SSID_WEAPON_PART  = 50 ---武器配件显示原装模型
---游玩时长
PlayerSetting.SSID_PLAY_TIME    = 51
---手柄
PlayerSetting.SSID_HAND_INDEX   = 52

PlayerSetting.SSID_PLOT         = 101
PlayerSetting.SSID_PRECONDITION = {1001,2000}

----公告弹出记录
PlayerSetting.SID_NOTICE        = 100
----自定义界面
PlayerSetting.SID_CUSTOMIZE     = 102

---设置界面跳转Tab名称
PlayerSetting.JumpTabName = nil

--界面相关的设置
CustomizeType = {
    
}

---操作相关的设置
OperationType = {
    JOYSTIC         = 1,
    SLIDE           = 2,
    AIM_FIRE        = 3,
    AIM             = 4,
    FIRE            = 5,
    SKILL           = 6,
    ACC_FACTOR      = 7,
    AWM_AIM_SLIDE   = 8,
    AIM_ASSIST_STRENGTH = 9,

    FIRE_ADSORB    = 10, ---准心吸附
    FIRE_SWERVE     = 11, ---开火按钮转向

    SKILL_FRAME     = 12, ---技能框

    PC_SLIDE        = 13, --PC"镜头灵敏度”，表示非瞄准状态下鼠标移动带动镜头的速率
    GYROSCOPE_AIM   = 14, --是否开启陀螺仪瞄准
    GYROSCOPE_INVERT = 15, --是否反转--不反 X Y 都反
    GYROSCOPE_SCALE = 16, --陀螺仪灵敏度
    DAMAGE_SHOW  = 17, --伤害显示
    PC_MOUSE_INVERT = 18, --鼠标反向
    JOYSTIC_FIXED = 19, -- 固定摇杆
    SKILL_TIP = 20, -- 技能范围提示
    SHOOT_AUTO = 21, -- 射击自动

    SMART_CASTING = 22, -- 智能施法
    SNIPER_FIRE = 23, -- 狙击枪激发方式
    SHOTGUN_FIRE = 24,  -- 霰弹枪激发方式
    PISTOL_FIRE = 25, -- 手枪激发方式
    MIX_AIM = 26, -- 混合射击按钮
    LEFT_HAND_FIRE = 27, -- 显示左手开火
    AIM_SWERVE = 28, -- 瞄准按钮转向
    AIM_MODEL = 29,  -- 瞄准按钮模式
    TURNING_ACCELERATE = 30, -- 转向加速
    RUSH_MODEL = 31, -- 疾跑模式
    BOOM_WARN = 32, -- 爆炸预警

    SHOOT_AUTO_GUNTYPE = 33, -- 自动设计枪械类型
    RUN_TYPE = 34, -- 奔跑方式
    DEFLECTION = 35, -- “偏斜”冒字显示
    SHOOT_VIEW1 = 36, -- 瞄准射击转动视角
    SHOOT_VIEW2 = 37, -- 普通射击转动视角
    SHOOT_VIEW3 = 38, -- 混合射击转动视角
    SENSITIVITY = 39, -- 灵敏度设置

    SENSITIVITY_CAMERA_TURN_OFF = 40, -- 镜头灵敏度开镜
    SENSITIVITY_CAMERA_TURN_ON = 41,  -- 镜头灵敏度开镜
    SENSITIVITY_CAMERA_TURN_ON_SNIPER = 42, -- 镜头灵敏度狙击枪开镜

    SENSITIVITY_FIRE_TURN_OFF = 43, -- 开火灵敏度开镜
    SENSITIVITY_FIRE_TURN_ON = 44,  -- 开火灵敏度开镜
    SENSITIVITY_FIRE_TURN_ON_SNIPER = 45, -- 开火灵敏度狙击枪开镜

    SENSITIVITY_GYROSCOPE_TURN_OFF = 46, -- 陀螺仪灵敏度开镜
    SENSITIVITY_GYROSCOPE_TURN_ON = 47,  -- 陀螺仪灵敏度开镜
    SENSITIVITY_GYROSCOPE_TURN_ON_SNIPER = 48, -- 陀螺仪灵敏度狙击枪开镜

    SENSITIVITY_FIRE_GYROSCOPE_TURN_OFF = 49, -- 陀螺仪开火灵敏度开镜
    SENSITIVITY_FIRE_GYROSCOPE_TURN_ON = 50,  -- 陀螺仪开火灵敏度开镜
    SENSITIVITY_FIRE_GYROSCOPE_TURN_ON_SNIPER = 51, -- 陀螺仪开火灵敏度狙击枪开镜

    DATAINPUT = 52,  -- 原始数据输入

    PC_MOUSE_SENSITIVITY_TURN_OFF           = 53,       -- PC鼠标灵敏度不开镜
    PC_MOUSE_SENSITIVITY_TURN_ON            = 54,       -- PC鼠标灵敏度开镜
    PC_MOUSE_SENSITIVITY_TURN_ON_SNIPER     = 55,       -- PC鼠标灵敏度狙击枪开镜
    VERTICALSLIDE                           = 56,       -- 纵向滑动比值
    ACTION_MODE                             = 57,       -- 操作模式
    PLACEHOLDER_1                           = 58,       -- 占位符1
    QUICK_SUPPORT_SUPERSKILL_LEAVE          = 59,       -- 快捷大招离场
}

---画面相关的设置
FrameType = {
    LEVEL           = 1, --画面等级
    CUSTOM          = 2, ---自定义参数
    DISPLAY         = 3, -- 显示模式及分辨率

    EFFECT                  = 4,
    SHADOW                  = 5,
    JAG                     = 6,
    RENDERING               = 7,
    FPS                     = 8,
    MIRRIR                  = 9,
    POST                    = 10,
    RENDERING_PC            = 11,
    PARTICLE                = 12,
    FROG                    = 13,
    BLUR                    = 14,
    MAXFPS                  = 15,
    VERTICAL                = 16,
    SCENE                   = 17
}

FrameDisplayType = {
    DISPLAY_MODE            = 1,
    RESOLUTION_SIZE         = 2 
}

FrameDisplayModeType = {
    FULL = 0,
    NO_BORDER = 1,
    WINDOWS = 2
}

---声音相关设置
SoundType = {
    ROLE            = 1,
    MUSIC           = 2,
    SOUND           = 3,
    LANGUAGE        = 4,
    QUALITY         = 5,
    DUBBING         = 6,
    EFFECTS         = 7
}

---其他设置
OtherType = {
    FONT_SIZE       = 1,
    FIGHT_SHOW_BROADCAST = 2, ---战斗中是否显示跑马灯
    UI_SAFE_ZONE_SCALE = 3, ---安全区缩放
    NOTICE_DISTURB  = 4, --公告免打扰
    CUSTOMER_SERVICE = 5, -- 客户服务
    EXCHANGE = 6, -- 兑换码

    GAMEPLAYAAGREE = 7, -- 游戏使用协议
    PRIVACY = 8,    -- 隐私协议
    SDKLIST = 9,    -- SDK列表
    LOGOUT = 10,     -- 注销

    SEASUN = 11,    -- 官方账号
    TWITTER = 12,   -- 推特账号
    APPLE = 13,     -- 苹果账号
    FACEBOOK = 14,  -- 脸书账号
    GOOGLE = 15,    -- 谷歌账号

    BACK_TO_LOGIN = 16 -- 返回登录
}

NoticeType = {
    GAME_MSG_PUSH,  -- 游戏消息推送
    ENERGY_FULL -- 体力回满感知
}

LanguageType = {
    LANGUAGE = 1,
    VOICE = 2
}

HandleType = {
    KEYBOARD = 1,
    SHAKE = 2,

    SENIOR_ANGLE_VIEW = 3,
    DETAIL_SETTING = 4,
    STEERING_SENSITIVITY = 5,
    AIMING_SENSITIVITY = 6,
    STEERING_CURVE = 7,
    STEERING_CORNER = 8,
    STEERING_INVERSE = 9,

    MOVE_CORNER = 10,

    CORNER = 11,
    EXTERNAL_THRESHOLD = 12,
    RESPONSE_CURVE = 13,
    HANDLE_LR_SPEED = 14,
    HANDLE_UD_SPEED = 15,
    EXTRA_LR_SPEED = 16,
    EXTRA_UD_SPEED = 17,
    EXTRA_START_STEERING_TIME = 18,
    EXTRA_START_STEERING_DELAY = 19,
    AIMED_HANDLE_LR_SPEED = 20,
    AIMED_HANDLE_UD_SPEED = 21,
    AIMED_EXTRA_LR_SPEED = 22,
    AIMED_EXTRA_UD_SPEED = 23,
    AIMED_EXTRA_START_STEERING_TIME = 24,
    AIMED_EXTRA_START_STEERING_DELAY = 25,
    MOVE_CORNER_VALUE = 26,
    HANDLE_AUTO_AIM = 27,
}

require 'Setting.SettingEvent'

local var = {
    tbDefault   = {}, ---默认配置
    tbFrame     = {

    }, ---画质配置项
    tbSave= {
       [PlayerSetting.SSID_OPERATION]   = {},
       [PlayerSetting.SSID_FRAME]       = {},
       [PlayerSetting.SSID_SOUND]       = {},
       [PlayerSetting.SSID_OTHER]       = {},
       [PlayerSetting.SSID_NOTIFICATION] = {},
       [PlayerSetting.SSID_LANGUAGE] = {},
       [PlayerSetting.SSID_HANDLE] = {}
    },

    tbResolution = {},

    bUseLocal = false, ---是否使用本地设置
}

PlayerSetting.tbClassType = {
    [0] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_option_item.uw_setup_option_item_C",
    [1] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_opition_choose.uw_setup_opition_choose_C",
    [2] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_slider.uw_setup_slider_C",
    [3] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_user_item.uw_setup_user_item_C",
    [4] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_uisafe.uw_setup_uisafe_C",
    [5] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_user_item2.uw_setup_user_item2_C"
}

PlayerSetting.tbKeyBoardSetting = {}
PlayerSetting.tbCustomizeTemplate = {}

-------------------参数改变时间----------------------

---设置数据
function PlayerSetting.Set(nSID, nType, Value)
    if not nSID or not nType or not Value then
        return
    end
    if var.tbSave[nSID] == nil then 
        var.tbSave[nSID] = {}
    end
    var.tbSave[nSID][nType] = Value
end

---获取数据
function PlayerSetting.Get(nSID, nType)
    if var.tbSave[nSID] == nil then 
        var.tbSave[nSID] = {}
    end
    local value = var.tbSave[nSID][nType]
    if value then
        return value
    end
    return PlayerSetting.GetDefault(nSID, nType)
end

---获取数据
function PlayerSetting.GetOne(nSID, nType)
    local tbValue = PlayerSetting.Get(nSID, nType)
    return tbValue[1] or 0
end

---获取默认数据
function PlayerSetting.GetDefault(nSID, nType)
    if nSID == PlayerSetting.SSID_FRAME and nType == FrameType.LEVEL then
        return {PlayerSetting.GetDefaultLevel()}
    end

    if nSID == PlayerSetting.SSID_FRAME and nType == FrameType.CUSTOM then
        return {}
    end

    if nSID == PlayerSetting.SSID_FRAME and nType == FrameType.DISPLAY then
        return {0, 1}
    end

    if nSID == PlayerSetting.SSID_LANGUAGE then
        return {0}
    end

    if var.tbDefault[nSID] and var.tbDefault[nSID][nType] then
        return var.tbDefault[nSID][nType].tbDefault
    end

    return {1}
end

function PlayerSetting.GetSliderRange(nSID, nType)
    if var.tbDefault[nSID] and var.tbDefault[nSID][nType] then
        return var.tbDefault[nSID][nType].nMin, var.tbDefault[nSID][nType].nMax
    end
end

---重置
function PlayerSetting.ResetBySID(nSID)
    local tbInfo = var.tbSave[nSID] or {}
    for k, _ in pairs(tbInfo) do
        if (nSID ~= PlayerSetting.SSID_FRAME or k ~= FrameType.DISPLAY) and PlayerSetting.IsValidType(nSID, k) then
            tbInfo[k] = PlayerSetting.GetDefault(nSID, k)
        end
    end
end

---重置
function PlayerSetting.ResetBySIDAndType(nSID, nType)
    if not PlayerSetting.IsValidType(nSID, nType) then
        return
    end

    local tbInfo = var.tbSave[nSID] or {}
    tbInfo[nType] = PlayerSetting.GetDefault(nSID, nType)
end


---获取显示名称
function PlayerSetting.GetShowName(nSID, nType)
    if var.tbDefault[nSID] and var.tbDefault[nSID][nType] then
        return var.tbDefault[nSID][nType].sName or ''
    end
    print('not find ===>', nSID, nType)
    return ''
end

function PlayerSetting.FrameIsCustom(nLevel)
    return nLevel == 6
end

function PlayerSetting.GetCustomLevel()
    return 6
end

--- 获取画面设置配置
---@param nLevel number 画面等级
function PlayerSetting.GetFrameCfg()
    return var.tbFrame
end

---获取默认画面设置
---@param nID number 
function PlayerSetting.GetFrameCheckDefaultIndex(nLevel, nID)
    return PlayerSetting.tbFrameCfg[nID].Default
end

function PlayerSetting.GetDisplayCheckDefaultIndex(nID)
    local GraphicsSetting = UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
    if nID == FrameDisplayType.RESOLUTION_SIZE then
        local vSize = GraphicsSetting:GetWindowSize()
        for i,v in ipairs(var.tbResolution) do
            if vSize.X == v.width and vSize.Y == v.height then
                return i
            end
        end
        return 1
    elseif nID == FrameDisplayType.DISPLAY_MODE then
        return GraphicsSetting:GetFullScreen()
    end
end

---获取默认适配等级
function PlayerSetting.GetDefaultLevel()
    return UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() + 1
end

---获取自定义画面设置
---@param nID number 
function PlayerSetting.GetFrameCheckIndex(nID)
    var.tbSave[PlayerSetting.SSID_FRAME][FrameType.CUSTOM] = var.tbSave[PlayerSetting.SSID_FRAME][FrameType.CUSTOM] or {}
    local tbInfo =  var.tbSave[PlayerSetting.SSID_FRAME][FrameType.CUSTOM] or {}
    local nValue =  tonumber(tbInfo[nID])
    if nValue ~= nil then
        return nValue
    end
    return PlayerSetting.GetFrameCheckDefaultIndex(PlayerSetting.GetDefaultLevel(), nID)
end

function PlayerSetting.GetDisplayCheckIndex(nID)
    var.tbSave[PlayerSetting.SSID_FRAME][FrameType.DISPLAY] = var.tbSave[PlayerSetting.SSID_FRAME][FrameType.DISPLAY] or {}
    local tbInfo =  var.tbSave[PlayerSetting.SSID_FRAME][FrameType.DISPLAY] or {}
    local nValue =  tbInfo[nID]
    if nValue ~= nil then
        return nValue
    end
    return PlayerSetting.GetDisplayCheckDefaultIndex(nID)
end

function PlayerSetting.GetFrameCheckIndexByLevel(nLevel, nID)
    if PlayerSetting.FrameIsCustom(nLevel) then
        return PlayerSetting.GetFrameCheckIndex(nID)
    end
    return PlayerSetting.GetFrameCheckDefaultIndex(nLevel, nID)
end

---自定义设置画面选择
---@param nID number
---@param nIndex number
function PlayerSetting.SetFrameCheck(nID, nIndex)
    var.tbSave[PlayerSetting.SSID_FRAME][FrameType.CUSTOM] = var.tbSave[PlayerSetting.SSID_FRAME][FrameType.CUSTOM] or {}
    var.tbSave[PlayerSetting.SSID_FRAME][FrameType.CUSTOM][nID] = nIndex
end

function PlayerSetting.SetDisplayCheck(nID, nIndex)
    var.tbSave[PlayerSetting.SSID_FRAME][FrameType.DISPLAY] = var.tbSave[PlayerSetting.SSID_FRAME][FrameType.DISPLAY] or {}
    var.tbSave[PlayerSetting.SSID_FRAME][FrameType.DISPLAY][nID] = nIndex

    -- 策划要求显示相关设置立刻生效
    local nR = PlayerSetting.GetDisplayCheckIndex(FrameDisplayType.RESOLUTION_SIZE)
    local nF = PlayerSetting.GetDisplayCheckIndex(FrameDisplayType.DISPLAY_MODE)
    SettingEvent.TriggerDisplayEvent(FrameType.DISPLAY, nR, nF)
end


local function InternalGetSave(nSID)
    return UE4.UUserSetting.GetString('PlayerSetting_' .. tostring(nSID), '')
end

local function InternalSetSave(nSID, sContent)
    return UE4.UUserSetting.SetString('PlayerSetting_' .. tostring(nSID), sContent)
end


---保存设置信息
function PlayerSetting.Save()
    if not me:IsLogined() then return end
    local tbChange = {}
    for nSID, tbData in pairs(var.tbSave) do 
        local sOld = var.bUseLocal and InternalGetSave(nSID) or me:GetStrAttribute(PlayerSetting.SGID, nSID)
        local tbOld = json.decode(sOld) or {}
        local sNew = json.encode(tbData)
        if sOld ~= sNew then
            InternalSetSave(nSID, sNew)
            me:SetStrAttribute(PlayerSetting.SGID, nSID, sNew)

            if nSID == PlayerSetting.SSID_FRAME then
                PlayerSetting.SaveFrame(tbData)
            else
                --通知游戏
                for nType, value in pairs(tbData) do
                    --- 通知改变
                    local sO = json.encode(tbOld[nType] or PlayerSetting.GetDefault(nSID, nType))
                    local sn = json.encode(value)
                    -- 进测试关卡的时候sOld会为空，如果设置的值等于默认值就不会通知，所以加个判断
                    if sO ~= sn or tbOld[nType] == null then
                        SettingEvent.Trigger(nSID, nType, value)
                        table.insert(tbChange, {id = nSID, type = nType, value = sn, default = json.encode(PlayerSetting.GetDefault(nSID, nType))})
                        print(string.format("PlayerSetting SettingChange: id = %d, type = %d, value = %s", nSID, nType, sn))
                    end
                end
            end
        end
    end
    if #tbChange > 0 then
        me:CallGS("SettingChange", json.encode(tbChange))
    end
    UE4.UUserSetting.Save()
end

---特殊处理画质设置
function PlayerSetting.SaveFrame(tbData)
    local nLevel = PlayerSetting.GetOne(PlayerSetting.SSID_FRAME, FrameType.LEVEL) or 1
    local bCustom = PlayerSetting.FrameIsCustom(nLevel)
    local sid = PlayerSetting.SSID_FRAME
    local nType = bCustom and FrameType.CUSTOM or FrameType.LEVEL
    SettingEvent.Trigger(sid, nType, tbData[nType] or PlayerSetting.GetDefault(sid, nType))
end

---打印存储信息
function PlayerSetting.Debug()
    for nSID, tbData in pairs(var.tbSave) do 
        print('SID', nSID, 'SaveInfo :', json.encode(tbData))
    end
end

---获取展示的角色卡
function PlayerSetting.GetShowCardID()
    local nId = me:Face()

    if nId > 0 then return nId end

    local Cards =  me:GetCharacterCards()
    for i = 1, Cards:Length() do
        local pCard = Cards:Get(i)
        ---版本特殊处理
        if pCard:Genre() == 1 and pCard:Detail() == 2 and pCard:Particular() == 1 and pCard:Level() == 1 then
           nId =pCard:Id()
        end
    end
   return nId
end

---背景音乐设置
function PlayerSetting.MuteMusic(bMute)
    local tbInfo = PlayerSetting.Get(PlayerSetting.SSID_SOUND, SoundType.MUSIC) or {1, 0}
    local bSaveMate = tbInfo[2] or 0
    local nSaveScale = tbInfo[1] or 1

    if bMute and (bSaveMate == 0) then
        UE4.UWwiseLibrary.SetVolumeScale('Music', 0, 1)
    else
        nSaveScale = (bSaveMate == 1) and 0 or nSaveScale
        UE4.UWwiseLibrary.SetVolumeScale('Music', nSaveScale / 100, 1)
    end 
end

---请求更换头像
function PlayerSetting.Req_ChangeRole(nID)
    local cmd = { nID = nID}
    me:CallGS("PlayerSetting_ChangeShowCard", json.encode(cmd))
end

s2c.Register("PlayerSetting_ChangeShowCard", function()
    UI.CloseByName('ChangeRole')

    if UI.GetUI("Main") then
        UI.GetUI("Main").PlayerInfo:SetFace()
    end
end)

---请求更换展示角色卡
function PlayerSetting.Req_ChangeAccountShowCard(nID, nIndex)
    local cmd = { nItemID = nID, nIndex = nIndex}
    UI.ShowConnection()
    me:CallGS("PlayerSetting_ChangeAccountShowCard", json.encode(cmd))
end
s2c.Register("PlayerSetting_ChangeAccountShowCard", function(sErr)
    UI.CloseConnection()

    if sErr ~= nil then
        UI.ShowTip(sErr)
        return
    end

    local pUI = UI.GetUI('SelectRole')
    if pUI then
        UI.Close(pUI)
        --UI.ShowTip('tip.rolefiles_pickrole')
    end
end)

--加载画面设置 
function PlayerSetting.UseFrameData()
    -- 画面只采用本地设置数据
    local sAttr = InternalGetSave(PlayerSetting.SSID_FRAME)
    local tbSet = json.decode(sAttr) or {}
    var.tbSave[PlayerSetting.SSID_FRAME] = tbSet

    local nLevel = PlayerSetting.GetOne(PlayerSetting.SSID_FRAME, FrameType.LEVEL)
    if nLevel == nil or nLevel == 0 then nLevel = PlayerSetting.GetDefaultLevel() end

    -- Init display type.
    for _,v in pairs(FrameDisplayType) do
        local nCheckIndex = PlayerSetting.GetDisplayCheckIndex(v)
        PlayerSetting.SetDisplayCheck(v, nCheckIndex)
    end

    -- Init current quality level.
    if PlayerSetting.FrameIsCustom(nLevel) then
        local tbCheck = {}
        for nType, nValue in pairs(FrameType) do
            if nValue > FrameType.DISPLAY then
                tbCheck[nValue] = PlayerSetting.GetFrameCheckIndex(nValue)
            end
        end
        SettingEvent.Trigger(PlayerSetting.SSID_FRAME, FrameType.CUSTOM, tbCheck)
    else
        SettingEvent.Trigger(PlayerSetting.SSID_FRAME, FrameType.LEVEL, {nLevel})
    end
end


---应用设置数据
function PlayerSetting.UseSettingData()
    for nSID, tbData in pairs(var.tbSave) do
        -- 画面只采用本地设置数据
        local sAttr = (var.bUseLocal or nSID == PlayerSetting.SSID_FRAME) and InternalGetSave(nSID) or me:GetStrAttribute(PlayerSetting.SGID, nSID)
        if nSID ~= PlayerSetting.SSID_SOUND then
            local tbSet = json.decode(sAttr) or {}
            var.tbSave[nSID] = tbSet
        end
    end
    
    ---操作设置
    for _, nType in pairs(OperationType) do
        local tbValue = PlayerSetting.Get(PlayerSetting.SSID_OPERATION, nType)
        SettingEvent.Trigger(PlayerSetting.SSID_OPERATION, nType, tbValue)
    end

    ---声音设置
    for _, nType in pairs(SoundType) do
        local tbValue = PlayerSetting.Get(PlayerSetting.SSID_SOUND, nType)
        SettingEvent.Trigger(PlayerSetting.SSID_SOUND, nType, tbValue)
    end    

    ---其他设置
    for _, nType in pairs(OtherType) do
        local tbValue = PlayerSetting.Get(PlayerSetting.SSID_OTHER, nType)
        SettingEvent.Trigger(PlayerSetting.SSID_OTHER, nType, tbValue)
    end
end

-- 设置存储的声音数据
function PlayerSetting.UseSoundData(bLoadSavedData)
    local nSID = PlayerSetting.SSID_SOUND

    if bLoadSavedData then
        local tbSoundLanguage = var.tbSave[nSID] and var.tbSave[nSID][SoundType.LANGUAGE] or {0,0}
        if (var.tbSave[nSID] == nil or #var.tbSave[nSID] == 0) then 
            var.tbSave[nSID] = json.decode(InternalGetSave(nSID)) or {}
        end
        var.tbSave[nSID][SoundType.LANGUAGE] =  tbSoundLanguage
    end

    for _, nType in pairs(SoundType) do
        local tbValue = PlayerSetting.Get(nSID, nType)
        SettingEvent.Trigger(nSID, nType, tbValue)
    end    
end

---初始化设置
function PlayerSetting.OnLogin()
    if not var.bUseLocal then
        PlayerSetting.UseSettingData()
    end
    PlayerSetting.UseKeyboardServerSetting()
 end

 function PlayerSetting.OnStart()
    if var.bUseLocal or not RunFromEntry then
        PlayerSetting.UseSettingData()
    end
    PlayerSetting.UseFrameData()
 end

function PlayerSetting.UseKeyboardServerSetting()
    local cfg = me and me:GetStrAttribute(PlayerSetting.GID,PlayerSetting.SSID_KEYBOARD)
    if cfg then
        local tb = json.decode(cfg)
        PlayerSetting.tbKeyBoardSetting = tb;
    end
end

 function PlayerSetting.SetKeyboardBind(InKey, KeyName, needSave, nInputType)
    if not PlayerSetting.tbKeyBoardSetting then PlayerSetting.tbKeyBoardSetting = {} end
    PlayerSetting.tbKeyBoardSetting[InKey] = PlayerSetting.tbKeyBoardSetting[InKey] or {}
    PlayerSetting.tbKeyBoardSetting[InKey][tostring(nInputType)] = KeyName
    if needSave then
        PlayerSetting.SaveKeyboardBind()
    end
 end

 function PlayerSetting.GetKeybordBind(InKey, nInputType)
    if not InKey or InKey == '' then return '' end
    if not PlayerSetting.tbKeyBoardSetting then PlayerSetting.tbKeyBoardSetting = {} end
    local sRet = ""
    if PlayerSetting.tbKeyBoardSetting[InKey] then
        local keyName = PlayerSetting.tbKeyBoardSetting[InKey][tostring(nInputType)]
        sRet = keyName or '';
    end
    return sRet
 end

function PlayerSetting.ClearKeyboardBind(nInputType)
    if not nInputType then return end
    PlayerSetting.tbKeyBoardSetting = PlayerSetting.tbKeyBoardSetting or {}
    for _, value in pairs(PlayerSetting.tbKeyBoardSetting or {}) do
        if value then
            value[tostring(nInputType)] = nil
        end
    end
end

function PlayerSetting.GetDefaultHandleData(nTypeID, nLevel)
    if PlayerSetting.tbHandleCfg[nTypeID] then
        local typeInfo = PlayerSetting.tbHandleCfg[nTypeID]
        if typeInfo.Standard then
            return typeInfo.Standard[nLevel + 1]
        end
    end
    return -1
end

function PlayerSetting.GetAdapterResolution(vScreenSize)
    local tbAdapter = {}
    for i,v in ipairs(var.tbResolution) do
        if v.width <= vScreenSize.X and v.height <= vScreenSize.Y then
            table.insert(tbAdapter, v)
        end 
    end
    return tbAdapter
end

 function PlayerSetting.SaveKeyboardBind()
    local old = me and me:GetStrAttribute(PlayerSetting.GID,PlayerSetting.SSID_KEYBOARD)
    local new = json.encode(PlayerSetting.tbKeyBoardSetting)
    if me and new ~= old then
        me:SetStrAttribute(PlayerSetting.GID,PlayerSetting.SSID_KEYBOARD,new)
    end
 end

 function PlayerSetting.GetResolution(nIndex)
    if nIndex == 0 then
        local GraphicsSetting = UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
        return GraphicsSetting:GetMaxWindowSize()
    end
    local tb = var.tbResolution[nIndex]
    return UE4.FIntPoint(tb.width, tb.height)
 end

 function PlayerSetting.GetConnect(data)
    if data then
        local ret = {}
        local tb = Split(data, ",")
        for _,v in ipairs(tb) do
            local temp = Split(v, "|")
            local idx = tonumber(temp[2])
            if not ret[idx] then
                ret[idx] = {}
            end
            table.insert(ret[idx], tonumber(temp[1]))
        end
        return ret
    end
 end

 function PlayerSetting.GetCustomizeCfg()
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    local nSelect = math.max(UE4.UUserSetting.GetInt(PlayerSetting.GetCustomizeSelectKey(nActionMode)), 1)
    local tbData = {}
    for i=1,3 do
        local sData = UE4.UUserSetting.GetString(PlayerSetting.GetCustomizeKey(nActionMode, i))
        tbData[i] = json.decode(sData) or {}
    end
    return tbData, nSelect
 end

 function PlayerSetting.SaveCustomizeSelect(nSelect)
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    UE4.UUserSetting.SetInt(PlayerSetting.GetCustomizeSelectKey(nActionMode), nSelect)
    UE4.UUserSetting.Save()
 end

 function PlayerSetting.GetCurrentCustomizeCfg()
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    local nSelect = math.max(UE4.UUserSetting.GetInt(PlayerSetting.GetCustomizeSelectKey(nActionMode)), 1)
    local sData = UE4.UUserSetting.GetString(PlayerSetting.GetCustomizeKey(nActionMode, nSelect))

    if sData == "" then
        local nRatio = PlayerSetting.GetWindowRatio()
        if PlayerSetting.tbCustomizeTemplate[nActionMode] and PlayerSetting.tbCustomizeTemplate[nActionMode][nSelect] then
            sData = PlayerSetting.tbCustomizeTemplate[nActionMode][nSelect][nRatio]
        end
    end
    return sData
 end

 function PlayerSetting.GetCurrentTemplateCfg()
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    local nSelect = math.max(UE4.UUserSetting.GetInt(PlayerSetting.GetCustomizeSelectKey(nActionMode)), 1)
    local sData = nil
    local nRatio = PlayerSetting.GetWindowRatio()
    if PlayerSetting.tbCustomizeTemplate[nActionMode] and PlayerSetting.tbCustomizeTemplate[nActionMode][nSelect] then
        sData = PlayerSetting.tbCustomizeTemplate[nActionMode][nSelect][nRatio]
    end
    return sData
 end

 function PlayerSetting.GetCustomizeCfgNameByIndex(nIndex)
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    local sName = UE4.UUserSetting.GetString(PlayerSetting.GetCustomizeNameKey(nActionMode, nIndex))
    return sName
 end

 function PlayerSetting.CoverCustomizeCfgByIndex(nIndex, sName)
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    UE4.UUserSetting.SetString(PlayerSetting.GetCustomizeNameKey(nActionMode, nIndex), sName)
    UE4.UUserSetting.Save()
 end

 function PlayerSetting.CoverCurrentCustomizeCfg(sData, sTempData)
    local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    local nSelect = math.max(UE4.UUserSetting.GetInt(PlayerSetting.GetCustomizeSelectKey(nActionMode)), 1)
    UE4.UUserSetting.SetString(PlayerSetting.GetCustomizeKey(nActionMode, nSelect), sData)
    UE4.UUserSetting.Save()
    
    print('=============================>', sTempData)
 end

 function PlayerSetting.GetCustomizeKey(nActionMode, nSelect)
    return me:Id()..'_Customize'..nActionMode..'_'..nSelect
 end
 function PlayerSetting.GetCustomizeNameKey(nActionMode, nSelect)
    return me:Id()..'_CustomizeName'..nActionMode..'_'..nSelect
 end
 function PlayerSetting.GetCustomizeSelectKey(nActionMode)
    return me:Id()..'_CustomizeSelect'..nActionMode
 end

function PlayerSetting.GetWindowRatio()
    local GraphicsSetting = UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
    local vSize = GraphicsSetting:GetWindowSize()
    if vSize.X / vSize.Y >= 1.55 then
        return 1
    else
        return 2
    end
end

function PlayerSetting.GetConfigTable(nSID)
    local tbCfg = {}
    local tbSort = {}
    if nSID == PlayerSetting.SSID_OPERATION then
        tbCfg = PlayerSetting.tbOperationCfg
        tbSort = PlayerSetting.tbOperationSort
    elseif nSID == PlayerSetting.SSID_FRAME then
        tbCfg = PlayerSetting.tbFrameCfg
        tbSort = PlayerSetting.tbFrameSort
    elseif nSID == PlayerSetting.SSID_SOUND then
        tbCfg = PlayerSetting.tbSoundCfg
        tbSort = PlayerSetting.tbSoundSort
    elseif nSID == PlayerSetting.SSID_OTHER then
        tbCfg = PlayerSetting.tbOtherCfg
        tbSort = PlayerSetting.tbOtherSort
    elseif nSID == PlayerSetting.SSID_NOTIFICATION then
        tbCfg = PlayerSetting.tbNoticeCfg
        tbSort = PlayerSetting.tbNoticeSort
    elseif nSID == PlayerSetting.SSID_LANGUAGE then
        tbCfg = PlayerSetting.tbLangCfg
        tbSort = PlayerSetting.tbLangSort
    elseif nSID == PlayerSetting.SSID_HANDLE then
        tbCfg = PlayerSetting.tbHandleCfg
        tbSort = PlayerSetting.tbHandleSort
    end
    return tbCfg, tbSort
end

function PlayerSetting.GetTypesByCategory(nSID, nContentType)
    local _, tbCfg = PlayerSetting.GetConfigTable(nSID)
    local tb = {}
    for i,v in ipairs(tbCfg) do
        if Contains(v.Category, nContentType) then
            table.insert(tb, v.Type)
        end
    end
    return tb
end

function PlayerSetting.InitWidget(SID, Widget, tbCfg, tbFunc, tbWidgets)
    if tbCfg.ClassType < 2 then
        local tb = tbCfg.Items or {'close', 'open'}
        local nValue = PlayerSetting.GetOne(SID, tbCfg.Type) or 0
        local check = tbCfg.Multi and nValue or math.min(nValue, #tb - 1) 
        Widget:Set({ tbData = {0, tbCfg.Name, tb}, nCheckIndex = check, fOnChange = function(nIndex)
            if tbCfg.Connect then
                for k,tb in pairs(tbCfg.Connect) do
                    if tbWidgets[k] then
                        local bDisable = false
                        for _,v in ipairs(tb) do
                            bDisable = bDisable or (v == nIndex)
                        end
                        if tbWidgets[k].Disable then
                            tbWidgets[k]:Disable(bDisable)
                        end
                    end
                end
            end
            if not tbCfg.CustomChange then
                PlayerSetting.Set(SID, tbCfg.Type, {nIndex})
            end
            if tbFunc and tbFunc[tbCfg.Type] then
                tbFunc[tbCfg.Type](nIndex, tbCfg)
            end
        end, bMulti = tbCfg.Multi, tip = tbCfg.BanTip})
    elseif tbCfg.ClassType == 2 then
        local nMin, nMax = PlayerSetting.GetSliderRange(SID, tbCfg.Type)
        Widget:Init(SID, tbCfg.Type, nMin, nMax, tbCfg.BanTip, tbFunc and tbFunc[tbCfg.Type] or nil)
    elseif (tbCfg.ClassType == 3 or tbCfg.ClassType == 5) and tbFunc then
        local text = tbCfg.Items and tbCfg.Items[1] or tbCfg.Name
        local icon = tbCfg.Items and tbCfg.Items[2] or nil
        local platform = tbCfg.Items and tbCfg.Items[3] or nil

        local URL = tbCfg.Url
        if Login and Login.IsOversea() and tbCfg.OverSeaUrl and tbCfg.OverSeaUrl ~= '' then
            URL = tbCfg.OverSeaUrl
        end
        Widget:Set({Cfg = {sName = tbCfg.Name, sText = text, sUrl = URL, nType = tbCfg.Type, bExternal = tbCfg.External, nIconId = icon, sPlatform = platform}, pFunc = tbFunc[tbCfg.Type]})
    elseif tbCfg.ClassType == 4 then
        Widget:OnActive()
    end
end

function PlayerSetting.IsPageContent(tbCfg, isPc, ContentType)
    local bVisable = not tbCfg.Hidden
    if tbCfg.Platform ~= 0 then
        if isPc then
            bVisable = bVisable and tbCfg.Platform == 1
        else
            bVisable = bVisable and tbCfg.Platform == 2
        end
    end

    local IsOversea = Login.IsOversea()
    if (IsOversea and tbCfg.Oversea == 1) or (not IsOversea and tbCfg.Oversea == 2) or tbCfg.Oversea == 0 then
        bVisable = bVisable
    else
        bVisable = false;
    end

    local ret = false;
    for _,v in pairs(ContentType) do
        ret = ret or Contains(tbCfg.Category, v)
    end
    return bVisable and ret
end

function PlayerSetting.IsValidType(nSID, nType)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    local tbCfg = PlayerSetting.GetConfigTable(nSID)

    local cfg = tbCfg[nType]
    if cfg then
        local bVisable = not cfg.Hidden
        if cfg.Platform ~= 0 then
            if IsPc then
                bVisable = bVisable and cfg.Platform == 1
            else
                bVisable = bVisable and cfg.Platform == 2
            end
        end


        local IsOversea = Login.IsOversea()
        if (IsOversea and cfg.Oversea == 1) or (not IsOversea and cfg.Oversea == 2) or cfg.Oversea == 0 then
            bVisable = bVisable
        else
            bVisable = false;
        end
        
        return bVisable
    end
    return false;
end

function PlayerSetting.CheckConnect(nSID, tbWidgets)
    local _, tb = PlayerSetting.GetConfigTable(nSID)
    for _,v in ipairs(tb) do
        if v.Connect then
            local nValue = PlayerSetting.GetOne(nSID, v.Type)
            for k,tb in pairs(v.Connect) do
                if tbWidgets[k] then
                    local bDisable = false
                    for _,v in ipairs(tb) do
                        bDisable = bDisable or (v == nValue)
                    end

                    if tbWidgets[k].Disable then
                        tbWidgets[k]:Disable(bDisable)
                    end
                    WidgetUtils.SelfHitTestInvisible(tbWidgets[k].ImgItem)
                end
            end
        end
    end
end

 function PlayerSetting.Load()
    ---加载默认设置
    PlayerSetting.tbOperationCfg = {}
    PlayerSetting.tbOperationSort = {}

    PlayerSetting.tbFrameCfg = {}
    PlayerSetting.tbFrameSort = {}

    PlayerSetting.tbSoundCfg = {}
    PlayerSetting.tbSoundSort = {}

    PlayerSetting.tbOtherCfg = {}
    PlayerSetting.tbOtherSort = {}

    PlayerSetting.tbNoticeSort = {}
    PlayerSetting.tbNoticeCfg = {}

    PlayerSetting.tbLangSort = {}
    PlayerSetting.tbLangCfg = {}

    PlayerSetting.tbHandleSort = {}
    PlayerSetting.tbHandleCfg = {}

    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    local tbInfo = LoadCsv("setting/default.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local nSID      =           tonumber(tbLine.sid) or 0
        local nType     =           tonumber(tbLine.type) or 0
        local min       =           tonumber(tbLine.min) or 0
        local max       =           tonumber(tbLine.max) or 100
        local tbDefault =           (IsMobile() and Eval(tbLine.default_mobile or tbLine.default) or Eval(tbLine.default)) or {}
        if type(tbDefault) ~= 'table' then
            tbDefault = {tbDefault}
        end

        var.tbDefault[nSID] =  var.tbDefault[nSID] or {}
        var.tbDefault[nSID][nType] = {
            tbDefault       =       tbDefault,
            sName           =       string.format('setting.%s', tbLine.name),
            nMax            =       max,
            nMin            =       min
        }
        
        local sItems = tbLine.items
        if IsPc and tbLine.pcitems then
            sItems = tbLine.pcitems
        end

        if tbLine.name then
            local tb = {
                Type = nType,
                Name = tbLine.name,
                ClassType = (IsPc and tonumber(tbLine.pcclass_type) or tonumber(tbLine.class_type)) or 0,
                Category = tbLine.category and SplitAsNumberTab(tbLine.category, ',') or {0},
                Items = sItems and Split(sItems, ",") or nil,
                Platform = tonumber(tbLine.platform) or 0,
                Connect = PlayerSetting.GetConnect(tbLine.connect),
                BanTip = tbLine.bantip,
                Hidden = tbLine.hidden and true or false,
                Multi = tbLine.multi and true or false,
                Standard = tbLine.standard and SplitAsNumberTab(tbLine.standard, ',') or nil,
                Reference = tonumber(tbLine.reference) or 0,
                Default = tonumber(tbLine.default) or 0,
                Url = tbLine.url,
                OverSeaUrl = tbLine.overseaurl,
                External = tbLine.external and true or false,
                Oversea = tonumber(tbLine.oversea) or 0,
                CustomChange = tbLine.customChange and true or false
            }

            if nSID == PlayerSetting.SSID_OPERATION then
                PlayerSetting.tbOperationCfg[nType] = tb
                table.insert(PlayerSetting.tbOperationSort, tb)
            end
    
            if nSID == PlayerSetting.SSID_FRAME then
                PlayerSetting.tbFrameCfg[nType] = tb
                table.insert(PlayerSetting.tbFrameSort, tb)
            end
    
            if nSID == PlayerSetting.SSID_SOUND then
                PlayerSetting.tbSoundCfg[nType] = tb
                table.insert(PlayerSetting.tbSoundSort, tb)
            end
    
            if nSID == PlayerSetting.SSID_OTHER then
                PlayerSetting.tbOtherCfg[nType] = tb
                table.insert(PlayerSetting.tbOtherSort, tb)
            end
    
            if nSID == PlayerSetting.SSID_NOTIFICATION then
                PlayerSetting.tbNoticeCfg[nType] = tb
                table.insert(PlayerSetting.tbNoticeSort, tb)
            end

            if nSID == PlayerSetting.SSID_LANGUAGE then
                PlayerSetting.tbLangCfg[nType] = tb
                table.insert(PlayerSetting.tbLangSort, tb)
            end

            if nSID == PlayerSetting.SSID_HANDLE then
                PlayerSetting.tbHandleCfg[nType] = tb
                table.insert(PlayerSetting.tbHandleSort, tb)
            end
        end
    end


    

    if var.tbDefault[PlayerSetting.SSID_FRAME] then
        var.tbDefault[PlayerSetting.SSID_FRAME][FrameType.LEVEL] = PlayerSetting.GetDefaultLevel()
    end

    local tbResolution = LoadCsv("setting/resolution.txt", 1)
    for i, tbLine in ipairs(tbResolution) do
        local width      =           tonumber(tbLine.Width) or 0
        local height     =           tonumber(tbLine.Height) or 0
        table.insert(var.tbResolution, {id = i, width = width, height = height})
    end

    local tbInfo = LoadCsv("setting/customize.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local nId         =           tonumber(tbLine.id) or 0
        local nAction     =           tonumber(tbLine.action) or 0
        local nTemplateId     =       tonumber(tbLine.templateID) or 0
        local nRatio          =       tonumber(tbLine.ratio) or 1
        local sData      =            tbLine.data

        if not PlayerSetting.tbCustomizeTemplate[nAction] then PlayerSetting.tbCustomizeTemplate[nAction] = {} end
        if not PlayerSetting.tbCustomizeTemplate[nAction][nTemplateId] then PlayerSetting.tbCustomizeTemplate[nAction][nTemplateId] = {} end
        PlayerSetting.tbCustomizeTemplate[nAction][nTemplateId][nRatio] = sData
    end
 end

 PlayerSetting.Load()
 
---登录初始化
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if me == nil then return end
    if bReconnected then return end

    if CLIENT == false then return end

    PlayerSetting.OnLogin()

    if UE4.UGMLibrary.IsEditor() then
        UE4.UUserSetting.SetString('LoginId', me:Id())
        UE4.UUserSetting.Save()
    end

    UE4.UCrashEyeHelper.CrashEyeSetUserIdentifier(tostring(me:Id()));
    print(string.format("login ok: %s-%d", me:AccountId(), me:Id()));
    UE4.UGameKeyboardLibrary.LoadSetting(false)
    UE4.UGamepadLibrary.UseGamepadSetting()

    -- 功能导致性能问题，先回退
    local GraphicsSetting = UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
    if GraphicsSetting and GraphicsSetting.WritpeThingsWhenPlayLogin then
        GraphicsSetting:WriteThingsWhenPlayLogin()
    end

    if GraphicsSetting then
        -- FPS的支持判断
        local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
        if not IsPc then
            local tbSupport = {}
            for _, v in ipairs(PlayerSetting.tbFrameCfg[FrameType.FPS].Items or {}) do
                local nFPS = Text('setting.'..v)
                nFPS = tonumber(nFPS)
                if nFPS and GraphicsSetting:SupportsFramePace(nFPS) then
                    table.insert(tbSupport, v)
                end
            end
            PlayerSetting.tbFrameCfg[FrameType.FPS].Items = tbSupport
            -- 适配一下渲染需求
            if #tbSupport <= 2 then
                PlayerSetting.tbFrameCfg[FrameType.FPS].ClassType = 0
            end
        end
    end

    Localization.CheckLanguageTip()
end)

EventSystem.On(Event.Start, function()
    if CLIENT then
        PlayerSetting.OnStart()
    end
 end, true)

 EventSystem.On(Event.Shutdown, function()
    if CLIENT then
        --PlayerSetting.Save()
    end
 end)

 EventSystem.On(Event.InitUseFrameData, function()
    if CLIENT then
        PlayerSetting.UseFrameData()
    end
 end)

 EventSystem.On(Event.OnToggleFullscreen, function (InFullScreen)
     PlayerSetting.SetDisplayCheck(FrameDisplayType.DISPLAY_MODE, InFullScreen)
     local top = UI.GetTop()
     if top and top.TryRefreshFrame then 
        top:TryRefreshFrame() 
     end
 end)

