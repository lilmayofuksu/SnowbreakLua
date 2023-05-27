-- ========================================================
-- @File    : umg_survey_grade.lua
-- @Brief   : 评分引导
-- @Author  :
-- @Date    : 2022-07-28 
-- ========================================================

---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    WidgetUtils.Hidden(self.Panel2)
    --WidgetUtils.HitTestInvisible(self.BtnSubmit);
    --WidgetUtils.HitTestInvisible(self.BtnGrade);
    WidgetUtils.Hidden(self.BtnGrade)
    self.BtnSubmit:SetDesaturate(true)
    --self.BtnGrade:SetDesaturate(true)
    BtnAddEvent(self.BtnClick,function () self:OnBtnClose() end)
    BtnAddEvent(self.CloseBtn,function () self:OnCancel() end)
    BtnAddEvent(self.BtnSubmit,function () self:OnSubmit() end)
    BtnAddEvent(self.BtnGrade,function () self:OnGrade() end)
    for i = 0, 4 do
        local pInBtn = self["BgEmpty_" .. i]
        WidgetUtils.Visible(pInBtn)
        pInBtn.OnMouseButtonDownEvent:Bind(self,function() 
            self:OnBtnClick(i)
            return UE4.UWidgetBlueprintLibrary.Handled()
        end)
    end
    self.tbSelectHistory = {}
end

function tbClass:PreOpen(strType)
    self.strType = strType
    --print("SurveyGrade", "PreOpen", self.strType)
    return true
end

function tbClass:GetType()
    --print("SurveyGrade", "type", self.strType)
    return self.strType or Survey.CHAPTER
end

function tbClass:WriteLog(tblog)
    me:CallGS("SurveyLogic_WriteLog", json.encode({logstr = table.concat(tblog, "|")}))
end

function tbClass:OnCancel()
    if not self.bSelelctGrade then
        SurveyLogic.AddFailedCount(1)
        local tblog = {self:GetType(), SurveyLogic.GetSumCount(), 1, 0, Survey.LOG_CLOSE}
        self:WriteLog(tblog)
    end
    UI.Close(self)
end

function tbClass:OpenKeFu()
    local tbPlayerInfo = {}
    tbPlayerInfo.role_id = me:Id()
    tbPlayerInfo.area = me:GetAreaID()
    tbPlayerInfo.role_name = me:Nick()
    tbPlayerInfo.account = me:AccountId()
    tbPlayerInfo.avatar = ""
    tbPlayerInfo.level = me:Level() or ""
    tbPlayerInfo.channel = me:Channel()
    tbPlayerInfo.server = ""

    local sData = json.encode(tbPlayerInfo)
    local key = "abcdefg123456788"
    local sEncrypt = UE4.UGMLibrary.JsonEncrypt(key, sData);

    
    local sTimestamp = tostring(os.time())
    local sNonce = sTimestamp .. me:Id()
    local sort = UE4.UGMLibrary.DictionaryOrder(sTimestamp, '31C3eQJQeXQBwN8BMY69BK9b4HV1JF', sNonce)  --os.time()
    local sSignature = UE4.UGMLibrary.SignatureEncrypt(sort)
    
    local sFormat = "http://gm-mobile-qa.xoyo.com/app/h5/home?encrypt_data=%s&key=cbjq&signature=%s&timestamp=%s&nonce=%s"
    local sUrl = string.format(sFormat, sEncrypt, sSignature, sTimestamp, sNonce);
    UE4.UKismetSystemLibrary.LaunchURL(sUrl)
end

function tbClass:OnSubmit()
    if not self.nSelectValue then
        local sMsg, _ = Text("ui.TxtGrade7")
        UI.Open("MessageBox", sMsg, function()

            end, "Hide")
        return
    end
    UE4.UKismetSystemLibrary.LaunchURL(Survey.SURVEY_URL)
    SurveyLogic.AddFailedCount(1)
    self:SubmitOperateLog(Survey.LOG_KEFU)
    UI.Close(self)
    local sMsg, _ = Text("ui.TxtGrade6")
    UI.Open("MessageBox", sMsg, function()
        end, "Hide")
end

function tbClass:OnGrade()
    Survey.GOTO_APPSTORE=true
    UE4.UKismetSystemLibrary.LaunchURL(Survey.APPSTORE_URL)
    Survey.OPEN_APPSTORE_TIME = GetTime()
    --[[
    WidgetUtils.Hidden(self.Panel1)
    WidgetUtils.SelfHitTestInvisible(self.Panel2)
    WidgetUtils.Visible(self.BG.Bg);
    self.BG.Bg.OnMouseButtonDownEvent:Bind(self, function()
        UI.Close(self)
    end)
    self.bSelelctGrade = true
    --]]
    self:SubmitOperateLog(Survey.LOG_APPSTORE)
    UI.Close(self)
    local sMsg, _ = Text("ui.TxtGrade6")
    UI.Open("MessageBox", sMsg, 
        function()
            Survey:Reactivated()
        end, "Hide")
end

function tbClass:GetSelectValue()
    --print("SurveyGrade", "select", self.nSelectValue)
    return self.nSelectValue or 0;
end

function tbClass:DisableBtnClick()
    for i = 0, 4 do
        local pInBtn = self["BgEmpty_" .. i]
        WidgetUtils.HitTestInvisible(pInBtn)
    end
end

function tbClass:OnBtnClick(nIndex)
    self.nSelectValue = nIndex
    for i = 0, nIndex do
        local pWidget = self["BgFull_" .. i];
        WidgetUtils.SelfHitTestInvisible(pWidget);
    end
    for m = nIndex + 1, 4 do
        local pWidget = self["BgFull_" .. m];
        WidgetUtils.Collapsed(pWidget);
    end
    if nIndex <= 2 then
        WidgetUtils.Hidden(self.BtnGrade)
        WidgetUtils.Visible(self.BtnSubmit);
        --WidgetUtils.HitTestInvisible(self.BtnGrade);
        self.BtnSubmit:SetDesaturate(false)
        --self.BtnGrade:SetDesaturate(true)
    else
        WidgetUtils.Hidden(self.BtnSubmit)
        --WidgetUtils.HitTestInvisible(self.BtnSubmit);
        WidgetUtils.Visible(self.BtnGrade);
        --self.BtnSubmit:SetDesaturate(true)
        self.BtnGrade:SetDesaturate(false)
    end
    -- 只能评分一次
    -- self:DisableBtnClick()
    local LastValue = nil
    local ItemCount = #self.tbSelectHistory
    if ItemCount > 0 then
        LastValue = self.tbSelectHistory[ItemCount]
    end
    if LastValue ~= nIndex then
        table.insert(self.tbSelectHistory, nIndex)
    end
end

function tbClass:OnOpen()
end

function tbClass:OnClose()
    self.bSelelctGrade = nil;
end

function tbClass:OnBtnClose()
    SurveyLogic.AddFailedCount(1)
    local tblog = {self:GetType(), SurveyLogic.GetSumCount(), 1, 0, Survey.LOG_CLOSE}
    self:WriteLog(tblog)
    UI.Close(self)
end

function tbClass:SubmitOperateLog(Type)
    print("Survey", "SubmitOperateLog", self.tbSelectHistory)
    local FirstSelectValue = self.tbSelectHistory[1] or -2;
    local SecondSelectValue = self.tbSelectHistory[2] or -2;
    local tblog = {self:GetType(), SurveyLogic.GetSumCount(), 2, string.format("{%d,%d,%d}", self:GetSelectValue() + 1, SecondSelectValue + 1, FirstSelectValue + 1), Type}
    self:WriteLog(tblog)
end

return tbClass