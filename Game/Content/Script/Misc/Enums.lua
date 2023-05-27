-- ========================================================
-- @File    : Enums.lua
-- @Brief   : 常用枚举定义
-- @Author  : Leo Zhao
-- @Date    : 2019-12-03
-- ========================================================

--- 对Unreal的碰撞类型简写
Trace = {
    Static          = UE4.ECollisionChannel.WorldStatic,
    Dynamic         = UE4.ECollisionChannel.WorldDynamic,
    Pawn            = UE4.ECollisionChannel.Pawn,
    Visibility      = UE4.ECollisionChannel.Visibility,
    Camera          = UE4.ECollisionChannel.Camera,
    Physics         = UE4.ECollisionChannel.PhysicsBody,
    Vehicle         = UE4.ECollisionChannel.Vehicle,
    Destructible    = UE4.ECollisionChannel.Destructible,

    Bullet          = UE4.ECollisionChannel.Bullet,
};

--- 事件类型
Event = {
    -- C++触发事件
    Start                       = "Start",                      -- App启动
    Shutdown                    = "Shutdown",                   -- App停止运行
    Logined                     = "Logined",                    -- 登录成功
    LoginFail                   = "LoginFail",                  -- 登录失败
    Kickout                     = "Kickout",                    -- 强制下线事件
    GetVersion                  = "GetVersion",                 -- 获取版本的返回
    FaceChanged                 = "FaceChanged",                -- 头像变更
    LevelUp                     = "LevelUp",                    -- 升级
    ExpChanged                  = "ExpChanged",                 -- 经验变更
    VigorChanged                = "VigorChanged",               -- 体力变更
    MoneyChanged                = "MoneyChanged",               -- 比特金变更
    VIPChanged                  = "VIPChanged",                 -- VIP等级变更
    Charged                     = "Charged",                    -- 充值统计变更
    VigorTime                   = "VigorTime",                  -- 最近一次体力恢复时间变更
    CustomAttr                  = "CustomAttr",                 -- 自定义属性（任务变量）变化
    ItemChanged                 = "ItemChanged",                -- 道具变化
    OnHealthChange              = "OnHealthChange",             -- 角色血量变化
    CharacterDeath              = "CharacterDeath",             -- 角色死亡
    CharacterFlyHP              = "CharacterFlyHP",             -- 伤害跳字
    CharacterBegin              = "CharacterBegin",             -- 角色BeginPlay
    CharacterEnd                = "OnCharacterEnd",             -- 角色EndPlay
    ConnectResult               = "ConnectResult",              -- 与服务器连接结果
    CharacterSpawned            = "CharacterSpawned",           -- 角色Spwaned
    CharacterChange             = "CharacterChange",            -- 角色改变
    SkillAimTarget              = "SkillAimTarget",             -- 技能锁定目标
    AISwitchTarget              = "AISwitchTarget",             -- AI切换目标
    ControlProtectionRefresh    = "ControlProtectionRefresh",   -- 控制保护角色控制状态更新
    AITargetFirstAdd            = "AITargetFirstAdd",           -- AI第一次进入仇恨添加目标
    CharacterLeave              = "CharacterLeave",             -- 怪物离场
    GameSkillEnd                = "GameSkillEnd",               -- 技能结束
    FightPlayerBackSkill        = "FightPlayerBackSkill",       -- 技能结束
    AppliedModifierChange       = "AppliedModifierChange",     -- Modifier改变
    UpdateLineup                = "UpdateLineup",               -- 更新编队信息
    ConnectBreaken              = "ConnectBreaken",             -- 连接断开了
    ReconnectSuccess            = "ReconnectSuccess",           -- 断线重连成功
    ReloginFail                 = "ReloginFail",                -- 重连登录失败
    DamageReceive               = "DamageReceive",              -- 造成伤害
    PartBreak                   = "PartBreak",                  -- 部位破坏
    LoginParamReady             = "LoginParamReady",            -- 登录参数准备完成
    MouseButtonDown             = "MouseButtonDown",            -- 鼠标按下
    MouseButtonUp               = "MouseButtonUp",              -- 鼠标抬起
    MouseMove                   = "MouseMove",                  -- 鼠标抬起
    PauseGame                   = "PauseGame",                  -- 暂停游戏
    GamepadReturn               = "GamepadReturn",              -- 手柄返回
    Rename                      = "Rename",                     -- 重命名
    FaceFrame                   = "FaceFrame",                  -- 头像框更改
    Sign                        = "Sign",                       -- 个性签名更改
    ReloginSuccess              = "ReloginSuccess",             -- 重连登录成功
    SyncMail                    = "SyncMail",                   -- 服务器下发邮件
    OnGMCastSkill               = "OnGMCastSkill",              -- GM技能释放
    OnSkillCast                 = "OnSkillCast",                -- 技能释放
    OnSkillEnd                  = "OnSkillEnd",                 -- 技能结束
    OnSkillCastCD               = "OnSkillCastCD",              -- 技能释放后进入CD（USkillCDComponent中触发，仅在技能释放后触发，不包含共享CD，Tag触发CD等）
    OnGMEmitterSearch           = "OnGMEmitterSearch",          -- GM Emitter 查找 
    OnWorldFinishDestroy        = "OnWorldFinishDestroy",       -- 切换场景
    TeamCreated                 = "TeamCreated",                -- 队伍创建
    TeamDestroyed               = "TeamDestroyed",              -- 队伍销毁
    OnEnmity                    = "OnEnmity",                   -- 仇恨产生
    EmitterEnd                  = "EmitterEnd",                 -- Emitter结束
    PlayerAimTarget             = "PlayerAimTarget",            -- 玩家瞄准目标改变通知
    GMAttackMonitor             = "GMAttackMonitor",            -- GM攻击伤害监测
    AITeamMemberChanged         = "AITeamMemberChanged",        -- AiTeam的数量发生变化
    AIFirstInFight              = "AIFirstInFight",             -- AI第一次进入战斗时通知
    AITargetChanged             = "AITargetChanged",            -- AI目标改变通知
    GetRecord                   = "GetRecord",                  -- 获取玩家记录的返回
    PCKeyboardEvent             = "PCKeyboardEvent",             -- 玩家键盘操作事件
    PCKeyboardFailEvent         = "PCKeyboardFailEvent",        -- 玩家键盘操作失败事件
    QRCodeChanged               = "OnQRCodeChanged",            -- PC端扫描登录，二维码已经更改
    QRCodeStatus                = "OnQRCodeStatus",             -- PC端扫描登录，扫码状态已经更新
    CleanBroadcast              = "CleanBroadcast",             -- 清除全服通告
    UpdateBroadcast             = "UpdateBroadcast",            -- 新的全服通告
    SetShowFlag                 = "SetShowFlag",                -- 通过画质管理器修改ShowFlag值
    RestoreShowFlag             = "RestoreShowFlag",            -- 通过画质管理器恢复ShowFlag值
    NextBulletChange            = "NextBulletChange",           -- Modifier下X颗子弹改变
    OnRecycleBullet             = "OnRecycleBullet",            -- 子弹回收事件
    ChangeAmmunitionUI          = "ChangeAmmunitionUI",         -- 修改准心、弹夹UI
    LevelSuccessShow            = "LevelSuccessShow",           -- 关卡成功时播结算特效
    AppWillDeactivate           = "AppWillDeactivate",          -- 应用进入后台
    AppHasReactivated           = "AppHasReactivated",          -- 应用进入前台
    ShowSpecialFightUI          = "ShowSpecialFightUI",         -- 显示特殊战斗UI
    FightBloodBarReady          = "FightBloodBarReady",         -- 战斗血条准备好了
    OnReleaseInput              = "OnReleaseInput",             -- 释放按键操作
    LanguageChange              = "LanguageChange",             -- 语言变化
    OnToggleFullscreen          = "OnToggleFullscreen",         -- 全屏变化
    InitUseFrameData            = "InitUseFrameData",           -- 画质等级初始化
    AIDeathBeKillZone           = "AIDeathBeKillZone",          -- 被KillZone Trigger杀死
    DestructibleDead            = "DestructibleDead",           -- 部件被破坏（参数1 Actor的Tags)
    ElemExplosion               = "ElemExplosion",              -- 触发元素爆发
    StopSpecializationSkill     = "StopSpecializationSkill",    -- 阻断特化技能
    IBShopBuyGoods              = "IBShopBuyGoods",             -- IB商店购买商品成功
    BannerCheck                 = "BannerCheck",                -- 检查Banner刷新
    LogOutCallBack              = "LogOutCallBack",             -- 注销回调

    -- 好友相关
    OnNewFriend         = "OnNewFriend",                -- 新增好友
    OnDelFriend         = "OnDelFriend",                -- 下发删除好友
    OnRemoveFriend      = "OnRemoveFriend",             -- 主动删除好友的返回
    OnNewFriendRequest  = "OnNewFriendRequest",         -- 下发的新好友申请
    OnNotifyFriendVigor = "OnNotifyFriendVigor",        -- 下发好友体力
    OnNotifyBlackList   = "OnNotifyBlackList",          -- 下发黑名单信息
    GetFriendRecommend  = "GetFriendRecommend",         -- 推荐玩家的返回
    OnFindPlayer        = "OnFindPlayer",               -- 查找玩家的返回
    OnSendFriendReq     = "OnSendFriendReq",            -- 发送好友申请的返回
    OnAgreeFriendReq    = "OnAgreeFriendReq",           -- 同意好友申请的返回
    OnRefuseFriendReq   = "OnRefuseFriendReq",          -- 拒绝好友申请的返回
    OnGiveFriendVigor   = "OnGiveFriendVigor",          -- 赠送好友体力的返回
    OnRecvFriendVigor   = "OnRecvFriendVigor",          -- 收取好友体力的返回
    OnAddBlackList      = "OnAddBlackList",             -- 添加黑名单的返回
    OnDelBlackList      = "OnDelBlackList",             -- 移除黑名单的返回

    -- 联机相关
    OnRspRoomStart      = "OnRspRoomStart",             -- RoomStart
    OnlineEvent         = "OnlineEvent",                -- 联机数据相关通知
    OnWaitAutoRevive    = "OnWaitAutoRevive",           -- 自动复活提示
    RefreshPlayerState  = "RefreshPlayerState",         -- 玩家数据刷新
    RefreshRandomBufferes  = "RefreshRandomBufferes",         -- 玩家购买Buffer刷新数据
    OnMultiLevelMoneyChange = "OnMultiLevelMoneyChange",   --玩家联机代币数据更新
    OnMultiLevelPointChange = "OnMultiLevelPointChange",   --玩家联机积分数据更新
    NotifyReviveCountChanged    = "NotifyReviveCountChanged";       -- 通知复活次数改变时
    NotifyReviveTimeChange      = "NotifyReviveTimeChange";         -- 通知复活币使用时间改变时
    OnCharacterReviveEnd        = "OnCharacterReviveEnd";           -- 通知角色复活结束（通过角色状态机发出）
    OnAddReviveHelper           = "OnAddReviveHelper";              -- 通知增加角色复活器
    OnRemoveReviveHelper        = "OnRemoveReviveHelper";           -- 通知移除角色复活器
    NotifyBufferShopState       = "NotifyBufferShopState";          -- 通知联机商店状态
    NotifyBufferShopSyncEnd     = "NotifyBufferShopSyncEnd";        -- 通知联机商店同步完成（断线重连时）
    NotifyBufferShopHideTip     = "NotifyBufferShopHideTip",        -- 通知交互联机商店
    ShowReviveTime              = "ShowReviveTime",                 -- 显示复活时间
    HideReviveTime              = "HideReviveTime",                 -- 隐藏复活时间
    NotifyTeammateDeathBegin    = "NotifyTeammateDeathBegin";       -- 通知队友开始
    NotifyTeammateDeathEnd      = "NotifyTeammateDeathEnd";         -- 通知队友死亡结束
    NotifyShowMsg               = "NotifyShowMsg";                  -- 通知显示消息
    NotifySelfCharacterDie      = "NotifySelfCharacterDie";         -- 通知自己角色死亡

    GetPlayerProfile  = "GetPlayerProfile",         -- 获取玩家信息
    
    -- UI相关事件[1001, 2000]
    UIOpen              = "UIOpen",                     -- 打开UI
    UIClose             = "UIClose",                    -- 关闭UI
    UIMessage           = "UIMessage",                  -- 显示简单提示信息
    UIGuideEnd          = "UIGuideEnd",                 -- 引导结束
    UICreateSkill       = "UICreateSkill",              -- 通知UI创建技能操作按钮
    ScreenOrientation   = "ScreenOrientation",          -- 屏幕翻转
    FightTip            = "FightTip",                   -- 战斗提示信息显示
    RoleOffShow         = "RoleOffShow",                -- 选中升级角色卡时关闭展示角色
    SignDay             = "SignDay",                    -- 登陆界面打脸签到
    ShortSign           = "ShortSign",                  -- 短签
    ActivityFace        = "ActivityFace",               -- 活动公告打脸图
    ActivityNotice      = "ActivityNotice",             -- 公告打脸图
    ShowQuestionaire    = "ShowQuestionaire",	        -- 是否显示问卷入口按钮，传入一个bool
    HideWeapon          = "HideWeapon",                 -- 预览模型是否显示武器
    OnWarningTip        = "OnWarningTip",               -- 主角预警事件
    OnLevelPathEndTip   = "OnLevelPathEndTip",          -- 引导线终点提示
    OnFightActorPositionTips = "OnFightActorPositionTips",-- 目标位置提示时间
    ShowPlayerMessage   = "ShowPlayerMessage",          -- 呼出角色提示消息，服务器返回报错等
    ExchangeSuc         = "ExchangeSuc",                -- 道具兑换成功
    GMCallServer        = "GMCallServer",               -- GM调用服务器代码
    PreviewModelUIEvent  = "PreviewModelUIEvent",       -- 预览模型的UI事件
    SdkExchangeResult   = "OnExchangeGift",             -- 礼包码对换结果
    GetBoxItem          = "GetBoxItem" ,                -- 获得道具箱内物品
    OWExploreAwardSync  = "OWExploreAwardSync",         -- 更新探索度奖励面包
    NotifyShopData      = "NotifyShopData",             -- 商店数据返回
    NotifyShopRefresh   = "NotifyShopRefresh",          -- 商店数据刷新
    NotifyRefreshOWTask  = "NotifyRefreshOWTask",       -- 通知刷新开放世界任务
    ShowItemNumChange   = "ShowItemNumChange"   ,       -- 测试
    DeviceBack          = "DeviceBack",                 -- 返回
    OnSdkLogout         = "OnSdkLogout",                -- sdk状态下，账号登出
    AntiAddiction       = "AntiAddiction",              -- 防沉迷相关通知
    SdkPaySuccess       = "SdkPaySuccess",
    SdkPayFail          = "SdkPayFail",
    SdkPayCancel        = "SdkPayCancel",
    SdkPayProgress      = "SdkPayProgress",
    SdkPayOthers        = "SdkPayOthers",
    OnGetSdkAccountInfo        = "OnGetSdkAccountInfo",
    SdkBindAccountSuccess = "SdkBindAccountSuccess",    --绑定账号成功
    SdkBindAccountFail = "SdkBindAccountFail",          --绑定账号失败
    ConfimCloseApp      = "ConfimCloseApp",
    UIOpenToCpp         = "UIOpenToCpp",                -- 打开UI，触发C++层事件
    OnGMCategorySelect  = "OnGMCategorySelect",          -- 选中GM类别
    OnFragmentStroyInteractFinish = "OnFragmentStroyInteractFinish", --碎片化叙事交互完成
    OpenOrCloseBuffDesc = "OpenOrCloseBuffDesc",               -- 打开或关闭buff的效果说明弹出框
    OnMessageTipsEnd    = "OnMessageTipsEnd",           -- 弹窗结束事件
    OnActionChange      = "OnActionChange",             -- 游戏操作模式变化
    OnInputDeviceChange = "OnInputDeviceChange",        -- 手柄输入改变
    OnInputTypeChange   = "OnInputTypeChange",          -- 输入方式改变（例如上次用键盘输入，这次用手柄输入）
    OnGainItemShow      = "OnGainItemShow",             -- 战斗提示
    UpdateControl       = "UpdateControl",              -- 更新控制UI
    CastPowerFail       = "CastPowerFail",
    ShowOrHideOneTips   = "ShowOrHideOneTips",              -- 显隐一个tips

    -- 关卡相关
    SyncLevelTask       = "SyncLevelTask",              -- 同步任务
    BeginOverlapTaskBox = "BeginOverlapTaskBox",        -- 触发箱子
    EndOverlapTaskBox   = "EndOverlapTaskBox",          -- 离开箱子
    WaveIndexChange     = "WaveIndexChange",            -- 刷怪波次更改
    OnStarTaskChange    = "OnStarTaskChange",           -- 星级条件更新
    OnFlowChange        = "OnFlowChange",               -- 任务更新
    OnExecuteChange     = "OnExecuteChange",            -- 条目更新
    OnChallengeStart    = "OnChallengeStart",           -- 突发挑战开始
    OnChallengeFinish   = "OnChallengeFinish",          -- 突发挑战结束
    ShowSudden          = "ShowSudden",                 -- 显示侧边突发事项

    OnLevelFinish       = "OnLevelFinish",              -- 关卡结束
    OnLevelUINotify     = "OnLevelUINotify",            -- 关卡UINotify
    OnPickupDrop        = "OnPickupDrop",               -- 拾取掉落物Notify
    BeginOverlapReviver = "BeginOverlapReviver",        -- 准备复活
    EndOverlapReviver   = "EndOverlapReviver",          -- 放弃复活
    ShowFightTip        = "ShowFightTip",               -- 显示战斗消息提示
    OnInteractListAddItem = "OnInteractListAddItem",    -- 交互列表UI新增Item
    OnInteractListRemoveItem = "OnInteractListRemoveItem",    -- 交互列表UI移除Item
    BeginOverlapTombstone = "BeginOverlapTombstone",    -- 触碰墓碑
    EndOverlapTombstone   = "EndOverlapTombstone",      -- 离开墓碑
    OnAccessoryDestructed   = "OnAccessoryDestructed",      -- 部件被破坏
    EndOverlapRandomShop = "EndOverlapRandomShop",      -- 离开随机商店
    EndOverlapFragmentstory = "EndOverlapFragmentstory",-- 离开碎片叙事
    DefeatFinish        = "DefeatFinish",
    StartRecoverBullet  = "StartRecoverBullet",         -- 开始自动恢复子弹
    StopRecoverBullet   = "StopRecoverBullet",          -- 停止自动恢复子弹

    ServerNextDay       = "ServerNextDay",              -- 服务器跨天

    OnKeyBoardSettingChanged = "OnKeyBoardSettingChanged",--按键绑定改变时
    LevelStarUpdate     = "LevelStarUpdate",              --

    -- 宿舍相关
    EndOverlapFurniture = "EndOverlapFurniture",        -- 离开家具trigger
    StartConstantlyInteract = "StartConstantlyInteract",  -- 持续交互开始
    EndConstantlyInteract = "EndConstantlyInteract",      -- 持续交互结束

    -- 棋盘相关
    NotifyChess2DMapOpened = "NotifyChess2DMapOpened",                  -- 通知棋盘2D地图已经打开
    NotifyChessMoudleChanged = "NotifyChessMoudleChanged",              -- 棋盘模块发生变化时
    NotifyChessMapChanged = "NotifyChessMapChanged",                    -- 棋盘地图发生变化时
    NotifyChessGridTypeSelected = "NotifyChessGridTypeSelected",        -- 棋盘格子类型选中时
    ApplyCreateChessMap = "ApplyCreateChessMap",                        -- 请求创建棋盘地图
    ApplyModifyMapCreateData = "ApplyModifyMapCreateData",              -- 请求修改地图创建信息
    NotifyModifyMapCreateData = "NotifyModifyMapCreateData",            -- 通知修改地图创建信息
    NotifyChessErrorMsg = "NotifyChessErrorMsg",                        -- 显示棋盘错误消息
    NotifyChessHintMsg = "NotifyChessHintMsg",                          -- 显示棋盘提示消息
    NotifyChessTipMsg = "NotifyChessTipMsg",                            -- 显示棋盘tip消息
    NotifyChessEditorTypeChanged = "NotifyChessEditorTypeChanged",      -- 通知棋盘编辑类型发生变化
    NotifyChessPutRegion = "NotifyChessPutRegion",                      -- 通知棋盘放置新的区域
    NotifyChessSelectRegion = "NotifyChessSelectRegion";                -- 通知棋盘选中指定区域
    NotifyChessRegionDetailChanged = "NotifyChessRegionDetailChanged";  -- 通知棋盘区域信息有变动
    NotifyChessRegionRefresh = "NotifyChessRegionRefresh";              -- 通知刷新棋盘区域数据
    NotifyChessLayerFlagChanged = "NotifyChessLayerFlagChanged";        -- 通知棋盘显示层级开关有变化 
    NotifyChessPutObject = "NotifyChessPutObject";                      -- 通知在棋盘上放置物件
    NotifyChessDeleteObject = "NotifyChessDeleteObject";                -- 通知删除物件
    NotifyChessSelectedObject = "NotifyChessSelectedObject";            -- 通知选中棋盘上的物件
    NotifyChessUpdateInspector = "NotifyChessUpdateInspector";          -- 通知刷新物件的Inspector面包
    NotifyChessInspectorUpdate = "NotifyChessInspectorUpdate";          -- 通知物件的Inspector面包刷新
    ApplyOpenChessSetting = "ApplyOpenChessSetting";                    -- 请求打开棋盘设置界面
    NotifyChessSettingTypeChanged = "NotifyChessSettingTypeChanged";    -- 通知棋盘配置类型变化
    NotifySetChessMapDataComplete = "NotifySetChessMapDataComplete";    -- 通知设置棋盘数据完成
    NotifyChessEntryGridHintMode = "NotifyChessEntryGridHintMode";      -- 通知进入格子提示模式
    NotifyChessExitGridHintMode = "NotifyChessExitGridHintMode";        -- 通知退出格子提示模式
    NotifyChessOpenFastJump = "NotifyChessOpenFastJump";                -- 通知打开快速跳转界面
    NotifyChessCloseFastJump = "NotifyChessCloseFastJump";              -- 通知关闭快速跳转界面
    NotifyChessLookAtPos = "NotifyChessLookAtPos",                      -- 通知棋盘看向某个格子
    NotifyChessBeginDrag = "NotifyChessBeginDrag",                      -- 通知棋盘开始拖动物件
    NotifyChessEndDrag = "NotifyChessEndDrag",                          -- 通知棋盘结束拖动物件
    NotifyChessModifyRegionSetting = "NotifyChessModifyRegionSetting";  -- 通知修改区域配置
    NotifyChessOpenHelp = "NotifyChessOpenHelp";                        -- 通知打开帮助界面
    NotifyChessShowMenu = "NotifyChessShowMenu";                        -- 通知显示右键菜单
    NotifyChessSelectEvent = "NotifyChessSelectEvent";                  -- 通知选中事件
    NotifyChessObjectCountChanged = "NotifyChessObjectCountChanged";    -- 通知物件数量发生变化
    NotifyHideChessMap = "NotifyHideChessMap";                          -- 隐藏棋盘地图
    NotifyUpdateChessObject = "NotifyUpdateChessObject";                -- 通知更新棋盘物件
    NotifyShowChessInteraction = "NotifyShowChessInteraction";          -- 通知显示棋盘交互物
    NotifyHideChessInteraction = "NotifyHideChessInteraction";          -- 通知隐藏棋盘交互物
    NotifyChessTalkMsg = "NotifyChessTalkMsg";                          -- 通知显示场景对话消息
    NotifyOpenSelectItemUI = "NotifyOpenSelectItemUI";                  -- 通知打开物件选择界面
    NotifyBeginLoad3DChess = "NotifyBeginLoad3DChess";                  -- 通知开始加载3D场景
    ApplyOpenChessTask = "ApplyOpenChessTask";                          -- 请求打开棋盘任务界面
    NotifyHideChessObject = "NotifyHideChessObject";                    -- 通知隐藏棋盘上的物件
    NotifyShowChessObject = "NotifyShowChessObject";                    -- 通知显示棋盘上的物件
    NotifyRefreshChessInteraction = "NotifyRefreshChessInteraction";    -- 通知刷新棋盘互动
    NotifyOpenSelectRewardUI = "NotifyOpenSelectRewardUI";              -- 通知打开奖励选择界面
    NotifyShowChessItemTip = "NotifyShowChessItemTip";                  -- 显示物件tip
    NotifyOpenSelectorUI = "NotifyOpenSelectorUI";                      -- 通知打开通用选择界面
	NotifyChessNpcInteractEnd = "NotifyChessNpcInteractEnd";            -- 通知棋盘Npc交互结束
    NotifyChessCameraTypeChange = "NotifyChessCameraTypeChange";        -- 通知棋盘Npc交互结束
    SwitchBoomWarn = "SwitchBoomWarn";									-- 通知爆炸物显示模式改变
    MouseButtonUpWithKey = "MouseButtonUpWithKey";                      -- 通知鼠标按键松开
};

function Global_GetEventNames()
    local EventNameArray = UE4.TArray(UE4.FName)

    for key, value in pairs(Event) do
        EventNameArray:Add(value)
    end

    return EventNameArray
end
