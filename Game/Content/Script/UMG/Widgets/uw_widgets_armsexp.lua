-- ========================================================
-- @File    : uw_widgets_armsexp.lua
-- @Brief   : 武器升级经验显示
-- ========================================================
---@class tbClass
---@field BarExp UProgressBar
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.TargetShowLevel = 0
    self.NowShowLevel = 0

    self.fPercent = 0

    self.nOldAddExp = 0
    self.nNewAddExp = 0

    --变化速率
    self.RefreshSpeed = 0.1
end

---@param pWeapon UWeaponItem
function tbClass:Set(pItem, nAddExp)
    if not pItem then
        return
    end
    if self.fTarget and self.fTarget ~= self.fPercent then
        self:DynamicRefreshEnd()
    end
    if self.pCard ~= pItem then
        self:DynamicRefreshEnd()
        self.TargetShowLevel = 0
        self.NowShowLevel = 0
        self.fPercent = 0
        self.nOldAddExp = 0
        self.nNewAddExp = 0
        self.pCard = pItem
    end

    local function GetType(InItem)
        if InItem:IsSupportCard() then
            return Item.TYPE_SUPPORT
        end
        if InItem:IsWeapon() then
            return Item.TYPE_WEAPON
        end
        if InItem:IsCharacterCard() then
            return Item.TYPE_CARD
        end
    end

    self.nItemType = GetType(pItem)

    --当前等级
    self.ItemLevel = pItem:EnhanceLevel()
    --当前经验
    local nExp = pItem:Exp()

    self.nOldAddExp = self.nNewAddExp or nAddExp
    self.nNewAddExp = nAddExp

    local nMaxLevel = Item.GetMaxLevel(pItem)
    local nNewLevel, nNewExp = Item.GetItemDestLevel(pItem:EnhanceLevel(), nExp, nAddExp, self.nItemType, nMaxLevel)
    self.TxtMaxLv:SetText(nMaxLevel)
    if nAddExp <= 0 and self.nNewAddExp == self.nOldAddExp then
        self.RankNum:SetText(nNewLevel)
        self.NowShowLevel = self.ItemLevel
    end

    local Exp = Item.GetExp(self.nItemType, self.ItemLevel)
    local nPercent = nExp / Exp
    self.BarExp:SetPercent(nPercent)

    if pItem:EnhanceLevel() == nMaxLevel then
        self.BarExp:SetPercent(1)
        self.BarNextExp:SetPercent(1)
        self.ShowRate:SetText(Exp)
        self.ShowRate_1:SetText(Exp)
        WidgetUtils.Collapsed(self.PanelExp)
        WidgetUtils.Collapsed(self.TxtAddExp)
        return
    else
        WidgetUtils.HitTestInvisible(self.PanelExp)
    end

    self.ShowRate_1:SetText(nExp + nAddExp)
    self.ShowRate:SetText(Exp)

    if nAddExp <= 0 and self.nNewAddExp == self.nOldAddExp then
        WidgetUtils.Collapsed(self.TxtAddExp)
        WidgetUtils.Collapsed(self.BarNextExp)
        WidgetUtils.HitTestInvisible(self.BarExp)
    else
        WidgetUtils.HitTestInvisible(self.BarNextExp)
        WidgetUtils.HitTestInvisible(self.TxtAddExp)
        self:DynamicRefresh(nNewLevel, nNewExp)
        self.TxtAddExp:SetText('+' .. nAddExp)
    end
end

---@param InNewLevel number 显示目标等级
---@param InNewExp number 显示目标经验
function tbClass:DynamicRefresh(InNewLevel, InNewExp)
    self.TargetShowLevel = InNewLevel

    ---1：经验增加 2：经验减少
    self.RefreshModel = 0
    if self.nNewAddExp == self.nOldAddExp then
        return
    elseif self.nNewAddExp > self.nOldAddExp then
        self.RefreshModel = 1
    elseif self.nNewAddExp < self.nOldAddExp then
        self.RefreshModel = 2
    end


    --最终显示的进度值
    self.fTarget = InNewExp / Item.GetExp(self.nItemType, InNewLevel)
    if self.TargetShowLevel ~= self.NowShowLevel then
        local abs = math.abs(self.TargetShowLevel - self.NowShowLevel)
        if abs > 2 then abs = 2 end
        if self.RefreshModel == 1 then
            self.fTarget = self.fTarget + abs
        elseif self.RefreshModel == 2 then
            if self.fPercent == 1 then
                abs = abs - 1
            end
            self.fTarget = self.fTarget - abs
        end
    end
end

--刷新结束
function tbClass:DynamicRefreshEnd()
    self.fPercent = self.fTarget
    self.NowShowLevel = self.TargetShowLevel
    self.nOldAddExp = self.nNewAddExp
    self.RefreshModel = nil

    if self.nNewAddExp == 0 then
        WidgetUtils.Collapsed(self.TxtAddExp)
        WidgetUtils.Collapsed(self.BarNextExp)
        WidgetUtils.HitTestInvisible(self.BarExp)
    end
end

--- 刷新经验值
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.RefreshModel or self.RefreshModel < 1 then
        return
    end

    if self.RefreshModel == 1 then
        if self.fPercent >= 1 then
            self.fPercent = 0
            if self.fTarget > 1 then
                self.fTarget = self.fTarget - 1
            end
        end
        self.fPercent = Lerp(self.fPercent, self.fTarget, self.RefreshSpeed)
    end

    if self.RefreshModel == 2 then
        if self.fPercent <= 0 and self.fTarget < 0 then
            self.fPercent = 1
            self.fTarget = self.fTarget + 1
        end
        self.fPercent = Lerp(self.fPercent, self.fTarget, self.RefreshSpeed)
    end
    self.NowShowLevel = Lerp(self.NowShowLevel, self.TargetShowLevel, self.RefreshSpeed)

    local LastRefresh = false
    if math.abs(self.fPercent - self.fTarget) <= 0.005 then
        self:DynamicRefreshEnd()
        LastRefresh = true
    end

    if self.fPercent == 1 and LastRefresh then
        self.BarNextExp:SetPercent(0)
    else
        self.BarNextExp:SetPercent(self.fPercent)
    end
    local showLevel
    if self.RefreshModel == 1 then
        showLevel = math.ceil(self.NowShowLevel)
    else
        showLevel = math.floor(self.NowShowLevel)
    end
    self.RankNum:SetText(showLevel)

    if showLevel == self.ItemLevel then
        WidgetUtils.HitTestInvisible(self.BarExp)
    elseif showLevel == self.ItemLevel + 1 and self.fTarget >= 1 and not LastRefresh then
        WidgetUtils.HitTestInvisible(self.BarExp)
    else
        WidgetUtils.Collapsed(self.BarExp)
    end
end



return tbClass
