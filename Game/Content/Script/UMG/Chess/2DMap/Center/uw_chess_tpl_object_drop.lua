-- ========================================================
-- @File    : uw_chess_tpl_object_drop.lua
-- @Brief   : 棋盘物件放置
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 1, 0, 0.8)
local ColorNone = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.15)

function view:Construct()

end

function view:SetData(tbData)
    self.tbData = tbData
    self.Background:SetColorAndOpacity(ColorNone)
end

function view:SetSelected(value)
    if value then 
        self.Background:SetColorAndOpacity(ColorGreen)
    else 
        self.Background:SetColorAndOpacity(ColorNone)
    end
end

function view:OnDrop(MyGeometry, PointerEvent, Operation)
    local payload = Operation.Payload;
    local x, y = table.unpack(payload.tbParam.pos)
    if x ~= self.tbData.X or y ~= self.tbData.Y then 
        payload.tbParam.pos[1] = self.tbData.X;
        payload.tbParam.pos[2] = self.tbData.Y;
        payload:UpdatePosition()
        ChessEditor:Snapshoot()
    end
end

function view:OnDragEnter()
    self.tbData.parent:OnSelected(self.tbData.gridId)
end

function view:OnDragLeave()
    self.tbData.parent:OnSelected(nil)
end

return view