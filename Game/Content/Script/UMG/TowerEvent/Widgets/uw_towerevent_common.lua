-- ========================================================
-- @File    : uw_towerevent_common.lua
-- @Brief   : 爬塔-战术考核关卡组件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnCommon, function ()
        if self.funClick then
            self.funClick()
        end
    end)
end

function tbClass:UpdatePanel(levelCfg, funClick)
    self.levelCfg =  levelCfg
    self.funClick =  funClick

    self.TxtLevelName:SetText(Text(self.levelCfg.sName))

    local bUnLock = Condition.Check(self.levelCfg.tbCondition)
    if bUnLock then
        WidgetUtils.Collapsed(self.CommonLock)
        if self.levelCfg:IsPass() then
            WidgetUtils.HitTestInvisible(self.CommonCompleted)
        else
            WidgetUtils.Collapsed(self.CommonCompleted)
        end
    else
        WidgetUtils.HitTestInvisible(self.CommonLock)
    end

    self:SetSelect(TowerEventChapter.GetLevelID() == self.levelCfg.nID)
end

function tbClass:SetSelect(isSelect)
    if isSelect then
        WidgetUtils.HitTestInvisible(self.CommonSelected)
    else
        WidgetUtils.Collapsed(self.CommonSelected)
    end
end

return tbClass
