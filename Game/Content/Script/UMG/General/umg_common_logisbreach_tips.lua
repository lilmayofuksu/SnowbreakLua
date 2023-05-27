

---@class tbClass
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self)

    BtnAddEvent(self.BtnClose, function()
         UI.Close(self)
    end)
end


function tbClass:OnOpen(InItem,InLv)
    if InLv and InLv>0 then
        self:ShowUpAttrChange(InItem,InLv)
    end
    if not InLv then
        self:ShowBreachAttrChange(InItem)
    end
end

--- 突破属性刷新
function tbClass:ShowBreachAttrChange(InItem)
    if InItem:Break() + 1 == Logistics.GetBreakMax(InItem) then
        self:PlayAnimation(self.BreachChange, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        SetTexture(self.ImgLogis, InItem:IconBreak())
    else
        self:PlayAnimation(self.Breach, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        SetTexture(self.ImgLogis, InItem:Icon())
    end

    if self.TxtNum then
        self.TxtNum:SetText(InItem:EnhanceLevel())
    end
    
    if self.TxtAddNum then
        self.TxtAddNum:SetText(Logistics.GetMaxLv(InItem, InItem:Break() + 1))
    end
    
    if self.ListLogisBreach then
        self:DoClearListItems(self.ListLogisBreach)

        for k, i in pairs(Logistics.tbSubAttr) do
            local tbParam = {
                ECate = i,
                sName = Text(string.format("attribute.%s", i)),
                nIcon = Resource.GetAttrPaint(i),
                nNum = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InItem, InItem:EnhanceLevel(), InItem:Break()),
                nAdd = tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InItem, InItem:EnhanceLevel(), InItem:Break() + 1)),
                IsPercent = not (i == "Command_break"),
            }
            if tbParam.nAdd > 0 then
                local NewObj = self.ListFactory:Create(tbParam)
                self.ListLogisBreach:AddItem(NewObj)
            end
        end

    end

    for i = 1, 6 do
        local pw = self["s_" .. i]
        if pw then
            if i <= InItem:Break() then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStar)
                WidgetUtils.Collapsed(pw.ImgStarOff)
            else
                WidgetUtils.Collapsed(pw.ImgStar)
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
            end
        end
    end

    if self.TxtSkillDes then
        local tbSkills = UE4.TArray(0)
        local SkillId = Logistics.GetSKill(InItem)
        if not SkillId then
            print('SkillId_error')
            return
        end
        self.TxtSkillDes:SetContent(SkillDesc(SkillId))
    end
end
return tbClass