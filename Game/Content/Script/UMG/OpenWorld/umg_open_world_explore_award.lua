-- ========================================================
-- @File    : umg_open_world_explore_award.lua
-- @Brief   : 开放世界 探索度奖励
-- ========================================================

local tbClass = Class("UMG.BaseWidget")


function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
    
    self.Factory = Model.Use(self);
end

function tbClass:OnOpen()
    self:OnUpdate()    
end

function tbClass:OnUpdate()
    self.ExploreValue:SetText(string.format("%0.2f%%", OpenWorldMgr.GetTaskCompleteProgress()))
    self:DoClearListItems(self.AwardList)

    local list = OpenWorldMgr.GetAllExploreAward()
    for index, tb in ipairs(list) do 
        local tbData = {data = tb, index = index, onDataChange = function() end }
        local pObj = self.Factory:Create(tbData);
        self.AwardList:AddItem(pObj)
    end
end

return tbClass