-- ========================================================
-- @File    : uw_setup_keystorke_handleleft.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Init()
end

function tbClass:DisplayKey(nType, nIdx)
    local sKeyName = self:GetBindKeyName()
    if not sKeyName then
        return
    end
    local bCustom = Gamepad.IsCustomHand(nIdx)
    if bCustom then
        local sDisplayName = Gamepad.GetDisplayNameByKeyName(sKeyName)
        self:Inner_DisplayKey(sDisplayName, sKeyName, nType, true)
    else
        local sAction = Gamepad.GetDefaultActionbyKeyName(sKeyName)
        local sDisplayName = Gamepad.GetDisplayNameByAction(sAction)
        self:Inner_DisplayKey(sDisplayName, sKeyName, nType, false)
    end
end


function tbClass:GetBindKeyName()
    if not self.Key then return end
    return UE4.UGamepadLibrary.GetKeyName(self.Key)
end

function tbClass:SetNoneKey()
    WidgetUtils.Collapsed(self)
end

function tbClass:Inner_DisplayKey(sShowName, sKeyName, nType, bCustom)
    if not sKeyName then return end

    local sCombineAction = Gamepad.GetCombineAction(sShowName, nType)
    if sCombineAction then
        self:SetNoneKey()
        return
    end

    if sShowName then
        WidgetUtils.SelfHitTestInvisible(self)
        WidgetUtils.HitTestInvisible(self.TxtHandle)
        local default = UE4.UGamepadLibrary.GetGamepadDefaultInputChord(sShowName, nType)
        local sDefaultSaveName = UE4.UGamepadLibrary.GetGamepadChordSaveName(default)

        local bSame = false

        if bCustom and sKeyName ~= sDefaultSaveName then
            bSame = false
        else
            bSame = true
        end

        local tbSame = Gamepad.GetSameKeyDisplayName(sKeyName)
        if tbSame and #tbSame > 1 then
            local tbDefault = {}
            local Keys = UE4.UGamepadLibrary.GetGamepadCfgRows(nil, false)
            for i = 1, Keys:Length() do
                local sKey = Keys:Get(i)
                local default = UE4.UGamepadLibrary.GetGamepadDefaultInputChord(sKey, nType)
                local keyName = UE4.UGamepadLibrary.GetKeyName(default.Key)
                if sKeyName == keyName then
                    table.insert(tbDefault, sKey)
                end
            end

            bSame = false
            if #tbDefault > 1 then
                if (tbDefault[1] == tbSame[1] and tbDefault[2] == tbSame[2] ) or (tbDefault[1] == tbSame[1] and tbDefault[2] == tbSame[2] ) then
                    bSame = true
                end
            end

            self.TxtHandle:SetText(Text('ui.' .. tbSame[1]) .. '/' .. Text('ui.' .. tbSame[2]))
        else
            self.TxtHandle:SetText(Text('ui.' .. sShowName))
        end

        if bSame == false then
            Color.SetTextColor(self.TxtHandle, 'FF8E00FF')
        else
            Color.SetTextColor(self.TxtHandle, 'F0F6FFFF')
        end
    else
        WidgetUtils.Collapsed(self.TxtHandle)
        -- WidgetUtils.Collapsed(self)
        -- return
    end

    local cfg = Keyboard.Get(sKeyName)
    if cfg then
        if cfg.nIcon ~= 0 then
            WidgetUtils.HitTestInvisible(self.ImgHandleIcon)
            SetTexture(self.ImgHandleIcon, cfg.nIcon)
        end
    end
end

return tbClass