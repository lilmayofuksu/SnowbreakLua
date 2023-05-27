-- ========================================================
-- @File    : uw_list_item_search.lua
-- @Brief   : 棋盘格子 快速跳转
-- ========================================================

local view = Class("UMG.SubWidget")

local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 1, 0, 1) 
local ColorWhite = UE4.UUMGLibrary.GetSlateColor(0.35, 0.35, 0.35, 1) 

function view:Construct()
    BtnAddEvent(self.BtnSelect, function() self:OnClick() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.cfg = self.tbData.cfg
    self.tbData.refresh = function(id)
        if id ~= self.tbData.id then return end 
        self:UpdateSelect()
    end

    self.TxtName:SetText(self:GetNameDesc())
    self.TxtGrid:SetText(self:GetGridDesc())
    self.TxtRegion:SetText(self.cfg.regionId)
    self:UpdateSelect()
end

function view:OnClick()
    if self.cfg.regionId ~= ChessEditor.CurrentRegionId then 
        ChessEditor:SetCurrentRegionId(self.cfg.regionId)
    end

    if self.tbData.find_type == "find_event" then 
        local tbData = ChessEditor:GetObjectDatas(self.cfg.type, self.cfg.id)
        if tbData.tbGroups then 
            for groupIdx, tbGroup in ipairs(tbData.tbGroups) do 
                tbGroup.expand = groupIdx == self.cfg.groupIdx
                for eventIdx, tbEvent in ipairs(tbGroup.tbEvents) do 
                    tbEvent.expand = eventIdx == self.cfg.eventIdx
                end
            end
        end
    end
    ChessEditor:SetSelectedObject(self.cfg.type, self.cfg.id)

    self.tbData.parent:OnSelect(self.tbData.id)
    EventSystem.Trigger(Event.NotifyChessLookAtPos, { x = self.pos[1], y = self.pos[2] })
end

function view:UpdateSelect()
    if self.tbData.select then 
        self.Background:SetColorAndOpacity(ColorGreen)
    else 
        self.Background:SetColorAndOpacity(ColorWhite)
    end
end

function view:GetGridDesc()
    local tbRegion = ChessEditor:GetRegionDataById(self.cfg.regionId)
    if self.cfg.type == "grid" then 
        local x, y = ChessTools:GridIdToXY(self.cfg.id)
        self.pos = {x, y}
        return string.format("[%d,%d]", x, y)
    elseif self.cfg.type == "object" then 
        local tb = tbRegion.tbObjects[self.cfg.id]
        self.pos = {tb.pos[1], tb.pos[2]}
        return string.format("[%d,%d]", tb.pos[1], tb.pos[2])
    end
end

function view:GetNameDesc()
    local tplId = self:GetTplId()
    local cfg = ChessEditor:GetGridDefByTypeId(tplId)
    return cfg and cfg.Name or "未知"
end


function view:GetTplId()
    local tbRegion = ChessEditor:GetRegionDataById(self.cfg.regionId)
    if self.cfg.type == "grid" then 
        return tbRegion.tbGround[self.cfg.id].objectId
    elseif self.cfg.type == "object" then 
        return tbRegion.tbObjects[self.cfg.id].tpl
    end
    return 0;
end

return view