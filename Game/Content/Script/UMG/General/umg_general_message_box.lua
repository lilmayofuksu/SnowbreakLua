-- ========================================================
-- @File    : umg_general_message_box.lua
-- @Brief   : 弹窗
-- ========================================================

local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    BtnAddEvent(self.BtnNo, function()
        if self.fCancel then
            self.fCancel()
        end
        self.fClose = nil
        if self.bClose then
            UI.Close(self)
        end
    end)
    BtnAddEvent(self.BtnOk, function()
        local fOkEvent = self.fOkEvent
        self.fClose = nil
        self.fOkEvent = nil;
        if self.bClose then
            UI.Close(self)
        end
        if fOkEvent then
            fOkEvent()
        end
    end)
    BtnAddEvent(self.BtnOK2, function()
        local fOkEvent = self.fOkEvent
        self.fClose = nil
        self.fOkEvent = nil;
        if self.bClose then
            UI.Close(self)
        end
        if fOkEvent then
            fOkEvent()
        end
    end)
    BtnAddEvent(self.BtnSelect, function()
        self.bCheck = not self.bCheck
        if self.bCheck then
            WidgetUtils.HitTestInvisible(self.Check)
        else
            WidgetUtils.Collapsed(self.Check)
        end

    end)
end

--fClose fOkEvent fCancel 只执行其一
--fCancel为"hide"时会只显示确定按钮
function tbClass:OnOpen(sMsg, fOkEvent, fCancel, bPause, bClose, fClose, sTxtOk, sTxtClose, sMsgTips)
    UI.CloseConnection()
    self.bMousePreStatus = WidgetUtils.MouseCursorStatus(self)
    if not self.bMousePreStatus then
        self:ShowMouseCursor(true)
    end

    self.TxtMsg:SetText(sMsg)

    self.fOkEvent = fOkEvent

    self.fClose = fClose

    if bPause then
        self.isPause = true
        UE4.UGameplayStatics.SetGamePaused(self, true)
    else
        self.isPause = false
    end

    if bClose == false then
        self.bClose = false
    else
        self.bClose = true
    end

    local bSingleBtn = (fCancel == "Hide")

    if bSingleBtn then
        self.fCancel = nil
        WidgetUtils.Collapsed(self.DoubleBtns)
        WidgetUtils.SelfHitTestInvisible(self.SingleBtn)
    else
        self.fCancel = fCancel
        WidgetUtils.Collapsed(self.SingleBtn)
        WidgetUtils.SelfHitTestInvisible(self.DoubleBtns)
    end

    sTxtOk = sTxtOk or Text("ui.TxtDialogueConfirm")
    self.TxtConfirm_1:SetText(sTxtOk)
    if bSingleBtn then
        self.TxtConfirm_21:SetText(sTxtOk)
    end

    sTxtClose = sTxtClose or Text("ui.TxtDialogueCancel")
    self.TxtCancel_1:SetText(sTxtClose)

    if sMsgTips then
        WidgetUtils.HitTestInvisible(self.TxtMsgTips)
        self.TxtMsgTips:SetText(sMsgTips)
    else
        WidgetUtils.Collapsed(self.TxtMsgTips)
    end

    WidgetUtils.Collapsed(self.CostTip)
end

---本次登录不在弹窗设置
---@param bCheck boolean 当前选择状态
---@param funUpdateCheck function 改变选择时执行
function tbClass:SetCostTip(bCheck, funUpdateCheck, a)
    WidgetUtils.SelfHitTestInvisible(self.CostTip)
    if bCheck then
        self.bCheck = true
        WidgetUtils.HitTestInvisible(self.Check)
    else
        self.bCheck = false
        WidgetUtils.Collapsed(self.Check)
    end
    self.FunUpdateCheck = funUpdateCheck
end

function tbClass:OnClose()
    if self.isPause then
        UE4.UGameplayStatics.SetGamePaused(self, false)
    end
    self:ShowMouseCursor(self.bMousePreStatus)
    if self.fClose then
        self.fClose()
    end

    if self.FunUpdateCheck then
        self.FunUpdateCheck(self.bCheck)
    end
end

function tbClass:ShowMouseCursor(bShow)
    RuntimeState.ChangeInputMode(true)
end

return tbClass
