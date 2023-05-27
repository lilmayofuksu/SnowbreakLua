-- ========================================================
-- @File    : uw_chess_mode_search.lua
-- @Brief   : 棋盘格子 快速跳转
-- ========================================================

local view = Class("UMG.SubWidget")


function view:Construct()
    self.Factory = Model.Use(self)
    self:RegisterEvent(Event.NotifyChessOpenFastJump, function(tbParam) self:OnEnter(tbParam) end)
    self:RegisterEvent(Event.NotifyChessCloseFastJump, function() self:OnExit() end)
    self:RegisterEvent(Event.NotifyChessSelectedObject, function(tbParam) self:OnSelectObject(tbParam) end)

    self:OnExit()

    BtnAddEvent(self.BtnClose, function() self:OnExit() end)
end


function view:OnEnter(tbParam)
    self.tbParam = tbParam
    WidgetUtils.SelfHitTestInvisible(self.Panel)
    self.TxtTitle:SetText(tbParam.title or "快速跳转")

    self:DoClearListItems(self.ListContent)
    self.tbList = {}
    for id, tb in ipairs(tbParam.tbList) do 
        local tbParam = {id = id, cfg = tb, find_type = tbParam.find_type, parent = self, select = false}
        self.ListContent:AddItem(self.Factory:Create(tbParam))
        table.insert(self.tbList, tbParam)
    end
end

function view:OnSelect(id)
    for i, tb in ipairs(self.tbList) do 
        tb.select = tb.id == id
        if tb.refresh then 
            tb.refresh(tb.id)
        end
    end
end

function view:OnExit()
    self.tbParam = nil
    WidgetUtils.Collapsed(self.Panel)
end


function view:OnSelectObject(tbParam)
    if not self.tbParam then return end

    local regionId = ChessEditor.CurrentRegionId
    for i, tb in ipairs(self.tbList) do 
        local isEqual = tb.cfg.type == tbParam.type and tb.cfg.id == tbParam.id and tb.cfg.regionId == regionId
        tb.select = isEqual;
        if tb.refresh then 
            tb.refresh(tb.id)
        end
    end
end


return view