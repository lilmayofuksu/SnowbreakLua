-- ========================================================
-- @File    : uw_chess_right_menu.lua
-- @Brief   :
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.Factory = self.Factory or Model.Use(self)
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)

    self.RootSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Root)
    self:OnClose()

    self:RegisterEvent(Event.NotifyChessShowMenu, function(tbParam) 
        if tbParam then 
            self:OnOpen(tbParam) 
        else 
            self:OnClose()
        end
    end);
end

function view:OnOpen(tbParam)
    WidgetUtils.SelfHitTestInvisible(self)

    local pos = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
    self.RootSlot:SetPosition(pos)

    self:DoClearListItems(self.ListView)
    if tbParam then
        for _, v in pairs(tbParam) do
            self.ListView:AddItem(self.Factory:Create({Name = v[1], pCall = v[2], CallParam = v[3]}))
        end
    end
    UE4.Timer.Add(0.02, function()
        local ListSize = UE4.USlateBlueprintLibrary.GetLocalSize(self.Root:GetCachedGeometry())
        local PanelSize = UE4.USlateBlueprintLibrary.GetLocalSize(self.BtnClose:GetCachedGeometry())
        local AlignmentX, AlignmentY = 0, 0
        if ListSize.X + pos.X > PanelSize.X then
            AlignmentX = 1
        end
        if ListSize.Y + pos.Y > PanelSize.Y then
            AlignmentY = 1
        end
        self.RootSlot:SetAlignment(UE4.FVector2D(AlignmentX, AlignmentY))
    end)
end

function view:OnClose()
    WidgetUtils.Collapsed(self)
end


return view