-- ========================================================
-- @File    : umg_bpmain.lua
-- @Brief   : bp通行证界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")
--奖励，每日，每周， 限定
tbClass.sMainIcon = {1701104, 1701088, 1701089, 1701092}

function tbClass:Construct()
    self.Factory = Model.Use(self);
    BtnAddEvent(self.BtnQuick, function() self:DoGetAward() end)
    BtnAddEvent(self.Check, function() self:GotoFashion() end)
end

function tbClass:OnOpen()
    self.tbConfig = BattlePass.GetMeConfig()
    if not self.tbConfig then
        UI.ShowTip("tip.BattlePass_Config_error")
        UI.Close(self)
        return
    end

    self:UpdateLeftListPanel()
    self:UpdateRightListPanel()

    self.Money:Init({Cash.MoneyType_Vigour, Cash.MoneyType_Silver, Cash.MoneyType_Gold})
    self:PlayAnimation(self.AllEnter)
end

--关闭
function tbClass:OnClose()
    self.tbConfig = nil
end

---刷新左边列表
function tbClass:UpdateLeftListPanel()
    self:DoClearListItems(self.LeftList)

    if not self.tbConfig then return end

    self.PageItems = {};
    for i=BattlePass.SHOW_AWARD,BattlePass.SHOW_NORMAL do
        if not self.sMainIcon[i] then return end
        local tbParam = {}
        tbParam.nType = i
        tbParam.nIcon = self.sMainIcon[i]
        if  not self.ShowType then
            self.ShowType = tbParam.nType
        end
        tbParam.bSelected = (self.ShowType == tbParam.nType)
        tbParam.showType = self.ShowType
        tbParam.sName = Text("ui.TxtBPName"..i)

        tbParam.funcOnClick = function()
            if self.ShowType == tbParam.nType then return end
            local tbNowObj = self:GetLeftObj(self.ShowType)
            if tbNowObj then
                tbNowObj.bSelected = false
                if tbNowObj.SubUI and tbNowObj.SubUI.SelectChange then
                    tbNowObj.SubUI:SelectChange(false)
                end
            end

            local tbNextObj = self:GetLeftObj(tbParam.nType)
            if tbNextObj then
                tbNextObj.bSelected = true
                if tbNextObj.SubUI and tbNextObj.SubUI.SelectChange then
                    tbNextObj.SubUI:SelectChange(true)
                end
            end

            for k, v in pairs(self.PageItems) do
                v.showType = tbParam.nType
            end
            self.ShowType = tbParam.nType
            self:UpdateRightListPanel()
        end
        local pObj = self.Factory:Create(tbParam);
        self.PageItems[i] = pObj.Data
        self.LeftList:AddItem(pObj)
    end
end

---刷新右边面板
function tbClass:UpdateRightListPanel()
    if not self.tbConfig then return end

    local nPage = 0
    local sWidgetName = ''

    if self.ShowType == BattlePass.SHOW_AWARD then
        sWidgetName = 'Reward'
        nPage = 0
    else 
        sWidgetName = 'Mission'
        nPage = 1
    end

    local pCurrent = self.Switcher:GetActiveWidget()
    if pCurrent and pCurrent.OnDisable then 
        pCurrent:OnDisable()
    end

    self.Switcher:SetActiveWidgetIndex(nPage)
    pCurrent = self.Switcher:GetActiveWidget()
    if pCurrent then
        self[sWidgetName] = pCurrent
        if pCurrent.OnActive then
            pCurrent:OnActive(self.ShowType, self.tbConfig);
        end
    end
    
    self:ShowQuickBtn()
    self:ShowBanner()
end

--检查一键领取按钮
function tbClass:CheckQuickBtn()
    local nLevel, nLeftExp = BattlePass.GetCurLevel()
    if (self.ShowType == BattlePass.SHOW_DAILY or self.ShowType == BattlePass.SHOW_WEEKLY) and BattlePass.CheckWeeklyExp(self.tbConfig) then
        return 1
    elseif self.ShowType == BattlePass.SHOW_AWARD and (BattlePass.CheckPass() == true and BattlePass.GetAdvanceAwardFlag() == nLevel) then
        return 2
    elseif self.ShowType == BattlePass.SHOW_AWARD and (not BattlePass.CheckPass() and BattlePass.GetNormalAwardFlag() == nLevel) then
        return 2
    end

    local tbMission = nil
    if self.ShowType ~= BattlePass.SHOW_AWARD then
        tbMission = BattlePass.CheckGetMissionList(self.ShowType)
        if not tbMission or #tbMission == 0 then
            return 3
        end
    end

    return 0, tbMission
end

--显示一键领取按钮
function tbClass:ShowQuickBtn()
    if not self.tbConfig then return end
    if self:CheckQuickBtn() > 0 then
        WidgetUtils.Collapsed(self.BtnQuick)
    else
        WidgetUtils.Visible(self.BtnQuick)
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

---获取奖励 一键领取
function tbClass:DoGetAward()
    local nRet,tbList = self:CheckQuickBtn()
    if nRet == 1 then
        UI.ShowTip("tip.BattlePass_Exp_Max")
        return
    elseif nRet == 2 then
        UI.ShowTip("tip.BattlePass_Award_Error")
        return
    elseif nRet > 0 then
        return
    end

    if self.ShowType == BattlePass.SHOW_AWARD then
        BattlePass.DoGetAward()
    else
        BattlePass.DoGetMission(self.ShowType - 1, tbList)
    end
end

---服务器返回后刷新页面
function tbClass:OnReceiveUpdate(tbParam)
    local tbNowObj = self:GetLeftObj(self.ShowType)
    if tbNowObj and tbNowObj.SubUI and tbNowObj.SubUI.UpdateRed then
        tbNowObj.SubUI:UpdateRed()
    end

    self:UpdateRightListPanel()

    if tbParam and tbParam.tbAwards and #tbParam.tbAwards > 0 then
        Item.Gain(tbParam.tbAwards)
    end
end

--显示左边立绘  通行证名字 和 广告短语
function tbClass:ShowBanner()
    WidgetUtils.Collapsed(self.Npc)
    WidgetUtils.Collapsed(self.Banner)
    WidgetUtils.Collapsed(self.Check)
    WidgetUtils.Collapsed(self.Des2_1)

    if not self.tbConfig then 
        return 
    end

    if self.ShowType ~= BattlePass.SHOW_AWARD then
        return
    end

    if self.tbConfig.tbNpcImgItem and #self.tbConfig.tbNpcImgItem >= 4 then
        WidgetUtils.Visible(self.Check)
    end
    
    if self.tbConfig.nBannerName then
        WidgetUtils.SelfHitTestInvisible(self.Banner)
        SetTexture(self.Banner, self.tbConfig.nBannerName)
    end

    if self.tbConfig.sBannerInfo then
        WidgetUtils.SelfHitTestInvisible(self.Des2_1)
        self.Des2_1:SetText(Text(self.tbConfig.sBannerInfo))
    end
end

--时装跳转
function tbClass:GotoFashion()
    if not self.tbConfig or not self.tbConfig.tbNpcImgItem then return end
    if #self.tbConfig.tbNpcImgItem < 4 then return end

    local tbParam = {
        CharacterTemplate = {Genre = 1, Detail = self.tbConfig.tbNpcImgItem[2], Particular = self.tbConfig.tbNpcImgItem[3], Level = 1},
        SkinIndex = self.tbConfig.tbNpcImgItem[4],
    }

    UI.Open("RoleFashion", tbParam)
end

--获取标签对象
function tbClass:GetLeftObj(nShowType)
    if not nShowType then return end
    if not self.PageItems then return end

    return self.PageItems[nShowType]
end

return tbClass