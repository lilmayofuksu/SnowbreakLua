HouseFurniture = HouseFurniture or {}
local tbClass = HouseFurniture

function tbClass:LoadCfg()
	self.tbFurniturePos = {}
	local tbFile = LoadCsv('house/furniturePos.txt', 1)
    for _, tbLine in ipairs(tbFile) do
    	local areaId = tonumber(tbLine.AreaId);
    	local posId = tonumber(tbLine.PosId)
    	local tbFurTmp = Eval(tbLine.FurnitureTmpId)
    	if areaId and not self.tbFurniturePos[areaId] then
    		self.tbFurniturePos[areaId] = {}
    	end
    	if posId and not self.tbFurniturePos[areaId][posId] then
    		self.tbFurniturePos[areaId][posId] = tbFurTmp
    	end
    end

    self.tbSupportFurniture = {};
	local tbFile2= LoadCsv('house/support_furniture.txt', 1)
    for _, tbLine in ipairs(tbFile2) do
    	local areaId = tonumber(tbLine.AreaId);
    	local index = tonumber(tbLine.Index)
    	local furnitureTmpId = tonumber(tbLine.FurnitureTmpId)
    	if areaId and not self.tbSupportFurniture[areaId] then
    		self.tbSupportFurniture[areaId] = {}
    	end
    	if index and not self.tbSupportFurniture[areaId][furnitureTmpId] and furnitureTmpId then
    		self.tbSupportFurniture[areaId][furnitureTmpId] = index
    	end
    end
end

--获取某位置的家具id，如果未获得就返回0,如果是单机关卡就返回-1
function tbClass.GetFurTmpId(AreaId,PosId)
	if not me then
		return -1
	end
	if not HouseFurniture.tbFurniturePos or not HouseFurniture.tbFurniturePos[AreaId] or not HouseFurniture.tbFurniturePos[AreaId][PosId] then
		return -1
	end
	if #HouseFurniture.tbFurniturePos[AreaId][PosId] == 0 then
		return -1
	end
	local index = 1 --me:GetAttribute()
	local tmpId = HouseFurniture.tbFurniturePos[AreaId][PosId][index]
	if not tmpId or not HouseFurniture.CheckFurnitureById(AreaId,tmpId) then
		return -1
	end
	return tmpId;
end

function tbClass.CheckFurnitureById(AreaId,TmpId)
	local self = HouseFurniture;
	local index = self:ConvertFurnitureTmpIdToIndex(AreaId,TmpId);
	if index > 0 then
		return self:CheckHasFurnitureInternel(AreaId,index,1);
	else
		return false;
	end
end

function tbClass:ConvertFurnitureTmpIdToIndex(AreaId,TmpId)
	--返回-1说明此家具不支持送给对应Area
	if not self.tbSupportFurniture or not self.tbSupportFurniture[AreaId] or not self.tbSupportFurniture[AreaId][TmpId] then
		return -1
	end
	return self.tbSupportFurniture[AreaId][TmpId]
end

function tbClass:CheckHasFurnitureInternel(AreaId,Index,Count)
	return HouseStorage.CheckHasFurnitureInternel(AreaId,Index,Count)
end

function tbClass:GetFurnitureCount(AreaId,TmpId)
	local index = self:ConvertFurnitureTmpIdToIndex(AreaId,TmpId);
	if index > 0 then
		return HouseStorage.GetFurnitureInternel(AreaId,index);
	else
		return 0;
	end
end

function tbClass.OnFurnitureCameraAnimBegin()
	--UI.Close('DormPresent2')
    --HouseLogic.EndTalk()
    --[[local ui = UI.GetTop()
    local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
    for i = 1,Widgets:Length() do
    	WidgetUtils.Hidden(Widgets:Get(i))
    end]]
    --UI.Open('DormSkipFurAnim')
end

function tbClass.OnFurnitureCameraAnimEnd()
	--[[local ui = UI.GetTop()
	local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
    for i = 1,Widgets:Length() do
    	WidgetUtils.Visible(Widgets:Get(i))
    end]]
    UI.CloseByName('DormSkipFurAnim')
    UI.CloseByName('DormPresent')
    UI.CloseByName('DormPresentSend')
    --UI.CloseByName('DormDialogue')

    HouseGiftLogic:OnGiveGiftSuccessAnimEnd()
end

return tbClass;