-- ========================================================
-- @File    : umg_levelinfo.lua
-- @Brief   : 关卡信息
-- ========================================================
---@class tbClass : UUserWidget
---@field PanelItem UTileView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    --self.Popup:Init('LEVEL INFO', function() UI.Close(self) end, 1701002)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)

    BtnAddEvent(self.BtnReturn, function()
        UI.CloseUntil('Fight')
    end)

    BtnAddEvent(self.BtnGiveUp, function()
        UI.Open('GiveUp')
    end)

    self.ListFactory = Model.Use(self)
end

function tbClass:OnOpen()
    WidgetUtils.Collapsed(self.DailyInfo)
    WidgetUtils.Collapsed(self.StarList)
    WidgetUtils.Collapsed(self.PanelTower)
    WidgetUtils.Collapsed(self.Boss)
    WidgetUtils.Collapsed(self.PanelItem)
    WidgetUtils.SelfHitTestInvisible(self.Panel)
    WidgetUtils.Collapsed(self.PanelItemlist)
    WidgetUtils.Collapsed(self.PanelRestrained)
    WidgetUtils.Collapsed(self.PanelSkill)

    local tbCfg = nil
    local nType = Launch.GetType()
    if nType == LaunchType.TOWER then
        WidgetUtils.Collapsed(self.Panel)
        WidgetUtils.SelfHitTestInvisible(self.PanelTower)
        self.PanelTower:UpdatePanel("fight")

    elseif nType == LaunchType.DAILY then
        --WidgetUtils.HitTestInvisible(self.DailyInfo)
        tbCfg = DailyLevel.Get(Daily.GetLevelID())
        if tbCfg then
            self.TxtContent:SetText(Text(tbCfg.sDes))
        end
        --self:ShowStarInfo(tbCfg)
        self:UpdatePanelItem()

    elseif nType == LaunchType.CHAPTER then
        tbCfg = ChapterLevel.Get(Chapter.GetLevelID())
        if not tbCfg then return end
        --self:ShowStarInfo(tbCfg)
        self:UpdatePanelItem()
    elseif nType == LaunchType.DLC1_CHAPTER then
        tbCfg = DLCLevel.Get(DLC_Chapter.GetLevelID())
        if not tbCfg then return end
        WidgetUtils.SelfHitTestInvisible(self.Num)
        self.Num:SetText(Text(tbCfg.sFlag))
        --self:ShowStarInfo(tbCfg)
        self:UpdatePanelItem()
    elseif nType == LaunchType.ROLE then
        tbCfg = RoleLevel.Get(Role.GetLevelID())
        if not tbCfg then return end
        WidgetUtils.HitTestInvisible(self.DailyInfo)
        self.TxtContent:SetText(Text(tbCfg.sDes))
        self:UpdatePanelItem()

    elseif nType == LaunchType.BOSS then
        WidgetUtils.SelfHitTestInvisible(self.Boss)
        self.TxtScore:SetText(BossLogic.GetNowIntegral())
        tbCfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
        if tbCfg.tbBuffID and tbCfg.tbBuffID[1] then
            self.TxtCurrBuff:SetText(Text("bossentries." .. tbCfg.tbBuffID[1]))
        else
            self.TxtCurrBuff:SetText("")
        end
        local diffinfo = BossLogic.GetNowDifficultyInfo()
        if diffinfo and #diffinfo >= 3 then
            self.TxtDifficulty:SetText(diffinfo[1])
            self.TxtNum:SetText(diffinfo[3])
        end
    elseif nType == LaunchType.ONLINE then
        WidgetUtils.HitTestInvisible(self.DailyInfo)
        tbCfg = OnlineLevel.GetConfig(Online.GetLevelId())
        self.TxtContent:SetText(Text(tbCfg.sDes))
    elseif nType == LaunchType.DEFEND then
        tbCfg = DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
        --self:ShowStarInfo(tbCfg)
    elseif nType == LaunchType.TOWEREVENT then
        tbCfg = TowerEventLevel.Get(TowerEventChapter.GetLevelID())
        self:UpdateLevelBuff(tbCfg)
        self:UpdatePanelItem()
    elseif nType == LaunchType.GACHATRY then
        tbCfg = GachaTry.GetLevelConf(GachaTry.GetLevelID())
        if not tbCfg then return end
        WidgetUtils.HitTestInvisible(self.DailyInfo)
        self.TxtContent:SetText(Text(tbCfg.sDes))
    elseif nType == LaunchType.DLC1_ROGUE then
        WidgetUtils.HitTestInvisible(self.DailyInfo)
        self.TxtContent:SetText(Text("rogue.TxtLevelDesc"))
        self:UpdatePanelItem()
    end

    if not tbCfg then tbCfg = Launch.GetLevelConf() end

    self:ShowSkillInfo()

    if tbCfg and tbCfg.sName then
        self.Num:SetText(GetLevelName(tbCfg))
    else
        WidgetUtils.Collapsed(self.Num)
    end
    if nType ~= LaunchType.DLC1_CHAPTER and nType ~= LaunchType.ONLINE and tbCfg and tbCfg.sFlag and self.TxtTitle then --联机不显示此组件
        self.TxtTitle:SetText(Text(tbCfg.sFlag))
    else
        WidgetUtils.Collapsed(self.TxtTitle)
    end
end

--- 显示奖励
function tbClass:UpdatePanelItem()
    WidgetUtils.SelfHitTestInvisible(self.PanelItemlist)
    WidgetUtils.SelfHitTestInvisible(self.PanelItem)
    local pDropSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelDropsManager)
    self:DoClearListItems(self.PanelItem)
    self.PanelItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    if pDropSubSys then
        local tbAward = pDropSubSys:GetGainedDrops():ToTable()
        if tbAward then
            for k, v in pairs(tbAward) do
                local tbGDPL = Split(k, "-")
                if #tbGDPL >= 4 then
                    local tbParam = {G = tbGDPL[1], D = tbGDPL[2], P = tbGDPL[3], L = tbGDPL[4], N = v}
                    local pObj = self.ListFactory:Create(tbParam)
                    self.PanelItem:AddItem(pObj)
                end
            end
        end
    end
end

function tbClass:ShowSkillInfo()
    if FunctionRouter.IsOpenById(FunctionType.ElemExplosion) then
        WidgetUtils.SelfHitTestInvisible(self.PanelRestrained)
    else
        WidgetUtils.Collapsed(self.PanelRestrained)
    end
    -- WidgetUtils.SelfHitTestInvisible(self.PanelSkill)
    -- self.Skill1:Show()
end

-- 显示关卡/Boss图片 推荐等级/战力
function tbClass:ShowStarInfo(tbCfg)
    WidgetUtils.HitTestInvisible(self.StarList)
    if tbCfg.nPictureLevel then
        SetTexture(self.ImgChapter, tbCfg.nPictureLevel)
    end
    if tbCfg.nPictureBoss then
        WidgetUtils.HitTestInvisible(self.Boss_1)
        SetTexture(self.ImgBoss, tbCfg.nPictureBoss)
    else
        WidgetUtils.Collapsed(self.Boss_1)
    end
    -- if tbCfg.GetRecommendPower then
    --     WidgetUtils.SelfHitTestInvisible(self.PanelCombat)
    --     self.TxtPower:SetText(tbCfg:GetRecommendPower())
    -- else
        WidgetUtils.Collapsed(self.PanelCombat)
    --end
    if Launch.GetType() == LaunchType.CHAPTER or Launch.GetType() == LaunchType.ROLE or  Launch.GetType() == LaunchType.DLC1_CHAPTER then
        WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
        self.TxtLevelNum:SetText(UE4.ULevelLibrary.GetPresetMonsterLevelById(tbCfg.nID))
    elseif Launch.GetType() == LaunchType.DEFEND then
        WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
        self.TxtLevelNum:SetText(tbCfg.nRecommendLevel)
    else
        WidgetUtils.Collapsed(self.PanelLevel)
    end
end

--- 显示关卡效果
function tbClass:UpdateLevelBuff(tbCfg)
    if not tbCfg or not tbCfg.tbBuffID then
        return
    end
    WidgetUtils.Visible(self.LevelInfo)
    for i = 1, 3 do
        local id = tbCfg.tbBuffID[i]
        if id then
            WidgetUtils.Visible(self["PanelCombat"..i])
            self["TxtName"..i]:SetText(Localization.GetSkillName(id))
            self["TxtPower"..i]:SetText(Localization.GetSkillDesc(id))
        else
            WidgetUtils.Collapsed(self["PanelCombat"..i])
        end
    end
end

return tbClass