-- ========================================================
-- @File    : uw_bpreward.lua
-- @Brief   : bp通行证奖励界面
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)

    BtnAddEvent(self.BtnUnLock, function() self:DoBuy() end)
    BtnAddEvent(self.BtnAdd, function() self:DoBuyLevel() end)
    BtnAddEvent(self.Btn, function() if not BattlePass.CheckPass() then self:DoBuy()  end end)

    self.ListReward:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnActive(ShowType, tbConfig)
    self.tbConfig = tbConfig or BattlePass.GetMeConfig()
    self.tbAwardConfig = BattlePass.GetLevelAward()
    self:ShowExpBar()
    self:ShowAward()
    self:ShowLeftTime()
    self:ShowBtn()
    self:ShowMain()
    self:ShowInfo()
end

function tbClass:OnClose()
    self.tbConfig = nil
    self.tbAwardConfig = nil
end

function tbClass:ShowMain()
    WidgetUtils.Collapsed(self.Image_75)
    WidgetUtils.Collapsed(self.Npc)

    if not self.tbConfig then 
        return 
    end

    if self.tbConfig.tbNpcImgItem and #self.tbConfig.tbNpcImgItem >= 4 then
        WidgetUtils.SelfHitTestInvisible(self.Npc)

        local temp = UE4.UItem.FindTemplate(self.tbConfig.tbNpcImgItem[1], self.tbConfig.tbNpcImgItem[2], self.tbConfig.tbNpcImgItem[3], self.tbConfig.tbNpcImgItem[4])
        print("==re===", temp.Icon)
        AsynSetTexture(self.Npc, temp.Icon)
    end
end

---得到进度条的值
---@param count number 当前计数
---@param tbReward table 奖励配置列表
---@return float 进度条的值 0~1
function tbClass:GetProgressBarValue(count, nMax)
    if not count or not nMax then return 0 end
    if nMax <= 0 then return 0 end
    if count > nMax then return 1 end

    return count / nMax
end

---显示底部经验条
function tbClass:ShowExpBar()
    local nLevel, nLeftExp = BattlePass.GetCurLevel()
    nLevel = nLevel or 1
    nLeftExp = nLeftExp or 0

    local nStepExp = self.tbConfig and self.tbConfig.nExpStep or 1
    local nMaxWeek = self.tbConfig and self.tbConfig.nMaxExPerWeek or 1

    if nLeftExp > nStepExp then
        nLeftExp = nStepExp
    end

    self.TxtLv:SetText(nLevel)
    self.TxtLvMAX:SetText(string.format("/%d", BattlePass.GetMaxLevel(self.tbConfig and self.tbConfig.nId or 1)))
    self.TxtTotalExp:SetText(string.format("%d/%d", nLeftExp , nStepExp))
    self.BarPT:SetPercent(self:GetProgressBarValue(nLeftExp, nStepExp))

    local nWeekExp = BattlePass.GetWeeklyExp()
    if nWeekExp > nMaxWeek then
        nWeekExp = nMaxWeek
    end
    self.TxtLimitExp:SetText(string.format("%d/%d", nWeekExp, nMaxWeek))
end

--显示奖励
function tbClass:ShowAward()
    self:DoClearListItems(self.ListReward)
    local bHasPass = BattlePass.CheckPass()
    if bHasPass then
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
    end

    local tbNormalConfig = nil
    local tbAdvanceConfig = nil
    local nCurLevel = BattlePass.GetCurLevel() or 0

    local doMakeParam = function(tbConfig, nIdx, bAdv) 
        if not tbConfig then return {} end
        nIdx = nIdx or 0
        local tbAward = tbConfig.tbNormalAward
        if bAdv then
            tbAward = tbConfig.tbAdvanceAward
        end

        local tbParam = {G = tbAward[1],D = tbAward[2],P = tbAward[3],L = tbAward[4],N =tbAward[5] or 1}
        tbParam.nLevel = nIdx
        tbParam.bNoLimit = true
        tbParam.bAdv = bAdv
        if bAdv then
            tbParam.bGeted = (nIdx <= BattlePass.GetAdvanceAwardFlag())
            tbParam.bNew = ((nCurLevel >= nIdx and nCurLevel >= BattlePass.GetAdvanceAwardFlag()) and (not tbParam.bGeted))
            tbParam.bLock = not bHasPass
        else
            tbParam.bGeted = (nIdx <= BattlePass.GetNormalAwardFlag())
            tbParam.bNew = ((nCurLevel >= nIdx and nCurLevel >= BattlePass.GetNormalAwardFlag()) and (not tbParam.bGeted))
        end

        tbParam.nNormalSp = 0
        tbParam.nAdvanceSp = 0
        if bAdv then
            tbParam.nAdvanceSp = tbConfig.nAdvanceSp
        else
            tbParam.nNormalSp = tbConfig.nNormalSp
        end

        tbParam.DoUpdate = function()
            if not tbParam.bAdv and tbParam.nNormalSp > 0 then
                self:ShowNormalSP(Copy(tbParam))
            end
            if tbParam.bAdv and tbParam.nAdvanceSp > 0 then
                self:ShowAdvanceSP(Copy(tbParam))
            end
        end
        return tbParam
    end


    for i,v in ipairs(self.tbAwardConfig) do
        local tbParam =doMakeParam(v, i)
        if not tbNormalConfig and v.nNormalSp > 0 then
            tbNormalConfig = Copy(tbParam)
        end

        local obj = self.Factory:Create(tbParam)
        self.ListReward:AddItem(obj)

        tbParam =doMakeParam(v, i, true)
        if not tbAdvanceConfig and v.nAdvanceSp > 0  then
            tbAdvanceConfig = Copy(tbParam)
        end

        obj = self.Factory:Create(tbParam)
        self.ListReward:AddItem(obj)
    end

    self:ShowNormalSP(tbNormalConfig)
    self:ShowAdvanceSP(tbAdvanceConfig)

    if nCurLevel > 1 then
        nCurLevel = nCurLevel -1
        nCurLevel = nCurLevel * 2
    end
    self.ListReward:ScrollIndexIntoView(nCurLevel)
end

---显示普通的特殊奖励
function tbClass:ShowNormalSP(tbCurConfig)
    if tbCurConfig then
        tbCurConfig.DoUpdate = nil
    end

    local tbNextConfig = BattlePass.GetNextSP(self.tbAwardConfig, tbCurConfig)
    if tbNextConfig then
        WidgetUtils.Visible(self.NormalSP)
        self.NormalSP:Display(tbNextConfig)
        self.Txt:SetText(tbNextConfig.nLevel or 0)
    else
        WidgetUtils.Collapsed(self.NormalSP)
    end
end

---显示高级的特殊奖励
function tbClass:ShowAdvanceSP(tbCurConfig)
    if tbCurConfig then
        tbCurConfig.DoUpdate = nil
    end

    local tbNextConfig = BattlePass.GetNextSP(self.tbAwardConfig, tbCurConfig, true)
    if tbNextConfig  then
        WidgetUtils.Visible(self.EliteSP)
        self.EliteSP:Display(tbNextConfig)
    else
        WidgetUtils.Collapsed(self.EliteSP)
    end
end

---Tick
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end

    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end

    self.detime = 0
    self:ShowLeftTime()
end

---显示倒计时
function tbClass:ShowLeftTime()
    if not self.tbConfig then return end

    if self.tbConfig.nEndTime < GetTime() then
        WidgetUtils.Collapsed(self.LimitTime)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.LimitTime)

    local nDay, nHour, nMin, nSec = TimeDiff(self.tbConfig.nEndTime, GetTime())
    if nDay > 0 then
        local strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
        WidgetUtils.SelfHitTestInvisible(self.TxtDay)
        WidgetUtils.Collapsed(self.TxtTime)
        self.TxtDay:SetText(strTime)
    else
        local strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
        WidgetUtils.SelfHitTestInvisible(self.TxtTime)
        WidgetUtils.Collapsed(self.TxtDay)
        self.TxtTime:SetText(strTime)
    end
end

---购买通行证
function tbClass:DoBuy()
    -- local nFlag = BattlePass.GetPassFlag()
    -- if nFlag == BattlePass.PASS_LEVEL2 then --最高等级
    --     UI.ShowTip("tip.BattlePass_BP_Max")
    --     return
    -- end

    UI.Open("BuyBP")
end

---购买等级
function tbClass:DoBuyLevel()
    if not self.tbConfig then return end

    local bRet,sDesc = BattlePass.CheckBuyLevel(self.tbConfig)
    if not bRet then
        UI.ShowTip(sDesc)
        return
    end
   
    UI.Open("BPLevel")
end

--显示按钮
function tbClass:ShowBtn()
    if BattlePass.CheckBuyLevel(self.tbConfig) then
        WidgetUtils.Visible(self.BtnAdd)
    else
        WidgetUtils.Collapsed(self.BtnAdd)
    end

    local nFlag = BattlePass.GetPassFlag()
    if nFlag == BattlePass.PASS_LEVEL2 then --最高等级
        WidgetUtils.Collapsed(self.BtnUnLock)
    else
        WidgetUtils.Visible(self.BtnUnLock)
    end
end

--显示信息
function tbClass:ShowInfo()
    self.Info:SetBtnListener(function ()
            if self.tbConfig and self.tbConfig.sIntro then
                UI.Open("Info", self.tbConfig.sIntro)
            end
    end)
end

return tbClass