-- ========================================================
-- @File    : uw_mail_list.lua
-- @Brief   : 邮件列表子面板
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local TARGET_MAIL_SELECTED = "TARGET_MAIL_SELECTED";

function tbClass:Construct()
    BtnAddEvent(self.Btnchoose, function() self.tbData.Show(); end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data;
    self.ParentUI = pObj.ParentUI;
    pObj.UI_List = self;
    self.TxtTitle:SetText(Mail.CheckContentParam(self.tbData.sTitle));
    self.TxtSender:SetText(Mail.CheckContentParam(self.tbData.sSender));
    self:UpdateState();

    if self.tbData.bSelected then
        self.tbData.Show();
    end
    self:SetSelected(self.tbData.bSelected);
    self:SetExpiration()

    WidgetUtils.Hidden(self.ImgNew); -- 屏蔽红点
end

function tbClass:UpdateState()
    WidgetUtils.Visible(self.PanelOn);
    WidgetUtils.Visible(self.PanelOff);

    if self.tbData.bReaded or self.tbData.bReceived then
        WidgetUtils.Visible(self.ImgRead);
        WidgetUtils.Hidden(self.ImgUnRead);
    else
        WidgetUtils.Hidden(self.ImgRead);
        WidgetUtils.Visible(self.ImgUnRead);
    end

    if self.tbData.bReceived or (not self.tbData.tbAttachments) then
        WidgetUtils.Hidden(self.ImgItem);
    else
        WidgetUtils.Visible(self.ImgItem);
    end

    if self.tbData.bReaded and (not self.tbData.tbAttachments) then
        WidgetUtils.Visible(self.PanelRead);
        WidgetUtils.Hidden(self.PanelOn);
        WidgetUtils.Hidden(self.PanelOff);
    end
end

function tbClass:SetSelected(bSelect)
    self.tbData.bSelected = bSelect;
    if bSelect then
        WidgetUtils.Visible(self.PanelSelect);
    else
        WidgetUtils.Hidden(self.PanelSelect);
    end
end

function tbClass:SetExpiration()
    if self.tbData.nExpiration == -1 then -- 整型最大值表示永不过期
        Color.Set(self.TxtExpiration, Color.DisableColor);
        return self.TxtExpiration:SetText(Text('ui.forever'));
    end

    if self.tbData.nExpiration <= GetTime() then
        if self.ParentUI.nCurrentMail == self.tbData.nID then
            self.tbData.Show();
        else
            self.tbData.bReaded = true;
            self:UpdateState();
        end
        Color.Set(self.TxtExpiration, Color.DisableColor);
        return self.TxtExpiration:SetText(Text('ui.expirated'));
    end

    local nDay, nHour, nMin, nSec = TimeDiff(self.tbData.nExpiration, GetTime());
    local sExpiration = "";
    Color.Set(self.TxtExpiration, Color.DefaultColor);
    if nDay > 0 then
        sExpiration = string.format(Text('ui.expiration_day'), nDay)
    elseif nHour > 0 then
        sExpiration = string.format(Text('ui.expiration_hour'), nHour)
    elseif nMin > 0 then
        Color.Set(self.TxtExpiration, Color.WarnColor);
        sExpiration = string.format(Text('ui.expiration_minute'), nMin)
        local nLoopTime = 60;
        if nMin < 2 then nLoopTime = 1; end
        self.ExpirationTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, tbClass.SetExpiration}, nLoopTime, false);
    else
        Color.Set(self.TxtExpiration, Color.WarnColor);
        sExpiration = string.format(Text('ui.expiration_sec'), nSec)
        self.ExpirationTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, tbClass.SetExpiration}, 1, false);
    end

    self.TxtExpiration:SetText(sExpiration);
end

function tbClass:OnDestruct()
    if self.ExpirationTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.ExpirationTimer);
    end
end

return tbClass;