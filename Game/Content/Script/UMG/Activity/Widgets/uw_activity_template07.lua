-- ========================================================
-- @File    : uw_activity_template07.lua
-- @Brief   : 活动模板7  充值返还
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListReward1)
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnPurchase, function()
        self:DoClickBtn()
    end)

    self.Info:SetBtnListener(function() 
        local tbActivityCfg = Activity.GetActivityConfig(self.nActivityId)
        if tbActivityCfg and #tbActivityCfg.tbDes > 0 then 
            UI.Open("Info", tbActivityCfg.tbDes[1]) 
        end
    end)

    self.ListReward1:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnOpen(tbParam)
    self.nActivityId = tbParam and tbParam.nActivityId or self.nActivityId
    local tbActivityCfg = Activity.GetActivityConfig(self.nActivityId)
    if not tbActivityCfg then return end

    self:SetTimeDes(tbActivityCfg)
    self:ShowBtn(tbActivityCfg)
    self:ShowInfo(tbActivityCfg)
end

function tbClass:OnClose()
    self.nActivityId = 0
end

-- 结束时间戳
function tbClass:SetTimeDes(tbConfig)
    if not tbConfig then
        return
    end

    if self.PanelTime and tbConfig.nEndTime > 0 then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(tbConfig.nEndTime)
    else
        WidgetUtils.Collapsed(self.PanelTime)
    end
end

-- 按钮显示
function tbClass:ShowBtn(tbConfig)
    if not tbConfig then
        return
    end

    if tbConfig.tbCustomData[1] and tbConfig.tbCustomData[1] > 0 then
        if RechargeLogic.GetAwardFlag(tbConfig.nId) > 0 then
            self.TxtBtn:SetText("TxtReceived")
        else
            --领取奖励
            self.TxtBtn:SetText("TxtActivityRecharge08")
        end
    else
        --前往充值
        self.TxtBtn:SetText("TxtActivityRecharge07")
    end
end

--显示奖励等次
function tbClass:ShowInfo(tbConfig)
    self:DoClearListItems(self.ListReward1)

    local tbCfg = RechargeLogic.GetAllConfig()
    local nRecharge = RechargeLogic.GetRechargeNum(tbConfig) or 0
    local tbGetConfig = nil
    local tbColorList = self:GetColorList(tbCfg and #tbCfg or 0, 3)
    for i, info in ipairs(tbCfg) do
        local tbParam = {nIndex = self:GetColorIndex(i, tbColorList), tbConfig = info}
        local pObj = self.Factory:Create(tbParam)
        self.ListReward1:AddItem(pObj)

        if info.nNum >= nRecharge then
            tbGetConfig = info
        end
    end

    self:ShowAward(nRecharge)
end

--显示目前可获得的返还
function tbClass:ShowAward(nRecharge)
    self.nRecharge = nRecharge or 0
    self.Num1:SetText(self.nRecharge)

    local tbAll = RechargeLogic.CalculationAward(nRecharge) or {0,0}
    self.Num2:SetText(tbAll[1])
    self.Num3:SetText(tbAll[2])
end

--点击
function tbClass:DoClickBtn()
    local tbActivityCfg = Activity.GetActivityConfig(self.nActivityId)
    if tbActivityCfg and tbActivityCfg.tbCustomData[1] and tbActivityCfg.tbCustomData[1] > 0 then
        if RechargeLogic.GetAwardFlag(self.nActivityId) > 0 then
            UI.ShowTip("tip.star_award_geted")
            return
        end

        if self.nRecharge == 0 then
            UI.ShowTip("tip.reward_not_exist")
            return
        end

        local cmd = {
            nId            = self.nActivityId,
        }
        Activity.Quest_GetAward(cmd)
    else
        IBLogic.GotoMall(IBLogic.Tab_IBMoney)
    end
end

--获取颜色分类 3种
function tbClass:GetColorList(nAll, nSplitNum)
    nAll = math.floor(nAll) or 0
    nSplitNum = math.floor(nSplitNum) or 0
    if nAll == 0 then return  end
    if nSplitNum < 1 then return end

    local tbList = {}
    local nRet = math.floor(nAll / nSplitNum)
    local nLeft = math.floor(nAll % nSplitNum)

    for i=1,nSplitNum do
        table.insert(tbList, nRet)
    end

    for i=1,nSplitNum do
        if nLeft == i - 1 then
            for j=1,nLeft do
                tbList[j] = tbList[j] + 1
            end
            return tbList
        end
    end
end

--获取具体某个颜色分类
function tbClass:GetColorIndex(nNum, tbColorList)
    nNum = nNum or 0
    tbColorList = tbColorList or {}

    local nAllNum = 0
    local nGetIdx = 0
    for i,v in ipairs(tbColorList) do
        v = v or 0
        nAllNum = nAllNum + v
        nGetIdx = i
        if nNum <= nAllNum then
            break
        end
    end

    return nGetIdx
end

return tbClass
