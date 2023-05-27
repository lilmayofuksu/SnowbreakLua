-- ========================================================
-- @File    : umg_chess_bag.lua
-- @Brief   : 棋盘 - 背包
-- ========================================================

local view = Class("UMG.BaseWidget")

local tbTypeDef = {
    [1] = Text("ui.TxtChessbutton3"),
    -- [2] = Text("ui.TxtChessbutton4"),
    -- [3] = Text("ui.TxtChessbutton5"),
}

function view:OnInit()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
end

function view:OnOpen()
    self:UpdateTypes()
end

function view:OnClose()
end

function view:UpdateTypes()
    local tbDef = ChessClient:GetItemDef();
    self.tbTypes = {}
    for _, tb in ipairs(tbDef.tbList) do 
        local tbList = self.tbTypes[tb.Type] or {}
        self.tbTypes[tb.Type] = tbList
        table.insert(tbList, tb);
    end

    self:DoClearListItems(self.ListFunction)
    self.tbFunction = {}
    for typeId, name in ipairs(tbTypeDef) do 
        local tbParam = {id = typeId, name = name, parent = self, selected = typeId == 1}
        self.ListFunction:AddItem(self.Factory:Create(tbParam))
        self.tbFunction[typeId] = tbParam
    end
    self:OnTypeSelect(1)
end

function view:OnTypeSelect(typeId)
    for id, tb in pairs(self.tbFunction) do 
        tb.selected = id == typeId;
        if tb.ui then 
            tb.ui:UpdateState()
        end
    end

    self:DoClearListItems(self.Item_list)
    self.tbItems = {}
    local haveItem = false
    for _, cfg in ipairs(self.tbTypes[typeId] or {}) do 
        local count = ChessData:GetItemCount(cfg.Id)
        if count > 0 then 
            local tbParam = {id = cfg.Id, cfg = cfg, parent = self, count = count}
            self.Item_list:AddItem(self.Factory:Create(tbParam))
            self.tbItems[cfg.Id] = tbParam
            haveItem = true
        end
    end
    if haveItem then
        WidgetUtils.Collapsed(self.PanelNoItem)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelNoItem)
    end
end

return view