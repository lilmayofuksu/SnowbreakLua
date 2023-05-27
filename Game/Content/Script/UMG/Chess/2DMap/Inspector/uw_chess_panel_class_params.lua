-- ========================================================
-- @File    : uw_chess_panel_class_params.lua
-- @Brief   : 物件类别参数
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.__Index = 0
    BtnAddEvent(self.BtnAuto, function() self:OnBtnClickAutoId() end)
end

function view:SetData(tbData, parent)
    self.classArg = nil
    self.parent = parent
    self.tbData = tbData
    self:FreeAll()
    local def = ChessEditor:GetGridDefByTypeId(parent.tplId);
    if not def then return end
    self.tbClassParams, self.szClassTitle = ChessObject:GetClassParams(def.ClassName)
    if not self.tbClassParams then 
        WidgetUtils.Collapsed(self.Root)
        return 
    end
    WidgetUtils.SelfHitTestInvisible(self.Root)

    if not tbData.id or #tbData.id == 0 then 
        self.TxtDesc:SetText("指定id后方可编辑参数")
        self.TxtDesc:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1,0,0,1))
        WidgetUtils.Visible(self.BtnAuto)
        WidgetUtils.Collapsed(self.Childs)
        return
    end
    WidgetUtils.Collapsed(self.BtnAuto)
    self.TxtDesc:SetText(self.szClassTitle .. "参数:")
    self.TxtDesc:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0,1,0,1))
    WidgetUtils.SelfHitTestInvisible(self.Childs)

    self.classArg = tbData.classArg or {}
    tbData.classArg = self.classArg

    self:Refresh()
end

function view:Refresh()
    self:FreeAll()
    for i, cfg in ipairs(self.tbClassParams) do 
        self:Alloc():SetStyleParam(self, {tbParam = self.classArg}, cfg, ChessEvent.TypeClassParam, i, -1)
    end
end

function view:OnBtnClickAutoId()
    if self.tbData and self.tbData.id and #self.tbData.id > 0 then return end

    local tb = ChessEditor:GetObjectIdDef()
    table.insert(tb, {name = "auto_id" .. (#tb + 1), desc = ""})
    self.tbData.id = {#tb}
    self.parent:Refresh()
    ChessEditor:Snapshoot()
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:Alloc()
    local widget = self.VerticalChilds:GetChildAt(self.__Index)
    if not widget then 
        widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Inspector/uw_item_tpl_event_arg.uw_item_tpl_event_arg_C")
        self.VerticalChilds:AddChild(widget)
    end
    WidgetUtils.Visible(widget)
    self.__Index = self.__Index + 1
    return widget
end

function view:FreeAll()
    local childCount = self.VerticalChilds:GetChildrenCount()
    for i = 1, childCount do 
        WidgetUtils.Collapsed(self.VerticalChilds:GetChildAt(i - 1))
    end
    self.__Index = 0
end

return view