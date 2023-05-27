local view = Class("UMG.SubWidget")

local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(0.5, 0.5, 0.5, 1);
local ColorClear = UE.FLinearColor(0.5, 0.5, 0.5, 0);

function view:Construct()
    BtnAddEvent(self.Select, function() self:OnBtnClickSelect() end)
    self:RegisterEvent(Event.NotifyChessGridTypeSelected, function() self:UpdateSelect() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    local cfg = self.tbData.Cfg
    local size = cfg.Size
    local name = string.gsub(cfg.Name, "\n", "");
    if self.tbData.Id <= 2 then 
        self.TxtName:SetText(string.format("%d. %s", self.tbData.Id, name))
        self.TxtLayer:SetText("")
    elseif cfg.Layer == 1 then 
        self.TxtName:SetText(string.format("%d. %s]", self.tbData.Id, name)) 
        self.TxtLayer:SetText(cfg.Layer)
    else
        self.TxtName:SetText(string.format("%d. %s[%d*%d]", self.tbData.Id, name, size[1], size[2])) 
        self.TxtLayer:SetText(cfg.Layer)
    end
    if cfg.Layer == 1 then 
        self.Hint:SetBackgroundColor(cfg.Background)
    else 
        self.Hint:SetBackgroundColor(ColorClear)
    end
    self:UpdateSelect()
end

function view:UpdateSelect()    
    local select = self.tbData.Id == ChessEditor.CurrentGridId
    if select then 
        self.Select:SetBackgroundColor(ColorGreen)
    else 
        self.Select:SetBackgroundColor(ColorWhite)
    end
    WidgetUtils.SetVisibleOrCollapsed(self.Arrow, select)
end

function view:OnBtnClickSelect()
    ChessEditor:SetCurrentGridId(self.tbData.Id)
    if self.tbData.Id <= 1 then return end

    if self.tbData.Cfg.Layer == 1 then 
        if ChessEditor.EditorType ~= ChessEditor.EditorTypeGround then 
            ChessEditor:SetEditorType(ChessEditor.EditorTypeGround)
        end
    else 
        if ChessEditor.EditorType ~= ChessEditor.EditorTypeObject then 
            ChessEditor:SetEditorType(ChessEditor.EditorTypeObject)
        end
    end
end

return view