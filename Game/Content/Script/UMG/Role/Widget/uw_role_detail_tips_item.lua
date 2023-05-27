-- ========================================================
-- @File    : uw_role_detail_tips_item.lua
-- @Brief   : 角色详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbDetailItem=Class("UMG.SubWidget")

function tbDetailItem:OnListItemObjectSet(InObj)
    if InObj then
        self.data=InObj.Logic
        if not self.data then
            return
        end
        if self.data.sUIType == "RoleDetail" then
            self:OnDesRoleDetail(self.data)
        else
            self:OnDes(self.data)
        end
    end
end

function tbDetailItem:OnDesRoleDetail(InData)
    self.TxtName:SetText(InData.InName)
    local sPath = Resource.GetAttrPaint(InData.sECate)
    SetTexture(self.ImgIcon,sPath)

    local percentage = tonumber(UE4.UAbilityLibrary.KeepTwoValidDecimal(InData.InScale*10)) * 10
    local p1, p2 = math.modf(percentage)
    if p2 > 0 then
        self.TxtSupAtt:SetText(string.format("%.1f%%", percentage))
    else
        self.TxtSupAtt:SetText(string.format("%d%%", p1))
    end

    self.TxtArmsAtt:SetText(string.format("%.0f", InData.InBase))
    self.TxtAll:SetText(string.format("%.0f", InData.InTotal))
end


function tbDetailItem:OnDes(InData)
    self.TxtName:SetText(InData.InName)
    self.TxtRoleAtt:SetText(InData.InRoleAttr)
    if self.TxtArmsAtt then
        self.TxtArmsAtt:SetText(InData.InWeaponAttr)
    end
    if self.TxtSupAtt then
        self.TxtSupAtt:SetText(InData.InLogisAttr)
    end

    if self.TxtAll then
        self.TxtAll:SetText(InData.InTotal)
    end
    local sPath = Resource.GetAttrPaint(InData.sECate)
    SetTexture(self.ImgIcon,sPath)

    -- if not InData.InRoleAttr  then
    --     self.TxtRoleAttr:SetText('/')
    -- end

    -- if tonumber(InData.InRoleAttr)<=0 then
    --     self.TxtRoleAttr:SetText('-')
    -- end

    -- if not InData.InWeaponAttr  then
    --     self.TxtWeaponAtt:SetText('/')
    -- end

    -- if tonumber(InData.InWeaponAttr)<=0 then
    --     self.TxtWeaponAtt:SetText('-')
    -- end

    -- if  not InData.InLogisAttr then
    --     self.TxtLogisAttr:SetText('/')
    -- end

    -- if tonumber(InData.InLogisAttr)<=0 then
    --     self.TxtLogisAttr:SetText('-')
    -- end

    -- if ntotal<=0 then
    --     self.TxtTotal:SetText('-')
    -- end
end

return tbDetailItem