-- ========================================================
-- @File    : uw_account_rolelist.lua
-- @Brief   : 账号界面
-- ========================================================

local tbClass= Class("UMG.SubWidget")

local tbQuality = {
    2100300,
    2100300,
    2100301,
    2100302,
    2100303
}

function tbClass:Construct()
    BtnAddEvent(self.BtnClick,function()
        if not self.Info then return end 
        UI.Open("SelectRole", self.Info.nIndex)  
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    if pObj.Data.bAdd then
        WidgetUtils.HitTestInvisible(self.PanelAdd)
    else
        WidgetUtils.Collapsed(self.PanelAdd)
    end

    local tbItem = pObj.Data.tbItem
    local pTemplate = nil
    if tbItem then
        pTemplate = UE4.UItem.FindTemplate(tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel)
    end
    if pTemplate and pTemplate.Genre ~= 0 and pTemplate.Detail ~= 0 and pTemplate.Particular ~= 0 and pTemplate.Level ~= 0  then
        WidgetUtils.HitTestInvisible(self.PanelNormal)
        WidgetUtils.Collapsed(self.PanelNone)
        SetTexture(self.ImgRole, pTemplate.Icon)
        SetTexture(self.ImgQuality, tbQuality[pTemplate.Color])
        self.TxtNum:SetText(tbItem.nEnhanceLevel)
    else
        WidgetUtils.Collapsed(self.PanelNormal)
        WidgetUtils.HitTestInvisible(self.PanelNone)
    end
end

function tbClass:Set(tbParam)
    if not tbParam then return end
    self.Info = tbParam
    local pCard = tbParam.pCard

    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelNone)
    WidgetUtils.Collapsed(self.PanelAdd)

    if pCard then
        WidgetUtils.HitTestInvisible(self.PanelNormal)
        ------
        SetTexture(self.ImgRole, pCard:Icon())
        SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[pCard:GetSlotWeapon():Detail()]) 
        SetTexture(self.ImgQuality, tbQuality[pCard:Color()])
        local nTriangleAttribute = UE4.UItemLibrary.GetCharacterAtrributeTemplate(UE4.UItem.FindTemplate(pCard:Genre(), pCard:Detail(), pCard:Particular(), pCard:Level())).TriangleType
        --SetTexture(self.ImgRestraint, Item.RoleTrangleAttr[nTriangleAttribute + 1])
        self.TxtNum:SetText(pCard:EnhanceLevel())
    else
        WidgetUtils.HitTestInvisible(self.PanelAdd)
    end
end

return tbClass