-- ========================================================
-- @File    : uw_chess_tpl_grid.lua
-- @Brief   : 棋盘格子模板
-- ========================================================

local view = Class("UMG.SubWidget")

local ColorGreen = UE.FLinearColor(0, 1, 0, 0.8);
local ColorNone = UE.FLinearColor(1, 1, 1, 0.125);

function view:Construct()
    BtnAddEvent(self.BtnSelect, function() self:OnClick() end)
    self:RegisterEvent(Event.NotifyChessLayerFlagChanged, function(idx) self:NotifyChessLayerFlagChanged(idx) end)
    self:RegisterEvent(Event.NotifyChessEditorTypeChanged, function() self:NotifyChessLayerFlagChanged() end)

    ChessEditor:RegisterBtnHoverTip(self.BtnSelect, function() self:ShowTipData() end)
end

function view:SetData(tbData)
    self.tbData = tbData
    self:Refresh()
end

function view:OnClick()
    if (ChessEditor.EditorType ~= ChessEditor.EditorTypeObject and ChessEditor.EditorType ~= ChessEditor.EditorTypeGround) or ChessEditor.CurrentGridId <= 1 then 
        return ChessEditor:SetSelectedObject("grid", self.tbData.gridId)
    end

    local newId = ChessEditor.CurrentGridId > 2 and ChessEditor.CurrentGridId or 0;
    if newId == self.tbData.objectId then 
        return ChessEditor:SetSelectedObject("grid", self.tbData.gridId)
    end
    
    local tbDef = ChessEditor:GetGridDefByTypeId(newId)
    if tbDef and tbDef.Layer > 1 then 
        EventSystem.Trigger(Event.NotifyChessPutObject, {self.tbData.X, self.tbData.Y, newId})
        return;
    end
    
    ChessEditor:ClearSelectedObject()
    self.tbData.objectId = newId
    self:Refresh();
    ChessEditor:Snapshoot()
    EventSystem.Trigger(Event.NotifyChessObjectCountChanged)
    EventSystem.Trigger(Event.NotifyChessUpdateInspector)
end

function view:Refresh()
    local tbRegion = ChessEditor:GetRegionDataById(self.tbData.regionId)
    local tbDef = ChessEditor:GetGridDefByTypeId(self.tbData.objectId)
    if not tbDef or self.tbData.objectId <= 1 then 
        self.tbData.objectId = 0
    end
    if self.tbData.objectId == 0 then 
        ChessEditor:SetGroundObjectId(tbRegion, self.tbData.gridId, nil);
        self:RefreshByObjectId(0)
    else 
        ChessEditor:SetGroundObjectId(tbRegion, self.tbData.gridId, self.tbData.objectId);
        self:RefreshByObjectId(self.tbData.objectId)
    end
end

function view:RefreshByObjectId(objectId)
    if objectId == 0 or not ChessEditor.tbLayerFlag[1] then 
        self.BtnSelect:SetBackgroundColor(ColorNone)
        if ChessEditor.EditorType == ChessEditor.EditorTypeGround or ChessEditor.EditorType == ChessEditor.EditorTypeHeight then 
            self.TxtName:SetText("")
        elseif ChessEditor.EditorType == ChessEditor.EditorTypeEvent then 
            self.TxtName:SetText("")
        elseif ChessEditor.EditorType ~= ChessEditor.EditorTypeNone then 
            self.TxtName:SetText(string.format("%d,%d", self.tbData.X, self.tbData.Y))
        else 
            self.TxtName:SetText("")
        end
    else 
        local tbDef = ChessEditor:GetGridDefByTypeId(objectId)
        if not tbDef then return end

        self.BtnSelect:SetBackgroundColor(tbDef.Background)
        if ChessEditor.EditorType == ChessEditor.EditorTypeHeight then 
            local tb = ChessEditor:GetGroundByGridId(self.tbData.gridId)
            if tb and tb.tbData and tb.tbData.height then 
                self.TxtName:SetText(tb.tbData.height)
            else 
                self.TxtName:SetText("")
            end
        elseif ChessEditor.EditorType == ChessEditor.EditorTypeGround then 
            self.TxtName:SetText(string.format("%d", tbDef.Id))
        elseif ChessEditor.EditorType == ChessEditor.EditorTypeEvent then 
            local tb = ChessEditor:GetGroundByGridId(self.tbData.gridId)
            local count = 0;
            if tb and tb.tbData then 
                for _, tbGroup in ipairs(tb.tbData.tbGroups or {}) do 
                    count = count + #tbGroup.tbEvents
                end
            end
            self.TxtName:SetText(count > 0 and count or "")
        elseif ChessEditor.EditorType ~= ChessEditor.EditorTypeNone then 
            self.TxtName:SetText(string.format("%d,%d", self.tbData.X, self.tbData.Y))
        else 
            self.TxtName:SetText("")
        end
    end

    if ChessEditor:IsObjectSelected("grid", self.tbData.gridId) then  
        self.BtnSelect:SetBackgroundColor(ColorGreen)
    end
end

function view:NotifyChessLayerFlagChanged(index)
    if self.tbData.__isFree then return end 

    if not index or index == 1 then 
        self:RefreshByObjectId(self.tbData.objectId)
    end
end

function view:ShowTipData() 
    local tbDef = ChessEditor:GetGridDefByTypeId(self.tbData.objectId)
    local msg = string.format("id:%d 坐标:%d,%d", self.tbData.gridId, self.tbData.X, self.tbData.Y)
    if tbDef then 
        msg = string.format("%s 地形:%s", msg, tbDef.Name)
    end
    EventSystem.Trigger(Event.NotifyChessTipMsg, msg) 
end

function view:SetSelected(isSelected)
    if isSelected then 
        self.BtnSelect:SetBackgroundColor(ColorGreen)
    else 
        self:RefreshByObjectId(self.tbData.objectId)    
    end
end

return view