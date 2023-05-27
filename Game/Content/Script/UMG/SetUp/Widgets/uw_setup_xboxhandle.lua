-- ========================================================
-- @File    : uw_setup_xboxhandle.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:DisplayKey(nType, nIdx)
    print('DisplayKey :', nType, nIdx)
    if not self.Content then return end
    local nCount = self.Content:GetChildrenCount()
    for i = 1, nCount - 1 do
        local pItem = self.Content:GetChildAt(i)
        if pItem and pItem.Init then
            if pItem.IsCombin then
                pItem:SetCombinInfo(nType, nIdx)
            else
                pItem:DisplayKey(nType, nIdx)
            end
        end
    end


    local tbAction = nil

    for _, tb in pairs(Gamepad.tbCombineKey or {}) do
        if tbAction == nil then
            tbAction = tb
        end
    end

    if not tbAction then return end

    local action1 = tbAction[1]
    local action2 = tbAction[2]

    if not action1 or not action2 then return end

    print('组合按键 ：', action1, action2)

    local fSet = function(ac, pImg)
        local sDisplayName = Gamepad.GetDisplayNameByAction(ac)
        local key = Gamepad.GetSetting(sDisplayName, nType)
        local cfg = Keyboard.Get(key)
        if cfg then
            SetTexture(pImg, cfg.nIcon)
        end
        WidgetUtils.HitTestInvisible(pImg)
    end

    fSet(action1, self.ImgHandelSkill3)
    fSet(action2, self.ImgHandelSkill4)

    WidgetUtils.HitTestInvisible(self.TxtAdd_1)

   

    -- self:Internal_ShowCustomCombine('TxtKeySkill1', nType, nIdx, self.ImgHandelSkill1, self.ImgHandelSkill2, self.TxtAdd, self.TxtHandleSkillTips1)
    -- self:Internal_ShowCustomCombine('TxtKeySkill2', nType, nIdx, self.ImgHandelSkill3, self.ImgHandelSkill4, self.TxtAdd_1, self.TxtHandleSkillTips2)


    -- self.Skill1:SetCombinInfo(nType, nIdx)
    -- self.Skill2:SetCombinInfo(nType, nIdx)
end


---显示自定义组合按键
function tbClass:Internal_ShowCustomCombine(sKey, nType, nIdx, img1, img2, imgAdd, showTxt)
    -- local sSaveKey = Gamepad.GetSetting(sKey, nType)

    -- local sCombineAction = Gamepad.GetCombineAction(sKey, nType)
    -- if not sCombineAction then return end

    -- if Gamepad.IsCustomHand(nIdx) then
    --     local default = UE4.UGamepadLibrary.GetGamepadDefaultInputChord(sKey, nType)
    --     local sDefaultSaveName = UE4.UGamepadLibrary.GetGamepadChordSaveName(default)
    --     if sSaveKey ~= sDefaultSaveName then
    --         Color.SetTextColor(showTxt, 'FF8E00FF')
    --     else
    --         Color.SetTextColor(showTxt, 'F0F6FFFF')
    --     end
    -- else
    --     Color.SetTextColor(showTxt, 'F0F6FFFF')
    -- end

    -- local sDisplayName = Gamepad.GetDisplayNameByAction(sCombineAction)
    -- local key1 = Gamepad.GetSetting(sDisplayName, nType)
    -- local cfg1 = Keyboard.Get(key1)
    -- if cfg1 then
    --     SetTexture(img1, cfg1.nIcon)
    -- end

    -- local cfg2 = Keyboard.Get(sSaveKey)
    -- if cfg2 then
    --     SetTexture(img2, cfg2.nIcon)
    -- end

    -- WidgetUtils.HitTestInvisible(img1)
    -- WidgetUtils.HitTestInvisible(imgAdd)
    -- WidgetUtils.HitTestInvisible(img2)
end

return tbClass