-- ========================================================
-- @File    : uw_open_world_explore_item.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    BtnAddEvent(self.BtnGet, function() self:OnBtnClickGet() end)
    self.Factory = Model.Use(self);

    self.handlerId = EventSystem.On(Event.OWExploreAwardSync, function()  
        self:UpdateAwardState()
    end)
    
end

function tbClass:OnDestruct()
    print("uw_open_world_explore_item Destruct");
    EventSystem.Remove(self.handlerId)
end

function tbClass:OnListItemObjectSet(pObj)
	print("OnListItemObjectSet", pObj);
	local tbParam = pObj.Data
	
	tbParam.onDataChange = function() 
		self:DataChange(tbParam)
	end
	self:DataChange(tbParam)
end

function tbClass:DataChange(tbParam)
	self.tbParam = tbParam
	local data = tbParam.data
	self.Index:SetText(string.format("探索度%d%%", data.id));

	self:DoClearListItems(self.Awards)
	for _, item in ipairs(data.tbItems) do 
		local tbData = {
			G = item[1], 
			D = item[2], 
			P = item[3],  
			L = item[4],  
			N = item[5] or 1,
		}
        local pObj = self.Factory:Create(tbData);
        self.Awards:AddItem(pObj)
	end
	self:UpdateAwardState()
end

function tbClass:UpdateAwardState()
	print("UpdateAwardState");
	local ok = OpenWorldMgr.CheckExploreAwardOK(self.tbParam.index);
	WidgetUtils.SetVisibleOrCollapsed(self.BtnGet, not ok)
	WidgetUtils.SetVisibleOrCollapsed(self.GetOK, ok)
end

function tbClass:OnBtnClickGet()
	print("OnBtnClickGet");
	OpenWorldClient.ApplyExploreAward(self.tbParam.index)
end

return tbClass