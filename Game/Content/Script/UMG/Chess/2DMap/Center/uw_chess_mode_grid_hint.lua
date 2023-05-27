-- ========================================================
-- @File    : uw_chess_mode_grid_hint.lua
-- @Brief   : 棋盘格子模板
-- ========================================================

local view = Class("UMG.SubWidget")


function view:Construct()
    self:RegisterEvent(Event.NotifyChessEntryGridHintMode, function(tbParam) self:OnEnter(tbParam) end)
    self:RegisterEvent(Event.NotifyChessExitGridHintMode, function() self:OnExit() end)
    self:OnExit()

    BtnAddEvent(self.BtnCancel, function() self:OnBtnClickCancel() end)
    BtnAddEvent(self.BtnOK, function() self:OnBtnClickOK() end)
    BtnAddEvent(self.BtnClear, function() self:OnBtnClickClear() end)
end


function view:OnEnter(tbParam)
    self.tbParam = tbParam
    self.lastRegionId = ChessEditor.CurrentRegionId
    tbParam.dirtyCB = function()
        self:UpdateShow()
    end
    tbParam.dirtyCB()
    WidgetUtils.SelfHitTestInvisible(self.Panel)
end

function view:OnExit()
    WidgetUtils.Collapsed(self.Panel)
end

function view:UpdateShow()
    if not self.tbParam.tbSelectedOrder then return end
    local count = 0;
    for regionId, tb in pairs(self.tbParam.tbSelectedOrder) do 
        if ChessEditor.CurrentRegionId == regionId then
            for k, v in pairs(tb) do 
                if v then 
                    local widget = self.tbParam.GetGridWidget(v)
                    print("UpdateShow", widget, k, v, regionId);
                    if widget then 
                        widget.TxtNum:SetText(k)
                    end
                    count = count + 1
                end
            end
        end
    end

    self.TxtCount:SetText(string.format("格子选择数: %d", count))
end

function view:OnBtnClickOK()
    EventSystem.Trigger(Event.NotifyChessExitGridHintMode)

    local tbRet = {}
    for regionId, tb in pairs(self.tbParam.tbSelectedOrder) do 
        for v, gridId in pairs(tb) do 
            table.insert(tbRet, {regionId, gridId})
        end
    end
    self.tbParam.onOK(#tbRet > 0 and tbRet or nil)
    if self.lastRegionId ~= ChessEditor.CurrentRegionId then 
        ChessEditor:SetCurrentRegionId(self.lastRegionId)
    end
end

function view:OnBtnClickClear()
    for regionId, tb in pairs(self.tbParam.tbSelectedOrder) do
        local tbSelect = self.tbParam.tbSelected[regionId]
        for i = #tb, 1, -1 do
            local gridId = tb[i]
            tbSelect[gridId] = not tbSelect[gridId]
            local widget = self.tbParam.GetGridWidget(gridId)
            if widget then
                widget:UpdateSelect()
            end
            table.remove(tb, i)
        end
    end
    if self.tbParam.dirtyCB then self.tbParam.dirtyCB() end
end

function view:OnBtnClickCancel()
    if self.tbParam.onCancel then 
        self.tbParam.onCancel()
    end
    EventSystem.Trigger(Event.NotifyChessExitGridHintMode)
end

return view