
local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.ClickBtn, function() self:OnBtnClick() end)
    print("btn add event", self.ClickBtn)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.BranchText:SetContent(self.tbData.msg)
end

function view:OnBtnClick()    
    self.tbData.onClick()
end

return view;