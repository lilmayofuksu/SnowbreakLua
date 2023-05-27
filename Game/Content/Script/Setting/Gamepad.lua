-- ========================================================
-- @File    : Gamepad.lua
-- @Brief   : 手柄按键设置
-- ========================================================

---@class Gamepad 手柄快捷键
Gamepad = Gamepad or {tbHandDefault = {}, tbCombineKey = {}, nHandDefaultCount = 0}

---PS4与XBOX 键位对应
local PS42XBOX = {
    ['HIDJoystick_Button1']     = 'Gamepad_FaceButton_Left',
    ['HIDJoystick_Button2']     = 'Gamepad_FaceButton_Bottom',
    ['HIDJoystick_Button3']     = 'Gamepad_FaceButton_Right',
    ['HIDJoystick_Button4']     = 'Gamepad_FaceButton_Top',
    ['HIDJoystick_Button5']     = 'Gamepad_LeftShoulder',
    ['HIDJoystick_Button6']     = 'Gamepad_RightShoulder',
    ['HIDJoystick_Button7']     = 'Gamepad_LeftTrigger',
    ['HIDJoystick_Button8']     = 'Gamepad_RightTrigger',
    ['HIDJoystick_Button9']     = 'Select/Back',
    ['HIDJoystick_Button10']    = 'Start/Forward',
    ['HIDJoystick_Button11']    = 'Gamepad_LeftThumbstick',
    ['HIDJoystick_Button12']    = 'Gamepad_RightThumbstick',
    ['HIDJoystick_Button13']    = 'Home',

    ['HIDJoystick_DPADUP']      = 'Gamepad_DPad_Up',
    ['HIDJoystick_DPADLEFT']    = 'Gamepad_DPad_Left',
    ['HIDJoystick_DPADRIGHT']   = 'Gamepad_DPad_Right',
    ['HIDJoystick_DPADDOWN']    = 'Gamepad_DPad_Down',
}

---获取对应的键位名称
function Gamepad.GetGamepadkeyName(nInputType, skeyName)
    if skeyName == 'None' then return 'None' end
    if nInputType == UE4.EKeyboardInputType.PS4 then
        for k, v in pairs(PS42XBOX) do
            if k == skeyName then  return v end
        end
    else
        for k, v in pairs(PS42XBOX) do
            if v == skeyName then return k end
        end
    end
end


---输入变更
function Gamepad.OnInputChange(nType)
    local pUI = UI.GetUI('HandleKeyPop')
    print('Gamepad.OnInputChange : ', nType, pUI)
    if pUI then
        pUI:UpdateByType(nType)
    end
end

---获取类型
function Gamepad.GetActiveInputType()
    local nType = UE4.UGamepadLibrary.GetGamepadActiveType()
    if nType == UE4.EKeyboardInputType.Keyboard then
        return UE4.EKeyboardInputType.XBox360
    end
    return nType
end

--[[ 缓存 DisplayName]]
local bInitCache = false
local tbCacheAction2I18n = {}
local tbCacheI18n2Action = {}
function Gamepad.InitCache()
    if SERVER_ONLY then return end

    if bInitCache then return end
    bInitCache = true

    tbCacheAction2I18n = {}
    tbCacheI18n2Action = {}
    local Keys = UE4.UGamepadLibrary.GetGamepadCfgRows(nil, true)
    for i = 1, Keys:Length() do
        local sKey = Keys:Get(i)
        local pItem = UE4.UGameKeyboardLibrary.GetKeyboardItem(sKey)
        tbCacheAction2I18n[pItem.ActionName] = pItem.I18n
        tbCacheI18n2Action[pItem.I18n] = pItem.ActionName
    end
end

function Gamepad.GetDisplayNameByAction(sAction)
    Gamepad.InitCache()
    return tbCacheAction2I18n[sAction]
end
function Gamepad.GetActionNameByI18n(sI18n)
    Gamepad.InitCache()
    return tbCacheI18n2Action[sI18n]
end


function Gamepad.GetHandDefaultKey(nType, nIdx)
    if Gamepad.tbHandDefault[nType] then
        return Gamepad.tbHandDefault[nType][nIdx]
    end
end

--[[
    手柄设置
]]

--- 获取组合键配置
---@param sAction string
function Gamepad.GetCombineKey(sAction)
    return Gamepad.tbCombineKey[sAction]
end


local nSelectIdx = nil

---获取手柄按键设置类型
function Gamepad.GetSaveHandType()
    if not nSelectIdx then
        nSelectIdx = me:GetAttribute(PlayerSetting.GID, PlayerSetting.SSID_HAND_INDEX)
    end
    return nSelectIdx or 0
end

---保存手柄按键配置
function Gamepad.SaveHandData(nIdx)
    print('Gamepad.SaveHandData :', nIdx)
    nSelectIdx = nIdx
    me:SetAttribute(PlayerSetting.GID, PlayerSetting.SSID_HAND_INDEX, nIdx)
end

---是否是自定义的样式
function Gamepad.IsCustomHand(nIdx)  return nIdx == 0 end


---获取显示的键位
function Gamepad.GetDisplayNameKeys(sKey, nInputType)
    local action = Gamepad.GetActionNameByI18n(sKey)
    if not action then return '' end
    local combinCfg = Gamepad.GetCombineKey(action)
    if combinCfg then
        local action1 = combinCfg[1]
        local action2 = combinCfg[2]
        local key1 = Gamepad.GetDisplayNameByAction(action1)
        local key2 = Gamepad.GetDisplayNameByAction(action2)
        return Gamepad.GetSetting(key1, nInputType), Gamepad.GetSetting(key2, nInputType)
    else
        return Gamepad.GetSetting(sKey, nInputType)
    end
end


---获取手柄设置的按键
---@param sKey string 条目Key
---@param nInputType EKeyboardInputType 类型
function Gamepad.GetSetting(sKey, nInputType)
    if not sKey or not nInputType then return end
    local sRet = ""
    if nInputType == UE4.EKeyboardInputType.Keyboard then return '' end
    local nSaveIdx = Gamepad.GetSaveHandType()
    if Gamepad.IsCustomHand(nSaveIdx) then
        local sSave = PlayerSetting.GetKeybordBind(sKey, nInputType)
        if sSave == nil or sSave == '' then
            local default = UE4.UGamepadLibrary.GetGamepadDefaultInputChord(sKey, nInputType)
            sRet = UE4.UGamepadLibrary.GetGamepadChordSaveName(default)
        else
            sRet = sSave
        end
    else
        ---获取模板配置
       sRet = Gamepad.GetTemplateKey(sKey, nInputType)
    end
    return sRet
end

function Gamepad.GetTemplateKey(sKey, nInputType)
    local nSaveIdx = Gamepad.GetSaveHandType()
    local sAction = Gamepad.GetActionNameByI18n(sKey)
    local ret = ''
    if sAction then
        local tbDefault = Gamepad.GetHandDefaultKey(nInputType, nSaveIdx) or {}
        ret = tbDefault[sAction] or ''
    end 
    return ret
end

---保存键位设置
function Gamepad.SaveSetting(sKey, sSetKeyName, nInputType)
    PlayerSetting.SetKeyboardBind(sKey, sSetKeyName, false, nInputType)
end

---自定义重置设置
function Gamepad.CustomReset()
    PlayerSetting.ClearKeyboardBind(UE4.EKeyboardInputType.PS4)
    PlayerSetting.ClearKeyboardBind(UE4.EKeyboardInputType.XBox360)
    UE4.UGamepadLibrary.UseGamepadSetting()
    PlayerSetting.SaveKeyboardBind()
end

function Gamepad.PrintSave()
    PlayerSetting.tbKeyBoardSetting = PlayerSetting.tbKeyBoardSetting or {}
    for _, value in pairs(PlayerSetting.tbKeyBoardSetting or {}) do
        if value then
             Dump(value)
        end
    end
end

---获取组合的功能
function Gamepad.GetCombineAction(sDisplayName, nType)
    -- local default = UE4.UGamepadLibrary.GetGamepadDefaultInputChord(sDisplayName, nType)
    -- if default.bShift then
    --     return 'GamepadLB'
    -- end
    -- if default.bCtrl then
    --     return 'GamepadRB'
    -- end
end

---检查组合键冲突
function Gamepad.CheckCombineConflict(sAction, nType, sKeyName)
    local Keys = UE4.UGamepadLibrary.GetGamepadCfgRows(nil, true)
    for i = 1, Keys:Length() do
        local sKey = Keys:Get(i)
        local sCombineAction = Gamepad.GetCombineAction(sKey, nType)
        if sCombineAction and sCombineAction == sAction then
            local sSave = Gamepad.GetSetting(sKey, nType)
            if sSave == sKeyName then
                return true
            end
        end
    end
    return false
end


---获取触发的组合动作
---@param sAction1 string
---@param sAction2 string
function Gamepad.GetTriggerCombineAction(sAction1, sAction2)
    for k, tbInfo in pairs(Gamepad.tbCombineKey or {}) do
        if tbInfo[1] == sAction1 and tbInfo[2] == sAction2 then
            return k
        end
    end
end

---获取设置的组合键
function Gamepad.GetSettingCombineAction(sAction)
    local nType = Gamepad.GetActiveInputType()
    local sDisplayName = Gamepad.GetDisplayNameByAction(sAction)
    if not sDisplayName then return end
    return Gamepad.GetCombineAction(sDisplayName, nType)
end

---键位缓存
local tbCacheKeyName2DisplayName = {}
local tbCacheDefaultKey2Action = {}
local tbCacheSameKey2DisplayName = {}

function Gamepad.UpdateCacheKey(nType, nIdx)
    tbCacheKeyName2DisplayName = {}
    tbCacheDefaultKey2Action = {}

    tbCacheSameKey2DisplayName = {}

    local Keys = UE4.UGamepadLibrary.GetGamepadCfgRows(nil, false)
    for i = 1, Keys:Length() do
        local sKey = Keys:Get(i)

        local sSave = Gamepad.GetSetting(sKey, nType)
        tbCacheKeyName2DisplayName[sSave] = sKey

        tbCacheSameKey2DisplayName[sSave] = tbCacheSameKey2DisplayName[sSave] or {}
        table.insert(tbCacheSameKey2DisplayName[sSave], sKey)
    end


    if Gamepad.IsCustomHand(nIdx) == false then
        local tbDefault = Gamepad.GetHandDefaultKey(nType, nIdx)
        for action, keyName in pairs(tbDefault or {}) do
            tbCacheDefaultKey2Action[keyName] = action
        end

    end
end

function Gamepad.GetSameKeyDisplayName(sKey)
    return tbCacheSameKey2DisplayName[sKey]
end

function Gamepad.GetDisplayNameByKeyName(sKey)
    return tbCacheKeyName2DisplayName[sKey]
end

function Gamepad.GetDefaultActionbyKeyName(gamepadKeyName)
    return tbCacheDefaultKey2Action[gamepadKeyName]
end


---配置加载
function Gamepad.LoadCfg()
    ---加载组合按键配置
    local tbInfo = LoadCsv("setting/combine_key.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local sAction =  tbLine.action
        local tbAction = Eval(tbLine.relation_action)
        if tbAction then
            Gamepad.tbCombineKey[sAction] = tbAction
        end
    end


    ---加载手柄默认按键设置
    Gamepad.tbHandDefault[1] = {}
    Gamepad.tbHandDefault[2] = {}

    local ps4Cfg = Gamepad.tbHandDefault[1]
    local xboxCfg = Gamepad.tbHandDefault[2]

    local tbInfo = LoadCsv("setting/hand_default.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local sAction =  tbLine.action
        local xbox = Eval(tbLine.xbox) or {}
        local ps4 = Eval(tbLine.ps4) or {}

        local nCount = #xbox
        if Gamepad.nHandDefaultCount == 0 then
            Gamepad.nHandDefaultCount = nCount
        end

        for i = 1, nCount do
            ps4Cfg[i] = ps4Cfg[i] or {}
            ps4Cfg[i][sAction] = ps4[i] or ''

            xboxCfg[i] = xboxCfg[i] or {}
            xboxCfg[i][sAction] = xbox[i] or ''
        end
    end
 end

 if not SERVER_ONLY then
    Gamepad.LoadCfg()
 end
