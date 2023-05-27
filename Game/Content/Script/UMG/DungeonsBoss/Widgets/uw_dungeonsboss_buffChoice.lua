-- ========================================================
-- @File    : uw_dungeonsboss_buffChoice.lua
-- @Brief   : boss挑战词条列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.LIstPath = "/Game/UI/UMG/DungeonsBoss/Widgets/uw_dungeonsboss_buffitemslistsmall.uw_dungeonsboss_buffitemslistsmall_C"
    self.Padding = UE4.FMargin()
    self.Padding.Top = 30
end

function tbClass:UpdatePanel(info)
    self.tbParam = info
    if not self.tbParam then return end

    if self.tbParam.tbEntries then
        local summary = nil
        self.tbEntriesItem = {}
        self.ListBox:ClearChildren()
        for i = 1, math.ceil(#self.tbParam.tbEntries / 3) do
            local pWidget = LoadWidget(self.LIstPath)
            if pWidget then
                self.ListBox:AddChild(pWidget)
                for j = 1, 3 do
                    if pWidget["Item"..j] then
                        local cfg = self.tbParam.tbEntries[(i-1)*3+j]
                        if cfg then
                            WidgetUtils.SelfHitTestInvisible(pWidget["Item"..j])
                            local info = {}
                            info.cfg = cfg
                            info.UpdateSelect = function()
                                if self.tbParam.FunUpdate then
                                    self.tbParam.FunUpdate()
                                end
                                for _, Item in pairs(self.tbEntriesItem) do
                                    Item:UpdateState()
                                end
                            end
                            pWidget["Item"..j]:UpdatePanel(info)
                            table.insert(self.tbEntriesItem, pWidget["Item"..j])
                            if not summary and cfg.sSummary then
                                summary = cfg.sSummary
                            end
                        else
                            WidgetUtils.Collapsed(pWidget["Item"..j])
                        end
                    end
                end
                if i > 1 then
                    pWidget:SetPadding(self.Padding)
                end
            end
        end
        if summary then
            self.TxtNumDesc:SetText(Text(summary))
        end
    end
end

return tbClass