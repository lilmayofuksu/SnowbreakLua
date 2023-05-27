-- ========================================================
-- @File    : uw_role_detail_list2.lua
-- @Brief   : 角色详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbDetailItem=Class("UMG.SubWidget")

function tbDetailItem:Construct()
    BtnAddEvent(self.BtnInfo, function ()
        if self.SkillName and self.SkillDescribe then
            UI.Open("SkillDescribe", self.SkillName, self.SkillDescribe)
        end
    end)
end

function tbDetailItem:OnListItemObjectSet(InObj)
    if InObj then
        self.data=InObj.Logic
        self:OnDes(self.data)
    end
end

function tbDetailItem:OnDes(InData)
    self.SkillName = InData.InName
    self.TxtName:SetText(Text(InData.InName))
    self.TxtRoleAtt:SetText(InData.InRoleAttr)
    local sPath = Resource.GetAttrPaint(InData.sECate)
    SetTexture(self.ImgIcon,sPath)

    if Localization.tbData[self.SkillName .. "_des"] then
        WidgetUtils.Visible(self.BtnInfo)
        self.SkillDescribe = self.SkillName .. "_des"
    else
        WidgetUtils.Collapsed(self.BtnInfo)
        self.SkillDescribe = nil
    end
end

return tbDetailItem