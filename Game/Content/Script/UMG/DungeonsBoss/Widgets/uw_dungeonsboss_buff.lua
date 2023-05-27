-- ========================================================
-- @File    : uw_dungeonsboss_buff.lua
-- @Brief   : boss挑战词条选择界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListDiff)
    BtnAddEvent(self.FightBtn, function()
        local pConfirm = function ()
            BossLogic.SetNowIntegral(BossLogic.GetIntegralByEntries())
            UI.Open("Formation", nil, nil, self.BossLevelCfg)
        end
        if self.targetIntegral > 0 then
            pConfirm()
        else
            UI.Open("MessageBox",Text("bossentries.Confirm"),pConfirm)
        end
    end)
    BtnAddEvent(self.BtnDiff, function()
        if self.ListDiff:GetVisibility() ~= UE4.ESlateVisibility.Visible then
            WidgetUtils.Visible(self.ListDiff)
        else
            WidgetUtils.Collapsed(self.ListDiff)
        end
    end)

    self.ContentScrollBox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    self.EntrieItemPath = "/Game/UI/UMG/DungeonsBoss/Widgets/uw_dungeonsboss_buffChoice.uw_dungeonsboss_buffChoice_C"
    self.Padding = UE4.FMargin()
    self.Padding.Top = 7
end

---打开界面
---@param bSelectBuff boolean 是否满词条打卡词条界面
function tbClass:OnOpen(bSelectBuff)
    if bSelectBuff then
        BossLogic.SetNowDifficulty(me:GetAttribute(BossLogic.GID, BossLogic.DiffRecordID) + 1)
    end
    self:Init(bSelectBuff)
end

function tbClass:Init(bSelectBuff)
    self.BossLevelCfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
    if not self.BossLevelCfg then return end
    Launch.SetType(LaunchType.BOSS)

    local difficultyInfo = BossLogic.GetNowDifficultyInfo()
    if difficultyInfo and difficultyInfo[4] then
        WidgetUtils.HitTestInvisible(self.BasicsPanel)
        self.BasicsItem:ShowBasicsItem()
        self.TxtBasicsDesc:SetText(Text("bossentries.BasicsDesc1"))
        self.BasicsItem.TxtSelected:SetText(Text("bossentries.BasicsDesc2"))
        self.BasicsItem.TextSelectedNum:SetText(difficultyInfo[4])
    else
        WidgetUtils.Collapsed(self.BasicsPanel)
    end

    self:UpdateEntriesPool()
    self:UpdateList(bSelectBuff)

    self:UpdateBuffPenel()
    WidgetUtils.Collapsed(self.ListDiff)

    self:UpdateDiffPanel()
    self:UpdateIntegral()
end

---更新基础分显示
function tbClass:UpdateBasicsPanel()
    local difficultyInfo = BossLogic.GetNowDifficultyInfo()
    if difficultyInfo and difficultyInfo[4] then
        self.BasicsItem.TextSelectedNum:SetText(difficultyInfo[4])
    end
end

---更新可选择的词条库
function tbClass:UpdateEntriesPool()
    self.tbEntriesCfg = {}
    local diff = BossLogic.GetNowDifficulty()
    for _, poolid in pairs(self.BossLevelCfg.tbBossEntries) do
        local cfg = BossLogic.tbEntriesPoolCfg[poolid]
        for _, id in pairs(cfg.tbEntries) do
            local entries = BossLogic.tbEntriesCfg[id]
            if entries and entries.nDiffLimit <= diff then
                self.tbEntriesCfg[id] = entries
            end
        end
    end
end

function tbClass:UpdateBuffPenel()
    if self.BossLevelCfg.tbBuffID and self.BossLevelCfg.tbBuffID[1] then
        self.TxtCurrBuff:SetText(Text("bossentries." .. self.BossLevelCfg.tbBuffID[1]))
    end
end

---刷新词条列表
---@param bSelectBuff boolean 是否选择满词条
function tbClass:UpdateList(bSelectBuff)
    local data = {}
    for id in pairs(self.tbEntriesCfg) do
        data[id] = true
    end

    local tbChoiceEntries = {}
    local tbOrdinaryEntries = {}
    for id, cfg in pairs(self.tbEntriesCfg) do
        if #cfg.tbMutex > 0 then
            local Group = {}
            if data[id] then
                table.insert(Group, cfg)
                data[id] = nil
            end
            for _, mid in pairs(cfg.tbMutex) do
                if self.tbEntriesCfg[mid] and data[mid] then
                    table.insert(Group, self.tbEntriesCfg[mid])
                    data[mid] = nil
                end
            end
            if #Group > 0 then
                table.sort(Group, function(a, b) return a.nID < b.nID end)
                table.insert(tbChoiceEntries, Group)
            end
        else
            if data[id] then
                table.insert(tbOrdinaryEntries, cfg)
                data[id] = nil
            end
        end
    end

    table.sort(tbChoiceEntries, function(a, b) return a[1].nID < b[1].nID end)
    table.sort(tbOrdinaryEntries, function(a, b) return a.nID < b.nID end)

    ---选择满词条
    if bSelectBuff then
        for _, tbGroup in ipairs(tbChoiceEntries) do
            if #tbGroup > 0 then
                BossLogic.AddEntrie(tbGroup[#tbGroup].nID)
            end
        end
        for _, cfg in ipairs(tbOrdinaryEntries) do
            BossLogic.AddEntrie(cfg.nID)
        end
    end

    for i = 1, math.max(self.BoxChoice:GetChildrenCount(), #tbChoiceEntries) do
        local pWidget = self.BoxChoice:GetChildAt(i-1)
        if pWidget then
            if tbChoiceEntries[i] then
                WidgetUtils.SelfHitTestInvisible(pWidget)
                local info = {}
                info.tbEntries = tbChoiceEntries[i]
                info.FunUpdate = function()
                    self:UpdateIntegral()
                end
                pWidget:UpdatePanel(info)
            else
                WidgetUtils.Collapsed(pWidget)
            end
        else
            if tbChoiceEntries[i] then
                pWidget = LoadWidget(self.EntrieItemPath)
                if pWidget then
                    local info = {}
                    info.tbEntries = tbChoiceEntries[i]
                    info.FunUpdate = function()
                        self:UpdateIntegral()
                    end
                    self.BoxChoice:AddChild(pWidget)
                    pWidget:UpdatePanel(info)
                end
            end
        end
        if pWidget and i > 1 then
            pWidget:SetPadding(self.Padding)
        end
    end

    if #tbOrdinaryEntries > 0 then
        WidgetUtils.SelfHitTestInvisible(self.BossBuffList)
        local info = {}
        info.tbEntries = tbOrdinaryEntries
        info.FunUpdate = function()
            self:UpdateIntegral()
        end
        self.BossBuffList:UpdatePanel(info)
    else
        WidgetUtils.Collapsed(self.BossBuffList)
    end
end

---刷新难度选择列表
function tbClass:UpdateDiffPanel()
    self:DoClearListItems(self.ListDiff)
    self.DiffItem = {}
    for i, v in ipairs(self.BossLevelCfg.tbBossLevel) do
        local data = {}
        data.index = i
        data.cfg = v
        data.UpdateSelect = function()
            if i > me:GetAttribute(BossLogic.GID, BossLogic.DiffRecordID) + 1 then
                UI.ShowTip(Text("bossentries.DiffRecord"))
                return
            end
            if BossLogic.GetNowDifficulty() ~= i then
                self.DiffItem[BossLogic.GetNowDifficulty()]:SetSelect(false)
                self.DiffItem[i]:SetSelect(true)
                BossLogic.SetNowDifficulty(i)
                self.TextDiff:SetText(Text("bossentries.Diff", v[1], v[2]))
                self.TextRate:SetText("X" .. v[3])
                BossLogic.CheckDiffLimit()
                self:UpdateBasicsPanel()
                self:UpdateEntriesPool()
                self:UpdateList()
                self:UpdateIntegral()
            end
            WidgetUtils.Collapsed(self.ListDiff)
        end
        local pObj = self.Factory:Create(data)
        self.ListDiff:AddItem(pObj)
        self.DiffItem[i] = pObj.Data
    end

    local diff = self.BossLevelCfg.tbBossLevel[BossLogic.GetNowDifficulty()]
    if diff and #diff >= 3 then
        self.TextDiff:SetText(Text("bossentries.Diff", diff[1], diff[2]))
        self.TextRate:SetText("X" .. diff[3])
    end
end

---刷新显示分数
function tbClass:UpdateIntegral()
    self.targetIntegral = BossLogic.GetIntegralByEntries()
    if not self.nowIntegral then
        self.nowIntegral = self.targetIntegral
    end
    if self.nowIntegral == self.targetIntegral then
        self.ShowTime = 0
        self.TxtNum:SetText(self.targetIntegral)
        return
    end
    ---积分变化时界面切换过程用时
    self.ShowTime = 0.3
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.ShowTime or self.ShowTime <= 0 then return end
    self.ShowTime = self.ShowTime - InDeltaTime

    if self.ShowTime <= 0 then
        self.ShowTime = 0
        self.nowIntegral = self.targetIntegral
        self.TxtNum:SetText(self.targetIntegral)
    else
        local step = self.ShowTime/InDeltaTime
        self.nowIntegral = math.floor((self.targetIntegral - self.nowIntegral) / step + self.nowIntegral)
        self.TxtNum:SetText(self.nowIntegral)
    end
end

return tbClass