-- ========================================================
-- @File    : umg_activityface.lua
-- @Brief   : 打脸图界面
-- ========================================================

local tbActivityface = Class("UMG.BaseWidget")

--- 界面初始化
function tbActivityface:Construct()
    self.BtnClose.OnClicked:Add(
        self,
        function()
            local nNextId = Activityface.GetNextFaceId(self.Param.nFaceId)
            Activityface.UpDataCallBack(nNextId)
            UI.CloseByName("ActiviyFace")
        end
    )

    self.BtnAD.OnClicked:Add(
        self,
        function()
            if self.Param then
                if not self.Param.Goto then return end
                FunctionRouter.GoTo(self.Param.Goto)
                UI.CloseByName("ActiviyFace")
            end
        end
    )

    self.BtnSelect.OnClicked:Add(
        self,
        function()
            self:DoCheck()
        end
    )
end


--- 显示初始化
function tbActivityface:DoInit()
    -- body
end

--- 刷新
function tbActivityface:OnOpen(tbParam)
    self.Param = {nFaceId = tbParam and tbParam.nActivityId}
    local cfg = Activityface.GetConfig(self.Param and self.Param.nFaceId)
    if not cfg or not IsInTime(cfg.tStarttime, cfg.tEndtime) then
        UI.Close(self)
        return
    end
    self.Param.Goto = cfg.nJump
    self.Param.sBg = cfg.sBg

    if not self:IsAnimationPlaying(self.EnterAnim) then
        self:PlayAnimation(self.EnterAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
    self:OnChanegTexture(self.Param.sBg)
    self:ShowCheckFlag(self.Param.nFaceId)
end

--- 切换背景
function tbActivityface:OnChanegTexture(InId)
    local bgTexture = Resource.Get(InId)
    if self.ImgAD and bgTexture then
        SetTexture(self.ImgAD, bgTexture, true)
    end
end

-- 显示勾选
function tbActivityface:ShowCheckFlag(InId)
    InId = InId or (self.Param and self.Param.nFaceId)
    local tbConfig = Activityface.GetConfig(InId)
    if not tbConfig or tbConfig.nPopFlag == 0 then
        WidgetUtils.Collapsed(self.Tip)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.Tip)

    local nFlag = Activityface.GetPopFlag(InId)
    if nFlag == 0 then
        WidgetUtils.Collapsed(self.Check)
        return
    end

    local nDateTime = Activityface.GetPopTime(InId)
    local nDissDay = Activityface.CheckTimeDay(nDateTime, GetTime())
    if nDissDay < Activityface.nShowDay then
        WidgetUtils.SelfHitTestInvisible(self.Check)
        return
    end

    WidgetUtils.Collapsed(self.Check)
end

--勾选
function tbActivityface:DoCheck()
    if WidgetUtils.IsVisible(self.Check) then
        WidgetUtils.Collapsed(self.Check)
        Activityface.SetPopFlag(self.Param.nFaceId, false)
    else
        WidgetUtils.SelfHitTestInvisible(self.Check)
        Activityface.SetPopFlag(self.Param.nFaceId, true)
    end
end

return tbActivityface