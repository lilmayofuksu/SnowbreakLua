local view = Class("UMG.SubWidget")

local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(1, 1, 1, 1); 

function view:Construct()
    BtnAddEvent(self.Select, function() self:OnBtnClickSelect() end)
    BtnAddEvent(self.Add, function() self:OnBtnClickAdd() end)

    self:RegisterEvent(Event.NotifyChessMapChanged, function() self:UpdateSelect() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data

    WidgetUtils.SetVisibleOrCollapsed(self.Select, not self.tbData.isAdd)
    WidgetUtils.SetVisibleOrCollapsed(self.Add, self.tbData.isAdd)

    if not self.tbData.isAdd then 
        self.TxtName:SetText(string.format("%d. %s", self.tbData.Id, self.tbData.Name))
        self:UpdateSelect()
    end
end

function view:UpdateSelect()
    if not self.tbData.isAdd then 
        self.Select:SetBackgroundColor(self.tbData.Select and ColorGreen or ColorWhite)
    end
end

function view:OnBtnClickSelect()
    if self.tbData.onSelect then 
        self.tbData.onSelect()
    end
end

function view:OnBtnClickAdd()
    EventSystem.Trigger(Event.ApplyCreateChessMap);
end

return view