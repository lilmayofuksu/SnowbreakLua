-- ========================================================
-- @File    : uw_login_server_item.lua
-- @Brief   : 登录界面 服务器条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function()
        print("=====", self.fClick, self.Data)
        if self.fClick then
            self.fClick(self.Data)
        end
    end)
end

function tbClass:OnListItemObjectSet(InObj)
    self.Data = InObj.Data
    self.fClick = InObj.Data.fClick

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
        WidgetUtils.SelfHitTestInvisible(self.Select)
        WidgetUtils.Collapsed(self.Normal)

        self.ServerName_1:SetText(Text(self.Data.tbData.sName))
        --self.Btn:SetBackgroundColor(UE4.FLinearColor(1, 0, 1, 1))
        -- WidgetUtils.SelfHitTestInvisible(self.TxtUse)
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
    else
        WidgetUtils.SelfHitTestInvisible(self.Normal)
        WidgetUtils.Collapsed(self.Select)

        self.ServerName:SetText(Text(self.Data.tbData.sName))
        --self.Btn:SetBackgroundColor(UE4.FLinearColor(1, 1, 1, 1))
        -- WidgetUtils.Collapsed(self.TxtUse)
        --WidgetUtils.Collapsed(self.ImgSl)
    end
end

return tbClass
