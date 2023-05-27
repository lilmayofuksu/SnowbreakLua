-- ========================================================
-- @File    : umg_mail.lua
-- @Brief   : 邮件界面
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    self.tbMails = {};
    self.tbGetListID = {}
    self.tbGetListItem = {}
    self.Factory = Model.Use(self);

    -- self.Popup:Init("Mail", function() UI.Close(self) end);

    self.BtnGet.OnClicked:Add(self, function()
        self.tbGetListID = {}
        self.tbGetListItem = {}
        me:GetMailAttachments(self.nCurrentMail);
        self.tbGetListID[self.nCurrentMail] = 1
    end)

    self.BtnDelete.OnClicked:Add(self, function()
        me:DelMail(self.nCurrentMail);
        self.nCurrentMail = 0;
        self:Flush();
    end)

    self.BtnAllGet.OnClicked:Add(self, function()
        self.tbGetListID = {}
        self.tbGetListItem = {}
        for _, pMail in pairs(self.tbMails) do
            if pMail.Data.tbAttachments and pMail.Data.bReceived ~= true and (not Mail.IsExpiration(pMail.Data.nExpiration)) then
                pMail.Data.bReaded = true;
                me:GetMailAttachments(pMail.Data.nID);
                self.tbGetListID[pMail.Data.nID] = 1
            end
        end
    end)

    self.BtnAllDelete.OnClicked:Add(self, function()
        print("DelMail!!");
        for _, pMail in pairs(self.tbMails) do
            print("DelMail", pMail.Data.nID);
            if pMail.Data.bReaded and (pMail.Data.bReceived or (not pMail.Data.tbAttachments)) then
                me:DelMail(pMail.Data.nID);
                if pMail.Data.nID == self.nCurrentMail then
                    self.nCurrentMail = 0;
                end
            end
        end
        self:Flush();
    end)

    WidgetUtils.Hidden(self.PanelContent);
    WidgetUtils.Visible(self.Title);

end

function tbClass:OnOpen()
    self.nCurrentMail = 0;
    self:Flush();
    self:PlayAnimation(self.AllEnter)

end

function tbClass:Flush()
    WidgetUtils.Hidden(self.PanelContent)

    self:DoClearListItems(self.ListMail)
	self.ListMail:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    local AllMails = UE4.TArray(UE4.UMail)
    me:GetMails(AllMails);

    if AllMails:Length() <= 0 then
        WidgetUtils.Hidden(self.PanelList)
        WidgetUtils.HitTestInvisible(self.PanelNomail)
    else
        WidgetUtils.Visible(self.PanelList)
        WidgetUtils.Collapsed(self.PanelNomail)
    end

    local tbSort = {};
    local bFindCur = false
    for i = 1, AllMails:Length() do
        local data = AllMails:Get(i);
        local tbMail = {
            nID = data.ID,
            sSender = data.Sender,
            sTitle = data.Title,
            sContent = data.Message,
            nTime = data.Time,
            nExpiration = data.Expiration,
            bReaded = data.Readed,
            bReceived = data.Received,
        };

        for j = 1, data.Attachments:Length() do
            local pAttachment = data.Attachments:Get(j);
            local tbAttatchment = {
                G = pAttachment:Genre(),
                D = pAttachment:Detail(),
                P = pAttachment:Particular(),
                L = pAttachment:Level(),
                N = pAttachment:Count(),
                bGeted = data.Received,
            };
            tbMail.tbAttachments = tbMail.tbAttachments or {};
            table.insert(tbMail.tbAttachments, tbAttatchment);
        end
        if data.ID == self.nCurrentMail then
           bFindCur = true
        end
        table.insert(tbSort, tbMail);
    end

    if #tbSort <= 0 then return; end

    table.sort(tbSort, function(tbMailA, tbMailB)
        return tbMailA.nTime > tbMailB.nTime
    end)
    if self.nCurrentMail == 0 or bFindCur == false then
        self.nCurrentMail = tbSort[1].nID;
    end
    for _, tbMail in ipairs(tbSort) do
        if tbMail.nID == self.nCurrentMail then
            tbMail.bSelected = true;
        else
            tbMail.bSelected = false;
        end

        local pMail = self:GetMailObj(tbMail);
        self.ListMail:AddItem(pMail);
        self.tbMails[tbMail.nID] = pMail;
    end
end

function tbClass:GetMailObj(tbData)
    local pObj = self.Factory:Create(tbData);
    pObj.ParentUI = self;
    tbData.Show = function()
        WidgetUtils.Visible(self.PanelContent);

        self.TxtMailTitle:SetText(Mail.CheckContentParam(tbData.sTitle));
        self.TxtSender:SetText(Mail.CheckContentParam(tbData.sSender));
        self.TxtSendTime:SetText(Localization.LocalDateFormat(tbData.nTime));
        self.TxtMailContent:SetText(Mail.CheckContentParam(tbData.sContent));
    
        if tbData.tbAttachments and (not tbData.bReceived) and (not Mail.IsExpiration(tbData.nExpiration)) then
            WidgetUtils.Visible(self.BtnGet);
            WidgetUtils.Hidden(self.BtnDelete);
        else
            WidgetUtils.Visible(self.BtnDelete);
            WidgetUtils.Hidden(self.BtnGet);
        end

		self.PanelItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
        self:DoClearListItems(self.PanelItem)
        if tbData.tbAttachments then
            WidgetUtils.Visible(self.PanelReward)
            for _, tbAttachment in ipairs(tbData.tbAttachments) do
                local pItemObj = self.Factory:Create(tbAttachment);
                self.PanelItem:AddItem(pItemObj);
            end
        else
            WidgetUtils.Collapsed(self.PanelReward)
        end

        if not (tbData.bReaded and tbData.bReceived) then
            me:ReadMail(tbData.nID);
            tbData.bReaded = true;
            pObj.UI_List:UpdateState();
        end

        if self.tbMails[self.nCurrentMail] then
            self.tbMails[self.nCurrentMail].UI_List:SetSelected(false);
        end
        pObj.UI_List:SetSelected(true);
        self.nCurrentMail = tbData.nID;
    end

    return pObj
end

---领取邮件奖励返回的回调
function tbClass:OnGetMailAttachments(nID)
    local pMail = self.tbMails[nID];
    if pMail and pMail.Data.tbAttachments then

    self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self,
        function()
            if next(self.tbGetListItem) ~= nil then
                Item.Gain(self.tbGetListItem);
                self.tbGetListItem = {}
            end
        end
    }, 1, false)
        -- local tbParam = {};
        for _, tbAttachment in ipairs(pMail.Data.tbAttachments) do
            -- table.insert(tbParam, {tbAttachment.G, tbAttachment.D, tbAttachment.P, tbAttachment.L, tbAttachment.N});
            table.insert(self.tbGetListItem,{tbAttachment.G, tbAttachment.D, tbAttachment.P, tbAttachment.L, tbAttachment.N})
        end

        if self.tbGetListID[nID] == 1 then
            self.tbGetListID[nID] = nil
        end
        if next(self.tbGetListID) == nil and next(self.tbGetListItem) ~= nil then
            Item.Gain(self.tbGetListItem);
            self.tbGetListItem = {}
            UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
        end
    end
    self:Flush()
end

return tbClass;