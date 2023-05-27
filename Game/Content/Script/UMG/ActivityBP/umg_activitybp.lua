-- ========================================================
-- @File    : umg_activitybp.lua
-- @Brief   : bp每期首次弹出界面
-- ========================================================
local tbActivityBP = Class("UMG.BaseWidget")

function tbActivityBP:Construct()
    BtnAddEvent(self.BtnClose, function() self:DoClick() end)
    BtnAddEvent(self.BtnAD, function() self:DoClick() end)
end

function tbActivityBP:OnOpen(nADImg)
    self:ShowAD(nADImg)
    self:PlayAnimation(self.EnterAnim)
end

--显示广告
function tbActivityBP:ShowAD(nADImg)
    if nADImg then
        SetTexture(self.ImgAD, nADImg)
    end
end

function tbActivityBP:DoClick()
    BattlePass.DoFirstOpen()
    
    UI.Open("BPMain")
    UI.Close(self)
end

return tbActivityBP
