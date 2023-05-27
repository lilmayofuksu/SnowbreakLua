-- ========================================================
-- @File    : uw_chess_tpl_grid_hint.lua
-- @Brief   : 棋盘格子提示格子
-- ========================================================

local view = Class("UMG.SubWidget")

local ColorGreen = UE.FLinearColor(0, 1, 0, 0.8);
local ColorNone = UE.FLinearColor(1, 1, 1, 0.55);

function view:Construct()
    BtnAddEvent(self.BtnSelect, function() self:OnClick() end)
    ChessEditor:RegisterBtnHoverTip(self.BtnSelect, function() self:ShowTipData() end)
end

function view:SetData(tbData)
    self.tbData = tbData
    self.TxtName:SetText("")
    self:UpdateSelect()
end

function view:OnClick()
    self.tbData.parent:SetGridSelected(self.tbData.regionId, self.tbData.gridId)
    self:UpdateSelect()
end

function view:UpdateSelect()
    if self.tbData.parent:IsGridSelected(self.tbData.regionId, self.tbData.gridId) then 
        WidgetUtils.SelfHitTestInvisible(self.TxtNum)
        self.BtnSelect:SetBackgroundColor(ColorGreen)
    else 
        WidgetUtils.Collapsed(self.TxtNum)
        self.BtnSelect:SetBackgroundColor(ColorNone)
    end
end

function view:ShowTipData() 
    local objectId = ChessEditor:GetGroundObjectId(ChessEditor:GetCurrentRegionData(), self.tbData.gridId)
    local tbDef = ChessEditor:GetGridDefByTypeId(objectId)
    local msg = string.format("坐标:%d,%d", self.tbData.X, self.tbData.Y)
    if tbDef then 
        msg = string.format("%s 地形:%s", msg, tbDef.Name)
    end
    EventSystem.Trigger(Event.NotifyChessTipMsg, msg) 
end

return view