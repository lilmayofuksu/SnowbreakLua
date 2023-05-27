-- ========================================================
-- @File    : uw_defense_block.lua
-- @Brief   : 防御活动难度选择界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class('UMG.SubWidget')

function tbClass:Construct()
    BtnAddEvent(self.BtnEntry, function()
        if not self.bUnlock then
            return UI.ShowMessage('ui.Defense_Unlock_Tips')
        end
        if self.bUnlock and self.cfg and self.cfg.FunClick then
            self.cfg.FunClick()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self:Init(pObj.Data)
end

function tbClass:Init(cfg)
    self.cfg = cfg
    self.TextName:SetText(tostring(cfg.nDiff))
    self.TextName1:SetText(tostring(cfg.nDiff))

    local levelCfg = DefendLogic.tbLevel[cfg.nLevelID]
    self.TxtNum:SetText(tostring(levelCfg.nRecommendLevel))
    self.TxtNum1:SetText(tostring(levelCfg.nRecommendLevel))
    if levelCfg.nPicture then
        SetTexture(self.Image_4, levelCfg.nPicture)
    end
    self.bUnlock = cfg.nDiff <= DefendLogic.GetMaxDiff() + 1
    if self.bUnlock then
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.HitTestInvisible(self.PanelLock)
    end
    self.cfg.UpdateSelect = function(nDiff)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.PanelSelect, nDiff == self.cfg.nDiff)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Color1, nDiff ~= self.cfg.nDiff)
    end
    local diff = UI.GetUI(DefendLogic.sUI).Popup.nDiff or 1
    self.cfg.UpdateSelect(diff)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Image_1036, cfg.nDiff > 5)
end

return tbClass