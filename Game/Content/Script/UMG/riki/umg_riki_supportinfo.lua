-- ========================================================
-- @File    : umg_riki_supportinfo.lua
-- @Brief   : 图鉴后勤详情
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

tbClass.BasicListItem = "/Game/UI/UMG/Riki/Widgets/uw_riki_supportlist.uw_riki_supportlist_C"
tbClass.StoryListItem = "/Game/UI/UMG/Riki/Widgets/uw_supportlist2.uw_supportlist2_C"
-- local StoryListItem = "/Game/UI/UMG/Support/LogisStory/Widgets/uw_logistics_story_list.uw_logistics_story_list_C"

function tbClass:Construct()
    -- self.Title:SetCustomEvent(function() UI.Open('RikiList',RikiLogic.tbType.Role) end, nil)
    self.Title:SetCustomEvent(function() UI.Close(self) end, nil)

    self.BtnSwitch:SetClickMethod(UE4.EButtonClickMethod.MouseDown)
	self.BtnSwitch:SetTouchMethod(UE4.EButtonTouchMethod.Down)
	self.BtnSwitch.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
			if self.tbItemData.rikiState == RikiLogic.tbState.Lock then
				UI.ShowMessage("ui.RikiSupportUnlock1")
				return
			else
				if not RikiLogic:IsRikiBreakMax(self.tbItemData.pItem) then
					UI.ShowMessage("ui.RikiSupportUnlock2")
					return
				end
			end

            if bChecked then
				WidgetUtils.Collapsed(self.TxtLogisStoryA)
				WidgetUtils.Visible(self.TxtLogisStoryB)
			else
				WidgetUtils.Visible(self.TxtLogisStoryA)
				WidgetUtils.Collapsed(self.TxtLogisStoryB)
			end

			self:ModifierModel(self.tbItemData.pItem, bChecked)
        end
    )
end

function tbClass:OnInit()
	self.Factory = Model.Use(self)

	-- self:DoClearListItems(self.List1)
	-- self:DoClearListItems(self.List2)
	self.ScrollBox_151:ClearChildren()
	self.ScrollBox_373:ClearChildren()


	BtnAddEvent(self.BtnLeft, function()
        local tbObj = self.tbItemData.OnLeft(self.tbItemData.Id)
		self:RefreshItemAttr()
        self:Update(tbObj)
    end)

    BtnAddEvent(self.BtnRight, function()
        local tbObj = self.tbItemData.OnRight(self.tbItemData.Id)
		self:RefreshItemAttr()
        self:Update(tbObj)
    end)
end

function tbClass:Update(tbData)
	PreviewScene.Enter(PreviewType.role_lvup)
	self.tbItemData = tbData
	-- self.tbItemData.rikiState = tbObj.Data.rikiState
	-- self.tbItemData.pItem = tbObj.Data.pItem
	-- self.tbItemData.nId = tbObj.Data.Id

	self.Content:Init({
		{sName = Text('ui.TxtSupportDetail'), nIcon = 1701021, bLock=false},  --详情
        {sName = Text('ui.TxtSupportStory'), nIcon = 1701020, bLock=(self.tbItemData.rikiState==RikiLogic.tbState.Lock)},  --履历
        }, 
        function(_, nPage)
			if nPage == 1 and self.tbItemData.rikiState == RikiLogic.tbState.Lock then
				UI.ShowMessage("ui.RikiSupportUnlock1")
				return
			end
            if self.nPage ~= nPage then
            	self:OpenPage(nPage)
            end
        end
    )
	self.ScrollBox_151:ClearChildren()
	self.ScrollBox_373:ClearChildren()
	WidgetUtils.Collapsed(self.PanelLock)
	if self.tbItemData.rikiState == RikiLogic.tbState.Lock then
		WidgetUtils.Visible(self.PanelLock)
	end
	WidgetUtils.Visible(self.Content)

	self.BtnSwitch:SetIsChecked(false)
	WidgetUtils.Visible(self.TxtLogisStoryA)
	WidgetUtils.Collapsed(self.TxtLogisStoryB)

	self:UpdateSupportInfo()
	self:UpdateInfo()
	self:UpdateStory()
	self:OpenPage(0)
end

function tbClass:OnOpen(data)
	PreviewScene.Enter(PreviewType.role_lvup)
	self.tbItemData = data
	-- self.tbItemData.rikiState = data.rikiState
	-- self.tbItemData.pItem = data.pItem
	-- self.tbItemData.nId = data.Id

	self.Content:Init({
		{sName = Text('ui.TxtSupportDetail'), nIcon = 1701021, bLock=false},  --详情
        {sName = Text('ui.TxtSupportStory'), nIcon = 1701020, bLock=(self.tbItemData.rikiState==RikiLogic.tbState.Lock)},  --履历
        }, 
        function(_, nPage)
			if nPage == 1 and self.tbItemData.rikiState == RikiLogic.tbState.Lock then
				UI.ShowMessage("ui.RikiSupportUnlock1")
				return
			end
            if self.nPage ~= nPage then
            	self:OpenPage(nPage)
            end
        end
    )

    WidgetUtils.Collapsed(self.BtnLeft)
    WidgetUtils.Collapsed(self.BtnRight)
    if self.tbItemData.nTotal > 1 then
        WidgetUtils.Visible(self.BtnLeft)
        WidgetUtils.Visible(self.BtnRight)
    end
	
	WidgetUtils.Collapsed(self.PanelLock)
	if self.tbItemData.rikiState == RikiLogic.tbState.Lock then
		WidgetUtils.Visible(self.PanelLock)
	end
	WidgetUtils.Visible(self.Content)

	self:UpdateSupportInfo()
	self:UpdateInfo()
	self:UpdateStory()
	self:OpenPage(0)
end

function tbClass:UpdateSupportInfo(bMax)
	-- WidgetUtils.Visible(self.TxtLogisStoryA)
	-- WidgetUtils.Collapsed(self.TxtLogisStoryB)
	local pItem = self.tbItemData.pItem
	self.nMaxBreak = 0
	if bMax then
		self.nMaxBreak = Item.GetMaxBreak(pItem)
	end
	SetTexture(self.ImgQuality, Item.RoleColor_short[pItem:Color()])
	self.TextName:SetText(Text(pItem:I18N()))
	self.TxtType:SetText(Text(Logistics.tbTeamDes[pItem:Detail()]))
	SetTexture(self.ImgType, Item.SupportTypeIcon[pItem:Detail()])

	local _,curMax = RikiLogic:IsRikiBreakMax(pItem)
	self.Level:OnOpen({nStar = self.nMaxBreak,nLv =pItem:EnhanceLevel(), bWeapon = false})
	self:ModifierModel(pItem)
end

--- 角色展示模型
function tbClass:ModifierModel(InCard)
	if self.BtnSwitch.CheckedState == 1 and self.tbItemData.rikiState ~= RikiLogic.tbState.Lock and RikiLogic:IsRikiBreakMax(self.tbItemData.pItem) then
    	SetTexture(self.ImgSerPoseA, InCard:IconBreak())
	else
		SetTexture(self.ImgSerPoseA, InCard:Icon())
	end

	if InCard:IconBreak() == InCard:Icon() then
		WidgetUtils.Collapsed(self.BtnSwitch)
	else
		WidgetUtils.Visible(self.BtnSwitch)
	end

	if self.tbItemData.Id and RikiLogic.tbCfg[self.tbItemData.Id] then
		local cfg = RikiLogic.tbCfg[self.tbItemData.Id]
		local tbScale = {1,1}
		local tbTransition = {0,0}
		if bBreak then
			tbScale = cfg.Extension3 and Eval(cfg.Extension3)
			tbTransition = cfg.Extension4 and Eval(cfg.Extension4)
		else
			tbScale = cfg.Extension1 and Eval(cfg.Extension1)
			tbTransition = cfg.Extension2 and Eval(cfg.Extension2)
		end

		self.ImgSerPoseA:SetRenderScale(UE.FVector2D(table.unpack(tbScale)))
		self.ImgSerPoseA:SetRenderTranslation(UE.FVector2D(table.unpack(tbTransition)))
	end
	Preview.PlayCameraAnimByCfgByID(0, PreviewType.role_riki)
end

function tbClass:RefreshItemAttr(bMax)
	if bMax then --最小
        Item.ChangeItemAttr(self.tbItemData.pItem, true)
    else --最大
        Item.ChangeItemAttr(self.tbItemData.pItem)
    end
end

function tbClass:UpdateInfo()
	for i=1, 2 do
		local tbInfo = {}
		tbInfo.nType = i
		tbInfo.ParentUI = self
		tbInfo.pItem = self.tbItemData.pItem
		local pWidget = LoadWidget(self.BasicListItem)
		-- local pObj = self.Factory:Create(tbInfo)
		if pWidget then
			local child = self.ScrollBox_151:AddChild(pWidget)
	        -- child:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Right)
	        pWidget:Display(tbInfo)
	    end
		-- self.List1:AddItem(pObj)
	end
end

function tbClass:UpdateStory()
	local pItem = self.tbItemData.pItem
	local sGDPL = string.format("%d-%d-%d-%d", pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level())
	local cfg = Logistics.tbLogiData[sGDPL]
    if not cfg then 
        UI.ShowTip(Text("congif_err"))
        return
    end

    local storyUnlock = cfg.StoryUnlock
    local I18n = cfg.I18n
    for i = 1, #storyUnlock do
        local tbParam = {
            Index = i,
            SupportCard = pItem,
            StoryTitle = Text("ui.TxtSupportStorytitle"..i),
            StoryContent = Text(I18n.. "_story".. i) or "Story"..i,
            UnlockStars = storyUnlock[i],
            MaxBreak = self.nMaxBreak,
            bExpand = i == 1
        }
        local pWidget = LoadWidget(self.StoryListItem)
        if pWidget then
        	-- local addedItem = self.List2:AddItem(pWidget)
            local child = self.ScrollBox_373:AddChild(pWidget)
            child:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Right)
            pWidget:Display(tbParam)
        end
    end
    -- self.List2:SetScrollable(false)
end

function tbClass:OpenPage(nPage)
	-- if nPage ~= 0 and self.tbItemData.rikiState ~= RikiLogic.tbState.Lock then
	-- 	return
	-- end

	WidgetUtils.Collapsed(self.PanelInfo)
	WidgetUtils.Collapsed(self.PanelStory)
	if nPage == 0 then
		WidgetUtils.Visible(self.PanelInfo)
	elseif nPage == 1 then
		WidgetUtils.Visible(self.PanelStory)
	end

	self.Content:SelectPage(nPage)
	self.nPage = nPage
end


return tbClass