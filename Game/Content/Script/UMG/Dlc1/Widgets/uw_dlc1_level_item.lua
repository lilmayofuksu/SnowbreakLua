-- ========================================================
-- @File    : uw_level_item.lua
-- @Brief   : 关卡界面 关卡条目数据
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = {}

function tbClass:OnInit()
end

function tbClass:Init(nLevelID, InClickFun)
    if nLevelID == nil then WidgetUtils.Hidden(self) return end
    self.tbCfg = nil
    self.tbCfg = DLCLevel.Get(nLevelID)
    if not self.tbCfg then return end
    self.ClickFun = InClickFun
    self:OnInit()

    local bUnLock, tbDes = Condition.Check(self.tbCfg.tbCondition)
    self:SetLockState(bUnLock == false)

    WidgetUtils.PlayEnterAnimation(self)
end

function tbClass:OnSelectChange(bSelect)
end

function tbClass:SelectChange(bSelect)
    self:OnSelectChange(bSelect)
end

function tbClass:SetLockState(bLock)

end

return tbClass
