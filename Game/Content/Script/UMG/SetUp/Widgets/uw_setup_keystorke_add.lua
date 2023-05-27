-- ========================================================
-- @File    : uw_setup_keystorke_add.lua
-- @Brief   : 手柄组合按键
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Init()
end

function tbClass:IsCombin()
    return true
end

function tbClass:SetCombinInfo(nType, nIdx)
    local tbAction = Gamepad.GetCombineKey(self.Action)
    if not tbAction then return end

    local action1 = tbAction[1]
    local action2 = tbAction[2]


    if not action1 or not action2 then return end

    local sDisplayName = Gamepad.GetDisplayNameByAction(action1)
    local pChord = UE4.UGamepadLibrary.GetGamepadInputChordByType(sDisplayName, nType)
    local sKeyName = UE4.UGamepadLibrary.GetKeyName(pChord.Key)
    local cfg = Keyboard.Get(sKeyName)
    if cfg then
        if cfg.nIcon ~= 0 then
            SetTexture(self.ImgHandleIcon, cfg.nIcon)
        end
    end
end

return tbClass