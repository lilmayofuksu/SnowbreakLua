-- ========================================================
-- @File    : uw_tower_reward.lua
-- @Brief   : 爬塔奖励领取按钮
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnReward, function ()
        if self.funReceive then --可领取直接领取
            ---领取奖励后的刷新回调
            self.funReceive()
            self.funReceive = nil
            return
        end
        if self.FunClick then   --没有可领取的弹出界面
            self.FunClick()
        end
    end)
end

function tbClass:Init(layer, funClick)
    if not layer then return end
    self.Layer = layer
    self.FunClick = funClick
    self:UpdateState()
end

function tbClass:UpdateState()
    local diff = 1
    if self.Layer > #ClimbTowerLogic.GetAllLayerTbLevel(1) then
        diff = ClimbTowerLogic.GetLevelDiff()
    end
    local cfg = ClimbTowerLogic.tbAwardConf[self.Layer][diff]
    if not cfg then return end
    --首通奖励
    local bAllReceive = ClimbTowerLogic.IsReceive(cfg.nID, 0)
    local bHaveCompleted = ClimbTowerLogic.GetLayerIsPass(nil, cfg.nID) and not bAllReceive
    --星级奖励
    for k, v in pairs(cfg.tbStarCount) do
        local bReceive = ClimbTowerLogic.IsReceive(cfg.nID, k)
        bAllReceive = bAllReceive and bReceive
        bHaveCompleted = bHaveCompleted or (ClimbTowerLogic.GetLayerStar(nil, cfg.nID) >= v and not bReceive)
    end
    if bAllReceive then
        WidgetUtils.Collapsed(self.RewardNormal)
        WidgetUtils.Collapsed(self.RewardLight)
        WidgetUtils.HitTestInvisible(self.RewardClear)
    elseif bHaveCompleted then
        WidgetUtils.Collapsed(self.RewardNormal)
        WidgetUtils.Collapsed(self.RewardClear)
        WidgetUtils.HitTestInvisible(self.RewardLight)
        self.funReceive = function()
            ClimbTowerLogic.GetReward(nil, self.Layer)
        end
    else
        WidgetUtils.Collapsed(self.RewardLight)
        WidgetUtils.Collapsed(self.RewardClear)
        WidgetUtils.HitTestInvisible(self.RewardNormal)
    end
end

return tbClass
