-- ========================================================
-- @File    : uw_change_role_list_item.lua
-- @Brief   : 角色信息显示
-- ========================================================
---@class tbClass UUserWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.SelClick, function()
        if not self.pObj then return end
        local data = self.pObj.Data
        if not data then return end
        
        if data.fClick then
            data.fClick(self.pObj)
        end
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
end


function tbClass:OnListItemObjectSet(pObj)
    if not pObj.Data then return end

    self.pObj = pObj
    self:Display(pObj.Data)
    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent = EventSystem.OnTarget(pObj.Data, "SET_SELECTED", function(_, bSelect)
        self:SetSelect(bSelect, 1)
    end )
end


function tbClass:Display(tbData)
    if not tbData then return end
    local pCard = tbData.pCard

    if not pCard then
        return
    end

    self:SetSelect(tbData.bSelect, 100)
    self:SetByCard(pCard)

    if tbData.bSet then
        WidgetUtils.HitTestInvisible(self.RoleSelected)
    else
        WidgetUtils.Collapsed(self.RoleSelected)
    end
end


---选中状态设置
---@param bSelect boolean 是否选中
function tbClass:SetSelect(bSelect, nSpeed)
    nSpeed = nSpeed or 1
    WidgetUtils.Collapsed(self.PanelLevel2)
    WidgetUtils.Collapsed(self.PanelLevel)
    if bSelect  then
        WidgetUtils.HitTestInvisible(self.PanelSelect)
        WidgetUtils.Collapsed(self.ImgRole)
        WidgetUtils.Collapsed(self.QualityBg)
        WidgetUtils.Collapsed(self.ImgQuality)
        WidgetUtils.Collapsed(self.ImgWeapon)
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, nSpeed)
    else
        WidgetUtils.Collapsed(self.PanelSelect)
        WidgetUtils.HitTestInvisible(self.ImgRole)
        WidgetUtils.HitTestInvisible(self.QualityBg)
        WidgetUtils.HitTestInvisible(self.ImgQuality)
        WidgetUtils.HitTestInvisible(self.ImgWeapon)
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Reverse, nSpeed)
    end
end

---设置角色信息
---@param pCard UCharacterCard
function tbClass:SetByCard(pCard)
    if not pCard then return end

    SetTexture(self.ImgRole, pCard:Icon())
    SetTexture(self.ImgRoleselect, pCard:Icon())
    SetTexture(self.Logo, pCard:Icon())

    local pWeapon = pCard:GetSlotWeapon()
    if pWeapon then
        SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[pWeapon:Detail()])
        SetTexture(self.ImgWeapon2, Item.WeaponTypeIcon[pWeapon:Detail()])
    end

    SetTexture(self.ImgQuality, Item.RoleColor2[pCard:Color()])
    SetTexture(self.ImgQuality2, Item.RoleColor2[pCard:Color()])

    self.TxtNum:SetText(Text('ui.roleup').. pCard:EnhanceLevel())
    self.TxtNum2:SetText(Text('ui.roleup').. pCard:EnhanceLevel())
end



return tbClass