-- ========================================================
-- @File    : uw_chess_panel_object.lua
-- @Brief   : 棋盘物件编辑
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbPool = {}        -- pool
    self.tbCurrent = {}     -- 当前使用

    self:RegisterEvent(Event.NotifyChessPutObject, function(tbParam) self:NotifyChessPutObject(tbParam) end)
    self:RegisterEvent(Event.NotifyChessDeleteObject, function(Id) self:NotifyChessDeleteObject(Id) end)
    self:RegisterEvent(Event.NotifyChessSelectedObject, function(tbParam, isSelected) self:OnChessSelectedObject(tbParam, isSelected) end)

    self:RegisterEvent(Event.NotifyChessRegionRefresh, function(Id) 
        -- 加定时器是为了避免界面闪烁
        UE4.Timer.Cancel(self.timerId or 0)
        self.timerId = UE4.Timer.Add(0.01, function() self:NotifyChessRegionRefresh(Id) end)
    end)
    
end

function view:NotifyChessPutObject(tbParam)
    local x = tbParam[1];
    local y = tbParam[2];
    local typeId = tbParam[3];

    local mapData = ChessEditor.tbMapData.tbData;
    mapData.MaxObjectId = mapData.MaxObjectId + 1;

    local regionData = ChessEditor:GetCurrentRegionData(); 
    local tb = ChessEditor:NewObjectData(typeId, x, y)
    regionData.tbObjects[mapData.MaxObjectId] = tb;
    self:ShowObject(mapData.MaxObjectId, tb)
    EventSystem.Trigger(Event.NotifyChessObjectCountChanged)
    ChessEditor:Snapshoot()
    ChessEditor:ClearSelectedObject()
end

function view:GetObjectRoot(layer)
    if layer == 2 then return self.PanelLayer1 end
    if layer == 3 then return self.PanelLayer2 end
    if layer == 4 then return self.PanelLayer3 end
    return self.PanelLayer3;
end

function view:NotifyChessRegionRefresh(Id)
    self:FreeAll()
    if not Id or Id <= 0 or Id ~= ChessEditor.CurrentRegionId then return end
    
    self.tbRegion = ChessEditor:GetCurrentRegionData()
    local SizeX = self.tbRegion.RangeX.max - self.tbRegion.RangeX.min + 1
    local SizeY = self.tbRegion.RangeY.max - self.tbRegion.RangeY.min + 1
    self.halfSize = UE.FVector2D(SizeX * 50, SizeY * 50) 

    for id, tbData in pairs(self.tbRegion.tbObjects) do 
        self:ShowObject(id, tbData);
    end
end

function view:ShowObject(objectId, tbParam)
    local tbDef = ChessEditor:GetGridDefByTypeId(tbParam.tpl)
    if not tbDef then 
        tbParam.tpl = ChessEditor:GetValidObjectId()
        tbDef = ChessEditor:GetGridDefByTypeId(tbParam.tpl)
    end
    local tbObj = self:Alloc(objectId, self:GetObjectRoot(tbDef.Layer))

    tbObj.tbParam = tbParam
    tbObj.tbRegion = self.tbRegion
    tbObj.halfSize = self.halfSize
    tbObj.dragParent = self.PanelLayer1;
    tbObj.widget:SetData(tbObj)
end

function view:NotifyChessDeleteObject(objectId)
    self.tbRegion.tbObjects[objectId] = nil
    self:FreeByKey(objectId)
    ChessEditor:Snapshoot()
end

function view:OnChessSelectedObject(tbParam, isSelected)
    if tbParam.type ~= "object" then return end

    local tbData = self.tbCurrent[tbParam.id]
    if tbData then 
        tbData.widget:SetSelected(isSelected)
    end
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:Alloc(Id, Parent)
    local tbData;
    if #self.tbPool > 0 then 
        tbData = self.tbPool[#self.tbPool]
        Parent:AddChild(tbData.widget)
        WidgetUtils.Visible(tbData.widget)
        table.remove(self.tbPool, #self.tbPool)
    else 
        tbData = {}
        local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Center/uw_chess_tpl_object.uw_chess_tpl_object_C")
        Parent:AddChild(widget)
        tbData.widget = widget
    end
    tbData.widget.wSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(tbData.widget)
    tbData.widget.wSlot:SetAlignment(UE.FVector2D(0.5, 0.5))
    tbData.widget.wSlot:SetMinimum(UE.FVector2D(0.5, 0.5))
    tbData.widget.wSlot:SetMaximum(UE.FVector2D(0.5, 0.5))
    tbData.Id = Id
    self.tbCurrent[Id] = tbData
    return tbData;
end

function view:FreeAll()
    for _, tb in pairs(self.tbCurrent) do 
        WidgetUtils.Collapsed(tb.widget)
        table.insert(self.tbPool, tb)
    end
    self.tbCurrent = {}
end

function view:FreeByKey(key)
    local tb = self.tbCurrent[key]
    if tb then 
        WidgetUtils.Collapsed(tb.widget)
        table.insert(self.tbPool, tb)
        self.tbCurrent[key] = nil
    end
end
---------------------------------------------------------------------


return view