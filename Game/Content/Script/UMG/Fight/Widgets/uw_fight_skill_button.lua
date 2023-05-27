-- ========================================================
-- @File    : uw_fight_skill_button.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.tbLights = {
        self.ImgWhiteLight1,
        self.ImgWhiteLight2,
        self.ImgWhiteLight3,
        self.ImgWhiteLight4,
        self.ImgWhiteLight5,
        self.ImgWhiteLight6,
        self.ImgWhiteLight7,
        self.ImgWhiteLight8
    }
end

function tbClass:OnChargeTimesChange(InCurrentTimes, InMaxTimes)
    if InMaxTimes <= 1 then return end
    if not self.LastChargeTime then self.LastChargeTime = 8 end
    if InCurrentTimes > self.LastChargeTime then
        local v = self.tbLights[self.LastChargeTime + 1]
        if not v then return end

        WidgetUtils.SelfHitTestInvisible(v)
        self:PlayAnimFromAnimation(self.CdNumber, 0, 1, UE4.EUMGSequencePlayMode.Forward)
    end
    self.LastChargeTime = InCurrentTimes
end 

function tbClass:K2_OnCustomUmgAnimFinished(AnimName)
    if AnimName == "CdNumber" then
        for i,v in ipairs(self.tbLights) do
            WidgetUtils.Collapsed(v)
        end
    end
end

return tbClass