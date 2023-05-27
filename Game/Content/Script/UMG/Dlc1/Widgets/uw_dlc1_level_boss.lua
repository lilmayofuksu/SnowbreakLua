-- ========================================================
-- @File    : uw_level_item_boss.lua
-- @Brief   : 关卡界面
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Button, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
    self.Btn = self.Button
end

function tbClass:Init(nLevelID, InClickFun)
    if nLevelID == nil then WidgetUtils.Hidden(self) return end
    self.tbCfg = DLCLevel.Get(nLevelID)
    if not self.tbCfg then return end
    self.ClickFun = InClickFun
    self:OnInit()

    local bUnLock, tbDes = Condition.Check(self.tbCfg.tbCondition)
    self:SetLockState(bUnLock == false)

    WidgetUtils.PlayEnterAnimation(self)
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.Selected)
        WidgetUtils.Collapsed(self.Normal)
        WidgetUtils.Collapsed(self.Lock)
    else
        WidgetUtils.HitTestInvisible(self.Normal)
        WidgetUtils.Collapsed(self.Selected)
        WidgetUtils.Collapsed(self.Lock)
    end
end

function tbClass:OnInit()
    self.TxtName:SetText(Text(self.tbCfg.sName))
    self.TxtNameLock:SetText(Text(self.tbCfg.sName))
    self.TxtNameSelected:SetText(Text(self.tbCfg.sName))
    -- self.TxtEN:SetText(Text(self.tbCfg.sFlag))
    -- self.TxtENLock:SetText(Text(self.tbCfg.sFlag))
    -- self.TxtENSelected:SetText(Text(self.tbCfg.sFlag))

    if #self.tbCfg.tbStarCondition > 0 then
        WidgetUtils.HitTestInvisible(self.StarNode)
        self.StarNode:Set(self.tbCfg)
    else
        WidgetUtils.Collapsed(self.StarNode)
    end

    if self.tbCfg.nPictureBoss then
        SetTexture(self.Icon, self.tbCfg.nPictureBoss)
        SetTexture(self.IconLock, self.tbCfg.nPictureBoss)
        SetTexture(self.IconSelected, self.tbCfg.nPictureBoss)
    end
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.Normal)
        WidgetUtils.Collapsed(self.Selected)
        WidgetUtils.HitTestInvisible(self.Lock)
    else
        WidgetUtils.Collapsed(self.Lock)
        WidgetUtils.Collapsed(self.Selected)
        WidgetUtils.SelfHitTestInvisible(self.Normal)
    end
end

return tbClass