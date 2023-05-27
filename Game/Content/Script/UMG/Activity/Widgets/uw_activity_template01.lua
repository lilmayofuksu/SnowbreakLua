-- ========================================================
-- @File    : uw_activity_template01.lua
-- @Brief   : 活动模板1
-- ========================================================


local tbActiveContent1 = Class("UMG.BaseWidget")

function tbActiveContent1:Construct()
    BtnAddEvent(
        self.BtnUse, 
        function()
            local tbConfig = Activity.GetActivityConfig(self.nActivityId)
            if tbConfig and tbConfig.sGotoUI then
                UI.Open(tbConfig.sGotoUI, table.unpack(tbConfig.tbUIParam))
            end
        end
    )
end

function tbActiveContent1:OnOpen(tbParam)
    self.nActivityId = tbParam.nActivityId
    self:ShowMain()
end

--显示当前界面
function tbActiveContent1:ShowMain()
    local tbConfig = Activity.GetActivityConfig(self.nActivityId)
    if not tbConfig then
        return
    end

    SetTexture(self.ImgPic, tbConfig.nBg)

    --暂时隐藏
    WidgetUtils.Collapsed(self.BtnIntro)
    WidgetUtils.Collapsed(self.BtnClick)

    WidgetUtils.Collapsed(self.TxtIntro1)
    WidgetUtils.Collapsed(self.TxtIntro2)

    WidgetUtils.Collapsed(self.TxtTimeEnd)
    WidgetUtils.Collapsed(self.TxtTime)
end



return tbActiveContent1