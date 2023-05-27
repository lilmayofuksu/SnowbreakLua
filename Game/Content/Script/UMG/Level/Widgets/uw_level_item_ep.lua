-- ========================================================
-- @File    : uw_level_item_ep.lua
-- @Brief   : 关卡界面
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.Level.Widgets.uw_level_item")

function tbClass:Construct()
    BtnAddEvent(self.BtnEP, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
    self.Btn = self.BtnEP
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        WidgetUtils.HitTestInvisible(self.EPSelected)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.EPSelected)
    end
end

function tbClass:OnInit()
    self.TxtLevelName:SetText(GetLevelName(self.tbCfg))

    self.New:SetTag(string.format('%s_%s-%s', Chapter.GetChapterID(), Chapter.GetChapterDifficult(), self.tbCfg.nID))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.EPCompleted, self.tbCfg:IsPass())
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.EPNormal)
        WidgetUtils.HitTestInvisible(self.EPLock)
        if self.CanvasPanel then
            WidgetUtils.HitTestInvisible(self.CanvasPanel)
        end
        self.TxtLevelName:SetRenderOpacity(0.4)
    else
        WidgetUtils.Collapsed(self.EPLock)
        WidgetUtils.SelfHitTestInvisible(self.EPNormal)
        if self.CanvasPanel then
            WidgetUtils.Collapsed(self.CanvasPanel)
        end
        self.TxtLevelName:SetRenderOpacity(1)
    end
end

return tbClass