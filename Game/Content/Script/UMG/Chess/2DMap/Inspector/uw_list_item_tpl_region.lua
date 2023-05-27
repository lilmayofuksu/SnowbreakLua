-- ========================================================
-- @File    : uw_list_item_tpl_region.lua
-- @Brief   : 模板
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorGrey = UE.FLinearColor(0.5, 0.5, 0.5, 1);

function view:Construct()
    BtnAddEvent(self.BtnAdd, function() self:OnBtnClickAdd() end) 
    BtnAddEvent(self.Select, function() self:OnClick() end) 
    BtnAddEvent(self.BtnSetting, function() self:OnBtnClickSetting() end) 

    self:RegisterEvent(Event.NotifyChessSelectRegion, function(regionId) self:UpdateRegionDetail() end)
    self:RegisterEvent(Event.NotifyChessRegionDetailChanged, function() self:UpdateRegionDetail() end)

    ChessEditor:RegisterBtnHoverTip(self.BtnAdd, "点击创建一个新的区域")
end

function view:OnListItemObjectSet(pObj)
    self.Data = pObj.Data
    self:UpdateRegionDetail()
end


function view:GetSize() 
    if not ChessEditor:CheckHasData() then return end
    
    local tbReginData = ChessEditor:GetRegionDataById(self.Data.Id)
    if tbReginData then 
        return {tbReginData.RangeX.max - tbReginData.RangeX.min + 1, tbReginData.RangeY.max - tbReginData.RangeY.min + 1}
    end
end

function view:OnBtnClickAdd()
    if not ChessEditor:CheckHasData() then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "请先创建地图")
    end
    if ChessEditor.IsGridHintMode then 
        return EventSystem.Trigger(Event.NotifyChessErrorMsg, "格子选择模式下，不允许放置新区域！")
    end
    local tb = ChessEditor.tbMapData.tbData.tbRegions
    if not tb[self.Data.Id] then 
        ChessEditor:CreateDefaultRegion(self.Data.Id, tb)
        EventSystem.Trigger(Event.NotifyChessPutRegion, self.Data.Id);
        ChessEditor:SetEditorType(ChessEditor.EditorTypeRegion)
        self:UpdateRegionDetail()
    end
    ChessEditor:SetCurrentRegionId(self.Data.Id)
    ChessEditor:Snapshoot()
end

function view:OnClick()
    if ChessEditor.CurrentRegionId == self.Data.Id then 
        return 
    end
    local tb = ChessEditor:GetRegionDataById(self.Data.Id)
    if tb and tb.RangeX then 
        ChessEditor:SetCurrentRegionId(self.Data.Id)
        ChessEditor:Snapshoot()
    end
end

function view:OnBtnClickSetting()
    self:OnClick()
    EventSystem.Trigger(Event.NotifyChessModifyRegionSetting, {Id = self.Data.Id})
end

function view:UpdateRegionDetail()
    local size = self:GetSize()
    if size then 
        self.TxtName:SetText(string.format("%d 区域 [%d,%d]", self.Data.Id, size[1], size[2]))
    else 
        self.TxtName:SetText(string.format("%d 区域 (未放置)", self.Data.Id))
    end

    if self.Data.Id == ChessEditor.CurrentRegionId then 
        self.Select:SetBackgroundColor(ColorGreen)
    else 
        self.Select:SetBackgroundColor(ColorGrey)
    end

    if self.Data.isAdd then 
        WidgetUtils.SetVisibleOrCollapsed(self.BtnAdd, true)    
        WidgetUtils.SetVisibleOrCollapsed(self.BtnSetting, false)    
        WidgetUtils.SetVisibleOrCollapsed(self.Select, false)    
    else 
        WidgetUtils.SetVisibleOrCollapsed(self.BtnAdd, false)    
        WidgetUtils.SetVisibleOrCollapsed(self.BtnSetting, true)    
        WidgetUtils.SetVisibleOrCollapsed(self.Select, true)    
    end
end



return view