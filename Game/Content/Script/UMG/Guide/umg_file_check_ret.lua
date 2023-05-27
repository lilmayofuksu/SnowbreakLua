-- ========================================================
-- @File    : umg_file_check_ret.lua
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnDay, function() self:SetNextCheckTime(24 * 3600) end)
    BtnAddEvent(self.BtnHour, function() self:SetNextCheckTime(3600) end)
    BtnAddEvent(self.BtnOK, function() self:SetNextCheckTime(0) end)
end

function tbClass:OnOpen(tbRets, count, callBack)
    self.TxtHint:SetText(string.format("以下%d个配置表服务器与客户端不一致:", #tbRets))
    self.TxtTotal:SetText(string.format("共检查了%d个配置表", count))
    self.Value:SetText(table.concat(tbRets, "\n"))
    self.pEnd = callBack

    if not IsEditor then 
        WidgetUtils.Collapsed(self.BtnDay)
        WidgetUtils.Collapsed(self.Tip1)

        WidgetUtils.Collapsed(self.BtnHour)
        WidgetUtils.Collapsed(self.Tip2)
    end
end

function tbClass:OnClose()
    
end

function tbClass:SetNextCheckTime(second)
    if self.pEnd then 
        self.pEnd(second);
        self.pEnd = nil;
    end
    UI.Close(self)
end


return tbClass
