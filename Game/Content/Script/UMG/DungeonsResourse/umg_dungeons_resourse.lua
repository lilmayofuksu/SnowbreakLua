-- ========================================================
-- @File    : umg_dungeons_resourse.lua
-- @Brief   : 出击主界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field Content UCanvasPanel
local tbClass = Class("UMG.BaseWidget")

---类型ID对应界面名称
local TypeId2WidgetName = {
    [1] = 'Gold',
    [2] = 'Weaponbreak',
    [3] = 'Weaponexp',
    [4] = 'Roleexp',
    [5] = 'Rolebreak',
    [6] = 'Rolematerials',
    [7] = 'Logismaterials'
}
function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.CustListView_66)
    self.CustListView_66:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnInit()
    self.CustListView_66.OnCustListViewScrolled:Add(self, self.ScrollHandle)
end

function tbClass:OnOpen()
    self.CustListView_66:SetScrollable(true)
    PreviewScene.PlayDungeonsSeq(2, UI.bPoping)

    Launch.SetType(LaunchType.DAILY)
    local tbCfg = Daily.GetCfg() or {}
    self:DoClearListItems(self.CustListView_66)

    local hasTeach, bPassAll = false, false
    if tbCfg[DailyLevel.TeachingLevelType] then  -- DailyLevel.TeachingLevelType 99 为教学关卡
        hasTeach = true
        bPassAll = Daily.CheckPassAll(DailyLevel.TeachingLevelType)
    end

    if hasTeach and not bPassAll then  -- 未通关全部教学关时放在最前
        self.CustListView_66:AddItem(self.Factory:Create({cfg = tbCfg[DailyLevel.TeachingLevelType]}))
    end

    for id, cfg in pairs(tbCfg) do
        if id ~= DailyLevel.TeachingLevelType then
            local tbParam = self.Factory:Create({cfg = cfg})
            self.CustListView_66:AddItem(tbParam)
        end
        -- local pNewWidget = self[TypeId2WidgetName[cfg.nID]]
        -- if pNewWidget then
        --     pNewWidget:Set(cfg)
        -- end
    end

    if hasTeach and bPassAll then  -- 通关全部教学关后放在最后
        self.CustListView_66:AddItem(self.Factory:Create({cfg = tbCfg[DailyLevel.TeachingLevelType]}))
    end
    self.OrgOffset, self.lastOffset = nil, nil
end

function tbClass.ScrollHandle(self, offset)
    if not self then return end
    if not self.OrgOffset then
        self.OrgOffset = offset
    end
    offset = (offset - self.OrgOffset) * 300
    if offset == 0 then return end

    if not self.lastOffset then
        local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
        self.pViewTarget = pCameraManger.ViewTarget.Target
        self.orgCameraPos = self.pViewTarget:K2_GetActorLocation()
    end

    self.lastOffset = offset
    self.pViewTarget:K2_SetActorLocation(UE4.FVector(self.orgCameraPos.X, offset + self.orgCameraPos.Y, self.orgCameraPos.Z))
end


return tbClass