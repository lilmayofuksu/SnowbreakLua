-- ========================================================
-- @File    : uw_widgets_skill_icon.lua
-- @Brief   : 技能图标
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:SetActived()
    BtnAddEvent(self.BtnClick, function()
        if self.Data and self.Data.fClickFun then 
            self.Data.fClickFun(self.Data.nSkillId) 
        end
    end)
    WidgetUtils.Collapsed(self.PanelRoleBreak)
end


function tbClass:OnOpen(InParam)
    self.Data = InParam
    self.SkillName:SetText(SkillName(self.Data.nSkillId))
    self:SetTxtTag(self.Data.sSkillTag)

    self:SetSkillTag()
    if self.Data.nLv == nil then
        WidgetUtils.Collapsed(self.TxtLevel)
    else
        WidgetUtils.SelfHitTestInvisible(self.TxtLevel)
        self.TxtLevel:SetText('Lv.' .. self.Data.nLv)
    end
    self:ShowBgState(self.Data.bBgIcon)
    local sIcon = UE4.UAbilityLibrary.GetSkillIcon(self.Data.nSkillId)
    if InParam.EType == RoleCard.SkillType.PassiveType then
        sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(self.Data.nSkillId)
    end
    SetTexture(self.SkillImg, sIcon)
    if InParam.bActived then
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.HitTestInvisible(self.PanelLock)
        SetTexture(self.SkillLock, sIcon)
    end
end


--- 技能激活标记
function tbClass:SetSkillTag(InState)
    WidgetUtils.Collapsed(self.ImgTag)
    if InState then
        WidgetUtils.Visible(self.ImgTag)
        -- WidgetUtils.Collapsed(self.Image)
    else
        -- WidgetUtils.SelfHitTestInvisible(self.Image)
        WidgetUtils.Hidden(self.ImgTag)
    end
end

function tbClass:SetActived(InState)
    WidgetUtils.Collapsed(self.PanelSelcet)
    if InState == 1 then
      WidgetUtils.SelfHitTestInvisible(self.PanelSelcet)
    end
end

--- 技能Icon
---@param InIdx interge 技能Idx
---@param InId interge 技能Id
function tbClass:SetStyleBySkill(InId,InType)
    WidgetUtils.Collapsed(self.PanelQte)
    WidgetUtils.Collapsed(self.PanelSkill)
    WidgetUtils.Collapsed(self.PanelSkill3)
    if InType == RoleCard.SkillType.QTESkill then
        WidgetUtils.SelfHitTestInvisible(self.PanelQte)
        local nQTEIconId,bQTEEndSwitchBack = RoleCard.GetQTEType(InId)
        if bQTEEndSwitchBack  then
            -- Color.SetColorFromHex(self.plateImg,'#FFFFFF66') ---闪击
        else
            -- Color.SetColorFromHex(self.plateImg,'#00A8FF66') -- - 强袭
        end
        
        SetTexture(self.IconQTE,nQTEIconId)
    elseif InType == RoleCard.SkillType.BigSkill then
        WidgetUtils.SelfHitTestInvisible(self.PanelSkill3)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelSkill)
    end
end

function tbClass:ShowBgState(InState)
    if self.Data.bBgIcon then
        WidgetUtils.SelfHitTestInvisible(self.PanelRoleBreak)
    else
        WidgetUtils.Collapsed(self.PanelRoleBreak)
    end
end

function tbClass:SetTxtTag(InStr)
    WidgetUtils.Collapsed(self.PanelTag)
    if InStr and InStr~="" then
        self.TxtTag:SetText(InStr)
        WidgetUtils.SelfHitTestInvisible(self.PanelTag)
        return
    end
end

function tbClass:ShowSpecialSkill(InIdx)
    WidgetUtils.Collapsed(self.ImgSkill1SP)
    WidgetUtils.SelfHitTestInvisible(self.ImgSkill_3)
    -- if InIdx == 1 then
    --    WidgetUtils.SelfHitTestInvisible(self.ImgSkill1SP)
    -- else
    --     WidgetUtils.SelfHitTestInvisible(self.ImgSkill_3)
    -- end
end

return tbClass
