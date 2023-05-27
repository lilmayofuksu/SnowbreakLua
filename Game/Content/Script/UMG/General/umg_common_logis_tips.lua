

---@class tbClass
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self)
end


function tbClass:OnOpen(InItem,InLv)
    if InLv and InLv>0 then
        self:ShowUpAttrChange(InItem,InLv)
    end
    if not InLv then
        self:ShowBreachAttrChange(InItem)
    end
end



--- 等级属性刷新
function tbClass:ShowUpAttrChange(InItem,OldLv)
    if InItem:Break() + 1 == Logistics.GetBreakMax(InItem) then
        SetTexture(self.ImgLogis, InItem:IconBreak())
    else
        SetTexture(self.ImgLogis, InItem:Icon())
    end

    if self.TxtLevelNum then
        -- self.TxtLevelNum:SetText(string.format("%s/%s", InItem:EnhanceLevel(), Item.GetMaxLevel(InItem)))
        self.TxtLevelNum:SetText(string.format("%s", InItem:EnhanceLevel()))
    end
    

    if self.ListLogisLevelAtt then
        self:DoClearListItems(self.ListLogisLevelAtt)

        for k, i in pairs(Logistics.tbMainAttr) do
            local tbParam = {
                ECate = i,
                sName = Text(string.format("attribute.%s", i)),
                nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InItem, OldLv),
                nAdd = tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InItem, InItem:EnhanceLevel(), InItem:Break() + 1)),
                CollapseBg = true,
            }
            if tbParam.nAdd > 0 then
                local NewObj = self.ListFactory:Create(tbParam)
                self.ListLogisLevelAtt:AddItem(NewObj)
            end
        end
    end

    local sMaxLevel = Logistics.GetMaxLevel(InItem)
    if (not sMaxLevel) or (sMaxLevel > InItem:EnhanceLevel()) then return end
    local affix = InItem:GetAffix(3)
    local AffixKey = affix:Length() > 0 and affix:Get(1) or 0
    if AffixKey > 0 then
        WidgetUtils.HitTestInvisible(self.TxtAffixIntro3)
        self.TxtAffixIntro3:SetText(Logistics.GetAffixShowNameByTarray(affix))
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
                nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InItem, InItem:EnhanceLevel(), InItem:Break()),
                nAdd = tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InItem, InItem:EnhanceLevel(), InItem:Break() + 1)),
                IsPercent = not (i == "Command_break"),
            }
            if tbParam.nAdd > 0 then
                local NewObj = self.ListFactory:Create(tbParam)
                self.ListLogisBreach:AddItem(NewObj)
            end
        end

    end

    for i = 1, 5 do
        local pw = self["s_" .. i]
        if pw then
            if i <= InItem:Break() + 1 then
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