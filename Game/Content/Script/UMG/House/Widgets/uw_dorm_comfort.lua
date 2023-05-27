local tbClass = Class("UMG.BaseWidget")

function tbClass:Display(NowNum,AllNum)
    if not AllNum or AllNum == 0 then
        AllNum = 1
    end
    self.TxtNum:SetText(NowNum..'/'..AllNum)
    self.Progress:GetDynamicMaterial():SetScalarParameterValue("Percent", NowNum / AllNum)
end

return tbClass