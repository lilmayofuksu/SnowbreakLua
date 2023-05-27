-- ========================================================
-- @File    : Keyboard.lua
-- @Brief   : 按键设置
-- ========================================================

---@class Keyboard 快捷键
Keyboard = Keyboard or { tbConfig = {}}

---获取触发的组合动作
---@param sAction1 string
---@param sAction2 string
function Keyboard.GetTriggerCombineAction(sAction1, sAction2)
    return Gamepad.GetTriggerCombineAction(sAction1, sAction2)
end

---获取设置的组合键
function Keyboard.GetSettingCombineAction(sAction)
    return Gamepad.GetSettingCombineAction(sAction)
end

function Keyboard.PrintSaveInfo()
    Dump(PlayerSetting.tbKeyBoardSetting)
end


---获取按键显示名称
---@param sKey string 按键字符串
function Keyboard.GetKeyName(sKey)
    local cfg = Keyboard.Get(sKey)
    return cfg and Text(cfg.sName) or sKey
end

---获取按键对应配置
---@param sKey string 按键字符串
function Keyboard.Get(sKey)
    return Keyboard.tbConfig[sKey]
end

function Keyboard.Load()
    ---加载默认设置
    local tbInfo = LoadCsv("setting/keyboard.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local sKey =  tbLine.Key
        local tbInfo = {
                sName = tbLine.Name,
                nIcon = tonumber(tbLine.Icon) or 0
        }

        Keyboard.tbConfig[sKey] = tbInfo
    end
 end

--显示组合键的文本，不是组合键就返回，是的话显示Ctrl/Alt/Shift
 function Keyboard:ShowCombinedKeyTxt(Chord,TxtWidget,TxtAddWidget)
     if Chord and (Chord.bShift or Chord.bAlt or Chord.bCtrl) then
        WidgetUtils.SelfHitTestInvisible(TxtWidget)
        WidgetUtils.SelfHitTestInvisible(TxtAddWidget)

        local cfg = nil;
        if Chord.bShift then
            cfg = Keyboard.Get('Shift')
        end
        if Chord.bAlt then
            cfg = Keyboard.Get('Alt')
        end
        if Chord.bCtrl then
            cfg = Keyboard.Get('Control')
        end
        if cfg and TxtWidget then
           TxtWidget:SetText(Text(cfg.sName))
        end
    else
        WidgetUtils.Collapsed(TxtWidget)
        WidgetUtils.Collapsed(TxtAddWidget)
    end
 end

 Keyboard.Load()