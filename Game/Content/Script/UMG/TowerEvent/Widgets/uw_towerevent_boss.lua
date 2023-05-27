-- ========================================================
-- @File    : uw_towerevent_boss.lua
-- @Brief   : 爬塔-战术考核关卡组件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnBoss, function ()
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
        WidgetUtils.Collapsed(self.BossLock)
        if self.levelCfg:IsPass() then
            WidgetUtils.HitTestInvisible(self.BossCompleted)
        else
            WidgetUtils.Collapsed(self.BossCompleted)
        end
    else
        WidgetUtils.HitTestInvisible(self.BossLock)
    end

    self:SetSelect(TowerEventChapter.GetLevelID() == self.levelCfg.nID)
end

function tbClass:SetSelect(isSelect)
    if isSelect then
        WidgetUtils.HitTestInvisible(self.BossSelected)
    else
        WidgetUtils.Collapsed(self.BossSelected)
    end
end

return tbClass
