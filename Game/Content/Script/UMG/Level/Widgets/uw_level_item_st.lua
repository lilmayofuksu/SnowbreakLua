-- ========================================================
-- @File    : uw_level_item_st.lua
-- @Brief   : 关卡界面
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.Level.Widgets.uw_level_item")

function tbClass:Construct()
    BtnAddEvent(self.BtnST, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
    self.Btn = self.BtnST
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        WidgetUtils.HitTestInvisible(self.STSelected)
    else
        WidgetUtils.Collapsed(self.STSelected)
        self:StopAnimation(self.AllLoop)
    end
end

function tbClass:OnInit()
    self.TxtLevelName:SetText(GetLevelName(self.tbCfg))

    self.New:SetTag(string.format('%s_%s-%s', Chapter.GetChapterID(), Chapter.GetChapterDifficult(), self.tbCfg.nID))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.EPCompleted, self.tbCfg:IsPass())
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.STNormal)
        WidgetUtils.HitTestInvisible(self.STLock)
    else
        WidgetUtils.Collapsed(self.STLock)
        WidgetUtils.SelfHitTestInvisible(self.STNormal)
    end
end

return tbClass