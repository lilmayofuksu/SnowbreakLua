-- ========================================================
-- @File    : uw_dorm_dialogua.lua
-- @Brief   : 宿舍3D对话
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

local path = "/Game/UI/UMG/Dorm/Widgets/uw_dorm_dialogue"

tbClass.HasShow = false;

function tbClass:OnInit()
	self:ShowTalk()
end

function tbClass:OnOpen(tbParam)
	if tbParam and tbParam.Type == 1 then
		self:PlayAfterAnimTalk(tbParam)
		return;
	end
end

function tbClass:ShowTalk()
	if self.HasShow or self.TalkNpcId <= 0 then
		return
	end
	WidgetUtils.Visible(self.ListBTNS)
	self.HasShow = true;
	local tbOptions = HouseTalk:GetNpcTalkOptions(self.TalkNpcId,self.TalkGirlId)
	if #(tbOptions or {}) == 0 then
		UI.Close(self)
		local player = UE4.UGameplayStatics.GetPlayerController(self,0)
	    local housePlayer = player:Cast(UE4.AHousePlayerController)
	    if housePlayer then
	        housePlayer:SetBlockControl(false)
	    end
	    self:ShowMouseCursor(false)
		return
	end
	self:DoClearListItems(self.ListBTNS)
	self.Factory = Model.Use(self)
	for i,v in ipairs(tbOptions or {}) do
		if not v.OptionCondition or HouseTalk:DealOptionFunc(v.OptionCondition,{self.TalkNpcId,self.TalkGirlId}) then
			local tbParam = {NpcId = self.TalkNpcId,GirlId = self.TalkGirlId,OptionInfo = v}
			self.ListBTNS:AddItem(self.Factory:Create(tbParam))
		end
	end
	self.DialogueText:SetContent(HouseTalk:GetTalkShow(self.TalkNpcId))
	self.Speaker:SetText(Text('house.NpcName'..self.TalkNpcId))
end

function tbClass:ShowMouseCursor(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function tbClass:OnTalkEnd()
	self.HasShow = false;
	self.TalkNpcId = -1
end

function tbClass:PlayAfterAnimTalk(tbParam)
	local SpeakerName = tbParam.SpeakerName
	local Content = tbParam.Content
	self.DialogueText:SetContent(Text(Content))
	if SpeakerName then
		self.Speaker:SetText(Text(SpeakerName))
	else
		self.Speaker:SetText(Text('house.NpcName2'))
	end
	WidgetUtils.Collapsed(self.ListBTNS)
	WidgetUtils.Visible(self.BtnCameraAnim)
	BtnClearEvent(self.BtnCameraAnim)
	BtnAddEvent(self.BtnCameraAnim,function ( ... )
		UI.Close(self)
		UI.Open('DormSkipFurAnim')
		local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
		if Mode then
			Mode:BeforePlayCameAnim(tbParam.AreaId)
		end
	end)
	--[[UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
						local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
						if Mode then
							Mode:PlayNextCameraView()
						end
						UI.Close(self)
                    end
                },
                2,
                false
            )]]
end

return tbClass;