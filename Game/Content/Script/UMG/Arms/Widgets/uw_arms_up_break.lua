-- ========================================================
-- @File    : uw_arms_up_break.lua
-- @Brief   : 武器突破
-- ========================================================

---@class tbClass
---@field pWeapon UWeaponItem
---@field ListBreachItem UListView
---@field Star UWrapBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnBreach, function() self:DoBreak() end)
    self.ListBreachItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListFactory = Model.Use(self)

    local icon, _, _ = Cash.GetMoneyInfo(Cash.MoneyType_Silver)
    SetTexture(self.ImgBreachMoney, icon)
 end

 function tbClass:OnDestruct()
 end
 
 function tbClass:OnActive(pWeapon, pParent)
     self.pWeapon = pWeapon
     self.pParent = pParent
     if not self.pWeapon then return end
    self.nCostGold = 0
    self.bEnoughMat = true
    self:Update()
 end

 function tbClass:OnDisable()
 end

 function tbClass:Update()
    local nCostGold = 0
    local bEnoughMat = true
    ---突破材料

    self:DoClearListItems(self.ListBreachItem)
    local tbBreakMat = Item.GetBreakMaterials(self.pWeapon)
    if tbBreakMat then
        for _, Mat in ipairs(tbBreakMat) do
            local G, D, P, L, N = table.unpack(Mat)
            local nHave = me:GetItemCount(G, D, P, L)
            if nHave < N then
                bEnoughMat = false
            end

            local tbParam = { G = G, D = D,  P = P, L = L, nNeedNum = N, nNum = nHave}
            local NewObj = self.ListFactory:Create(tbParam)
            self.ListBreachItem:AddItem(NewObj)
            local pTemplate = UE4.UItem.FindTemplate(G, D, P, L)
            if  pTemplate then
                nCostGold = nCostGold + pTemplate.ConsumeGold * N
            end
        end
    end

    local nNow, sSubType =  Weapon.GetSubAttr(self.pWeapon, self.pWeapon:EnhanceLevel(), self.pWeapon:Quality())
    local nNew, _ =  Weapon.GetSubAttr(self.pWeapon, self.pWeapon:EnhanceLevel(), self.pWeapon:Quality() + 1)
    self.SubAtt:SetData(Text(string.format("attribute.%s", sSubType)), Resource.GetAttrPaint(sSubType), nNow, nNew)


    sSubType = 'DamageCoefficient'
    nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByStr(sSubType, self.pWeapon)
    nNew = UE4.UItemLibrary.GetCharacterCardAbilityValueByStr(sSubType, self.pWeapon, self.pWeapon:EnhanceLevel(), self.pWeapon:Quality() + 1)

    local fCover = function(n) return string.format('%0.1f', n) .. '%' end
    self.BreachAtt:SetData(Text(string.format("attribute.%s", sSubType)), Resource.GetAttrPaint(sSubType), fCover(tonumber(nNow)) , fCover(tonumber(nNew)))

    ---星级显示
    local nStarNum = self.pWeapon:Break()
    self:SetStar(nStarNum)

    self.nCostGold = nCostGold
    self.bEnoughMat = bEnoughMat

    local nSilver = Cash.GetMoneyCount(Cash.MoneyType_Silver)

    if nSilver < nCostGold then
        Color.SetTextColor(self.TxtBreachMoney, 'FF0000FF')
    else
        Color.SetTextColor(self.TxtBreachMoney, '03061FFF')
    end

    self.TxtBreachMoney:SetText(nCostGold)
    self.TxtNum:SetText(self.pWeapon:EnhanceLevel())
    self.TxtAddNum:SetText(Weapon.GetMaxLv(self.pWeapon, self.pWeapon:Quality() + 1))
    self.Partslock:Set(self.pWeapon, true)
    local BreakLimit = Item.GetBreakDemandLevel(self.pWeapon, self.pWeapon:Break() + 1)
    if me:Level() < BreakLimit then
        WidgetUtils.SelfHitTestInvisible(self.PanelTips)
        self.TextBlock_146:SetText(string.format(Text("ui.TxtUserLevelLimit"), BreakLimit))
    end
 end

 -- 星级展示
function tbClass:SetStar(nStar)
    for i = 1, 6 do
        local pw = self['s_' .. i]
        if pw then
            WidgetUtils.Collapsed(pw.ImgStarOff)
            WidgetUtils.Collapsed(pw.ImgStarNext)
            WidgetUtils.Collapsed(pw.ImgStar)
            if i <= nStar then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStar)
            elseif i == nStar + 1 then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarNext)
            else
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
            end
        end
    end
end
 
---执行突破
function tbClass:DoBreak()
    local CanBreak, Des = Item.CanBreak(self.pWeapon)
    if not CanBreak then
        UI.ShowTip(Des or "tip.BadParam")
        return
    end

    ---通用银检查
    if Cash.GetMoneyCount(Cash.MoneyType_Silver) < self.nCostGold then
        UI.ShowTip('tip.gold_not_enough')
        return
    end

    ---材料检查
    if not self.bEnoughMat then
        UI.ShowTip("tip.not_material_for_break")
        return
    end
    Weapon.Req_Break(self.pWeapon)
end

function tbClass:OnRsp()
    local fVisibleWidget = function(bVisible)
        local pUI = UI.GetUI('Arms')
        if pUI then
            if bVisible then 
                WidgetUtils.SelfHitTestInvisible(pUI)
            else
                WidgetUtils.Collapsed(pUI)
             end
        end
    end

    Adjust.WeaponBreakRecord(self.pWeapon:Break(), Item.GetBreakMaterials(self.pWeapon))
    UI.Open("WeaponBreak", self.pWeapon, function()
        fVisibleWidget(true)
        Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_lvup, nil)
    end)
    self.pParent:AutoPage()
    Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_break, nil)
    fVisibleWidget(false)
end

return tbClass