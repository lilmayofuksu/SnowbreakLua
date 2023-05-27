-- ========================================================
-- @File    : umg_logistics_main.lua
-- @Brief   : 后勤主界面
-- ========================================================



local tbLogistClass = Class("UMG.BaseWidget")


local page_name = {
    [0] = 'Detail',
    [1] = 'Up',
    [2] = 'Story',
}


function tbLogistClass:Construct()
    self.tbEntry = {self.Detail,self.Up,self.Story}
    -- print('tbLogistClass->Construct')
end

function tbLogistClass:OnInit()
    self.Content:Init({
        {sName = Text('ui.TxtSupportDetail'), nIcon = 1701020},
        {sName = Text('ui.TxtSupportUp'), nIcon = 1701021},
        {sName = Text('ui.TxtSupportStory'), nIcon = 1701022}
        }, 
        function(_, nPage)
            if nPage == 0 then
                WidgetUtils.HitTestInvisible(self.Detail2)
                self.Detail2:Display(self.pSupportCard)
            else
                WidgetUtils.Collapsed(self.Detail2)
            end

            if self.nPage ~= nPage then
                local pWidget = self.Switcher:GetWidgetAtIndex(self.nPage)
                if pWidget then
                    pWidget:OnDisable()
                end
                self:OpenPage(nPage)
            end
        end
    )

    self.SetTabVisible = EventSystem.OnTarget(
        Logistics,
        "PushOrMoveTitleEvent",
        function(_, IsPush)
            if IsPush then
                self.Title:Push(function()
                    WidgetUtils.Collapsed(self.Select)
                    self.Up.bShowSelect = false
                end)
            else
                self.Title:ClearPushEvent()
            end
        end
    )

    self.SetSupportTexture = EventSystem.OnTarget(
        Logistics,
        "SetSupportTexture",
        function(_, pLogicCard)
            local ResId = pLogicCard:Icon()
            local ResBreakId = pLogicCard:IconBreak()
            if Logistics.CheckUnlockBreakImg(pLogicCard) then
                local IconId = ResBreakId
                SetTexture(self.ImgSerPoseA, IconId, true)
            else
                local IconId = ResId
                SetTexture(self.ImgSerPoseA, IconId, true)
            end
        end
    )

    self.SetTextureVisible = EventSystem.OnTarget(
        Logistics,
        "SetTextureVisible",
        function(_, Visible)
            if Visible then
                WidgetUtils.HitTestInvisible(self.ImgSerPoseA)
            else
                WidgetUtils.Collapsed(self.ImgSerPoseA)
            end
        end
    )
end


function tbLogistClass:OnOpen(InSupportCard,InPage)
    PreviewScene.Enter(PreviewType.role_lvup)
    Preview.PlayCameraAnimByCfgByID(0, PreviewType.role_logistics)
    self.pSupportCard = InSupportCard or Logistics.CurCard
    Logistics.CurCard = self.pSupportCard
    InPage = InPage or Logistics.CurPage
    self.nPage = InPage or 1
    self:OpenPage(self.nPage)
    -- self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Money, Cash.MoneyType_Vigour})
    Logistics.CurPage = self.nPage
    if InPage == 0 then
        WidgetUtils.HitTestInvisible(self.Detail2)
    else
        WidgetUtils.Collapsed(self.Detail2)
    end
    self.Detail2:Display(self.pSupportCard)
    if self.Close then
        self.Title:SetCustomEvent(
            function()
                self:BindToAnimationEvent(self.Close,
                {
                    self,
                    function()
                        UI.CloseTop()
                    end
                },
                UE4.EWidgetAnimationEvent.Finished)
                self:PlayAnimation(self.Close, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
            end)
    end
end

function tbLogistClass:OpenPage(nPage)
    self.Switcher:SetActiveWidgetIndex(nPage)
    local pWidget = self.Switcher:GetWidgetAtIndex(nPage)
    WidgetUtils.HitTestInvisible(self.ImgSerPoseA)
    if pWidget then
        local sPageName = page_name[nPage]
        if sPageName then
            self[sPageName] = pWidget
        end

        pWidget:OnActive(
            self.pSupportCard,
            function(InState)
                self:ChangeTab(InState)
            end,
            function(InOn)
                self:ChangeTitleTab(InOn)
            end,
            self.Select
        )
        self.Content:SelectPage(nPage)
        self.nPage = nPage
    end
end


function tbLogistClass:OnDisable()
    if self.nPage ~= nil then
        local pWidget = self.Switcher:GetWidgetAtIndex(self.nPage)
        if pWidget then
            pWidget:OnDisable()
        end
    end
end

--- 左侧页签是否显示
function tbLogistClass:ChangeTab(InOn)
    WidgetUtils.Collapsed(self.Content)
    if InOn then
        WidgetUtils.Visible(self.Content)
    end
end

--- 返回TitleTab
function tbLogistClass:ChangeTitleTab(InOn)
    WidgetUtils.Visible(self.Title)
    if InOn then
        WidgetUtils.Collapsed(self.Title)
    end
    -- body
end

function tbLogistClass:OnClose()
    EventSystem.Remove(self.SetTabVisible)
    EventSystem.Remove(self.SetSupportTexture)
    EventSystem.Remove(self.SetTextureVisible)
end

return tbLogistClass