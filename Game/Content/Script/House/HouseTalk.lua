HouseTalk = HouseTalk or {}

function HouseTalk:LoadCfg()
	self.tbNpcTalkOptions = {}
	--self.tbNpcTalkActions = {}
	local tbFile = LoadCsv('house/talk_options.txt', 1)
    for _, tbLine in ipairs(tbFile) do
    	local npcId = tonumber(tbLine.NpcId);
    	local tbOptions = {}
    	for i=1,5 do
    		if tbLine['OptionKey'..i] then
    			tbOptions[i] = {}
    			tbOptions[i].OptionKey = tbLine['OptionKey'..i]
    			tbOptions[i].OptionFunc = Eval(tbLine['OptionFunc'..i])
    			tbOptions[i].OptionCondition = tbLine['OptionCondition'..i]
    			tbOptions[i].OptionIcon = tonumber(tbLine['OptionIcon'..i])
    		end
    	end
    	self.tbNpcTalkOptions[npcId] = tbOptions;

    	--self.tbNpcTalkActions[npcId] = tbLine['TalkActionPath']
    end

    self.tbNpcTalkRandom = {}
    local tbFile2 = LoadCsv('house/random_talk.txt',1)
    for _, tbLine in ipairs(tbFile2) do
    	local npcId = tonumber(tbLine.NpcId);
    	local index = tonumber(tbLine.Index)
    	if not self.tbNpcTalkRandom[npcId] then
    		self.tbNpcTalkRandom[npcId] = {}
    	end
    	self.tbNpcTalkRandom[npcId][index] = tbLine.RandomKey or 'NoCfg';
    end

	self.tbNpcTalkDaily = {}
	local tbFile3 = LoadCsv('house/daily_talk.txt',1)
    for _, tbLine in ipairs(tbFile3) do
    	local GirlId = tonumber(tbLine.GirlId)
    	local StoryId = tonumber(tbLine.StoryId)
    	local AreaId = tonumber(tbLine.StoryArea)
		if GirlId and StoryId then
			if not self.tbNpcTalkDaily[GirlId] then
				self.tbNpcTalkDaily[GirlId] = {}
			end
			self.tbNpcTalkDaily[GirlId][StoryId] = {key = tbLine.StoryKey or 'NoCfg',areaId = AreaId};
		end
    	
    end
end

--[[function HouseTalk:GetNpcTalkActionPath(NpcId)
	return self.tbNpcTalkActions and self.tbNpcTalkActions[NpcId]
end]]

--return {{OptionKey,OptionFunc = 'FuncName'},...}
function HouseTalk:GetNpcTalkOptions(NpcId)
	if self.tbNpcTalkOptions and self.tbNpcTalkOptions[NpcId] then
		return self.tbNpcTalkOptions[NpcId]
	end
end

function HouseTalk:DealOptionFunc(FuncStr,tbParams)
	if not FuncStr or type(tbParams) ~= 'table' then
		return
	end
	if not self[FuncStr] then
		return
	end
	--UI.Close('DormDialogue')
	return self[FuncStr](self,table.unpack(tbParams))
end

function HouseTalk:DealFunc(FuncStr)
	if not FuncStr or not self[FuncStr] then
		return
	end
	return self[FuncStr](self)
end

--打开剧情界面
function HouseTalk:ShowPlotUI(NpcId,GirlID)
	UI.Open('DormLoveStory',GirlID)
end

--打开送礼界面
function HouseTalk:ShowGiftUI(NpcId,GirlID,AreaId)
	--[[local gifts = HouseGiftLogic:GetGiftsHad(self.AreaId)
	if gifts:Length() == 0 then
		UI.ShowTip("tip.house.NoGift")
		return
	end]]
	if HouseLogic:CheckIsGirl(AreaId) then
		UI.Open('DormPresentSend',AreaId)
	else
		UI.Open('DormPresent2',AreaId)
	end
end

function HouseTalk:ShowExChangeGiftUI( NpcId,GirlID )
	UI.Open('DormPresent')
end

--再见
function HouseTalk:SayBye(NpcId,GirlID)
	HouseLogic.EndTalk()
end

function HouseTalk:PlayAction(NpcId,GirlID,Path)
	local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
	local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
    if HouseMode then
    	Mode:LetNpcPlayAction(NpcId,Path)
    end
end

function HouseTalk:RandomEvent(NpcId,GirlID)
	if GirlID <= 0 then
		return false
	end
	local EventId = HouseStorage.GetCharacterAttr(GirlID, HouseStorage.EGirlAttr.DailyEvent)
	if EventId and EventId > 0 then

		self:DoDailyTalk(GirlID, function()

			local StoryKey = HouseTalk:GetDailyStoryKey(GirlID, EventId)
			if StoryKey then
				local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
				if Mode then
					local BedRoomMgr = Mode:GetBedRoomMgr()
					local func = function()
						HouseGirlLove:Play3DStory(StoryKey.key,nil,function ()
							local ui = UI.GetUI('DormDialogue')
							if ui then
								ui:OnOpen()
							end
							local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
							if Mode then
								local brm = Mode:GetBedRoomMgr()
	                            if brm then
	                                brm:On3DStoryPlayEnd()
	                            end
							end
						end)
					end
					if BedRoomMgr then
						BedRoomMgr:Before3DStoryPlay(StoryKey.areaId,{GetGameIns(),func})
					end
				end
			end
		end)
	end
end

function HouseTalk:HasAnyRandomEvent(NpcId,GirlID)
	if GirlID <= 0 then
		return false
	end
	local EventId = HouseStorage.GetCharacterAttr(GirlID, HouseStorage.EGirlAttr.DailyEvent)
	if EventId and EventId > 0 then
		return true
	end
	return false
end

function HouseTalk:IsGirlLiveIn(NpcId,GirlID)
	local roomId = HouseBedroom.GetGirlBedroomId(GirlID)
	return roomId and roomId > 0
end

--对话时显示随机一句话
function HouseTalk:GetTalkShow(NpcId)
	if not self.tbNpcTalkRandom[NpcId] then
		return 'NoCfg'
	end
	local maxIndex = #self.tbNpcTalkRandom[NpcId]
	if maxIndex < 1 then
		return 'NoCfg'
	end
	local index = math.random(1,maxIndex) 
	return Text(self.tbNpcTalkRandom[NpcId][index])
end

function HouseTalk:DoDailyTalk(GirlId, InCallback)
	HouseMessageHandle.HouseMessageSender({
		FuncName = 'DoDailyTalk',
		GirlId = GirlId,
	}, InCallback)
end

function HouseTalk:PlayAfterAnimTalk(AreaId,ThanksKey)
	local InGirlId = HouseGiftLogic.GiftGivenAreaId or 0
	local RoleTemplate
	if InGirlId ~= 0 then
		RoleTemplate = UE4.UItem.FindTemplate(1, InGirlId, 1, 1)
	end
	local tbParam = {
		SpeakerName = RoleTemplate and RoleTemplate.I18N,
		Content = ThanksKey,
		Type = 1,
		AreaId = AreaId,
	}
	if not UI.IsOpen('DormDialogue') then
		UI.Open("DormDialogue", tbParam)
	else
		local ui = UI.GetUI('DormDialogue')
		ui:OnOpen(tbParam)
	end
end

function HouseTalk:GetDailyStoryKey(GirlId, StoryId)
	if self.tbNpcTalkDaily[GirlId] then
		return self.tbNpcTalkDaily[GirlId][StoryId]
	end
end

function HouseTalk:OpenDormRoom()
	local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
	UI.Open("DormRoom", PlayerController)
end

return HouseTalk;
