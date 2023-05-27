-- ========================================================
-- @File    : uw_open_world_map_min.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")
tbClass.tbUsedTip = {}
tbClass.tbUnusedTip = {}

function tbClass:Construct()
    self.slotRegion = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Region)
    self.regionSize = self.slotRegion:GetSize()
    self.halfRegionSize = self.regionSize / 2;

    self.canvasSlotBG = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Bg)
    self.canvasSlotBG:SetSize(self.regionSize)

    self.canvasSlotCoor = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Coordinate)

    self.scale = 1
    self.normalSize = self.canvasSlotBG:GetSize()
    self.gamePlayer = self:GetOwningPlayer()
end

function tbClass:UpdateSize()
    self.regionSize = self.canvasSlotBG:GetSize()
    self.halfRegionSize = self.regionSize / 2
    self.normalSize = self.regionSize
end

function tbClass:UpdatePaint(tbTrigger, leftTop, zoom)
    --{UE4.FVector2D(0,0), UE4.FVector2D(0,10), UE4.FVector2D(10,10), UE4.FVector2D(10,0)}
    self.tbTrigger = {}
    if tbTrigger then
        for i,v in ipairs(tbTrigger) do
            table.insert(self.tbTrigger, {
                UE4.FVector2D(v.left_bottom[1] - leftTop[1], v.right_top[2] - leftTop[2]) / zoom,
                UE4.FVector2D(v.left_bottom[1] - leftTop[1], v.left_bottom[2] - leftTop[2]) / zoom,
                UE4.FVector2D(v.right_top[1] - leftTop[1], v.left_bottom[2] - leftTop[2]) / zoom,
                UE4.FVector2D(v.right_top[1] - leftTop[1], v.right_top[2] - leftTop[2]) / zoom,
                v.type
            })
        end
    end
end

--- 设置父亲UI
function tbClass:SetParent(parent)
	self.parent = parent;
end

function tbClass:OnPaint(Context)
    if not self.tbTrigger then return end
    local white = UE4.FLinearColor(1, 1, 1, 1)
    local red = UE4.FLinearColor(1, 0, 0, 1)
    for _,v in ipairs(self.tbTrigger) do
        UE4.UWidgetBlueprintLibrary.DrawLine(Context, v[1] * self.scale + self.deltaOffet, v[2] * self.scale + self.deltaOffet, v[5] == 2 and red or white, true, 1)
        UE4.UWidgetBlueprintLibrary.DrawLine(Context, v[2] * self.scale + self.deltaOffet, v[3] * self.scale + self.deltaOffet, v[5] == 2 and red or white, true, 1)
        UE4.UWidgetBlueprintLibrary.DrawLine(Context, v[3] * self.scale + self.deltaOffet, v[4] * self.scale + self.deltaOffet, v[5] == 2 and red or white, true, 1)
        UE4.UWidgetBlueprintLibrary.DrawLine(Context, v[4] * self.scale + self.deltaOffet, v[1] * self.scale + self.deltaOffet, v[5] == 2 and red or white, true, 1)
    end 
end

function tbClass:Refresh()
	print("min map refresh")

    self:FreeAllTip();

    local tbPoints = OpenWorldMgr.GetPointCfg();
    local wBg = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Bg)
    local localPos = wBg:GetPosition();
    local bgSize = wBg:GetSize()

    for _, id in ipairs(OpenWorldClient.tbTaskIds) do 
        local cfg = OpenWorldMgr.GetTaskCfg(id);
        local pointName = cfg.PointName;        
        local tip = self:AllocTip();
        tip.posRate  = tbPoints:GetPositionPercent(pointName);
        if cfg.Category == 1 then
            tip:SetName("主线")
        elseif cfg.Category == 2 then 
            tip:SetName("支线")
        elseif cfg.Category == 3 then 
            tip:SetName("随机")
        end
        tip:ShowStyleTask()
        tip.pointName = pointName
        tip:SetId(id)
    end

    -- 玩家位置
    do
        local OwnerPlayer = self.parent:GetOwningPlayer():Cast(UE4.AGamePlayerController)
        local Pawn = OwnerPlayer:K2_GetPawn();
        local location = Pawn:K2_GetActorLocation();
        local rotation = Pawn:K2_GetActorRotation();    
        local tip = self:AllocTip();
        tip.posRate = tbPoints:GetPositionPercent(nil, {location.X, location.Y, location.Z});
        tip:ShowStylePlayer()
        tip:SetPlayerAngle(rotation.Yaw + 90);
    end

    -- 传送点
    local tbPoints = OpenWorldMgr.GetPointCfg();
    for name, _ in pairs(tbPoints.points) do 
        if OpenWorldMgr.IsTransPoint(name) then
            local tip = self:AllocTip();
            tip.posRate  = tbPoints:GetPositionPercent(name);
            tip:SetName(name)
            tip:SetId(name)
            tip:ShowStyleTransPoint()
            if OpenWorldMgr.IsUnlockTransPoint(name) then 
                tip:SetTransColor(UE4.UUMGLibrary.GetSlateColor(0, 1, 0, 1))
            else 
                tip:SetTransColor(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
            end
        end
    end
    self:UpdateTipPosition()
end

function tbClass:AllocTip()
    if #self.tbUnusedTip == 0 then 
        local widget = LoadWidget("/Game/UI/UMG/OpenWorld/Widgets/umg_open_world_map_tip.umg_open_world_map_tip_C")
        self.tbUnusedTip[1] = widget;
        widget:SetClickDetailCallback(function(class) self:OnBtnClickTipDetail(class) end)
        widget:SetClickTransCallback(function(class) self:OnBtnClickTrans(class) end)
        self.Items:AddChild(widget)
        widget.wSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
    end
    local widget = self.tbUnusedTip[#self.tbUnusedTip]
    table.remove(self.tbUnusedTip, #self.tbUnusedTip)
    table.insert(self.tbUsedTip, widget)
    WidgetUtils.Visible(widget);
    return widget
end

function tbClass:FreeAllTip()
    for _, data in ipairs(self.tbUsedTip) do 
        table.insert(self.tbUnusedTip, data)
        WidgetUtils.Collapsed(data)
    end
    self.tbUsedTip = {}
end

function tbClass:UpdateTipPosition()
    local localPos = self.canvasSlotBG:GetPosition();
    local bgSize = self.canvasSlotBG:GetSize()
    local offset = self.halfRegionSize - bgSize / 2 + localPos;

    for _, tip in ipairs(self.tbUsedTip) do 
        local n1 = bgSize.X * tip.posRate[1]
        local n2 = bgSize.Y * tip.posRate[2];
        tip.wSlot:SetPosition(UE4.FVector2D(n1, n2) + offset)
    end
end

function tbClass:OnBtnClickTipDetail(tipClass)
    WidgetUtils.Visible(self.parent.TaskDetail)
    self.parent.currentTipClass = tipClass

    local slotTask = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.parent.TaskRegion)
    local slotTip = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(tipClass)
    local pos = slotTip:GetPosition();
    local slotMinMap = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.parent.MinMap)
    slotTask:SetPosition(slotMinMap:GetPosition() + pos - self.regionSize / 2)

    self.parent:UpdateTaskDetail(tipClass.id)
end

function tbClass:OnBtnClickTrans(tipClass)
    local tbPoints = OpenWorldMgr.GetPointCfg();
    if not OpenWorldMgr.IsUnlockTransPoint(tipClass.id) then 
        return 
    end

    local uiName = self.parent.sName
    UI.Open("MessageBox", "确认传送吗?", function()
        if UI.IsOpen(uiName) then
            local pos = tbPoints.points[tipClass.id].pos
            local OwnerPlayer = self.parent:GetOwningPlayer():K2_GetPawn()
            local newPos = UE4.FVector(pos[1], pos[2], pos[3] + 80)
            local SweepResult = UE4.FHitResult()
            OwnerPlayer:K2_SetActorLocation(newPos, false, SweepResult, true);

            UI.Close(self.parent)
            UI.Open('OpenWorldFadein', true)
        end
    end)
end

-- ========================================================
-- 操作反馈
-- ========================================================
---移动地图背景
function tbClass:OnBGMove(delta)
    local localPos = self.canvasSlotBG:GetPosition();
    localPos.X = localPos.X + delta.X;
    localPos.Y = localPos.Y + delta.Y;

    -- 检查是否越界
    local size = self.canvasSlotBG:GetSize()
    local leftTop = localPos - size / 2;
    local offset = {X = 0, Y = 0};
    if leftTop.X > -self.halfRegionSize.X then 
        offset.X = -self.halfRegionSize.X - leftTop.X;
    end
    if leftTop.Y > -self.halfRegionSize.Y then 
        offset.Y = -self.halfRegionSize.Y - leftTop.Y;
    end

    local rightBottom = localPos + size / 2
    if rightBottom.X < self.halfRegionSize.X then 
        offset.X = self.halfRegionSize.X - rightBottom.X;
    end
    if rightBottom.Y < self.halfRegionSize.Y then 
        offset.Y = self.halfRegionSize.Y - rightBottom.Y;
    end

    localPos.X = localPos.X + offset.X;
    localPos.Y = localPos.Y + offset.Y;

    self.canvasSlotBG:SetPosition(localPos)
    self.canvasSlotCoor:SetPosition(localPos)
    self.deltaOffet = localPos
    self:UpdateTipPosition()

 --   print("new position is", localPos)
end

---缩放地图背景
function tbClass:OnBGScale(value)
    if value == 0 then return end
    
    local newSize = self.scale * (value > 0 and 1.1 or 0.9)
    if newSize > 3 then newSize = 3
    elseif newSize < 1 then newSize = 1
    end

    local deltaScale = newSize - self.scale
    self.scale = newSize

    -- 大小最小不低于regionSize
    local size = self.normalSize * self.scale;
    if size.X < self.regionSize.X then size.X = self.regionSize.X end
    if size.Y < self.regionSize.Y then size.Y = self.regionSize.Y end

    self.canvasSlotBG:SetSize(size)

    local localPos = self.canvasSlotBG:GetPosition();
    self:OnBGMove(localPos * deltaScale)

    if UI.IsOpen("OpenWorldDebugMap") then
        UI.Call("OpenWorldDebugMap", "OnBGScale", self.scale)
    end
end

-- ========================================================
-- event 注册
-- ========================================================
-- function tbClass:OnMouseEnter(arg1, arg2)
--     print("on mouse enter", arg1, arg2)
-- end
-- function tbClass:OnMouseLeave(arg1, arg2)
--     print("on mouse leave")
-- end

function tbClass:OnTouchMoved(MyGeometry, InTouchEvent)
    local delta = UE4.UKismetInputLibrary.PointerEvent_GetCursorDelta(InTouchEvent);
    self:OnBGMove(delta);
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if IsMobile() or not self.CanDrag then 
        self.last = nil 
        return 
    end
    local MousePos = UE4.UWidgetLayoutLibrary.GetMousePositionOnPlatform()
    if not self.last then self.last = MousePos end
    local delta = UE4.FVector2D(MousePos.X - self.last.X, MousePos.Y - self.last.Y);
    self:OnBGMove(delta);
    self.last = MousePos;
end

-- function tbClass:OnTouchStarted(MyGeometry, InTouchEvent)
--     print("on touch started")
-- end

-- function tbClass:OnTouchEnded(MyGeometry, InTouchEvent)
--     print("on touch ended")
-- end

-- function tbClass:OnTouchGesture()
--     print("on touch gesture")
-- end

function tbClass:OnMouseWheel(MyGeometry, MouseEvent)
    local delta = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent);
    self:OnBGScale(delta)
end

return tbClass