local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.Select, function() self:OnBtnClickSelect() end)
    self:RegisterEvent(Event.NotifyChessMoudleChanged, function() self:UpdateSelect() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.TxtName:SetText(string.format("%d. %s", self.tbData.Id, self.tbData.Name))
    self:UpdateSelect()
end

function view:UpdateSelect()
    local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
    local ColorWhite = UE.FLinearColor(1, 1, 1, 1); 
    self.Select:SetBackgroundColor(self.tbData.Name == ChessEditor.ModuleName and ColorGreen or ColorWhite)
end

function view:OnBtnClickSelect()
    ChessEditor:ResetSnapshoot()
    ChessEditor:SetCurrentModule(self.tbData.Name)
end

return view