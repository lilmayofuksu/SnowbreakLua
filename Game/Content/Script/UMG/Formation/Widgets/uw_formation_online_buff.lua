-- ========================================================
-- @File    : uw_dungeonsonline_activity_buff.lua
-- @Brief   : 联机编队界面 buff信息
-- ========================================================
local tbClass = Class("UMG.SubWidget")

--打开界面
function tbClass:ShowBuff(tbInfo, funcShow)
    self.BtnClick.OnClicked:Clear()
    self.BtnClick.OnClicked:Add(self, function()
        self:ShowInfo()
    end)

    self.tbBuffInfo = tbInfo or {0,0}
    self.doFuncShow = funcShow
   self:ShowBuffIcon(self.tbBuffInfo[1])
   self:ShowBuffBg(self.tbBuffInfo)

    self:CloseAll()
end

function tbClass:CloseAll()
    self:CloseInfo()
    if self.doFuncShow then
        self.doFuncShow(false)
    end
end

--关闭当前面板
function tbClass:CloseInfo()
    WidgetUtils.Collapsed(self.PanelBuffDetail)
end

--显示bufficon
function tbClass:ShowBuffIcon(nBuffId)
    nBuffId = nBuffId or 0
    local skillInfo = UE4.UAbilityComponentBase.K2_GetSkillInfoStatic(nBuffId)
    if skillInfo and skillInfo.Icon then
        SetTexture(self.ImgBuff, skillInfo.Icon)
    end
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

--显示buff信息
function tbClass:ShowInfo()
    local nBuffId = self.tbBuffInfo[1] or 0
    local skillInfo = UE4.UAbilityComponentBase.K2_GetSkillInfoStatic(nBuffId)
    if not WidgetUtils.IsVisible(self.PanelBuffDetail) and skillInfo and skillInfo.SkillDescribe then
        if self.doFuncShow then
            self.doFuncShow(false)
        end

        WidgetUtils.SelfHitTestInvisible(self.PanelBuffDetail)

        self.TxtBuffName:SetText(SkillName(nBuffId))
        self.TxtDetail:SetContent(SkillDesc(nBuffId))

        if self.doFuncShow then
            self.doFuncShow(true)
        end
    else
        self:CloseAll()
    end
end


return tbClass
