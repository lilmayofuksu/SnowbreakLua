-- ========================================================
-- @File    : uw_notice_tab.lua
-- @Brief   : 公告条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function()  Notice.ReadNotice(self.Data.tbInfo) self:UpdateRedState()  if self.fClick then self.fClick(self.Data)  end end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nHandleId)
    BtnClearEvent(self.BtnClick)
end

function tbClass:OnListItemObjectSet(InObj)
    ---数据缓存
    self.Data = InObj.Data
    self.fClick = InObj.Data.fClick

    ---选择监听
    self:SelectChange( self.Data.bSelect)
    EventSystem.Remove(self.nHandleId)
    self.nHandleId = EventSystem.OnTarget(self.Data, 'SELECT_CHANGE', function(_, bSelect)  self:SelectChange(bSelect) end)

    ---公告信息
    local tbInfo = self.Data.tbInfo

    local sTxt = string.gsub(LocalContent(tbInfo.left_title), "\\n", "\n") 
    ---标题显示
    self.TxtName1:SetText(sTxt)
    self.TxtName:SetText(sTxt)
    ---日期显示
    local time = os.date("*t", tbInfo.start_time)
    self.TxtMonthCheck1:SetText(Text('ui.TxtNoticeSMonth', time.month))
    self.TxtMonthCheck:SetText(Text('ui.TxtNoticeSMonth', time.month))
    self.TxtDayCheck1:SetText(Text('ui.TxtNoticeSDay', time.day))
    self.TxtDayCheck:SetText(Text('ui.TxtNoticeSDay', time.day))

    self:UpdateRedState()
end

function tbClass:UpdateRedState()
    local bRead = Notice.IsRead(self.Data.tbInfo)
    if bRead then
        WidgetUtils.Collapsed(self.New)
    else
        WidgetUtils.HitTestInvisible(self.New)
    end
end

---选择显示
---@param bSelect boolean 选择标记
function tbClass:SelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.PanelCheck)
        WidgetUtils.Collapsed(self.New)

        local bRead = Notice.IsRead(self.Data.tbInfo)
        if not bRead then
            Notice.ReadNotice(self.Data.tbInfo)
        end
       
    else
        WidgetUtils.Collapsed(self.PanelCheck)
    end
end

return tbClass