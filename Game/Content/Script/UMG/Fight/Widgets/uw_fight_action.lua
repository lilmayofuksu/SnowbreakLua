-- ========================================================
-- @File    : uw_fight_action.lua
-- @Brief   : 指引操作设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:UpdatePanel()
    local tbActions = {
        self.Action1,
        self.Action2,
        self.Action3
    }
    local nCheckIndex = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
    local nImgIndex = 1003032
    for i, v in ipairs(tbActions) do
        v:Set({sName = 'ui.TxtSetAction'..i, sDetail = 'ui.TxtSetActionDetail'..i, nIndex = i, bSelected = nCheckIndex == i, nImg = nImgIndex + i})
    end
    self.Bg:Init(function () end)
    self.Bg:PlayAnimation(self.Bg.AllEnter)
    self:PlayAnimation(self.AllEnter)
end

return tbClass
