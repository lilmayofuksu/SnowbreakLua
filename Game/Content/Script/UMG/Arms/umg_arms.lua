-- ========================================================
-- @File    : umg_arms.lua
-- @Brief   : 武器
-- ========================================================
---@class tbClass 
---@field Switcher UWidgetSwitcher
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.tbPageInfo = {
        {sName = Text('ui.TxtWeaponDetail'), nIcon = 1701020},
        {sName = Text('ui.TxtArmsUp'), nIcon = 1701022},
        {sName = Text('ui.TxtArmsEvolution'), nIcon = 1701023},
        {sName = Text('ui.weapon_part'), nIcon = 1701016},
    }
    self.funPageClick = function(_, nPage)
        if self.nPage ~= nPage then
            local pWidget = self.GameSwitcher:GetWidgetAtIndex(self.nPage)
            if pWidget then
                pWidget:OnDisable()
            end
            self:OpenPage(nPage, 2)
        end
    end

    self.tbRedFunction = {}
    ---是否有新的配件
    self.tbRedFunction[3] = function()
        return Weapon.CheckPartCanEquip(self.pWeapon)
    end
end

function tbClass:UpdatePageBtn(tbIndex)
    local tb = {}
    for _, Index in pairs(tbIndex) do
        if self.tbPageInfo[Index] then
            table.insert(tb, self.tbPageInfo[Index])
        end
    end
    self.Content:Init(tb, self.funPageClick)
end

function tbClass:UpdateRedPoint(nPage)
    local pPageItem = self.Content.tbPage[nPage]
    if pPageItem and pPageItem.New then
        if self.tbRedFunction[nPage] then
            local bShow = self.tbRedFunction[nPage]()
            if bShow then
                WidgetUtils.HitTestInvisible(pPageItem.New)
            else
                WidgetUtils.Collapsed(pPageItem.New)
            end
        end
    end
end

function tbClass:OnOpen(nPage, pWeapon, nForm, tbData)
    Weapon.PreviewClose(true)
    self.nForm = nForm
    self.tbData = tbData
    if nForm == 5 then
        self:UpdatePageBtn({1})
        self.nPage = 0
    elseif nForm == RikiLogic.tbState.Lock or nForm == RikiLogic.tbState.New then
        --图鉴界面显示武器
        self:UpdatePageBtn({})
        self.nPage = 0
    else
        local bUnlock, _  = FunctionRouter.IsOpenById(FunctionType.WeaponPart)
        local tbOpenId = bUnlock and {1, 2, 3, 4} or {1, 2, 3}
        self:UpdatePageBtn(tbOpenId)
        self.nPage = nPage or self.nPage or (Weapon.tbCacheArgs.nPage or 1)
    end
    self.pWeapon = pWeapon or self.pWeapon or Weapon.tbCacheArgs.pWeapon

    if self.pWeapon == nil then return end

    self:UpdateRedPoint(3)
    Weapon.PreviewShow(self.pWeapon)
    Weapon.nShowWeaponID = self.pWeapon:Id()
    PreviewScene.Enter(PreviewType.weapon, function()  end)
    self:OpenPage(self.nPage, 1)
end

function tbClass:OnClose()
    Weapon.PreviewClose(true)
    Preview.Destroy()
end

function tbClass:OnDisable()
    Weapon.PreviewClose(false)
    if self.nPage ~= nil then
        local pWidget = self.GameSwitcher:GetWidgetAtIndex(self.nPage)
        if pWidget then
            pWidget:OnDisable()
        end
    end
end

function tbClass:OpenPage(nPage, nReason)
    if not self:IsOpen() then return end

    Weapon.CloseRenderCustomDepth(self.pWeapon)

    self.GameSwitcher:SetActiveWidgetIndex(nPage)

    local pWidget = self.GameSwitcher:GetActiveWidget()
    if pWidget then
        pWidget:OnActive(self.pWeapon, self.nForm, self.tbData, nReason)
        WidgetUtils.PlayEnterAnimation(pWidget)

        self.Content:SelectPage(nPage)
        self.nPage = nPage
        if nPage == 1 or nPage == 2 then
            WidgetUtils.SelfHitTestInvisible(self.Money)
            self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Silver, Cash.MoneyType_Vigour})
        else
            WidgetUtils.Collapsed(self.Money)
        end
        if nPage == 3 then
            Weapon.ResetRotate()
            PreviewScene.Enter(PreviewType.weapon_info)
        else
            PreviewScene.Enter(PreviewType.weapon)
            Weapon.ResetRotate2()
       end
        self.Rotate:SetModel(Weapon.GetPreviewModel())
        Weapon.tbCacheArgs = {nPage = nPage, pWeapon = self.pWeapon}

        ---缓存 引导可能用
        if nPage == 0 then
            self.Details = pWidget
        elseif nPage == 1 then
            self.Level = pWidget
        elseif nPage == 2 then
            self.Evolution = pWidget
        elseif nPage == 3 then
            self.Part = pWidget
        end
    end
end

function tbClass:PushEvent(fEvent)
    if self.Title then
        self:ClearPushEvent()
        self.Title:Push(fEvent)
    end
end

function tbClass:ClearPushEvent()
    if self.Title then
        self.Title:ClearPushEvent()
    end
end

function tbClass:Call(sUI, sFun, ...)
    local pWidget = self:GetCacheWidget(sUI)
    if pWidget and pWidget[sFun] then
        pWidget[sFun](pWidget, ...)
    end
end

function tbClass:GetCacheWidget(sType)
    if sType == 'LevelUp' then
        local level = self.GameSwitcher:GetWidgetAtIndex(1)
        if level then
            return level:GetWidgetByPage(0)
        end
    elseif sType == 'Break' then
        local level = self.GameSwitcher:GetWidgetAtIndex(1)
        if level then
            return level:GetWidgetByPage(1)
        end
    elseif sType == 'Evoluation' then
        return self.GameSwitcher:GetWidgetAtIndex(2)
    end
end

return tbClass