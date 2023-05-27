local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.Select, function() self:OnBtnClickSelect() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.TxtName:SetText(self.tbData.Name)
end

function view:OnBtnClickSelect()
    if self.tbData.pCall then self.tbData.pCall(self.tbData.CallParam) end
    EventSystem.Trigger(Event.NotifyChessShowMenu)
end

return view