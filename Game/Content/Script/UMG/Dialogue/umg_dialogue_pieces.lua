-- ========================================================
-- @File    : umg_dialogue_pieces.lua
-- @Brief   : 碎片化剧情
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Pos1 = UE.FVector2D(-82, -514)
end

function tbClass:OnOpen(tbConf)
    tbConf = tbConf or self.tbConf
    if not tbConf then UI.Close(self) end
    if UI.bPoping then return end

    self.Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CanvasPanel_143)
    self.OrgPos = self.OrgPos or self.Slot:GetPosition()
    if self.closeTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.closeTimer)
        self.closeTimer = nil
    end
    self.nBeginTime = os.clock()
    local scrollBox
    if tbConf.nIcon > 0 then
        WidgetUtils.Collapsed(self.PanelTxt)
        WidgetUtils.SelfHitTestInvisible(self.PanelIcon)
        SetTexture(self.ImgIcon, tbConf.nIcon)
        self.Title1:SetText(Text(tbConf.sTitle))
        self.TalkText1:SetContent(Text(tbConf.sDesc))
        scrollBox = self.ScrollPageBox1
    else
        WidgetUtils.Collapsed(self.PanelIcon)
        WidgetUtils.SelfHitTestInvisible(self.PanelTxt)
        self.Title2:SetText(Text(tbConf.sTitle))
        self.TalkText2:SetContent(Text(tbConf.sDesc))
        if tbConf.nGroup > 0 then
            WidgetUtils.SelfHitTestInvisible(self.TxtProgress)
            local GotNum, TotalNum = FragmentStory.GetGroupProgress(tbConf.nGroup)
            self.TxtProgress:SetText(string.format('%d/%d', GotNum + 1, TotalNum))
        else
            WidgetUtils.Collapsed(self.TxtProgress)
        end
        scrollBox = self.ScrollPageBox2
    end

    if scrollBox then
        scrollBox:ScrollToStart()
        if self.nTimer then
            UE4.Timer.Cancel(self.nTimer)
            self.nTimer = nil
        end
        self.nTimer = UE4.Timer.Add(2, function()
            if self then
                scrollBox:MoveToEndBySpeed(-1, UE4.EMoveInterpType.CircularOut)
            end
        end)
    end

    self.Slot:SetPosition(self.OrgPos)

    self.closeTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, function()
        UI.Close(self)
        self.closeTimer = nil
    end}, 4, false)
    self.tbConf = tbConf
end

function tbClass:OnClose()
    UE4.Timer.Cancel(self.nTimer or 0)
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.closeTimer)
    DialogueMgr.OnClose(UE4.EUIDialogueType.FragmentStory,self.IsFromFight)
end

-- 打开时不聚焦
function tbClass:DontFocus()
    return true;
end

return tbClass