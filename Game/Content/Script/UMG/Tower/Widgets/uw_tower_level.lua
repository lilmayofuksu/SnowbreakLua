-- ========================================================
-- @File    : uw_tower_level.lua
-- @Brief   : 爬塔界面关卡按钮控件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Button, function()
        if self.unLock and self.tbparam then
            if self.tbparam.UpdateSelect then
                self.tbparam.UpdateSelect()
            end
        else
            UI.ShowMessage(self.sDec)
        end
    end)
end

function tbClass:Init(info)
    self.tbparam = info

    local realLayer = self.tbparam.layer
    if self.tbparam.type == 2 then
        realLayer = self.tbparam.layer + #ClimbTowerLogic.GetAllLayerTbLevel(1)
    end
    self.TxtLevelName:SetText(realLayer)

    self.unLock, self.sDec = ClimbTowerLogic.CheckUnlock(self.tbparam.type, self.tbparam.layer)
    if self.unLock then
        WidgetUtils.Collapsed(self.Lock)
        if self.BgCommon_3 then
            self.BgCommon_3:SetOpacity(1)
        end
        if self.tbparam.type == 2 then
            WidgetUtils.HitTestInvisible(self.Bg)
        end
        local tbAward = ClimbTowerLogic.GetLayerTbAward(self.tbparam.type, self.tbparam.layer)
        if tbAward.tbStarCount and tbAward.tbStarCount[3] then
            local num = ClimbTowerLogic.GetLayerStar(self.tbparam.type, self.tbparam.layer)
            if num >= tbAward.tbStarCount[3] then
                WidgetUtils.Collapsed(self.Normal)
                WidgetUtils.HitTestInvisible(self.Completed)
                self.TxtNum_1:SetText(num .. "/" .. tbAward.tbStarCount[3])
            else
                WidgetUtils.Collapsed(self.Completed)
                WidgetUtils.HitTestInvisible(self.Normal)
                self.TxtNum:SetText(num .. "/" .. tbAward.tbStarCount[3])
            end
        else
            WidgetUtils.Collapsed(self.Normal)
            WidgetUtils.Collapsed(self.Completed)
        end
    else
        if self.BgCommon_3 then
            self.BgCommon_3:SetOpacity(0.4)
        end
        if self.tbparam.type == 2 then
            WidgetUtils.Collapsed(self.Bg)
        end
        WidgetUtils.Collapsed(self.Normal)
        WidgetUtils.Collapsed(self.Completed)
        WidgetUtils.HitTestInvisible(self.Lock)
    end

    if self.tbparam.isSelect and self.unLock then
        WidgetUtils.HitTestInvisible(self.Selected)
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.Selected)
    end
end

function tbClass:SetSelect(isSelect)
    if isSelect then
        WidgetUtils.HitTestInvisible(self.Selected)
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.Selected)
    end
    self.tbparam.isSelect = isSelect
end

return tbClass
