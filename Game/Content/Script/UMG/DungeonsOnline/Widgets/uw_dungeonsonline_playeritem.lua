-- ========================================================
-- @File    : uw_dungeonsonline_playeritem.lua
-- @Brief   : 联机界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnInvite, function()        
        if Online.CheckSetInvite(self.Pid) then
            Online.InvitePlayer(self.Pid)
            self:ShowMain(self.tbProfile)
        end
    end)
end

--打开界面
function tbClass:OnListItemObjectSet(pObj)
    self.tbProfile = pObj.Data.tbProfile
    self.Pid =  self.tbProfile.nPid
    self:ShowMain(self.tbProfile)
end

--显示主要界面
function tbClass:ShowMain(tbProfile)
    self.TxtName:SetText(tbProfile.sName)
    self.TextLvNum:SetText(tbProfile.nLevel)

    local nFace = 1520001--默认星期三
    local tbFaceCard = tbProfile.tbShowItems[Profile.SHOWITEM_CARD]
    if tbFaceCard then
        local pTemp =
            UE4.UItem.FindTemplate(tbFaceCard.nGenre, tbFaceCard.nDetail, tbFaceCard.nParticular, tbFaceCard.nLevel)
        if pTemp then
            nFace = pTemp.Icon
        end
    end

    self.Portrait:OnOpen(nFace, tbProfile.nFaceFrame)

    self:ShowInvite()
end

function tbClass:ShowInvite()
    if not Online.CheckInviteState(self.Pid) then
        WidgetUtils.Collapsed(self.BtnInvite)
        WidgetUtils.SelfHitTestInvisible(self.TxtInvited)
    else
        WidgetUtils.Visible(self.BtnInvite)
        WidgetUtils.Collapsed(self.TxtInvited)
    end
end

---Tick
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end

    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end

    self.detime = 0
    self:ShowInvite()
end

return tbClass
