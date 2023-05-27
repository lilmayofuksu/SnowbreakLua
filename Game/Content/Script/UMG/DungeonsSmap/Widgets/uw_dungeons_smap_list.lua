-- ========================================================
-- @File    : uw_dungeons_smap_list.lua
-- @Brief   : 出击主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function()
        local fClick = self.pObj.Data.fClick
        if fClick then
            fClick(self.pObj)
        end   
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectHandle)
end

function tbClass:OnListItemObjectSet(InObj)
    local tbData = InObj.Data
    if not tbData then return end
    self.pObj = InObj
    local tbChapter = Daily.GetChapterByID(tbData.nID)
    if not tbChapter then return end
    self.TxtName:SetText(Text(tbChapter.sName))
    self.TxtNameCheck:SetText(Text(tbChapter.sName))
    SetTexture(self.Icon, tbChapter.nImg)

    EventSystem.Remove(self.nSelectHandle)
    self.nSelectHandle = EventSystem.OnTarget(InObj, 'SELECT_CHANGE', function(_, bSelect)
        self:OnSelectChange(bSelect)
    end)
    self:OnSelectChange(tbData.bSelect)
    WidgetUtils.Collapsed(self.PanelTag)

    if tbChapter:IsOpen() then
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.HitTestInvisible(self.PanelLock)
    end
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.Checked)
        WidgetUtils.Collapsed(self.Unchecked)
    else
        WidgetUtils.Collapsed(self.Checked)
        WidgetUtils.HitTestInvisible(self.Unchecked)
    end
end

return tbClass