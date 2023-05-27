-- @DESCRIPTION OccupyUI 左侧的信息框 包含三个盾牌和信息提示
-- @AUTHOR zhangguangyu
-- @DATE 2022/06/23

local tbClass = Class('UMG.SubWidget')
function tbClass:Construct()
    self.OccupySummaryList = self.ListSmallOccupy.ListOccupy -- 上方三个盾牌
	self.OccupyInfoList = self.ListOccupy -- 下方信息提示栏
	self.ListIndex = 0
	self.tbCache = {}
end

function tbClass:InitByAreaNum(num,tbNameKey)
	WidgetUtils.Visible(self.OccupySummaryList)
	WidgetUtils.Visible(self.OccupyInfoList)
	self.OccupyInfoList:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
	self:DoClearListItems(self.OccupySummaryList)
	self:DoClearListItems(self.OccupyInfoList)
	if not self.Factory then
		self.Factory = Model.Use(self);
	end
	for i=1,num do
		local Obj = self.Factory:Create({name = tbNameKey[i], TriggerIndex = i})
		self.OccupySummaryList:AddItem(Obj)
	end
end

function tbClass:UpdateOccupyInfoItem(TriggerId, bIsPlayer, OccupyState) --OccupyState 1 占领中，2 占领完成 3 占领取消
	if not self.OccupyInfoList then
		return
	end
	if OccupyState ~= 3 then
		local FindIndex = self:GetOccupyInfoItemIndex(TriggerId, bIsPlayer, OccupyState)
		--if FindIndex > -1 then
		--	print("Occupy Info List Update Find:TriggerId=", TriggerId, " IsPlayer=", bIsPlayer, " OccupyState=",OccupyState, " Obj=", FindObj)
		--end
		if FindIndex == -1 then
			self.ListIndex = self.ListIndex + 1
			local Obj = self.Factory:Create({ name = TriggerId, TriggerIndex = TriggerId,
				InstigatorFlag = bIsPlayer,
				OccupyState = OccupyState, ListId = self.ListIndex - 1 })
			self.tbCache[self.ListIndex - 1] = Obj
			self.OccupyInfoList:AddItem(Obj)
		end
	end

	if OccupyState == 2 then
		UE4.Timer.Add(5, function()
			self:RemoveOccupyInfo(TriggerId, bIsPlayer, OccupyState)
		end
		)
	elseif OccupyState == 3 then
		self:RemoveOccupyInfo(TriggerId, true, 1) -- 我方占领取消 删掉之前的占领中状态
		self:RemoveOccupyInfo(TriggerId, false, 1) -- 敌方占领取消
	end
	-- end
end

function tbClass:RemoveOccupyInfo(TriggerId, bIsPlayer, OccupyState)
	if not self.OccupyInfoList then
		return
	end
	local FindIndex = self:GetOccupyInfoItemIndex(TriggerId, bIsPlayer, OccupyState)
	if FindIndex ~= -1 then
		self.OccupyInfoList:RemoveItem(self.tbCache[FindIndex])
		self.tbCache[FindIndex] = nil
        self.ListIndex = self.ListIndex - 1
	end
end

function tbClass:GetOccupyInfoWidget(TriggerId, bIsPlayer, OccupyState, bIsShowLog)--获取列表中的控件
	local WidgetArray = self.OccupyInfoList:GetDisplayedEntryWidgets()
	if WidgetArray and WidgetArray:Length() >= 1 then
		for i=1, WidgetArray:Length() do
			local Obj = WidgetArray:Get(i)
			if Obj ~= nil and Obj.OccupyInfoItem.TriggerIndex == TriggerId and Obj.OccupyState == OccupyState and Obj.bIsPlayerInstigate == bIsPlayer then
				return Obj
			end
		end
	end
end

function tbClass:GetOccupyInfoItemIndex(TriggerId, bIsPlayer, OccupyState)--获取列表中的数据索引
	local Num = self.OccupyInfoList:GetNumItems()
	for i = 1,Num do
		local Obj = self.OccupyInfoList:GetItemAt(i - 1)
		if Obj ~= nil and Obj.Data ~= nil then
			if Obj.Data.OccupyState == OccupyState and Obj.Data.TriggerIndex == TriggerId and Obj.Data.InstigatorFlag == bIsPlayer then
				return Obj.Data.ListId
			end
		end
	end
	return -1
end

function tbClass:GetOccupyInfoItem(TriggerId, bIsPlayer, OccupyState)--获取列表中的数据
    local Num = self.OccupyInfoList:GetNumItems()
    for i = 1,Num do
        local Obj = self.OccupyInfoList:GetItemAt(i - 1)
        if Obj ~= nil and Obj.Data ~= nil then
            if Obj.Data.OccupyState == OccupyState and Obj.Data.TriggerIndex == TriggerId and Obj.Data.InstigatorFlag == bIsPlayer then
                return Obj
            end
        end
    end
    return nil
end

function tbClass:UpdateOccupyInfoProgressbar(TriggerId, TbControlTime, NeedTimeToControl, bIsPlayer)
    local Obj = self:GetOccupyInfoWidget(TriggerId, bIsPlayer, 1)
	if Obj ~= nil then
        Obj.OccupyInfoItem:UpdateProgressBar(TbControlTime, NeedTimeToControl)
	end
end

function tbClass:GetAreaUIAt(id)--获取指定controlarea trigger对应的左侧occupy盾牌
	local tArray = self.OccupySummaryList:GetDisplayedEntryWidgets()
	if tArray and tArray:Length() >= id then
		return tArray:Get(id)
	end
end

return tbClass
