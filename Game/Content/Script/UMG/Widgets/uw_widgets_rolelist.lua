-- ========================================================
-- @File    : uw_widgets_rolelist.lua
-- @Brief   : 角色信息显示
-- ========================================================
---@class tbClass UUserWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end



---选中状态设置
---@param bSelect boolean 是否选中
function tbClass:SetSelect(bSelect)
    if bSelect  then
        WidgetUtils.HitTestInvisible(self.PanelSelect)
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward)
    else
        WidgetUtils.Collapsed(self.PanelSelect)
        if self:IsAnimationPlaying(self.Select) then
            self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Reverse)
        end
    end
end

---选中选择状态设置
---@param bSelect boolean 是否已经被选择
function tbClass:SetOnSelected(bSelect)
    if bSelect  then
        WidgetUtils.HitTestInvisible(self.PanelSelectd)
    else
        WidgetUtils.Collapsed(self.PanelSelectd)
        
    end
end



---设置角色信息
---@param pCard UCharacterCard
function tbClass:SetByCard(pCard)
    WidgetUtils.Collapsed(self.PanelSelectd)
    if pCard==nil  then
        WidgetUtils.Collapsed(self.Image_62)
        WidgetUtils.Collapsed(self.PanelSelect)
        WidgetUtils.Collapsed(self.ImgRole)
        WidgetUtils.Collapsed(self.ImgQuality)
        WidgetUtils.Collapsed(self.PanelLevel)
        WidgetUtils.Collapsed(self.PanelWeapon)
        WidgetUtils.Visible(self.PanelAdd)
        return
    end
    WidgetUtils.HitTestInvisible(self.Image_62)
    WidgetUtils.HitTestInvisible(self.PanelSelect)
    WidgetUtils.HitTestInvisible(self.ImgRole)
    WidgetUtils.HitTestInvisible(self.ImgQuality)
    WidgetUtils.HitTestInvisible(self.PanelLevel)
    WidgetUtils.HitTestInvisible(self.PanelWeapon)
    WidgetUtils.Collapsed(self.PanelAdd)
    self.nIndex=pCard.nIndex
    self:SetInfo(UE4.UItem.FindTemplateForID(pCard:TemplateId()), pCard:EnhanceLevel(), pCard:GetSlotWeapon():Detail())
end

---设置角色信息
---@param pTemplate FItemTemplate
function tbClass:SetByTemplate(pTemplate)
    self:SetInfo(pTemplate, 1, pTemplate.DefaultWeaponGPDL.Detail)
end

---设置角色信息
---@param pTemplate FItemTemplate 模板
---@param nLv Integer 角色等级
---@param nWeaponDetail Integer 武器类别
function tbClass:SetInfo(pTemplate, nLv, nWeaponDetail)
    SetTexture(self.ImgRole, pTemplate.Icon, true)
    SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[nWeaponDetail] ) 
    SetTexture(self.ImgQuality, Item.RoleColor[pTemplate.Color])
    local nTriangleAttribute = UE4.UItemLibrary.GetCharacterAtrributeTemplate(UE4.UItem.FindTemplate(pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level)).TriangleType
    SetTexture(self.ImgRestraint,Item.RoleTrangleAttr[nTriangleAttribute + 1])
    self.TxtNum:SetText(Text('ui.roleup').. nLv)
end
---获取当前已经展示的Cards
function tbClass:GetNowShowCards()
    local AccountWidget=UI.GetUI("Account")
    if AccountWidget~=nil then
        return AccountWidget:GettbShowCharacters()
    end
end

return tbClass