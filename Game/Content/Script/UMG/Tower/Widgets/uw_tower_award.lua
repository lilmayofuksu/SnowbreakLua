-- ========================================================
-- @File    : uw_tower_award.lua
-- @Brief   : 爬塔奖励领取界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListNum)
    self.Popup:Init("", function() UI.Close(self) end)
    self.ListNum:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnOpen(type, layer)
    self.nType = type or self.nType
    self.nLayer = layer or self.nLayer
    self:UpdateList(self.nLayer)
end

function tbClass:UpdatePanel(_, type)
    ---1基座 2大楼
    self.nType = type or self.nType
end

function tbClass:UpdateList(layer)
    self:DoClearListItems(self.ListNum)
    local diff = 1
    if self.nType == 2 then
        diff = ClimbTowerLogic.GetLevelDiff()
    end
    local cfg = ClimbTowerLogic.tbAwardConf[layer][diff]
    if not cfg then return end
    local tbData = {}

    local data = {}
    data.nID = cfg.nID
    data.nGroup = 1
    data.tbAward = cfg.FirstAward
    data.bReceive = ClimbTowerLogic.IsReceive(cfg.nID, 0)
    data.bCompleted = ClimbTowerLogic.GetLayerIsPass(nil, cfg.nID)
    table.insert(tbData, data)

    for k, v in pairs(cfg.tbStarCount) do
        local data = {}
        data.nID = cfg.nID
        data.nGroup = 2
        data.index = k
        data.starCount = v
        data.tbAward = cfg.tbStarAward[k]
        data.bReceive = ClimbTowerLogic.IsReceive(cfg.nID, k)
        data.nowStarCount = ClimbTowerLogic.GetLayerStar(nil, cfg.nID)
        data.bCompleted = data.nowStarCount >= v
        table.insert(tbData, data)
    end

    for _, data in ipairs(tbData) do
        local pObj = self.ListFactory:Create(data)
        self.ListNum:AddItem(pObj)
    end
end

return tbClass
