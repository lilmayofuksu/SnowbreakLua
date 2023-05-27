-- ========================================================
-- @File    : uw_achievement_reward.lua
-- @Brief   : 任务界面  主线阶段奖励
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnOK, function()  UI.Close(self) end)
    BtnAddEvent(self.BG.BtnClose, function()  UI.Close(self) end)

    self:DoClearListItems(self.ListNum)
    self.ListNum:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnOpen()
    self:ShowMain()
end

function tbClass:OnClose()
end

function tbClass:ShowMain()
    self:DoClearListItems(self.ListNum)

    for _, v in ipairs(Achievement.tbChapterList) do
        local pObj = self.Factory:Create(v)
        self.ListNum:AddItem(pObj)
    end
end

return tbClass