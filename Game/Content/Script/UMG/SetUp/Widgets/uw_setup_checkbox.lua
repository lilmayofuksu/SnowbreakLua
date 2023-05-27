-- ========================================================
-- @File    : uw_setup_checkbox.lua
-- @Brief   : 设置
-- ========================================================

---@class tbClass : UUserWidget
---@field Check UCheckBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Check.OnCheckStateChanged:Add(self, function(_, bCheck)
        local nFlag = bCheck and 1 or 0
        PlayerSetting.Set(self.nSID, self.nType, {nFlag})
        self:SetCheckedState(bCheck)
    end)
end

function tbClass:Set(SID, nType)
    self.nSID = SID
    self.nType = nType
    local nFlag = PlayerSetting.Get(SID, nType)[1]
    local bCheck = (nFlag == 1)
    local sDes = PlayerSetting.GetShowName(SID, nType)
    sDes = Text(sDes)
    self.TxtCheck1:SetText(sDes)
    self.TxtCheck2:SetText(sDes)

    self.Check:SetCheckedState(bCheck and UE4.ECheckBoxState.Checked or UE4.ECheckBoxState.Unchecked)
    self:SetCheckedState(bCheck)
end

---更新显示状态
function tbClass:SetCheckedState(bCheck)
    if bCheck then
        WidgetUtils.HitTestInvisible(self.CheckMark)
    else
        WidgetUtils.Collapsed(self.CheckMark)
    end
end

return tbClass