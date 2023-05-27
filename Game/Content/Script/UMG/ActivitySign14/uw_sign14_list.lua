-- ========================================================
-- @File    : uw_activityweek_list.lua
-- @Brief   : 短签Task
-- ========================================================

local tbShortTask=Class("UMG.SubWidget")
tbShortTask.bShowAmi = false

function tbShortTask:Construct()
    self.tbItemList = {
        self.item1, 
        self.item2,
        self.item3,
        self.item4,
        self.item5
    }
end

--- 奖励条目
function tbShortTask:OnListItemObjectSet(InParam)
    self.tbParam = InParam.Data
    for nIdx, item in ipairs(self.tbItemList) do
        self:OnAddRewardItem(nIdx, self.tbParam[nIdx])
    end
end

--- 签到奖励
function tbShortTask:OnAddRewardItem(nIndex, InData)
    if not InData then 
        self.tbItemList[nIndex]:OnListItemObjectSet()
        return 
    end
    self.pRewardItem = Model.Use(self)
    local Reward =self.pRewardItem:Create(InData)

    self.tbItemList[nIndex]:OnListItemObjectSet(Reward)
end

function tbShortTask:OnDestruct()
    EventSystem.Remove(self.ClickHandle)
end

return tbShortTask