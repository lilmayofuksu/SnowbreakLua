-- ========================================================
-- @File    : umg_tower.lua
-- @Brief   : 爬塔主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Factory = Model.Use(self)

    self.tbTextColor = {
        "#11B44AFF",
        "#F2A73DFF",
        "#EE2B4CFF"
    }

    self.BtnIntro.BtnInfo.OnClicked:Add(self, function()
        self:CloseOtherWidget()
        UI.Open("HelpImages", 1)
    end)

    BtnAddEvent(self.BtnShop, function()
        self:CloseOtherWidget()
        UI.Open("Shop", 23)
    end)

    ---1：基座 2：大楼
    self.nType = nil
end

function tbClass:OnOpen()
    Launch.SetType(LaunchType.TOWER)
    self:PlayAnimation(self.First)

    if ClimbTowerLogic.bShowLevelInfo then
        ClimbTowerLogic.bShowLevelInfo = nil
        self.SelectLayer = ClimbTowerLogic.GetNowLayer()
        self:UpdateOnOpen()
        self:ShowLevelInfo()
    else
        self:UpdateOnOpen()
    end
end

function tbClass:UpdateOnOpen()
    self:CloseOtherWidget()
    self:CloseTopChild()

    if not self.nType then
        if ClimbTowerLogic.IsAdvanced() then
            self.nType = 2
        else
            self.nType = 1
        end
    end

    self.Bg:InitWidget(self.nType == 2)

    self:UpdateModeList()
    self:PlayAnimation(self.LevelOriginal)
    --未选择难度弹出难度选择界面
    if self.nType == 2 and ClimbTowerLogic.GetLevelDiff() == 0 then
        WidgetUtils.Collapsed(self.HardMode)
        WidgetUtils.Collapsed(self.EasyMode)
        WidgetUtils.Collapsed(self.Difficulty)
        if not self.TowerDifficulty then
            self.TowerDifficulty = WidgetUtils.AddChildToPanel(self.TowerPanel, "/Game/UI/UMG/Tower/Widgets/uw_tower_difficulty.uw_tower_difficulty_C", 8)
        end
        if self.TowerDifficulty then
            WidgetUtils.Visible(self.TowerDifficulty)
        end
    else
        self:UpdateLevel()
    end

    ---设置进度条长度
    local layerNum1 = #ClimbTowerLogic.GetAllLayerTbLevel(1)
    local layerNum2 = #ClimbTowerLogic.GetAllLayerTbLevel(2)
    local ExpBarSlot1 = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ExpBar)
    ExpBarSlot1:SetSize(UE4.FVector2D(2, layerNum1 * 216))
    local ExpBarSlot2 = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ExpBarH)
    ExpBarSlot2:SetSize(UE4.FVector2D(2, layerNum2 * 216))
    ---刷新进度条的进度值
    local progres1 = ClimbTowerLogic.GetLayerID(1)
    local progres2 = ClimbTowerLogic.GetLayerID(2)
    if progres1 == 1 then
        self.ExpBar:SetPercent(0)
    elseif progres1 == layerNum1 then
        self.ExpBar:SetPercent(1)
    else
        self.ExpBar:SetPercent(1 / layerNum1 * progres1)
    end
    if progres2 == 1 then
        self.ExpBarH:SetPercent(0)
    elseif progres2 == layerNum2 then
        self.ExpBarH:SetPercent(1)
    else
        self.ExpBarH:SetPercent(1 / layerNum2 * progres2)
    end
end

function tbClass:OnClose()
    if self.nSetScrollOffsetTimer then
        UE4.Timer.Cancel(self.nSetScrollOffsetTimer)
        self.nSetScrollOffsetTimer = nil
    end
    self:StopAnimation(self.AllEnter)
end

---刷新本期buff显示
function tbClass:UpdateBuffPenel()
    if self.nType == 1 then
        WidgetUtils.Collapsed(self.PanelBuff)
    elseif self.nType == 2 then
        WidgetUtils.HitTestInvisible(self.PanelBuff)
        self.TimeCfg = ClimbTowerLogic.GetTimeCfg()
        if self.TimeCfg and self.TimeCfg.sBuffDesc then
            self.TxtBuff:SetText(Text(self.TimeCfg.sBuffDesc))
        end
    end
end

---刷新红点显示
function tbClass:UpdateRed()
    if ClimbTowerLogic.CanReceive(self.nType) then
        WidgetUtils.HitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

---刷新奖励领取状态
function tbClass:UpdateRewardState()
    local allLayertbLevel = ClimbTowerLogic.GetAllLayerTbLevel(self.nType)
    for i = 1, #allLayertbLevel do
        local BtnReward = nil
        if self.nType == 1 then
            BtnReward = self["BtnReward" .. i]
        elseif self.nType == 2 then
            BtnReward = self["BtnRewardH" .. i]
        end
        if BtnReward then
            BtnReward:UpdateState()
        end
    end
    self:UpdateModeList()
end

---关闭其他子界面
function tbClass:CloseOtherWidget(index)
    if UI.IsOpen("TowerAward") then
        UI.Close("TowerAward")
    end
    if UI.IsOpen("TowerArea") then
        UI.Close("TowerArea")
    end
    WidgetUtils.Collapsed(self.TowerInfo)
end

--刷新难度选择列表
function tbClass:UpdateModeList()
    self.tbModeItem = {}
    self:DoClearListItems(self.Mode)
    for i = 1, 2 do
        local data = {}
        data.nType = i
        data.isSelect = self.nType == i
        data.UpdateSelect = function(ntype)
            if ntype == self.nType then return end
            self.tbModeItem[self.nType]:SetSelect(false)
            self.tbModeItem[ntype]:SetSelect(true)
            self.nType = ntype
            self.SelectLayer = ClimbTowerLogic.GetLayerID(ntype)
            if ntype == 1 then
                self.Bg:SwitchToPrevious()
            elseif ntype == 2 then
                self.Bg:SwitchToNext()
            end
            self:PlayAnimation(self.LevelSwitch)
            --未选择难度弹出难度选择界面
            if ntype == 2 and ClimbTowerLogic.GetLevelDiff() == 0 then
                WidgetUtils.Collapsed(self.HardMode)
                WidgetUtils.Collapsed(self.EasyMode)
                if not self.TowerDifficulty then
                    self.TowerDifficulty = WidgetUtils.AddChildToPanel(self.TowerPanel, "/Game/UI/UMG/Tower/Widgets/uw_tower_difficulty.uw_tower_difficulty_C", 8)
                end
                if self.TowerDifficulty then
                    WidgetUtils.Visible(self.TowerDifficulty)
                end
            else
                self:UpdateLevel()
            end
        end
        local pObj = self.Factory:Create(data)
        self.Mode:AddItem(pObj)
        self.tbModeItem[i] = pObj.Data
    end
end

function tbClass:UpdateLevel()
    self:CloseOtherWidget()
    WidgetUtils.Collapsed(self.TowerInfo)
    local allLayertbLevel = ClimbTowerLogic.GetAllLayerTbLevel(self.nType)
    if #allLayertbLevel <= 0 then
        return
    end

    if not self.SelectLayer then
        self.SelectLayer = ClimbTowerLogic.GetLayerID(self.nType)
    end

    self.tbLayerWidget = {}
    local widgetnum = 0
    if self.nType == 1 then
        widgetnum = 17
        WidgetUtils.Collapsed(self.HardMode)
        WidgetUtils.Collapsed(self.Difficulty)
        WidgetUtils.SelfHitTestInvisible(self.EasyMode)
        self.TxtName:SetText(Text("ui.TxtDungeonsTowerEasy"))
        WidgetUtils.Collapsed(self.Time)
    elseif self.nType == 2 then
        widgetnum = 4
        WidgetUtils.Collapsed(self.EasyMode)
        WidgetUtils.SelfHitTestInvisible(self.HardMode)
        self.TxtName:SetText(Text("ui.TxtDungeonsTowerHard"))
        local diff = ClimbTowerLogic.GetLevelDiff()
        if diff ~= 0 then
            WidgetUtils.SelfHitTestInvisible(self.Difficulty)
            self.TxtDifficulty:SetText(Text("ui.TxtDungeonsTowerDifficulty"..diff))
            Color.SetTextColor(self.TxtDifficulty, self.tbTextColor[diff])
        else
            WidgetUtils.Collapsed(self.Difficulty)
        end
        WidgetUtils.HitTestInvisible(self.Time)
        self.TimeCfg = self.TimeCfg or ClimbTowerLogic.GetTimeCfg()
        self.Time:ShowNormal(self.TimeCfg.nEndTime, function() ClimbTowerLogic.CheckCycleLevel() end)
    end
    for i = 1, widgetnum do
        local pWidget = nil
        if self.nType == 1 then
            pWidget = self["Level" .. string.format("%02d", i)]
        elseif self.nType == 2 then
            pWidget = self["LevelH" .. string.format("%02d", i)]
        end
        if pWidget then
            local tblevel = allLayertbLevel[i]
            if tblevel then
                WidgetUtils.SelfHitTestInvisible(pWidget)
                local pLevel = nil
                if self.nType == 1 then
                    pLevel = self["TowerLevel" .. string.format("%02d", i)]
                elseif self.nType == 2 then
                    pLevel = self["TowerLevelH" .. string.format("%02d", i)]
                end
                if pLevel then
                    local info = {}
                    info.layer = i
                    info.type = self.nType
                    info.isSelect = self.SelectLayer == i
                    info.UpdateSelect = function()
                        if self.SelectLayer ~= i then
                            local Common = nil
                            local Current = nil
                            local CommonNew = nil
                            local CurrentNew = nil
                            if self.nType == 1 then
                                Common = self["Common" .. self.SelectLayer]
                                Current = self["Current" .. self.SelectLayer]
                                CommonNew = self["Common" .. i]
                                CurrentNew = self["Current" .. i]
                            elseif self.nType == 2 then
                                Common = self["CommonH" .. self.SelectLayer]
                                Current = self["CurrentH" .. self.SelectLayer]
                                CommonNew = self["CommonH" .. i]
                                CurrentNew = self["CurrentH" .. i]
                            end
                            WidgetUtils.Collapsed(Current)
                            WidgetUtils.Collapsed(CommonNew)
                            WidgetUtils.HitTestInvisible(Common)
                            WidgetUtils.HitTestInvisible(CurrentNew)
                        end
                        self:OnSelectLayer(i)
                    end
                    pLevel:Init(info)
                    self.tbLayerWidget[i] = pLevel
                end
                local BtnReward = nil
                local layer = nil
                if self.nType == 1 then
                    BtnReward = self["BtnReward" .. i]
                    layer = i
                elseif self.nType == 2 then
                    BtnReward = self["BtnRewardH" .. i]
                    layer = i + #ClimbTowerLogic.GetAllLayerTbLevel(1)
                end
                if BtnReward then
                    BtnReward:Init(layer, function()
                        UI.Open("TowerAward", self.nType, layer)
                    end)
                end
            else
                WidgetUtils.Collapsed(pWidget)
            end
        end
        local PDot = nil
        if self.nType == 1 then
            PDot = self["Dot" .. i]
        elseif self.nType == 2 then
            PDot = self["DotH" .. i]
        end
        if PDot then
            if allLayertbLevel[i] then
                WidgetUtils.HitTestInvisible(PDot)
                local Common = nil
                local Lock = nil
                local Current = nil
                if self.nType == 1 then
                    Common = self["Common" .. i]
                    Lock = self["Lock" .. i]
                    Current = self["Current" .. i]
                elseif self.nType == 2 then
                    Common = self["CommonH" .. i]
                    Lock = self["LockH" .. i]
                    Current = self["CurrentH" .. i]
                end
                if self.SelectLayer == i then
                    WidgetUtils.Collapsed(Lock)
                    WidgetUtils.Collapsed(Common)
                    WidgetUtils.HitTestInvisible(Current)
                else
                    WidgetUtils.Collapsed(Current)
                    local unLock = ClimbTowerLogic.CheckUnlock(self.nType, i)
                    if unLock then
                        WidgetUtils.Collapsed(Lock)
                        WidgetUtils.HitTestInvisible(Common)
                    else
                        WidgetUtils.Collapsed(Common)
                        WidgetUtils.HitTestInvisible(Lock)
                    end
                end
            else
                WidgetUtils.Collapsed(PDot)
            end
        end
    end
    self:PlayAnimation(self.AllEnter)

    --将选择的关卡滑动到视图中
    local v = 0
    if self.SelectLayer > 0 then
        v = (self.SelectLayer-1) / (#allLayertbLevel-1)
    end
    if v > 0 then
        self.nSetScrollOffsetTimer = UE4.Timer.Add(0.1, function()
            local OffsetOfEnd = self.LevelScrollBox_1:GetScrollOffsetOfEnd()
            self.LevelScrollBox_1:SetScrollOffset(Lerp(0, OffsetOfEnd, v))
            self.nSetScrollOffsetTimer = nil
        end)
    end

    self:UpdateBuffPenel()
end

function tbClass:OnSelectLayer(layer)
    local level, area = ClimbTowerLogic.GetLevelAndArea(self.nType)
    if level and area then
        local cfg = ClimbTowerLogic.GetLevelInfo(level)
        local Layer, nUpOrDown = ClimbTowerLogic.GetNowRealLayer(level)
        local showArea = area
        if nUpOrDown == 2 then
            showArea = showArea + 3
        end
        if cfg then
            UI.Open("MessageBox", Text("climbtower.recordProgre", Layer, showArea),
                function()
                    ClimbTowerLogic.SetLevelID(cfg.nID)
                    ClimbTowerLogic.SetLevelArea(area)
                    ClimbTowerLogic.AddRefreshHPEvent(self.nType)
                    Launch.Start()
                end,
                function() me:CallGS("ClimbTowerLogic_TowerGiveUp", json.encode({nType = self.nType})) end
            )
            return
        end
    end

    if not layer or not self.tbLayerWidget[layer] then return end
    if self.SelectLayer and self.tbLayerWidget[self.SelectLayer] then
        self.tbLayerWidget[self.SelectLayer]:SetSelect(false)
    end
    self.tbLayerWidget[layer]:SetSelect(true)
    self.SelectLayer = layer

    self:CloseOtherWidget()

    local tblevel = ClimbTowerLogic.GetLayerTbLevel(self.nType, layer)
    local towerlevel = ClimbTowerLogic.GetLevelInfo(tblevel[1])
    if towerlevel and towerlevel.nID and towerlevel.nLevelID then
        local tbLevelCfg = TowerLevel.Get(towerlevel.nLevelID)
        if tbLevelCfg then
            ClimbTowerLogic.SetLevelID(towerlevel.nID)
            ClimbTowerLogic.SetLevelArea(1)
            tbLevelCfg.TowerLayer = layer
            tbLevelCfg.TowerType = self.nType
            if not self.TowerInfo then
                self.TowerInfo = WidgetUtils.AddChildToPanel(self.Panel, "/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C", 8)
            end
            if self.TowerInfo then
                WidgetUtils.SelfHitTestInvisible(self.TowerInfo)
                self.TowerInfo:Show(tbLevelCfg)
            end
        end
    end
end

--- 重新挑战或者下一关时打开关卡信息
function tbClass:ShowLevelInfo()
    local nLevelID = ClimbTowerLogic.GetLevelID()
    if nLevelID and nLevelID ~= 0 then
        local tbLevelCfg = TowerLevel.Get(nLevelID)
        if tbLevelCfg then
            if not self.TowerInfo then
                self.TowerInfo = WidgetUtils.AddChildToPanel(self.Panel, "/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C", 8)
            end
            if self.TowerInfo then
                self.TowerInfo:Show(tbLevelCfg)
            end
        end
    end
end

return tbClass
