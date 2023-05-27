-- ========================================================
-- @File    : uw_role_branch.lua
-- @Brief   : 角色培养（升级，天启，脊椎）
-- @Author  :
-- @Date    :
-- ========================================================

local tbReRole = Class("UMG.BaseWidget")
tbReRole.CanDiable = true
local tbPageFunType = {
    [1] = FunctionType.RoleBreak,
    [2] = FunctionType.Nerve,
}

function tbReRole:OnInit()

    local function SwitchPage(InPage)
        Preview.CancelTimer()
        if self.nPage ~= InPage then
            if tbPageFunType[InPage] then
                -- NoteDynamicShow()
                local val1,val2 = FunctionRouter.IsOpenById(tbPageFunType[InPage])
                if not val1 then
                    UI.ShowTip(val2[1])
                    return
                end
            end

            local pWidget = self.Switcher:GetWidgetAtIndex(self.nPage)
            if pWidget then
                pWidget:OnDisable()
            end

            self:OpenPage(InPage)
        end
    end

    -- self.tbRedFunction = {}
    -- --- 升级材料判定
    -- self.tbRedFunction[0] = function()
    --     return RoleCard.CkeckUpMat() and not RoleCard.IsMaxLimit(self.ThisCard)
    -- end
    -- --- 天启材料判定
    -- self.tbRedFunction[1] = function()
    --     return RoleCard.CheckBreak(self.ThisCard)
    -- end

    -- --- 神经枢组材料判定
    -- self.tbRedFunction[2] = function()
    --     return RoleCard.CheckSpine(self.ThisCard)
    -- end

    self.Content:Init({
        {sName = Text('ui.roleup_levelup'), nIcon = 1701019},
        --{sName = Text('ui.roleup_break'), nIcon = 1701020},
        --{sName = Text('ui.roleup_skill'), nIcon = 1701021}
        },
        function(nPage)
            SwitchPage(nPage or self.nPage)
        end
    )
end

--- 默认进入的是角色卡升级页签
---@param InCard UE4.UCharacterCard 角色卡
---@param InPage Interge 页签(0:升级，1:突破(天启)，2:脊椎)
---@param bDesModel bool 页面关闭时是否删除模型
function tbReRole:OnOpen(InCard, InPage, bDesModel)
    local CacheData = RoleCard:GetCache()
    self.ThisCard = InCard or self.ThisCard or CacheData.pCard
    if not self.ThisCard then return end
    --屏蔽天启和神经，只留升级
    --InPage = (InPage ~= nil) and InPage or self.nPage or 0
    --self.nPage = InPage or CacheData.nPage
    WidgetUtils.Collapsed(self.Content)
    self.nPage = 0
    self.bDesModel = bDesModel
    self:InitSpine(self.ThisCard)
    self.money:Init({Cash.MoneyType_Vigour, Cash.MoneyType_Silver, Cash.MoneyType_Gold})
    self:OpenPage(self.nPage)
end


function tbReRole:OpenPage(nPage)
    self.Switcher:SetActiveWidgetIndex(nPage)
    local pWidget = self.Switcher:GetWidgetAtIndex(nPage)
    if pWidget then
        pWidget:OnActive(self.ThisCard)
        self.Content:SelectPage(nPage)
        self.nPage = nPage
    end
end

function tbReRole:ChangeState(InState)
    self.Content:SetVisibility(InState and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.HitTestInvisible)
end

function tbReRole:OnDisable()
    if self.nPage ~= nil then
        local pWidget = self.Switcher:GetWidgetAtIndex(self.nPage)
        if pWidget then
            pWidget:OnDisable()
        end
    end
end

function tbReRole:OnClose()
    RoleCard:SetCache(self.ThisCard, nil, PreviewType.role_lvup)
    if self.bDesModel then
        RoleCard.ClearCach()
        Preview.Destroy()
    end

    local ChildNum = self.Switcher:GetChildrenCount()
    for i = 1, ChildNum do
        local ChildWidget = self.Switcher:GetWidgetAtIndex(i-1)
        ChildWidget:OnClose()
    end
end

-- 初始化神经的进度
function tbReRole:InitSpine(Card)
    EventSystem.TriggerTarget(Spine,Spine.ResetProgressHandle)
    for mastId = Spine.MaxMastNum,1,-1 do
        for subId = Spine.MaxSubNum,1,-1 do
            if Card:GetSpine(mastId, subId) then
                Spine.ActivedProgress.MastId = mastId
                Spine.ActivedProgress.SubId = subId
                return
            end
        end
    end
end

return tbReRole
