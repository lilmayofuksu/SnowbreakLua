-- ========================================================
-- @File    : umg_cartoon.lua
-- @Brief   : 剧情界面
-- ========================================================
local view = Class("UMG.BaseWidget")


function view:OnLuaInit()
    self.Factory = Model.Use(self);

    BtnAddEvent(self.Btn_hide, function() self:OnBtnClickHide() end)
    BtnAddEvent(self.Btn_automatic, function() self:OnBtnClickAuto() end)
    BtnAddEvent(self.Btn_skip, function() self:OnBtnClickSkip() end)
    BtnAddEvent(self.Btn_review, function() self:OnBtnClickReview() end)
    BtnAddEvent(self.Btn_setting, function() self:OnBtnClickSetting() end)

    local isMobile = IsMobile()
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgKeyDir, isMobile)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CustomImageAndText, not isMobile)
    
    -- 
    self:ListenForInputAction("PauseGame", 0, false, {GetGameIns(), function() 
        self:OnBtnClickSkip()
    end})
end

function view:OnLuaReset() 
    self.isUIHide = false
    WidgetUtils.Collapsed(self.ImgFullScreen)
    WidgetUtils.Collapsed(self.ScrollFullText)
    WidgetUtils.Collapsed(self.PanelMsg)

    WidgetUtils.Collapsed(self.BranchTalk_2D)
    self:DoClearListItems(self.BranchTalk_2D)
end

function view:OnTextInfoChange(widget, text)
    widget:SetContent(text)
end

function view:OnChoices(options)
    WidgetUtils.Visible(self.BranchTalk_2D)
    self:DoClearListItems(self.BranchTalk_2D)
    for i = 1, options:Length() do 
        local id = i;
        local pObj = self.Factory:Create({msg = options:Get(i), onClick = function()            
            self:OnChoiceClick(id)
        end})
        self.BranchTalk_2D:AddItem(pObj)
    end
end

function view:OnChoiceClick(id)
    self.ChoiceIndex = id;
    WidgetUtils.Collapsed(self.BranchTalk_2D)
end

function view:OnBtnClickHide()
    self.isUIHide = not self.isUIHide
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Objects, not self.isUIHide)
    WidgetUtils.SetVisibleOrCollapsed(self.ImgDisplay, self.isUIHide)
    WidgetUtils.SetVisibleOrCollapsed(self.ImgHide, not self.isUIHide)

    if self.IsAutoPlay then 
        self:OnBtnClickAuto()
    end
end


function view:OnBtnClickAuto()
    self.IsAutoPlay = not self.IsAutoPlay;
    WidgetUtils.SetVisibleOrCollapsed(self.ImgPlay, not self.IsAutoPlay)
    WidgetUtils.SetVisibleOrCollapsed(self.ImgPause, self.IsAutoPlay)
end

function view:OnBtnClickSkip()
    if self.IsShowSkipUI then return end

    self.IsShowSkipUI = true;
    local path = "/Game/UI/UMG/Dialogue/Widgets/uw_dialogue_tip.uw_dialogue_tip_C"
    local ui = LoadUIByPath(path)
    if not ui then return end 
    ui:AddToViewport(101)
    ui.OnConfirmHandler:Add(self, function(obj, confirm)
        self.IsShowSkipUI = false;
        if confirm then 
            self.IsSkip = true;
        end
        UE4.UGameplayStatics.SetGamePaused(self, false)
    end)
    UE4.UGameplayStatics.SetGamePaused(self, true)
end

function view:OnBtnClickReview()

end

function view:OnBtnClickSetting()

end



return view