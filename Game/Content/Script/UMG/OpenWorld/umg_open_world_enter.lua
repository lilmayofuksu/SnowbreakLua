-- ========================================================
-- @File    : umg_open_world_enter.lua
-- @Brief   : 开放世界中间界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    BtnAddEvent(self.BtnShop, function() UI.Open('Shop2', {shopId = 2}) end)
    BtnAddEvent(self.BtnStart, function() UI.Open('Formation') end)
    BtnAddEvent(self.BtnAward, function() UI.Open('OpenWorldExploreAward') end)
    
    self.Factory = Model.Use(self);

    self.tbWorld = {
        {id = 1, name = "废弃区域"},
        {id = 2, name = "旧金山"},
        {id = 3, name = "华盛顿"},
    }
end

function tbClass:OnOpen()
    self:OnUpdate()    
end

function tbClass:OnUpdate()
    self:DoClearListItems(self.ListWorld)
    self.tbDatas = {}
    local currentWorld = OpenWorldMgr.GetCurrentWorld()
    for _, cfg in ipairs(self.tbWorld) do
        local tbData = {
            id = cfg.id,
            name = cfg.name,
            onSelect = function() self:OnWorldSelect(cfg.id) end,
            progress = cfg.id == currentWorld and OpenWorldMgr.GetTaskCompleteProgress() or 0,
            onRefresh = function() end,
            isSelect = cfg.id == 1,
        }
        local pObj = self.Factory:Create(tbData);
        self.ListWorld:AddItem(pObj)
        table.insert(self.tbDatas, tbData)
    end

    self.TxtMoney:SetText(OpenWorldMgr.GetMoneyCount())
end

function tbClass:OnWorldSelect(id) 
    for _, data in ipairs(self.tbDatas) do 
        data.isSelect = id == data.id
        data.onRefresh(data.id)
    end
end

return tbClass