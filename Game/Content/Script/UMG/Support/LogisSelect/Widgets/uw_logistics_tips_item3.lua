-- ========================================================
-- @File    : uw_logistics_tips_item3.lua
-- @Brief   : 角色后勤Tip3 item
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnLock, function()
        self:SetLock()
    end)
end

--- 刷新锁定UI
--- @param Incard UCharacter 装备该后勤的角色
--- @param InItem USupportCard 当前选中的后勤
function tbClass:UpdateState(Incard, InItem)
    self.pItem = InItem
    if not Incard then
        WidgetUtils.Collapsed(self.PanelState)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelState)
        SetTexture(self.ImgHead, Incard:Icon())
    end
    if self.pItem:HasFlag(Item.FLAG_LOCK) then
        WidgetUtils.SelfHitTestInvisible(self.Locked)
        WidgetUtils.Collapsed(self.Unlocked)
    else
        WidgetUtils.SelfHitTestInvisible(self.Unlocked)
        WidgetUtils.Collapsed(self.Locked)
    end
end

function tbClass:SetLock()
    if not self.pItem then
        return
    end

    local NowLock = self.pItem:HasFlag(Item.FLAG_LOCK)
    local bLock = NowLock == nil and true or not NowLock
    me:CallGS("Item_SetLock", json.encode({ItemId = self.pItem:Id(), Lock = bLock}))
end
return tbClass