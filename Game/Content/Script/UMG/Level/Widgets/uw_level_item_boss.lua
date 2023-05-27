-- ========================================================
-- @File    : uw_level_item_boss.lua
-- @Brief   : 关卡界面
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.Level.Widgets.uw_level_item")

function tbClass:Construct()
    BtnAddEvent(self.BtnBoss, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
    self.Btn = self.BtnBoss
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        WidgetUtils.HitTestInvisible(self.BossSelected)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.BossSelected)
    end
end

function tbClass:OnInit()
    self.TxtLevelName:SetText(Text(self.tbCfg.sFlag))
    self.TxtLevelNum:SetText(GetLevelName(self.tbCfg))

    if #self.tbCfg.tbStarCondition > 0 then
        WidgetUtils.HitTestInvisible(self.StarNode)
        self.StarNode:Set(self.tbCfg)
    else
        WidgetUtils.Collapsed(self.StarNode)
    end

    if self.tbCfg.nPictureBoss then
        SetTexture(self.ImgBoss, self.tbCfg.nPictureBoss)
        SetTexture(self.ImgBossLock, self.tbCfg.nPictureBoss)
    end
    if self.tbCfg.nPictureLevel then
        SetTexture(self.ImgChapter, self.tbCfg.nPictureLevel)
    end
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.BossNormal)
        WidgetUtils.HitTestInvisible(self.BossLock)
        self.TxtLevelName:SetRenderOpacity(0.4)
    else
        WidgetUtils.Collapsed(self.BossLock)
        WidgetUtils.SelfHitTestInvisible(self.BossNormal)
        self.TxtLevelName:SetRenderOpacity(1)
    end
end

return tbClass