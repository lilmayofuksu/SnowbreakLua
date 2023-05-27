-- ========================================================
-- @File    : uw_dungeonsboss_monster.lua
-- @Brief   : boss挑战主界面boss按钮
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Button, function()
        if self.funClick then
            self.funClick()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    self.funClick = self.tbParam.UpdateSelect
    self.tbParam.SetSelect = function(owner, isSelect)
        if isSelect then
            WidgetUtils.HitTestInvisible(self.Selected)
        else
            WidgetUtils.Collapsed(self.Selected)
        end
        owner.isSelect = isSelect
    end

    if self.tbParam.isSelect then
        WidgetUtils.HitTestInvisible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
    end

    local Cfg = BossLogic.GetBossLevelCfg(self.tbParam.ID)
    if not Cfg then return end
    self.TxtScore:SetText(Text("ui.TxtActivityBossScore2", BossLogic.GetMaxIntegral(Cfg.nID)))

    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(Cfg.nBossID)
    if MonsterInfo and MonsterInfo.ProfileID then
        SetTexture(self.ImgBoss, MonsterInfo.ProfileID)
    end
end

return tbClass