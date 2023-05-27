-- ========================================================
-- @File    : uw_dungeonsboss_buffList.lua
-- @Brief   : boss挑战词条列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ItemPath = "/Game/UI/UMG/DungeonsBoss/Widgets/uw_dungeonsboss_buffitem.uw_dungeonsboss_buffitem_C"

    self.Padding = UE4.FMargin()
    self.Padding.Top = 30
    self.TxtNumDesc:SetText(Text("bossentries.GeneralDesc"))
end

function tbClass:UpdatePanel(info)
    self.tbParam = info
    if not self.tbParam then return end

    if self.tbParam.tbEntries then
        self.tbEntriesItem = {}
        self.ItemBox:ClearChildren()
        for i, cfg in ipairs(self.tbParam.tbEntries) do
            local pWidget = LoadWidget(self.ItemPath)
            if pWidget then
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
                self.ItemBox:AddChild(pWidget)
                pWidget:UpdatePanel(info)
                self.tbEntriesItem[cfg.nID] = pWidget
                if i > 1 then
                    pWidget:SetPadding(self.Padding)
                end
            end
        end
    end
end

return tbClass