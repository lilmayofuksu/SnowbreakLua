local view = Class("UMG.SubWidget")

local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 0.8, 0, 1);
local ColorWhite = UE4.UUMGLibrary.GetSlateColor(0.5, 0.5, 0.5, 1);


function view:Construct()
    BtnAddEvent(self.BtnSelect, function() self:OnBtnClickSelect() end)
    BtnAddEvent(self.BtnOK, function() self:OnBtnClickSelect() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.tbData.pRefresh = function(data)
        if data ~= self.tbData then return end
        self:UpdateSelected()
    end
    
    self.TxtId:SetText(self.tbData.id);
    self.TxtName:SetText(self.tbData.name);
    self.TxtDesc:SetText(self.tbData.desc)
    self:UpdateSelected()
end

function view:UpdateSelected()
    if self.tbData.isSelected then 
        self.Background:SetColorAndOpacity(ColorGreen)
    else 
        self.Background:SetColorAndOpacity(ColorWhite)
    end
end

function view:OnBtnClickSelect()
    if self.tbData.isSelected then 
        self.tbData.parent:DoSelect(nil)
    else
        self.tbData.parent:DoSelect(self.tbData.id) 
    end
end

return view