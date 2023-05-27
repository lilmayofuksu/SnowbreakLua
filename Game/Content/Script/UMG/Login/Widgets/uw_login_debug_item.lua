-- ========================================================
-- @File    : uw_login_debug_item.lua
-- @Brief   : 登录界面 服务器条目 debug用
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function()
        if self.fClick then
            self.fClick(self.Data)
        end
    end)
end

function tbClass:OnListItemObjectSet(InObj)
    self.Data = InObj.Data
    self.fClick = InObj.Data.fClick
    self.ServerName:SetText(Text(self.Data.tbData.sName))
    self.ServerName_1:SetText(Text(self.Data.tbData.sName))
    self:SelectChange( self.Data.bSelect)
    EventSystem.Remove(self.nHandleId)
    self.nHandleId = EventSystem.OnTarget(self.Data, 'SELECT_CHANGE', function(_, bSelect)
        self:SelectChange(bSelect)
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nHandleId)
end

function tbClass:SelectChange(bSelect)
    if bSelect then
        --self.Btn:SetBackgroundColor(UE4.FLinearColor(1, 0, 1, 1))
        WidgetUtils.SelfHitTestInvisible(self.TxtUse)
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
    else
        --self.Btn:SetBackgroundColor(UE4.FLinearColor(1, 1, 1, 1))
        WidgetUtils.Collapsed(self.TxtUse)
        WidgetUtils.Collapsed(self.ImgSl)
    end
end

return tbClass
