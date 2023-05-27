-- ========================================================
-- @File    : uw_dungeonsboss_team.lua
-- @Brief   : boss挑战阵容成绩记录
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
    end)

    self.Factory = self.Factory or Model.Use(self)
    self.PanelBoss:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.PanelList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    self:DoClearListItems(self.PanelBoss)
    self:DoClearListItems(self.PanelList)
end

function tbClass:OnOpen(bossID)
    self:UpdatePanel(bossID)
end

function tbClass:UpdatePanel(ID)
    local cfg = BossLogic.GetTimeCfg()
    if not cfg then return end

    self.nBossID = ID or BossLogic.GetBossLevelID()
    self.tbBossItem = {}
    self:DoClearListItems(self.PanelBoss)
    for _, ID in pairs(cfg.tbBossID) do
        local data = {}
        data.ID = ID
        data.isSelect = self.nBossID == ID
        data.UpdateSelect = function()
            if self.nBossID == ID then return end
            self.tbBossItem[self.nBossID]:SetSelect(false)
            self.tbBossItem[ID]:SetSelect(true)
            self.nBossID = ID
            self:ChangeBoss(ID)
        end
        local pObj = self.Factory:Create(data)
        self.PanelBoss:AddItem(pObj)
        self.tbBossItem[ID] = pObj.Data
    end

    self:ChangeBoss(self.nBossID)
end

function tbClass:ChangeBoss(id)
    if not id then return end
    local roledata = BossLogic.GetIntegralAndFormation(id)
    if roledata[1].nRole == 0 and roledata[2].nRole == 0 and roledata[3].nRole == 0 then
        WidgetUtils.Collapsed(self.PanelList)
        WidgetUtils.HitTestInvisible(self.RecordNone)
        return
    else
        WidgetUtils.Collapsed(self.RecordNone)
        WidgetUtils.HitTestInvisible(self.PanelList)
    end
    self:DoClearListItems(self.PanelList)
    for i = 1, 3 do
        if roledata[i].nRole and roledata[i].nRole > 0 then
            local pObj = self.Factory:Create(roledata[i])
            self.PanelList:AddItem(pObj)
        end
    end
end

return tbClass