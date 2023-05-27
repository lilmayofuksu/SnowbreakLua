-- ========================================================
-- @File    : uw_chess_panel_event_detail.lua
-- @Brief   : 事件详情
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(1, 1, 1, 1);

function view:Construct()
    WidgetUtils.Collapsed(self.Scroll)
    self:RegisterEvent(Event.NotifyChessSelectedObject, function(tbParam, isSelected) 
        self:UpdateEventShow(tbParam)
    end)
    self:RegisterEvent(Event.NotifyChessUpdateInspector, function() 
        self:UpdateEventShow(self.tbParam or {}) 
    end)

    for i = 0, 3 do 
        local angle = i * 90
        BtnAddEvent(self["Rotate" .. angle], function() self:OnBtnClickRotate(angle) end)
    end

    BtnAddEvent(self.BtnId, function() self:OnBtnClickId() end)
    BtnAddEvent(self.BtnTag, function() self:OnBtnClickTag() end)
    BtnAddEvent(self.BtnHide, function() self:OnBtnClickHide() end)

    self.InputHeight.OnTextCommitted:Add(self, function(_, value) self:OnEditorHeight(value) end)
end

function view:UpdateEventShow(tbParam)
    self.tbParam = tbParam
    local newData = ChessEditor:GetObjectDatas(tbParam.type, tbParam.id)
    self.tplId = ChessEditor:GetTplId(tbParam.type, tbParam.id)

    -- 尝试修复切换格子时，高度没保存的bug
    if newData == self.tbData and newData then 
        local value = tonumber(self.InputHeight:GetText()) or 0
        self.tbData.height = value ~= 0 and value or nil
    end

    self.tbData = newData
    ChessEditor:SetCurrentInspectorData(self.tbData)
    if not self.tbData then 
        return WidgetUtils.Collapsed(self.Scroll)
    end 

    WidgetUtils.Visible(self.Scroll)

    -- 只有地形才有事件编辑功能
    if tbParam.type == "grid" then 
        WidgetUtils.SelfHitTestInvisible(self.Groups)
        WidgetUtils.SelfHitTestInvisible(self.TxtEventTitle)
    else 
        WidgetUtils.Collapsed(self.Groups)
        WidgetUtils.Collapsed(self.TxtEventTitle)
    end
    self:Refresh()
end

function view:Refresh()
    self:FreeAll()

    local tbData = ChessEditor.tbCurrentInspectorData
    self.TxtTag:SetText(ChessEditor:GetObjectTagDesc(tbData.tag))
    self.TxtId:SetText(ChessEditor:GetObjectIdDesc(tbData.id))
    self.InputHeight:SetText(tbData.height)
    self.TxtHide:SetText(tbData.hide and "√" or "");
    self:OnBtnClickRotate(tbData.angle or 0)

    self.uw_chess_panel_class_params:SetData(tbData, self)

    local tbGroups = tbData.tbGroups or {}
    for i = 1, #tbGroups do 
        self:Alloc(i):SetData(i, tbGroups[i])
    end
    local index = #tbGroups + 1
    self:Alloc(index):SetData(index, {isAdd = true})
end

function view:OnBtnClickRotate(_angle)
    for i = 0, 3 do 
        local angle = i * 90
        if _angle == angle then 
            self["Rotate" .. angle]:SetBackgroundColor(ColorGreen)
        else 
            self["Rotate" .. angle]:SetBackgroundColor(ColorWhite)
        end
    end

    if _angle > 0 then 
        if self.tbData.angle ~= _angle then 
            self.tbData.angle = _angle
            ChessEditor:Snapshoot()
        end
    elseif self.tbData.angle then 
        self.tbData.angle = nil
        ChessEditor:Snapshoot()
    end
end

function view:OnBtnClickTag()
    local tbParam = {
        type = "select",
        typeId = 1,         -- 类型id
        multi = true,       -- 开启多选
        tbSelect = self.tbData.tag and Copy(self.tbData.tag) or {},
        onSelect = function(tbRet)
            self.tbData.tag = tbRet
            self.TxtTag:SetText(ChessEditor:GetObjectTagDesc(tbRet))
            ChessEditor:Snapshoot()
        end
    }
    EventSystem.Trigger(Event.ApplyOpenChessSetting, tbParam)
end

function view:OnBtnClickId()
    local tbParam = {
        type = "select",
        typeId = 3,         -- 类型id
        multi = false,       -- 单选
        tbSelect = self.tbData.id and Copy(self.tbData.id) or {},
        openType = 1,
        onSelect = function(tbRet)
            self.tbData.id = tbRet
            self.TxtId:SetText(ChessEditor:GetObjectIdDesc(tbRet))
            self.uw_chess_panel_class_params:SetData(self.tbData, self)
            ChessEditor:Snapshoot()
        end
    }
    EventSystem.Trigger(Event.ApplyOpenChessSetting, tbParam)
end

function view:OnEditorHeight(value)
    value = tonumber(value) or 0
    if value == 0 then 
        value = nil
    end
    if value ~= self.tbData.height then 
        self.tbData.height = value
        ChessEditor:Snapshoot()
        ChessEditor:UpdateSelectedObject()
    end
    self.InputHeight:SetText(value)
end

function view:OnBtnClickHide()
    if not self.tbData.hide then 
        if not self.tbData.id or #self.tbData.id == 0 then 
            EventSystem.Trigger(Event.NotifyChessErrorMsg, "请先为物件设置id，不然无法存档！")
            return;
        end
    end
    self.tbData.hide = not self.tbData.hide
    self.TxtHide:SetText(self.tbData.hide and "√" or "");
    ChessEditor:Snapshoot()
end


---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:Alloc(Index)
    local widget = self.Groups:GetChildAt(Index - 1)
    if not widget then 
        widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Inspector/uw_item_tpl_event_group.uw_item_tpl_event_group_C")
        self.Groups:AddChild(widget)
    end
    WidgetUtils.Visible(widget)
    return widget
end

function view:FreeAll()
    local childCount = self.Groups:GetChildrenCount()
    for i = 1, childCount do 
        WidgetUtils.Collapsed(self.Groups:GetChildAt(i - 1))
    end
end

---------------------------------------------------------------------
return view
---------------------------------------------------------------------