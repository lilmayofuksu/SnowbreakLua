-- ========================================================
-- @File    : uw_friendbtn_list.lua
-- @Brief   : 好友列表中的功能键
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param pObj ModelInstance
function tbClass:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.funcClick = pObj.Data.funcClick
    self:Update()
end

function tbClass:Update()
    BtnClearEvent(self.Btn)
    BtnAddEvent(
        self.Btn,
        function()
            if self.funcClick then
                self.funcClick()
            end
        end
    )

    WidgetUtils.Collapsed(self.Friendpoint)
    WidgetUtils.Collapsed(self.send)
    WidgetUtils.Collapsed(self.get)
    WidgetUtils.Collapsed(self.got)

    WidgetUtils.Collapsed(self.Friendtype)
    WidgetUtils.Collapsed(self.agree)
    WidgetUtils.Collapsed(self.disagree)
    WidgetUtils.Collapsed(self.add)
    WidgetUtils.Collapsed(self.del)

    WidgetUtils.Collapsed(self.Chat)

    if self.tbData.bVigorSend then
        WidgetUtils.Visible(self.Friendpoint)
        WidgetUtils.Visible(self.send)
    end
    if self.tbData.bVigorGet then
        WidgetUtils.Visible(self.Friendpoint)
        WidgetUtils.Visible(self.get)
    end
    if self.tbData.bVigorGot then
        WidgetUtils.Visible(self.Friendpoint)
        WidgetUtils.Visible(self.got)
    end
    if self.tbData.bAgreeFriend then
        WidgetUtils.Visible(self.Friendtype)
        WidgetUtils.Visible(self.agree)
        self.ImgFriendType:SetOpacity(1.0)
    end
    if self.tbData.bDisagreeFriend then
        WidgetUtils.Visible(self.Friendtype)
        WidgetUtils.Visible(self.disagree)
        self.ImgFriendType:SetOpacity(0.5)
    end
    if self.tbData.bAddFriend then
        WidgetUtils.Visible(self.Friendtype)
        WidgetUtils.Visible(self.add)
    end
    if self.tbData.bDelFriend then
        WidgetUtils.Visible(self.Friendtype)
        WidgetUtils.Visible(self.del)
    end
    if self.tbData.bChat then
        WidgetUtils.Visible(self.Chat)
    end
end

return tbClass
