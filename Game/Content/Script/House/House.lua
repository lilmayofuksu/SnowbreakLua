HouseLogic = HouseLogic or {}
local tbClass = HouseLogic

require 'House.HouseStorage'
require 'House.HouseFurniture'
require 'House.HouseGift'
require 'House.HouseMessageHandle'
require 'House.HouseTalk'
require 'House.HouseBedroom'
require 'House.HouseGirlLove'

function tbClass:LoadCfg()
	HouseFurniture:LoadCfg()
	HouseGiftLogic:LoadCfg()
	HouseTalk:LoadCfg()
	HouseGirlLove:LoadCfg()
	self.tbAreaIcon = {}
    local tbFile = LoadCsv('house/area_icon.txt',1)
    for _, tbLine in ipairs(tbFile) do
    	local AreaId = tonumber(tbLine.AreaId or 0)
    	local Icon = tonumber(tbLine.Icon or 0)
    	
    	self.tbAreaIcon[AreaId] = Icon
    end 
	EventSystem.On("HousePlayerLoaded",self.OpenUI)
end

function tbClass:LoadHouse()
	UE4.UMapManager.Open(20, sOption or '')
end

function tbClass.OpenUI()
	UI.Open('Dorm')
end

function tbClass.TalkWith(InNpcId,GirlID)
	local ui = UI.GetUI('Dorm')
	if ui then
		ui:TalkWith(InNpcId,GirlID)
	end
	--return HouseTalk:GetNpcTalkActionPath(InNpcId)
end

function tbClass.EndTalk()
	local ui = UI.GetUI('Dorm')
	if ui then
		ui:EndTalk()
	end
end

--检测Npc有无新事件(地图上显示)
function tbClass:GetNpcHasNew(NpcId)
	return false;
end

function tbClass.CheckHasGirlSuitCard(GirlId,SuitId)
	if not me then
		return false;
	end
	local AllCharacter = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(AllCharacter)
    for i=1,AllCharacter:Length() do
    	local Card = AllCharacter:Get(i)
    	if Card and Card:Detail() == GirlId and Card:Particular() == SuitId then
    		return true;
    	end
    end
    return false;
end

function tbClass.CheckHasGirl(GirlId)
	if not me then
		return false;
	end
	local AllCharacter = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(AllCharacter)
    for i=1,AllCharacter:Length() do
    	local Card = AllCharacter:Get(i)
    	if Card and Card:Detail() == GirlId then
    		return true;
    	end
    end
    return false;
end

function tbClass:GetGirlIcon(GirlId)
    local Template = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
    if Template then
    	return Template.Icon
    else
    	return ''
    end
end

function tbClass:GetAreaIcon( AreaId )
	return self.tbAreaIcon and self.tbAreaIcon[AreaId]
end

function tbClass:CheckIsGirl(AreaId)
	return AreaId > 0 and AreaId < 50
end

function tbClass.OnClickMap()
	if UI.IsOpen('DormMap') then
		UI.Close('DormMap')
	else
		UI.Open('DormMap',0)
	end
end

function tbClass.OnClickEsc()
	if UI.IsOpen('Dorm') then
		UI.Open('DormMap',0)
	end
end

function tbClass.ShowUIMask(bShow)
	--[[local ui = UI.GetUI('Dorm')
	if ui then
		ui:ShowUIMask(bShow)
	end]]
	if bShow then
		UI.Open('DormMask')
	else
		local ui = UI.GetUI('DormMask')
		--UI.Close('DormMask')
		if ui then
			ui:HideMask()
		end
	end
end

function tbClass:GetGirlName(GirlId)
	local RoleTemplate = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
	local GirlName = Text(RoleTemplate and RoleTemplate.I18N) or ''
	return GirlName
end

function tbClass.ShowTip(key,girlId)
	if not girlId then
		UI.ShowTip(Text(key))
	else
		local RoleTemplate = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
		local GirlName = Text(RoleTemplate and RoleTemplate.I18N)
		local str = string.format(Text(key),GirlName)
		UI.ShowTip(str)
	end
end

function tbClass.ShowHouseBubble(InCharacter,InTexId,bShow)
	local ui = UI.GetUI('Dorm')
	if ui then
		if bShow then
			ui:AddBubble(InCharacter,InTexId)
		else
			ui:RemoveBubble(InCharacter,InTexId)
		end
	end
end

function tbClass:ShowMouseCursor( bShow )
	RuntimeState.ChangeInputMode(bShow)
end

--玩家是否处于切场景等无法操作的情况
function tbClass:IsPlayerCanControl()
	local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
    local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
    if IsValid(HouseMode) then
        local BedRoomMgr = HouseMode:GetBedRoomMgr()
        if IsValid(BedRoomMgr) and BedRoomMgr:IsInLoading() then
        	return false;
        end
    end

    local player = UE4.UGameplayStatics.GetPlayerController(GetGameIns(),0)
    if IsValid(player) then
	    local housePlayer = player:Cast(UE4.AHousePlayerController)
	    if IsValid(housePlayer) then
	        if housePlayer:IsInCartoon() or housePlayer:IsInBlockControl() then
	        	return false;
	        end
	    end
	end
    return true;
end

tbClass:LoadCfg()

return tbClass;