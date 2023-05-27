-- ========================================================
-- @File    : uw_fight_action2.lua
-- @Brief   : 指引自动开火设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnOK, function ()
        if self.nCheckIndex ~= self.nSelectedIndex then
            PlayerSetting.Save()
        end
    end)
    BtnAddEvent(self.BtnChoose1, function ()
        self:OnChange(0)
    end)
    BtnAddEvent(self.BtnChoose2, function ()
        self:OnChange(1)
    end)
    self.Bg:Init(function () end)
end

function tbClass:UpdatePanel()
    self.nCheckIndex = PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.SHOOT_AUTO)
    self.nSelectedIndex = self.nCheckIndex
    if self.nSelectedIndex == 0 then
        WidgetUtils.Collapsed(self.ImgSl2)
        WidgetUtils.HitTestInvisible(self.ImgSl1)
        self:PlayAnimation(self.Loop2, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        self:StopAnimation(self.Loop1)
    elseif self.nSelectedIndex == 1 then
        WidgetUtils.Collapsed(self.ImgSl1)
        WidgetUtils.HitTestInvisible(self.ImgSl2)
        self:PlayAnimation(self.Loop1, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        self:StopAnimation(self.Loop2)
    end
    self.Bg:PlayAnimation(self.Bg.AllEnter)
    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnChange(Index)
    if self.nSelectedIndex == Index then
        return
    end
    self.nSelectedIndex = Index
    PlayerSetting.Set(PlayerSetting.SSID_OPERATION, OperationType.SHOOT_AUTO, {Index})

    if Index == 0 then
        WidgetUtils.Collapsed(self.ImgSl2)
        WidgetUtils.HitTestInvisible(self.ImgSl1)
        self:PlayAnimation(self.Loop2, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        self:StopAnimation(self.Loop1)
    elseif Index == 1 then
        WidgetUtils.Collapsed(self.ImgSl1)
        WidgetUtils.HitTestInvisible(self.ImgSl2)
        self:PlayAnimation(self.Loop1, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        self:StopAnimation(self.Loop2)
    end
end

return tbClass
