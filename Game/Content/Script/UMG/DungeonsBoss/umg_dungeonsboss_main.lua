-- ========================================================
-- @File    : umg_dungeonsboss_main.lua
-- @Brief   : boss挑战主界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Factory = Model.Use(self)
    self.tbBossItem = {}
    BtnAddEvent(self.AWARD_btn, function()
        UI.Open("BossScore")
    end)
    BtnAddEvent(self.BtnInfo, function()
        Audio.PlaySounds(3005)
        UI.Open("HelpImages", 2)
    end)

    ---点击准备作战
    self.funcOnClickFight = function ()
        local cfg = BossLogic.GetTimeCfg()
        if not cfg or not IsInTime(cfg.nStartTime, cfg.nEndTime) then
            return
        end
        local levelcfg = BossLogic.GetBossLevelCfg(self.nBossLevelID)
        if levelcfg then
            BossLogic.SetBossLevelID(levelcfg.nID)
            UI.Open("BossBuff", self.bSelectBuff)
            self.bSelectBuff = nil
        end
    end
    ---点击编队信息
    self.funcOnClickInfo = function ()
        UI.Open("BossTeam", self.nBossLevelID)
    end
end

---打卡界面
---@param nBossID integer 选择的boss
---@param nBuff integer 是否满词条打卡词条界面
function tbClass:OnOpen(nBossID, nBuff)
    Launch.SetType(LaunchType.BOSS)
    self.nBossLevelID = nBossID or BossLogic.GetBossLevelID()
    --是否满词条打卡词条界面
    self.bSelectBuff = nBuff and nBuff > 0

    WidgetUtils.Collapsed(self.BossTabBoss)
    WidgetUtils.Collapsed(self.BossInfo)
    self.BossInfo.TextScrollBox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    PreviewScene.Enter(PreviewType.dungeonsboss, function()
        if self.nBossLevelID and BossLogic.GetTimeCfg() then
            self:UpdatePanel(true)
        else
            self:ShowNotOpenPanel()
        end
        UI.ShowConnection()
        me:CallGS("BossLogic_GetOpenID")
    end)
end

function tbClass:Clean()
    if self.GardenActor and IsValid(self.GardenActor) then
        self.GardenActor:K2_DestroyActor()
    end
    --底部圆圈
    self.GardenActor = nil
    Preview.Destroy()
    self.bSelectBuff = nil
end

function tbClass:OnClose()
    self:Clean()
end
function tbClass:OnDisable()
    self:Clean()
end

---暂未开放
function tbClass:ShowNotOpenPanel()
    WidgetUtils.Collapsed(self.BossInfo.FightBtn)
    WidgetUtils.Collapsed(self.BtnReward)
    self:UpdateResultsPanel()
end

---等待开放
function tbClass:ShowWaitOpenPanel()
    WidgetUtils.Collapsed(self.BossInfo.FightBtn)
    WidgetUtils.Collapsed(self.BtnReward)

    local time = GetTime()
    local lastcfg = nil
    local nextcfg = nil
    for _, cfg in pairs(BossLogic.tbTimeCfg) do
        if cfg.nStartTime > time then
            nextcfg = cfg
            break
        end
        if cfg.nEndTime <= time then
            lastcfg = cfg
        end
    end

    local cfg = nil
    if nextcfg then
        cfg = nextcfg
        self.BossInfo.TxtTime:SetText(Text("ui.TxtDungeonsBossNext"))
        self.RefreshTime = cfg.nStartTime
    elseif lastcfg then
        cfg = lastcfg
        self.BossInfo.TxtTime:SetText(Text("ui.TxtDungeonsBossComing"))
        self.RefreshTime = nil
    end
    if not cfg then return end

    if self.RefreshTime and self.RefreshTime > 0 then
        local seconds = math.ceil(self.RefreshTime - GetTime())
        local hour = math.floor(seconds / 3600)
        if hour >= 24 then  --大于一天
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime1", math.floor(hour / 24), math.ceil(seconds / 3600 % 24)))
        elseif hour >= 1 then   --大于一小时
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime2", hour, math.ceil((seconds % 3600) / 60)))
        else  --分钟
            local min = math.ceil((seconds % 3600) / 60)
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime3", min))
        end
    else
        self.BossInfo.TxtTimeNum:SetText("")
    end

    self.BossInfo.TxtName:SetText(Text(cfg.sName))
    self.tbBossItem = {}
    self:DoClearListItems(self.BossTabBoss.TabBoss)
    for _, ID in pairs(cfg.tbBossID) do
        if not self.nBossLevelID then
            self.nBossLevelID = ID
        end
        local data = {}
        data.ID = ID
        data.isSelect = self.nBossLevelID == ID
        data.UpdateSelect = function()
            if self.nBossLevelID == ID then return end
            self.tbBossItem[self.nBossLevelID]:SetSelect(false)
            self.tbBossItem[ID]:SetSelect(true)
            self.nBossLevelID = ID
            self:ChangeBoss(ID)
        end
        local pObj = self.Factory:Create(data)
        self.BossTabBoss.TabBoss:AddItem(pObj)
        self.tbBossItem[ID] = pObj.Data
    end
    self:ChangeBoss(self.nBossLevelID)

    if self.BossTabBoss:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        WidgetUtils.SelfHitTestInvisible(self.BossTabBoss)
    end
    if self.BossInfo:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        WidgetUtils.SelfHitTestInvisible(self.BossInfo)
    end
end

---刷新本期界面
---@param bRefreshOnly boolean 仅刷新
function tbClass:UpdatePanel(bRefreshOnly)
    local cfg = BossLogic.GetTimeCfg()
    if not cfg then return end

    WidgetUtils.Visible(self.BossInfo.FightBtn)
    WidgetUtils.SelfHitTestInvisible(self.BossInfo.Record)
    WidgetUtils.SelfHitTestInvisible(self.BtnReward)

    --刷新红点
    self:OnReceiveCallback()

    self.BossInfo.TxtName:SetText(Text(cfg.sName))
    self.RefreshTime = cfg.nEndTime
    if self.RefreshTime > 0 then
        self.BossInfo.TxtTime:SetText(Text("ui.TxtDungeonsBossTime"))
        local seconds = math.ceil(self.RefreshTime - GetTime())
        local hour = math.floor(seconds / 3600)
        if hour >= 24 then  --大于一天
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime1", math.floor(hour / 24), math.ceil(seconds / 3600 % 24)))
        elseif hour >= 1 then   --大于一小时
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime2", hour, math.ceil((seconds % 3600) / 60)))
        else  --分钟
            local min = math.ceil((seconds % 3600) / 60)
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime3", min))
        end
    end

    self.tbBossItem = {}
    self:DoClearListItems(self.BossTabBoss.TabBoss)
    local haveSelect = false
    for _, ID in pairs(cfg.tbBossID) do
        if not self.nBossLevelID then
            self.nBossLevelID = ID
            break
        elseif self.nBossLevelID == ID then
            haveSelect = true
            break
        end
    end
    if not haveSelect and self.nBossLevelID then
        self.nBossLevelID = nil
    end
    for _, ID in pairs(cfg.tbBossID) do
        if not self.nBossLevelID then
            self.nBossLevelID = ID
        end
        local data = {}
        data.ID = ID
        data.isSelect = self.nBossLevelID == ID
        data.UpdateSelect = function()
            if self.nBossLevelID == ID then return end
            if self.nBossLevelID and self.tbBossItem[self.nBossLevelID] then
                self.tbBossItem[self.nBossLevelID]:SetSelect(false)
            end
            if self.tbBossItem[ID] then
                self.tbBossItem[ID]:SetSelect(true)
            end
            self.nBossLevelID = ID
            self:ChangeBoss(ID)
        end
        local pObj = self.Factory:Create(data)
        self.BossTabBoss.TabBoss:AddItem(pObj)
        self.tbBossItem[ID] = pObj.Data
    end
    self:ChangeBoss(self.nBossLevelID)

    if self.BossTabBoss:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        WidgetUtils.SelfHitTestInvisible(self.BossTabBoss)
    end
    if self.BossInfo:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        WidgetUtils.SelfHitTestInvisible(self.BossInfo)
        self.BossInfo.funcOnClickFight = self.funcOnClickFight
        self.BossInfo.funcOnClickInfo = self.funcOnClickInfo
    end

    if not bRefreshOnly and self.bSelectBuff then
        self.funcOnClickFight()
        self.bSelectBuff = nil
    end
end

function tbClass:ChangeBoss(id)
    if not id then return end

    local bosslevelcfg = BossLogic.GetBossLevelCfg(id)
    if not bosslevelcfg then
        return
    end
    BossLogic.SetBossLevelID(id)

    self.BossInfo.TxtMonster:SetText(Text(Localization.GetMonsterName(bosslevelcfg.nBossID)))
    self.BossInfo.TxtDesc:SetText(Text(Localization.GetMonsterDesc(bosslevelcfg.nBossID)))
    if BossLogic.GetMaxIntegral(id) > 0 then
        WidgetUtils.Visible(self.BossInfo.BtnReset)
    else
        WidgetUtils.Collapsed(self.BossInfo.BtnReset)
    end

    self:UpdateResultsPanel(bosslevelcfg.nID)
    self:PreviewMonster(bosslevelcfg)
end

---领取奖励后刷新界面红点
function tbClass:OnReceiveCallback()
    --刷新红点显示
    if BossLogic.IsCanReceive() then
        WidgetUtils.HitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
    local sUI = UI.GetUI("BossScore")
    if sUI and sUI:IsOpen() then
        --刷新奖励列表
        sUI:UpdateList()
    end
end

---刷新成绩面板
function tbClass:UpdateResultsPanel(id)
    if not id then
        WidgetUtils.Collapsed(self.BossInfo.List)
        WidgetUtils.HitTestInvisible(self.BossInfo.RecordNone)
        return
    end

    local roledata, isNone = BossLogic.GetMaxIntegralLineup(id)
    if isNone then
        WidgetUtils.Collapsed(self.BossInfo.List)
        WidgetUtils.HitTestInvisible(self.BossInfo.RecordNone)
        return
    end
    WidgetUtils.Collapsed(self.BossInfo.RecordNone)
    WidgetUtils.HitTestInvisible(self.BossInfo.List)
    for i = 1, 3 do
        if self.BossInfo["Char"..i] then
            if roledata[i] and roledata[i] > 0 then
                WidgetUtils.HitTestInvisible(self.BossInfo["Char"..i])
                local card = me:GetItem(roledata[i])
                if card then
                    local ID = card:Id()
                    local TemplateId = card:TemplateId()
                    local pCardItem = LoadClass("/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data")
                    local obj = NewObject(pCardItem, self, nil)
                    local template = UE4.UItem.FindTemplateForID(TemplateId)
                    obj:Init(ID, false, template)
                    obj.nTemplateId = TemplateId
                    obj.bUIBoss = true
                    self.BossInfo["Char"..i]:Display(obj)
                end
            else
                WidgetUtils.Collapsed(self.BossInfo["Char"..i])
            end
        end
    end
end

function tbClass:PreviewMonster(bosslevelcfg)
    local SceneData = BossLogic.tbSceneDataCfg[bosslevelcfg.nDataId] or {}
    -- local pos = UE4.FVector(0, 0, 0)
    -- if SceneData.Position and #SceneData.Position >= 3 then
    --     pos = UE4.FVector(SceneData.Position[1], SceneData.Position[2], SceneData.Position[3])
    -- end
    -- local rot = UE4.FRotator(0, 0, 0)
    -- if SceneData.Rotator and #SceneData.Rotator >= 3 then
    --     rot = UE4.FRotator(SceneData.Rotator[1], SceneData.Rotator[2], SceneData.Rotator[3])
    -- end
    local sca = UE4.FVector(1, 1, 1)
    if SceneData.Scale and #SceneData.Scale >= 3 then
        sca = UE4.FVector(SceneData.Scale[1], SceneData.Scale[2], SceneData.Scale[3])
    end

    local b_pos = UE4.FVector(0, 0, 0)
    if SceneData.BossPosition and #SceneData.BossPosition >= 3 then
        b_pos = UE4.FVector(SceneData.BossPosition[1], SceneData.BossPosition[2], SceneData.BossPosition[3])
    end

    local b_rot = UE4.FRotator(0, 180, 0)
    if SceneData.BossRotator and #SceneData.BossRotator >= 3 then
        b_rot = UE4.FRotator(SceneData.BossRotator[1], SceneData.BossRotator[2], SceneData.BossRotator[3])
    end

    --SetCameraPosition(GetGameIns(), pos, rot)
    Preview.PreviewByMonsterID(bosslevelcfg.nBossID, PreviewType.dungeonsboss, b_pos, b_rot, sca)
    Preview.PlayCameraAnimByCallback(Preview.COMMONID, PreviewType.dungeonsboss)

    local actor = self:GetGardenActor()
    if actor then
        if SceneData.BPScale and #SceneData.BPScale >= 3 then
            local bpsca = UE4.FVector(SceneData.BPScale[1], SceneData.BPScale[2], SceneData.BPScale[3])
            actor:SetActorScale3D(bpsca)
        end

        local bpos = UE4.FVector(0, 0, 0)
        if SceneData.BPPosition and #SceneData.BPPosition >= 3 then
            bpos = UE4.FVector(SceneData.BPPosition[1], SceneData.BPPosition[2], SceneData.BPPosition[3])
        end
        actor:K2_SetActorLocation(bpos)
    end
end

--获取底部圆圈Actor
function tbClass:GetGardenActor()
    if self.GardenActor then
        return self.GardenActor
    end

    local ActorClass = UE4.UClass.Load("/Game/Environment/07Terrain/entry02/BP_boss_bottom.BP_boss_bottom_C")
    if ActorClass then
        self.GardenActor = self:GetWorld():SpawnActor(ActorClass)
        return self.GardenActor
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.RefreshTime or self.RefreshTime <= 0 then return end

    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    local seconds = math.ceil(self.RefreshTime - GetTime())
    if seconds > 0 then
        local hour = math.floor(seconds / 3600)
        if hour >= 24 then  --大于一天
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime1", math.floor(hour / 24), math.ceil(seconds / 3600 % 24)))
        elseif hour >= 1 then   --大于一小时
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime2", hour, math.floor((seconds % 3600) / 60)))
        else  --分钟
            local min = math.ceil((seconds % 3600) / 60)
            self.BossInfo.TxtTimeNum:SetText(Text("ui.TxtDungeonsTowerTime3", min))
        end
    else
        self.nBossLevelID = nil
        BossLogic.GetOpenID()
    end
end

return tbClass
