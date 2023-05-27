-- ========================================================
-- @File    : uw_achievement_reward.lua
-- @Brief   : 任务界面  主线阶段奖励
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnOpen(tbConfig)
    if not self.Factory then
        self.Factory = Model.Use(self)
    end

    self:DoClearListItems(self.ListItem)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)

    self.tbConfig = tbConfig
    if not self.tbConfig then 
        WidgetUtils.Collapsed(self)
        return 
    end

    self:ShowMain()
    self:PlayAnimation(self.allenter)
end

function tbClass:OnClose()
    self.tbConfig = nil
end

function tbClass:ShowMain()
    self:DoClearListItems(self.ListItem)

    self.nLeft = self.tbConfig.nSec
    for nIdx, v in ipairs(self.tbConfig.tbRewards) do
        local cfg = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5]}
        local pObj = self.Factory:Create(cfg)
        self.ListItem:AddItem(pObj)

        if nIdx >= 3 then
            break
        end
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end

    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    if not self.nLeft then return end

    self.nLeft = self.nLeft - 1
    self.detime = 0

    if self.nLeft <= 0 then
        self.nLeft = nil
        self:BindToAnimationFinished(self.allenter_out, {self, function()
            self:UnbindAllFromAnimationFinished(self.allenter_out)
            WidgetUtils.Collapsed(self)
        end})
        self:PlayAnimation(self.allenter_out)
    end
end

return tbClass