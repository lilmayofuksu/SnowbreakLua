-- ========================================================
-- @File    : uw_role_role.lua
-- @Brief   : 角色展示
-- ========================================================

local tbRoleClass = Class("UMG.SubWidget")

tbRoleClass.Obj = nil
tbRoleClass.nTagIdx = -1

function tbRoleClass:Construct()
    BtnAddEvent(self.SelClick, function()
        if self.Obj and self.Obj.Click then
            self.Obj:Click(self.Obj.SelectId)
        end
    end)
end

function tbRoleClass:Display(InObj)
    WidgetUtils.Collapsed(self.PanelSelect)
    WidgetUtils.Collapsed(self.ImgLock2)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.PanelLevel)

    if InObj == nil then
        self:UnLock()
        return
    end

    self.Obj = InObj
    self:UnLockMat(self.Obj.tbUnLockMat)
    self:SetIcon(self.Obj.Icon)
    WidgetUtils.Collapsed(self.Red)
end

--- 角色相关:头像，角色品质，武器，克制属性,Icon
function tbRoleClass:SetIcon(InId)
    SetTexture(self.ImgRole, InId, true)
    if self.ImgRoleselect then
        SetTexture(self.ImgRoleselect, InId, true)
    end

    local WeaponTemplateId = self.Obj.DefaultWeaponGPDL
    SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[WeaponTemplateId.Detail])

    if self.Obj.bUIBoss then
        SetTexture(self.ImgQuality, Item.RoleColor[self.Obj.Template.Color])
    else
        SetTexture(self.ImgQuality, Item.RoleColor2[self.Obj.Template.Color])
    end
end

function tbRoleClass:UnLock(InState)
    WidgetUtils.Collapsed(self.ImgLock2)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.PanelLevel)
    if InState == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
        WidgetUtils.SelfHitTestInvisible(self.LvImg)
        self.ImgRole:SetRenderOpacity(1)
        self.ImgRoleselect:SetRenderOpacity(1)
    elseif InState == 2 then
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
        self.ImgRole:SetRenderOpacity(0.5)
        self.ImgRoleselect:SetRenderOpacity(0.5)
    end
end

function tbRoleClass:UnLockMat(InMatAtt)
    self.TextCurr:SetText(InMatAtt.Need)
    self.TextMax:SetText(InMatAtt.N)
    Color.Set(self.TextCurr, InMatAtt.Color)
end

return tbRoleClass
