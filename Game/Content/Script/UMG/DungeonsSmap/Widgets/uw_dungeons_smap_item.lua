-- ========================================================
-- @File    : uw_dungeons_smap_item.lua
-- @Brief   : 出击主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.ClickBtn, function()
        if self.fClick then
            self.fClick(self.nLevelID)
        end
    end)
end

function tbClass:Set(nLevelID, bSelect, fClick)
    self.bSelect = bSelect
    local tbCfg = DailyLevel.Get(nLevelID)
    if not tbCfg then return end
    self.nLevelID = nLevelID
    self.ChapterNumber:SetText(nLevelID)
    self.LevelName:SetText(Text(tbCfg.sName))
    self.fClick = fClick
    self:OnSelectChange(bSelect)
end


function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.SelectBg)
    else
        WidgetUtils.Collapsed(self.SelectBg)
    end
end

return tbClass