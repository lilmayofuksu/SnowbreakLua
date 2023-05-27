-- ========================================================
-- @File    : umg_open_world_map.lua
-- @Brief   : 开放世界
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self:DoClearListItems(self.PointList)
    self:DoClearListItems(self.RegionList)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
    self.Factory = Model.Use(self);
    self.tbRegion = {}
    self.tbColor = {
        red = { 255, 0, 0 },
        blue = { 0, 0, 255 },
        green = { 0, 255, 0 },
        yellow = { 255, 255, 0},
    }
    self.zoom = 100
end

function tbClass:OnOpen(tbParam)
    WidgetUtils.ShowMouseCursor(self, true);
    UE4.UGameplayStatics.SetGamePaused(self, true)

    local tbData = OpenWorldClient.GetMapDebugData();
    self.PointList:SetScrollable(true)
    self.RegionList:SetScrollable(true)
    self.tbRegionTrigger = tbData.tbRegionTrigger
    self:UpdateRegion()
    self:UpdatePoint(tbData)
    self:UpdateMin(tbData)
end

function tbClass.OnBGScale(nScale)
    local pUI = UI.GetUI("OpenWorldDebugMap")
    for _,tb in pairs(pUI.tbRegion) do
        for _,v in pairs(tb) do
            v.widget.wSlot:SetPosition(v.origin * nScale)
        end
    end
end

function tbClass:UpdateMin(tbParam)
    local left_top = nil
    if tbParam.point_right_top and tbParam.point_left_bottom then
        local X = tbParam.point_right_top[1] - tbParam.point_left_bottom[1]
        local Y = tbParam.point_left_bottom[2] - tbParam.point_right_top[2]
        left_top = { tbParam.point_left_bottom[1], tbParam.point_right_top[2] }
        local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MinMap.Bg)
        Slot:SetSize(UE4.FVector2D(X/self.zoom, Y/self.zoom))
        self.MinMap:UpdateSize()
        self.MinMap:UpdatePaint(self.tbRegionTrigger, left_top, self.zoom)
    end

    if not left_top then return end

    local pAddFunc = function (tbOne, tbColor, key)
        if not self.tbRegion[tbOne.regionId] then self.tbRegion[tbOne.regionId] = {} end
        local widget = LoadWidget("/Game/UI/UMG/OpenWorld/uw_debug_map_coordinate.uw_debug_map_coordinate_C")
        self.MinMap.Coordinate:AddChild(widget)
        widget.wSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
        local r, g, b = table.unpack(tbColor)
        local origin = UE4.FVector2D((tbOne.pos[1] - left_top[1]) / self.zoom, (tbOne.pos[2] - left_top[2]) / self.zoom)
        widget.wSlot.bAutoSize = true;
        widget.wSlot:SetAlignment(UE4.FVector2D(0.5, 0.5))
        widget.wSlot:SetPosition(origin)
        UE4.UGMLibrary.SetBrushTintColor(widget.Img, r, g, b)
        table.insert(self.tbRegion[tbOne.regionId], {widget = widget, data = tbOne, origin = origin, key = key})
    end

    for _,v in ipairs(tbParam.tbPartol) do
        pAddFunc(v, self.tbColor.red, 'Partol')
    end

    for i,v in ipairs(tbParam.tbExplore) do
        pAddFunc(v, self.tbColor.yellow, 'Explore')
    end

    for i,v in ipairs(tbParam.tbTransfer) do
        pAddFunc(v, self.tbColor.blue, 'Transfer')
    end

    for i,v in ipairs(tbParam.tbTask) do
        pAddFunc(v, self.tbColor.green, 'Task')
    end
end



function tbClass:UpdatePoint(tbParam)
    -- 巡逻点
    if #tbParam.tbPartol > 0 then
        local tbData = {
            sName = '巡逻点',
            rgb= self.tbColor.red,
            pToggle = function (bShow)
                self:TogglePoint('tbPartol', bShow)
            end
        }
        local pObj = self.Factory:Create(tbData);
        self.PointList:AddItem(pObj)
    end

    -- 探索点
    if #tbParam.tbExplore > 0 then
        local tbData = {
            sName = '探索点',
            rgb= self.tbColor.yellow,
            pToggle = function (bShow)
                self:TogglePoint('Explore', bShow)
            end

        }
        local pObj = self.Factory:Create(tbData);
        self.PointList:AddItem(pObj)
    end
    
    -- 传送点
    if #tbParam.tbTransfer > 0 then
        local tbData = {
            sName = '传送点',
            rgb= self.tbColor.blue,
            pToggle = function (bShow)
                self:TogglePoint('Transfer', bShow)
            end
        }
        local pObj = self.Factory:Create(tbData);
        self.PointList:AddItem(pObj)
    end

    -- 任务点
    if #tbParam.tbTask > 0 then
        local tbData = {
            sName = '任务点',
            rgb= self.tbColor.green,
            pToggle = function (bShow)
                self:TogglePoint('Task', bShow)
            end
        }
        local pObj = self.Factory:Create(tbData);
        self.PointList:AddItem(pObj)
    end
end

function tbClass:UpdateRegion()
    local _tbRegion = {}
    for _, item in ipairs(self.tbRegionTrigger) do
        if not _tbRegion[item.id] then
            local tbData = {
                sName = 'region'..item.id,
                Id = item.id, 
                nType = item.type,
                pToggle = function (bShow)
                    self:ToggleRegion(item.id, bShow)
                end
            }
            _tbRegion[item.id] = tbData
            local pObj = self.Factory:Create(tbData);
            self.RegionList:AddItem(pObj)
        end
    end
end

function tbClass:ToggleRegion(id, bShow)
    if not self.tbRegion[id] then return end
    for _,v in pairs(self.tbRegion[id]) do
        if bShow then
            WidgetUtils.Visible(v.widget);
        else
            WidgetUtils.Collapsed(v.widget)
        end
    end
end

function tbClass:TogglePoint(key, bShow)
    for i,tb in pairs(self.tbRegion) do
        for _,v in pairs(tb) do
            if v.key == key then
                if bShow then
                    WidgetUtils.Visible(v.widget);
                else
                    WidgetUtils.Collapsed(v.widget)
                end
            end 
        end
    end
end

function tbClass:OnClose()
    WidgetUtils.ShowMouseCursor(self, false);
    UE4.UGameplayStatics.SetGamePaused(self, false)
    MinMap:UpdatePaint()
end

return tbClass