-- ========================================================
-- @File    : uw_activity_template09.lua
-- @Brief   : 活动模板9  扭蛋角色试玩
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:Construct()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListTryRole)
    self:DoClearListItems(self.ListReward)

    BtnAddEvent(self.FightBtn, function() self:ShowSpine(false); self:OnClickFight() end)
    BtnAddEvent(self.BtnGacha, function() self:ShowSpine(false); FunctionRouter.GoTo(FunctionType.Welfare, self.tbTryGirl.nGachaId) end)
    BtnAddEvent(self.BtnRolePv, function() UE4.UKismetSystemLibrary.LaunchURL(self.tbTryGirl.sPv) end)
    BtnAddEvent(self.BtnCheck, function() self:ShowSpine(false); self:ShowDetail() end)
    self.Info:SetBtnListener(function() UI.Open("Info", self.tbConf.sDesc) end)

    self.tbTrialCard = {}
    self.tbSpine = {}
    self.tbRoleWidgets = {}
end

function tbClass:OnOpen(tbParam, girlId)
    if tbParam and tbParam.nActivityId then
        if self.nActId and self.nActId ~= tbParam.nActivityId then
            self.nGirlIdx = 1
        end
        self.nActId = tbParam.nActivityId
    end
    if not self.nActId then self.nActId = GachaTry.LastEnterId end
    if not self.nActId then return end

    if UI.bRecover then self.nGirlIdx = GachaTry.GetGirlIdx() end
    GachaTry.LastEnterId = self.nActId
    PreviewScene.HiddenAll()
    PreviewScene.Reset()

    self.tbConf = GachaTry.GetConfig(self.nActId)

    local actConf = Activity.GetActivityConfig(self.nActId)
    self.Time:ShowNormal(actConf.nEndTime)

    self:DoClearListItems(self.ListTryRole)
    self.tbRoleWidgets = {}
    for idx, nGrilId in ipairs(self.tbConf.tbTryGirl) do
        if girlId and girlId == nGrilId then self.nGirlIdx = idx end
        local tbGirl = GachaTry.GetTryGirlConf(nGrilId)
        local g, d, p, l = table.unpack(tbGirl.tbGDPL)
        local tb = {G = g, D = d, P = p, L = l,
            fCustomEvent = function(widget) self:ShowGirl(idx, nil, widget) end,
            DoUpdate = function(widget)
                self.tbRoleWidgets[idx] = widget
                if idx == self.nGirlIdx then
                    if self.SelectWidget then
                        WidgetUtils.Collapsed(self.SelectWidget.PanelLight)
                    end
                    WidgetUtils.SelfHitTestInvisible(widget.PanelLight)
                    self.SelectWidget = widget
                end
            end }
        self.ListTryRole:AddItem(self.ListFactory:Create(tb))
        self.tbTrialCard[idx] = self.tbTrialCard[idx] or me:GetTrialCard(tbGirl.nTrialId)
    end

    UE4.Timer.NextFrame(function() self:ShowGirl(self.nGirlIdx or 1, true) end)
end

function tbClass:ShowGirl(nGirlIdx, bReOpen, widget)
    if nGirlIdx == self.nGirlIdx and not bReOpen then return end

    widget = widget or self.tbRoleWidgets[nGirlIdx]
    if widget then
        if self.SelectWidget then
            WidgetUtils.Collapsed(self.SelectWidget.PanelLight)
        end
        WidgetUtils.SelfHitTestInvisible(widget.PanelLight)
        self.SelectWidget = widget
    end

    self.nGirlIdx = nGirlIdx
    GachaTry.CacheId(self.nActId, self.nGirlIdx)
    local tbTryGirl = GachaTry.GetTryGirlConf(self.tbConf.tbTryGirl[nGirlIdx])
    self.tbTryGirl = tbTryGirl

    local g, d, p, l = table.unpack(tbTryGirl.tbGDPL)
    local girlInfo = UE4.UItem.FindTemplate(g,d,p,l)
    SetTexture(self.Rarity4_1, girlInfo.Color == 5 and 1700110 or 1700112)
    SetTexture(self.Rarity4_2, girlInfo.Color == 5 and 1700109 or 1700111)
    SetTexture(self.ImgArtTxt, tbTryGirl.nTitleBg)

    if tbTryGirl.sTitleBgColor and tbTryGirl.sTitleBgColor ~= '' then
        self.ImgArtTxt:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex(tbTryGirl.sTitleBgColor))
    else
        self.ImgArtTxt:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('FFFFFFFF'))
    end

    if self.ImgBg then SetTexture(self.ImgBg, tbTryGirl.nBg) end
    local uiActivity = UI.GetUI('Activity')
    if uiActivity and UI.IsOpen('Activity') then
        uiActivity:ChangeBG(tbTryGirl.nBg)
    end

    if tbTryGirl.sSpine and tbTryGirl.sSpine ~= '' then
        self:ShowSpine(true, tbTryGirl.sSpine)
        WidgetUtils.Collapsed(self.PanelSr)
        WidgetUtils.Collapsed(self.ImgBg)
    else
        self:ShowSpine(false)
        WidgetUtils.SelfHitTestInvisible(self.PanelSr)
        WidgetUtils.SelfHitTestInvisible(self.ImgBg)
        if tbTryGirl.sBgColor and tbTryGirl.sBgColor ~= '' then
            self.ImgSrBg:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex(tbTryGirl.sBgColor))
        end
        if not bReOpen then
            self:PlayAnimation(self.Switch)
        end
    end

    if tbTryGirl.nPose > 0 then
        WidgetUtils.SelfHitTestInvisible(self.ImgRolePose)
        SetTexture(self.ImgRolePose, tbTryGirl.nPose, true)
        SetTexture(self.ImgSrRole, tbTryGirl.nPose, true)
        self.ImgRolePose:SetRenderTranslation(UE4.FVector2D(tbTryGirl.tbPoseOffset[1] or 0, tbTryGirl.tbPoseOffset[2] or 0))
        self.ImgRolePose:SetRenderScale(UE4.FVector2D(tbTryGirl.tbPoseOffset[3] or 1, tbTryGirl.tbPoseOffset[3] or 1))
    else
        WidgetUtils.Collapsed(self.ImgRolePose)
    end
    self.TxtName:SetText(Text(girlInfo.I18N)..'-'..Text(girlInfo.I18N..'_title'))

    WidgetUtils.SetVisibleOrCollapsed(self.BtnRolePv, tbTryGirl.sPv and tbTryGirl.sPv ~= '')
    if tbTryGirl.sTitleColor and tbTryGirl.sTitleColor ~= '' then
        self.TxtActivityTry:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex(tbTryGirl.sTitleColor))
    end
    for i = 1, 5 do
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Star'..i], i <= girlInfo.Color)
    end

    self:DoClearListItems(self.ListReward)
    for _, tbItem in ipairs(tbTryGirl.tbReward) do
        local g,d,p,l,n = table.unpack(tbItem)
        local tb = {
            G = g, D = d, P = p, L = l, N = n,
            dropType = Launch.nDropType.FirstDrop,
            bGeted = GachaTry.IsLevelPassed(self.nActId, self.nGirlIdx)
        }
        self.ListReward:AddItem(self.ListFactory:Create(tb))
    end
end

function tbClass:OnClickFight()
    if not Activity.IsOpen(self.nActId) then return UI.ShowTip(Text('ui.TxtSignOver')) end

    local levelCfg = GachaTry.GetLevelConf(self.tbTryGirl.nLevelId)
    if not levelCfg then return UI.ShowTip(Text('tip.congif_err')) end

    Launch.SetType(LaunchType.GACHATRY)
    UI.Open('Formation', self.tbTryGirl.nLevelId, nil, levelCfg)
end

function tbClass:ShowDetail()
    UI.Open("Role", 1, self.tbTrialCard[self.nGirlIdx], self.tbTrialCard)
end

function tbClass:ShowSpine(bShow, path)
    local pCamera = PreviewMain.GetCamera()
    local uiActivity = UI.GetUI('Activity')
    if bShow then
        local spine = GachaTry.GetSpine(path)
        if spine then
            self.bShowSpine = true
            PreviewMain.SetBgVisble(false)
            UE4.UCGSpineLibrary.ClearCGSpine(pCamera)
            UE4.Timer.NextFrame(function()
                UE4.UGameLocalPlayer.SetAutoAdapteToScreen(false)
                UE4.UCGSpineLibrary.PlayCGSpine(spine, pCamera)
                local animInfo = self.tbTryGirl.tbSpineAnimInfo
                if #animInfo >= 4 then
                    UE4.UCGSpineLibrary.PlayCameraAnimation(animInfo[1], UE4.FVector2D(animInfo[2][1], animInfo[2][2]),
                    UE4.FVector2D(animInfo[3][1], animInfo[3][2]), UE4.FVector2D(animInfo[4][1], animInfo[4][2]))
                end
                if uiActivity and UI.IsOpen('Activity') then
                    uiActivity:SetBgActive(false)
                end
            end)
        end
    else
        if self.bShowSpine then
            UE4.UCGSpineLibrary.ClearCGSpine(pCamera)
            UE4.UGameLocalPlayer.SetAutoAdapteToScreen(true)
            self.bShowSpine = false
            if uiActivity and UI.IsOpen('Activity') then
                uiActivity:SetBgActive(true)
            end
        end
    end
end

function tbClass:OnClose()
    if self.bShowSpine then
        PreviewMain.SetBgVisble(true)
    end
    self:ShowSpine(false)
end

return tbClass