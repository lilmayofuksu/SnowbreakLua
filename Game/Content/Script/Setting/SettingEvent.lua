-- ========================================================
-- @File    : SettingEvent.lua
-- @Brief   : 设置
-- ========================================================

SettingEvent = SettingEvent or {}

local var = {
    tbEvent = {
        [PlayerSetting.SSID_OPERATION]  = {},
        [PlayerSetting.SSID_FRAME]      = {},
        [PlayerSetting.SSID_SOUND]      = {},
        [PlayerSetting.SSID_OTHER]      = {},
        [PlayerSetting.SSID_HANDLE]     = {},
    },

    tbFrameEvent    = {},
    tbTargetEvent   = {},
    tbDisplayEvent  = {}
}

function SettingEvent.Trigger(nSID, nType, Value)
    if var.tbEvent[nSID][nType] then
        var.tbEvent[nSID][nType](Value)
    end
    local nValue = Value[1] or 0
    SettingEvent.TriggerTarget(nSID, nType, nValue)
end

function SettingEvent.TriggerTarget(nSID, nType, Value)
    if var.tbTargetEvent[nSID] and var.tbTargetEvent[nSID][nType] then
        local tbInfo = var.tbTargetEvent[nSID][nType]
        for _, v in pairs(tbInfo) do
            if v and v.OnSettingChange then 
                v:OnSettingChange(nSID, nType, Value)
            end
        end
    end
end

function SettingEvent.Add(nSID, nType, fun)
    var.tbEvent[nSID][nType] = fun
end

function SettingEvent.AddTarget(pTarget, nSID, nType)
    var.tbTargetEvent[nSID] =  var.tbTargetEvent[nSID] or {}
    var.tbTargetEvent[nSID][nType] =  var.tbTargetEvent[nSID][nType] or {}
    if var.tbTargetEvent[nSID][nType][pTarget] == nil then
            table.insert(var.tbTargetEvent[nSID][nType], pTarget)
    end
end

function SettingEvent.Remove(nSID, nType)
    var.tbEvent[nSID][nType] = nil
end

function SettingEvent.RemoveTarget(pTarget, nSID, nType)
    if var.tbTargetEvent[nSID] and var.tbTargetEvent[nSID][nType] then
        local tbInfo =  var.tbTargetEvent[nSID][nType]
       for i = #tbInfo, 1 , -1 do
           if tbInfo[i] == pTarget then
                table.remove(tbInfo, i)
           end
       end
    end
end

function SettingEvent.AddFrameEvent(nType, fun)
    var.tbFrameEvent[nType] = fun
end

function SettingEvent.AddDisplayEvent(nType, fun)
    var.tbDisplayEvent[nType] = fun
end

function SettingEvent.TriggerFrameEvent(nType, nValue)
     if var.tbFrameEvent[nType] then
        var.tbFrameEvent[nType](nValue)
     end
end

function SettingEvent.TriggerDisplayEvent(nType, nValue, nValue1)
     if var.tbDisplayEvent[nType] then
        var.tbDisplayEvent[nType](nValue, nValue1)
     end
end

--[[
    音量变化
]]
local function VolumeScaleChange(sType, tbValue)
    local nScale = (tbValue[1] or 100) / 100
    local bMate = (tbValue[2] or 0) == 1
    if bMate then
        nScale = 0;
    end
    UE4.UWwiseLibrary.SetVolumeScale(sType, nScale, 1)
end

SettingEvent.Add(PlayerSetting.SSID_SOUND, SoundType.ROLE, function(tbValue)
    VolumeScaleChange('Voice', tbValue)
end)

SettingEvent.Add(PlayerSetting.SSID_SOUND, SoundType.MUSIC, function(tbValue)
    VolumeScaleChange('Music', tbValue)
end)

SettingEvent.Add(PlayerSetting.SSID_SOUND, SoundType.SOUND, function(tbValue)
    VolumeScaleChange('Sound', tbValue)
end)

SettingEvent.Add(PlayerSetting.SSID_SOUND, SoundType.DUBBING, function(tbValue)
    VolumeScaleChange('Master', tbValue)
end)

SettingEvent.Add(PlayerSetting.SSID_SOUND, SoundType.QUALITY, function(tbValue)
    local tb = { UE4.EWwiseQuality.Low, UE4.EWwiseQuality.Middle, UE4.EWwiseQuality.Highest }
    UE4.UWwiseLibrary.SetWwiseQuality(tb[tbValue[1] + 1])
end)

SettingEvent.Add(PlayerSetting.SSID_SOUND, SoundType.EFFECTS, function(tbValue)
    UE4.UWwiseLibrary.SetLowAmmunitionEffect(tbValue[1] == 1)
end)

--[[
    画面设置变化
]]

local function GetGrapSetting()
    return UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
end

local function CheckEffectQualityChangeAndTips(nOldValue)
    if IsMobile() and me:IsLogined() then
        local pSetting = GetGrapSetting()
        local nNewEffectQuality = pSetting:GetCategoryLevel(UE4.EGraphicsSettingCategory.EffectQuality)

        if nNewEffectQuality ~= nOldValue then
            UI.ShowTip("ui.TxtApprestartTip");
        end
    end
end

SettingEvent.Add(PlayerSetting.SSID_FRAME, FrameType.LEVEL, function(Value)
    local nLevel = Value[1] or 1
    local pSetting = GetGrapSetting()

    local nOldEffectQuality
    if pSetting then
        nOldEffectQuality = pSetting:GetCategoryLevel(UE4.EGraphicsSettingCategory.EffectQuality)
    end

    for _,v in ipairs(PlayerSetting.tbFrameSort) do
        if v.Reference and v.Standard and v.Reference == FrameType.LEVEL and nLevel <= #v.Standard then
            SettingEvent.TriggerFrameEvent(v.Type, v.Standard[nLevel])
        end
    end

    -- Real change graphics quality level.
    if pSetting then
        pSetting:SetGraphicsLevel(nLevel - 1)
        CheckEffectQualityChangeAndTips(nOldEffectQuality)
    end

    if IsMobile() then 
        UE4.UUMGLibrary.SetIsPerformanceMode(nLevel <= 2)
    end
end)

SettingEvent.Add(PlayerSetting.SSID_FRAME, FrameType.CUSTOM, function(tbCheck)
    local pSetting = GetGrapSetting()
    local nOldEffectQuality
    if pSetting then
        nOldEffectQuality = pSetting:GetCategoryLevel(UE4.EGraphicsSettingCategory.EffectQuality)
    end

    for nType, nValue in pairs(tbCheck) do
        SettingEvent.TriggerFrameEvent(nType, nValue)
    end

    if pSetting then
        pSetting:SetGraphicsLevel(PlayerSetting.GetCustomLevel() - 1)
        CheckEffectQualityChangeAndTips(nOldEffectQuality)
    end
end)

---------------------------画面参数设置---------------------------

---视觉效果
SettingEvent.AddFrameEvent(FrameType.EFFECT, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetEffectQuality(nValue)
    end
end)

---阴影
SettingEvent.AddFrameEvent(FrameType.SHADOW, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetShadowQuality(nValue)
    end
end)

---抗锯齿
SettingEvent.AddFrameEvent(FrameType.JAG, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetAAQuality(nValue)
    end
end)

--渲染精度
SettingEvent.AddFrameEvent(FrameType.RENDERING, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetScreenPercentage(nValue)
    end
end)
SettingEvent.AddFrameEvent(FrameType.RENDERING_PC, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetScreenPercentageForPC(nValue)
    end
end)

---FPS
SettingEvent.AddFrameEvent(FrameType.FPS, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        local nIndex = nValue + 1
        local nFPS = Text('setting.'..PlayerSetting.tbFrameCfg[FrameType.FPS].Items[nValue + 1])
        if (tonumber(nFPS) == nil) then
            nFPS = 0 -- means use custom fps.
        end
        pSetting:SetFpsQuality(nFPS)
    end
end)

---MAXFPS
SettingEvent.AddFrameEvent(FrameType.MAXFPS, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetCustomFpsQuality(nValue)
    end
end)

---镜面效果
SettingEvent.AddFrameEvent(FrameType.MIRRIR, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetReflection(nValue)
    end
end)

---后期效果
SettingEvent.AddFrameEvent(FrameType.POST, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetPPQuality(nValue)
    end
end)

---特效质量
SettingEvent.AddFrameEvent(FrameType.PARTICLE, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetParticleQuality(nValue)
    end
end)

---场景细节
SettingEvent.AddFrameEvent(FrameType.SCENE, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetSceneQuality(nValue)
    end
end)

---垂直同步
SettingEvent.AddFrameEvent(FrameType.VERTICAL, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetVSync(nValue)
    end
end)

-- ---辉光
-- SettingEvent.AddFrameEvent(FrameType.GLOW, function(nValue)
--     local pSetting = GetGrapSetting()
--     if pSetting then
--         pSetting:SetBloomQuality(nValue)
--     end
-- end)

-- ---扭曲
-- SettingEvent.AddFrameEvent(FrameType.WRAP, function(nValue)
--     local pSetting = GetGrapSetting()
--     if pSetting then
--         pSetting:SetRefractionQuality(nValue)
--     end
-- end)

-- ---景深
-- SettingEvent.AddFrameEvent(FrameType.DEPATH, function(nValue)
--     local pSetting = GetGrapSetting()
--     if pSetting then

--       --TODO-------------------------------------------
--     end
-- end)

---动态模糊
SettingEvent.AddFrameEvent(FrameType.BLUR, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetMotionBlur(nValue)
    end
end)

---体积雾
SettingEvent.AddFrameEvent(FrameType.FROG, function(nValue)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetVolumetricFog(nValue)
    end
end)


---画面质量
-- SettingEvent.AddFrameEvent(FrameType.IMG_QUALITY, function(nValue)
--     local pSetting = GetGrapSetting()
--     if pSetting then
--         pSetting:SetImageQuality(nValue)
--     end
-- end)

-- 窗口化&分辨率
SettingEvent.AddDisplayEvent(FrameType.DISPLAY, function(nResolution, nFullScreen)
    local pSetting = GetGrapSetting()
    if pSetting then
        pSetting:SetDisplayMode(PlayerSetting.GetResolution(nResolution), nFullScreen)
    end
end)

---------------------------------------------------------------------


---其他设置

SettingEvent.Add(PlayerSetting.SSID_OTHER, OtherType.FIGHT_SHOW_BROADCAST, function(tbValue)
    local nValue = tbValue[1] or 0
    CacheBroadcast.OnSettingChange(nValue == 1)
end)

SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.SKILL_TIP, function (tbValue)
    UE4.AGamePlayerController.SetUseSkillTipSelector(tbValue[1])
end)

--- 冲锋操作模式
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.RUSH_MODEL, function (tbValue)
    UE4.AGamePlayerController.SetRushMode(tbValue[1])
end)

---安全区缩放变化
SettingEvent.Add(PlayerSetting.SSID_OTHER, OtherType.UI_SAFE_ZONE_SCALE, function (tbValue)
   local nValue = tbValue[1] or 0
   if nValue < 0 then
        return
   end
   if UE4.UScreenMatchingSettings.UpdateZoomSafetyZone then
        UE4.UScreenMatchingSettings.UpdateZoomSafetyZone()
   end
   print('UpdateZoomSafetyZone *********** :', nValue)
   UE4.UUserSetting.SetInt('PLAYER_SETTING_SAFE_ZONE', nValue)
   UE4.UUserSetting.Save()
end)

---转向加速度变化
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.TURNING_ACCELERATE, function (tbValue)
    local nValue = tbValue[1] or 0
    UE4.AGamePlayerController.SetTuringAcceletate(nValue)
end)    

-- 狙击枪激发方式变化
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.SNIPER_FIRE, function(tbValue
)    local nValue = tbValue[1] or 0
    UE4.AGamePlayerController.SetSniperFireMode(nValue)
end)

-- 霰弹枪激发方式变化
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.SHOTGUN_FIRE, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.AGamePlayerController.SetShotGunFireMode(nValue)
end)

-- 手枪激发方式变化
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.PISTOL_FIRE, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.AGamePlayerController.SetPistolFireMode(nValue)
end)

-- 左手开火按钮
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.LEFT_HAND_FIRE, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.USkillPanel.SetLeftFireBtnMode(nValue)
end)

-- 瞄准按钮模式
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.AIM_SWERVE, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.UFightWidget.SetAimCanDrag(nValue)
end)

-- 开火按钮模式
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.FIRE_SWERVE, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.UFightWidget.SetFireCanDrag(nValue)
end)

-- 瞄准模式
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.AIM_MODEL, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.AGamePlayerController.SetAimMode(nValue)
end)

-- 混合射击按钮模式
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.MIX_AIM, function(tbValue)
    local nValue = tbValue[1] or 0
    UE4.AGamePlayerController.SetMixFireMode(nValue)
end)

-- 爆炸物预警
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.BOOM_WARN, function(tbValue)
    local nValue = tbValue[1] or 1
    UE4.ULevelLibrary.SetBoomWarn(nValue == 1)
end)

-- 智能施法
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.SMART_CASTING, function(tbValue)
    local nValue = tbValue[1] or 0
    local GameInstance = GetGameIns();
    if GameInstance then
        local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        if Controller then
            local PlayerController = Controller:Cast(UE4.AGamePlayerController);
            if PlayerController then
                PlayerController:SetSkillAutoFindTarget(nValue == 1)
            end
        end
    end
end)

-- 技能鎖定提示框
SettingEvent.Add(PlayerSetting.SSID_OPERATION, OperationType.SKILL_FRAME, function(tbValue)
    local nValue = tbValue[1] or 0
    local GameInstance = GetGameIns();
    if GameInstance then
        local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        if Controller then
            local PlayerController = Controller:Cast(UE4.AGamePlayerController);
            if PlayerController then
                PlayerController:SetActiveSkillEffect(nValue == 1)
            end
        end
    end
end)
