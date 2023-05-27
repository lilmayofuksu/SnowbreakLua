-- ========================================================
-- @File    : uw_dungeonsonline_activity_buff.lua
-- @Brief   : 联机界面 buff信息
-- ========================================================
local tbClass = Class("UMG.SubWidget")

--打开界面
function tbClass:ShowBuff(tbBuffInfo)
    tbBuffInfo = tbBuffInfo or {}
    self:ShowBuffBg(tbBuffInfo)
    self:ShowBuffInfo(tbBuffInfo)
end

--显示背景
function tbClass:ShowBuffBg(tbBuffInfo)
    local nFlag = tbBuffInfo and tbBuffInfo[2] or 0
    if nFlag == 0 then
        WidgetUtils.SelfHitTestInvisible(self.ImgbuffBg)
        WidgetUtils.Collapsed(self.ImgDebuffBg)

        WidgetUtils.SelfHitTestInvisible(self.ImgIconBg)
        WidgetUtils.Collapsed(self.ImgDeIconBg)
    else
        WidgetUtils.SelfHitTestInvisible(self.ImgDebuffBg)
        WidgetUtils.Collapsed(self.ImgbuffBg)

        WidgetUtils.SelfHitTestInvisible(self.ImgDeIconBg)
        WidgetUtils.Collapsed(self.ImgIconBg)
    end
end

function tbClass:ShowBuffInfo(tbBuffInfo)
    local nBuffId = tbBuffInfo and tbBuffInfo[1] or 0
    local skillInfo = UE4.UAbilityComponentBase.K2_GetSkillInfoStatic(nBuffId)
    if skillInfo and skillInfo.Icon then
        SetTexture(self.IMgDeBuff, skillInfo.Icon)
    end

    if skillInfo and skillInfo.SkillDescribe then
        self.TxtBuffDetail:SetContent(SkillDesc(nBuffId))
    end
end


return tbClass
