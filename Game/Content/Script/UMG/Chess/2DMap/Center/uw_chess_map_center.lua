-- ========================================================
-- @File    : uw_chess_map_center.lua
-- @Brief   : 棋盘编辑界面-中央部分
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(0.484, 0.484, 0.484, 1);
local KeyRightMouseButton = UE4.UUMGLibrary.GetFKey("RightMouseButton")
local MaxTypeLayer = 6

function view:Construct()
    self.TxtTip:SetText("")
    self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    self:RegisterEvent(Event.NotifyChessMapChanged, function(mapId) 
        if mapId > 0 then 
            self.TxtMapName:SetText(string.format("%s/map%d.txt", ChessEditor.ModuleName, mapId))
        else 
            self.TxtMapName:SetText("")
        end
        self:UpdateTypeLayerShow()
        self:UpdateTypeLayerCountShow()
    end)
    self:RegisterEvent(Event.NotifyChessEditorTypeChanged, function(type) self:OnBtnClickEditorType(type, true) end)
    self:RegisterEvent(Event.NotifyChess2DMapOpened, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeNone) end)
    self:RegisterEvent(Event.NotifyChessTipMsg, function(msg) self.TxtTip:SetText(msg or "") end)
    self:RegisterEvent(Event.NotifyChessObjectCountChanged, function() self:UpdateTypeLayerCountShow() end)

    for i = 0, MaxTypeLayer do 
        BtnAddEvent(self["BtnTypeLayer" .. i], function()  
            ChessEditor.tbLayerFlag[i] = not ChessEditor.tbLayerFlag[i];
            if i > 0 then 
                EventSystem.Trigger(Event.NotifyChessLayerFlagChanged, i)
            else 
                for j = 1, MaxTypeLayer do 
                    ChessEditor.tbLayerFlag[j] = ChessEditor.tbLayerFlag[0]
                end
                EventSystem.Trigger(Event.NotifyChessLayerFlagChanged)
            end
            self:UpdateTypeLayerShow()
        end)
    end

    BtnAddEvent(self.BtnTypeRegion, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeRegion) end)
    BtnAddEvent(self.BtnTypeEvent, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeEvent) end)
    BtnAddEvent(self.BtnTypeObject, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeObject) end)
    BtnAddEvent(self.BtnTypeGround, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeGround) end)
    BtnAddEvent(self.BtnTypeHeight, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeHeight) end)
    BtnAddEvent(self.BtnTypeNone, function() self:OnBtnClickEditorType(ChessEditor.EditorTypeNone) end)    

    ChessEditor:RegisterBtnHoverTip(self.BtnTypeRegion, "点击编辑区域信息")
    ChessEditor:RegisterBtnHoverTip(self.BtnTypeEvent, "点击编辑事件信息")
    ChessEditor:RegisterBtnHoverTip(self.BtnTypeObject, "点击编辑格子/物件信息")
    ChessEditor:RegisterBtnHoverTip(self.BtnTypeNone, "只读模式")

    ChessEditor:RegisterBtnHoverTip(self.BtnTypeLayer1, "显示/隐藏 地面层信息 (Layer为1)")
    ChessEditor:RegisterBtnHoverTip(self.BtnTypeLayer2, "显示/隐藏 第一层物件信息 (Layer为2)")
    ChessEditor:RegisterBtnHoverTip(self.BtnTypeLayer3, "显示/隐藏 第二层物件信息 (Layer为3)")
    ChessEditor:RegisterBtnHoverTip(self.BtnTypeLayer4, "显示/隐藏 第三层物件信息 (Layer为4)")
end


function view:OnBtnClickEditorType(type, dontSendEvent)
    local tbTypes = {ChessEditor.EditorTypeRegion, ChessEditor.EditorTypeEvent, ChessEditor.EditorTypeObject, 
        ChessEditor.EditorTypeGround, ChessEditor.EditorTypeHeight, ChessEditor.EditorTypeNone}
    for _, name in ipairs(tbTypes) do
        self["BtnType" .. name]:SetBackgroundColor(ColorWhite)
    end
    self["BtnType" .. type]:SetBackgroundColor(ColorGreen)

    WidgetUtils.SetVisibleOrCollapsed(self.HorizontalLayer, type == ChessEditor.EditorTypeObject or type == ChessEditor.EditorTypeEvent)

    if not dontSendEvent then ChessEditor:SetEditorType(type) end
end

function view:UpdateTypeLayerShow()
    for i, v in pairs(ChessEditor.tbLayerFlag) do 
        self["BtnTypeLayer" .. i]:SetBackgroundColor(v and ColorGreen or ColorWhite)
    end
end

function view:UpdateTypeLayerCountShow()
    local tbRegion = ChessEditor:GetCurrentRegionData() or {}
    local tbCount = {}
    for i = 0, MaxTypeLayer do 
        tbCount[i] = 0
    end
    for _, tb in pairs(tbRegion.tbGround or {}) do 
        if tb.objectId > 0 then 
            tbCount[1] = tbCount[1] + 1
        end
    end
    for _, tb in pairs(tbRegion.tbObjects or {}) do 
        local def = ChessEditor:GetGridDefByTypeId(tb.tpl)
        if def then 
            tbCount[def.Layer] = tbCount[def.Layer] or 0
            tbCount[def.Layer] = tbCount[def.Layer] + 1
        end
    end
    -- for i = 1, MaxTypeLayer do 
    --     tbCount[0] = tbCount[0] + tbCount[i]
    -- end

    for i, n in pairs(tbCount) do 
        if i == 0 then 
            self["TxtLayer" .. i]:SetText("All")
        else 
            if n > 0 then 
                self["TxtLayer" .. i]:SetText("L" .. i .. "\n" .. n)
            else 
                self["TxtLayer" .. i]:SetText("L" .. i)
            end
        end
    end
end

---------------------------------------------------------------------
--- tick
---------------------------------------------------------------------
function view:Tick(MyGeometry, InDeltaTime)
    local MousePos = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
    if not self.lastMousePosition then self.lastMousePosition = MousePos end
    ChessEditor.MoveDelta = MousePos - self.lastMousePosition

    if not ChessEditor.IsTopUIMode and not ChessEditor.IsOpenSpecialUI and self.playerController:IsInputKeyDown(KeyRightMouseButton) and not ChessEditor.EnterMenuOrInspector then 
        local delta = ChessEditor.MoveDelta
        if delta.X ~= 0 or delta.Y ~= 0 then 
            self.uw_chess_panel_region:Event_Move(delta)
        end
    end
    self.lastMousePosition = MousePos;
end

function view:OnMouseWheel(MyGeometry, MouseEvent)
    if ChessEditor.IsTopUIMode or ChessEditor.IsOpenSpecialUI or ChessEditor.EnterMenuOrInspector then return end  
    local delta = UE.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent);
    if delta == 0 then return UE4.UWidgetBlueprintLibrary.Unhandled() end

    self.uw_chess_panel_region:Event_OnMouseWheel(delta)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function view:OnMouseEnter()
    ChessEditor.EnterMenuOrInspector = false
end
return view