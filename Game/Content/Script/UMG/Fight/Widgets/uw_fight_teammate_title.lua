-- ========================================================
-- @File    : uw_fight_teammate_hp.lua
-- @Brief   : 战斗界面 队友名字
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    local IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    if not IsOnlineClient then 
        WidgetUtils.Collapsed(self)
        return;
    end

    self:InitPlayers()
end

-------------------------------------------------------------
--- BlueprintImplementableEvent
function tbClass:SetPlayerName(InWidget, InName)
    InWidget:SetName(InName)
end

function tbClass:SetReviveBarShow(InWidget, InShow)
    InWidget:SetReviveBarShow(InShow)
end

function tbClass:SetNameShow(InWidget, InShow)
    InWidget:SetNameShow(InShow)
end

function tbClass:AllocNewWidget()
    local widget = LoadWidget("/Game/UI/UMG/Fight/Widgets/Teammate/uw_fight_teammate_title_item.uw_fight_teammate_title_item_C")
    self.Root:AddChild(widget)

    local slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
    slot:SetAlignment(UE4.FVector2D(0.5, 0.5))
    return widget
end

function tbClass:GetReviveBar(widget)
    if not widget then return end
    return widget:GetReviveBar()
end

function tbClass:GetOtherReviveBar(widget)
    if not widget then return end
    return widget:GetOtherReviveBar()
end

function tbClass:PlayOtherReviveAnim(widget, bPlay)
    if not widget then return end
    widget:PlayOtherReviveAnim()
end

function tbClass:GetPanelTeamBar(widget)
    if not widget then return end
    return widget:GetPanelTeamBar()
end

-------------------------------------------------------------

return tbClass
