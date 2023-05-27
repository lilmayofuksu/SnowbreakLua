-- ========================================================
-- @File    : umg_chess_log.lua
-- @Brief   : 棋盘 - 收集度
-- ========================================================

local view = Class("UMG.BaseWidget")

function view:OnInit()
    BtnAddEvent(self.BtnMask, function() UI.Close(self) end)    
    BtnAddEvent(self.BtnClick, function() UI.Close(self) end)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
end

function view:OnOpen()
    local tbCfgs = ChessConfig:GetGridDefineByModuleName(ChessClient.moduleName)
    local tbSmallBoxCfg, tbBigBoxCfg
    for _, tbCfg in pairs(tbCfgs.tbList) do
        if ChessTools:Contain(tbCfg.Tags, "treasurebox1") then
            tbSmallBoxCfg = tbCfg
        end

        if ChessTools:Contain(tbCfg.Tags, "treasurebox2") then
            tbBigBoxCfg = tbCfg
        end
    end
    local score = ChessReward:GetScore(ChessClient.activityId, ChessClient.activityType, ChessData.mapId) * 0.001
    self.TxtProgress:SetText(string.format("%g%%", score * 100))
    self.Roll:GetDynamicMaterial():SetScalarParameterValue("Percent", score)

    -- 地图中的箱子，必须有id，且类型为box，否则功能会出问题
    local count1, max1 = ChessTools:GetBoxCount("treasurebox1")
    self.TxtSmallBox2:SetText(count1)
    self.TxtSmallBox:SetText(string.format(" / %d", max1))
    self.TxtSmallBoxName:SetText(Text(tbSmallBoxCfg and tbSmallBoxCfg.NameKey))

    local count2, max2 = ChessTools:GetBoxCount("treasurebox2")
    self.TxtBigBox2:SetText(count2)
    self.TxtBigBox:SetText(string.format(" / %d", max2))
    self.TxtBigBoxName:SetText(Text(tbBigBoxCfg and tbBigBoxCfg.NameKey))

    self.uw_chess_content_list1:UpdateTaskMain()
    self.uw_chess_content_list2:UpdateTaskSub()
end

function view:OnClose()

end


return view