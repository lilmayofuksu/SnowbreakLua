-- ========================================================
-- @File    : umg_riki_exploreinfo.lua
-- @Brief   : 图鉴探索详情
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
self.Title:SetCustomEvent(
        function() 
        	-- self:StopSound()
            UI.Close(self);
        end, 
        function() 
        	-- self:StopSound()
            -- UI.Close(self);
            UI.OpenMainUI()
            UI.GC()

        end)
	self:DoClearListItems(self.ListMail)
end


function tbClass:OnInit()
	self.Factory = Model.Use(self);
	self.nCurrentItem = 0;
	self.tbItems = {};
	self.ItemSort = {}
	self.bChooseGet = false

	WidgetUtils.Collapsed(self.BtnPlay);

	BtnAddEvent(
		self.BtnPlay, 
    	function()
    		if self.Conponent == nil then
    			self:PlayExploreSound(self.nCurrentItem)
    		else
    			self:StopSound()
    		end
        end
        )
end

function tbClass:OnClose()
	self:StopSound()
end

function tbClass:OnOpen(tbData)
	self.Type = tbData.type
	self.TxtTitle_1:SetText(Text(tbData.sName))
	self:GetExploreItemList()
	self:Update()

	self.ListMail:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
	
	self.Check1.OnCheckStateChanged:Add(self,
        function(_, bChecked)
        	self.bChooseGet = bChecked
        	self:Update()
        end)


end

function tbClass:GetExploreItemList()
	local configList = RikiLogic:GetExploreList(self.Type)

	
	local itemList = {}
	if configList[1] then
		self.nCurrentItem = configList[1].Id or 0
	end
	for _,config in pairs(configList or {}) do
		local tbData = {}
		tbData.ExploreID = config.ExploreID
		tbData.TitleImg = config.TitleImg
		tbData.RikiID = config.Id
		tbData.tbConfig = config

		local nGet,nNew = RikiLogic:GetRiki(config.Id)
		tbData.nGet = nGet
		local pObj = self.Factory:Create(tbData);
		pObj.ParentUI = self;
		tbData.Show = function()
			WidgetUtils.Visible(self.PanelContent);

			if tbData.tbConfig.Extension2 then
				WidgetUtils.Visible(self.Icon);
				WidgetUtils.Visible(self.Image_101);
				SetTexture(self.Icon, tonumber(tbData.tbConfig.Extension2))
			else
				WidgetUtils.Collapsed(self.Icon);
				WidgetUtils.Collapsed(self.Image_101);
			end
			local fragmentConfig =  FragmentStory.tbConfig[tbData.ExploreID]
			if not fragmentConfig then
				return
			end
			self.ScrollBox_137:ScrollToStart()
			if fragmentConfig.sContent then
				self.TxtContent:SetText(Text(fragmentConfig.sContent));
			else
				self.TxtContent:SetText(Text(fragmentConfig.sDesc));
			end
			self.TxtMailTitle:SetText(Text(fragmentConfig.sTitle))

			WidgetUtils.Collapsed(self.Lock);
			WidgetUtils.Collapsed(self.Normal)

			if tbData.nGet == 1 then
				WidgetUtils.Visible(self.Normal);
			else
				WidgetUtils.Visible(self.Lock);
				
				local sContent 
				if fragmentConfig.nLevel == 1 or fragmentConfig.nLevel == 2 then  --主线
					tbCfg = ChapterLevel.Get(fragmentConfig.sChapter, true)

					sContent = string.format(Text('riki.fragment_story_'..fragmentConfig.nLevel), GetLevelName(tbCfg))
				elseif fragmentConfig.nLevel == 3 then
					sContent = string.format(Text('riki.fragment_story_'..fragmentConfig.nLevel))
				elseif fragmentConfig.nLevel == 4 then
					tbCfg = DLCLevel.Get(fragmentConfig.sChapter)
					sContent = string.format(Text('riki.fragment_story_'..fragmentConfig.nLevel), Text(tbCfg.sName))
				end
				-- if fragmentConfig.nLevel == CHAPTER_LEVEL.NORMAL then
				-- 	sContent = string.format(Text('riki.fragment_story_1'), fragmentConfig.sChapter)
				-- elseif fragmentConfig.nLevel == CHAPTER_LEVEL.DIFFCULT then
				-- 	sContent = string.format(Text('riki.fragment_story_2'), fragmentConfig.sChapter)
				-- else
				-- 	sContent = Text('riki.fragment_story_3')
				-- end
				self.TxtTips:SetText(sContent);
			end
			WidgetUtils.Collapsed(self.BtnPlay)
			self:StopSound()
			if fragmentConfig.sWwise_event then
				WidgetUtils.Visible(self.BtnPlay);
				WidgetUtils.Visible(self.ImgPlay);
				WidgetUtils.Collapsed(self.ImgPause);
			end
			if self.tbItems[self.nCurrentItem] then
            	self.tbItems[self.nCurrentItem].UI_List:SetSelected(false);
        	end
        	self.nCurrentItem = tbData.RikiID;
			pObj.UI_List:SetSelected(true);
		end
		self.tbItems[tbData.RikiID] = pObj
		table.insert(self.ItemSort,tbData.RikiID)
	end

end

function tbClass:Update()
	--根据是否解锁初始化item列表
	self:DoClearListItems(self.ListMail)
	for _,nRikiId in pairs(self.ItemSort) do
		local pObj = self.tbItems[nRikiId]
		if pObj and (self.bChooseGet == false or pObj.Data.nGet ~= 0) then
			if pObj.Data.RikiID == self.nCurrentItem then
				if pObj.UI_List then
					pObj.Data.Show()
				else
					pObj.Data.bSelected = true
				end
			end
			self.ListMail:AddItem(pObj);
			
		end
	end
end

function tbClass:PlayExploreSound(nRikiID)
	local pObj = self.tbItems[nRikiID]
	if not pObj then
		return
	end

	local fragmentConfig = FragmentStory.tbConfig[pObj.Data.ExploreID]
	if not fragmentConfig then
		return
	end

	if self.Conponent then
		self:StopSound()
	end
	if fragmentConfig.sWwise_event then
		-- Audio.PlayVoices(fragmentConfig.VoiceID)
		WidgetUtils.Collapsed(self.ImgPlay);
		WidgetUtils.Visible(self.ImgPause);
		self.Conponent = UE4.UWwiseLibrary.PostEvent2DWithCallback(GetGameIns(), fragmentConfig.sWwise_event, {
            self,
            function()
            	WidgetUtils.Visible(self.ImgPlay);
				WidgetUtils.Collapsed(self.ImgPause);

				self.Conponent = nil
            end
        })
	end
end

function tbClass:StopSound()
	if self.Conponent then
		
		self.Conponent:Stop(false)
		WidgetUtils.Visible(self.ImgPlay);
		WidgetUtils.Collapsed(self.ImgPause);
		self.Conponent = nil
	end
end

return tbClass