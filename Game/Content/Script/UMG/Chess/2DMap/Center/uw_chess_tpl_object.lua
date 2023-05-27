-- ========================================================
-- @File    : uw_chess_tpl_object.lua
-- @Brief   : 棋盘物件模板
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 1, 0, 0.8)
local KeyLeftMouseButton = UE4.UUMGLibrary.GetFKey("LeftMouseButton")

function view:Construct()
    -- 注意，这里的构造函数会反复执行（因为切换父节点的原因）
    self.slotRoot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PanelRoot)
end

function view:SetData(tbData)
    self.tbData = tbData
    self.tbParam = tbData.tbParam
    self.tbRegion = tbData.tbRegion
    self.halfSize = tbData.halfSize
    self.tbDef = ChessEditor:GetGridDefByTypeId(self.tbParam.tpl)
    self.TxtName:SetText(self.tbDef.Name)
    self.TxtName:SetColorAndOpacity(self.tbDef.TxtColor)
    self.slotRoot:SetSize(UE.FVector2D(self.tbDef.Size[1] * 100 - 4, self.tbDef.Size[2] * 100 - 4))
    self:UpdatePosition()
    
    if ChessEditor:IsObjectSelected("object", self.tbData.Id) then 
        self.Background:SetColorAndOpacity(ColorGreen)
    else
        self.Background:SetColorAndOpacity(self.tbDef.BackgroundSlate) 
    end
end

function view:UpdatePosition()
    local position = UE.FVector2D(self.tbParam.pos[1] * 100 + 2, self.tbParam.pos[2] * 100 - 2)
    self.wSlot:SetPosition(position)
end

function view:ShowTipData() 
    local x, y = self.tbParam.pos[1], self.tbParam.pos[2]
    local sizeX, sizeY = self.tbDef.Size[1], self.tbDef.Size[2]
    local msg = string.format("id:%d 坐标:%d,%d 物件:%s 大小:%d,%d", self.tbDef.Id, x, y, self.tbDef.Name, sizeX, sizeY)
    EventSystem.Trigger(Event.NotifyChessTipMsg, msg) 
end

function view:SetSelected(isSelected)
    if isSelected then 
        self.Background:SetColorAndOpacity(ColorGreen)
    else 
        self.Background:SetColorAndOpacity(self.tbDef.BackgroundSlate)
    end
end

---------------------------------------------------------------------
--- event 
--- 当鼠标按下时
function view:OnMouseButtonDown(MyGeometry, MouseEvent)
    ChessEditor:SetSelectedObject("object", self.tbData.Id)

    if ChessEditor.EditorType == ChessEditor.EditorTypeObject and ChessEditor.CurrentGridId == 2 then 
        EventSystem.Trigger(Event.NotifyChessDeleteObject, self.tbData.Id)
    elseif ChessEditor.EditorType == ChessEditor.EditorTypeEvent or ChessEditor.EditorType == ChessEditor.EditorTypeObject then
        local key = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
        if key == ChessEditor.KeyRightMouseButton then 
            local tbParam = {
                {"克隆", self.Menu_Clone, self},
                {"删除", self.Menu_Delete, self},
            }
            EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
            return UE4.UWidgetBlueprintLibrary.Handled()
        end

        return UE4.UWidgetBlueprintLibrary.DetectDragIfPressed(MouseEvent, self, KeyLeftMouseButton)
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function view:OnMouseEnter()
    self:ShowTipData()
end

function view:OnMouseLeave()
    EventSystem.Trigger(Event.NotifyChessTipMsg, "") 
end

function view:GetDragNameShow()
    return self.tbDef.Name
end

function view:NotifyBeginDrag()
    WidgetUtils.Collapsed(self.TxtName)
    EventSystem.Trigger(Event.NotifyChessBeginDrag, {type = "drag_object"}) 
end

function view:OnDragCancelled()
    WidgetUtils.SelfHitTestInvisible(self.TxtName)
    EventSystem.Trigger(Event.NotifyChessEndDrag) 
end

-- 克隆
function view:Menu_Clone()
    local x, y = self.tbParam.pos[1], self.tbParam.pos[2]
    EventSystem.Trigger(Event.NotifyChessPutObject, {x + 1, y, self.tbParam.tpl})
end

-- 删除
function view:Menu_Delete()
    ChessEditor:DeleteSelectedObject()
end

return view