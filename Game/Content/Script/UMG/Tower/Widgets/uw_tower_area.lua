-- ========================================================
-- @File    : uw_tower_area.lua
-- @Brief   : 关卡目标和怪物信息界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Popup:Init("", function() UI.Close(self) end)
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListSystem)
    self:DoClearListItems(self.ListMonster)
    self.ListMonster:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnOpen()
    self:UpdatePanel()
end

function tbClass:UpdatePanel(sType)
    self:PlayAnimation(self.AllEnter)
    self.sType = sType
    if self.sType == "fight" then   --战斗界面打开
        WidgetUtils.Collapsed(self.Popup)
    else
        WidgetUtils.SelfHitTestInvisible(self.Popup)
    end

    self.TbLevelID = ClimbTowerLogic.GetNowTbLevelID()
    for i = 1, #self.TbLevelID do
        if self.TbLevelID[i] == ClimbTowerLogic.GetLevelID() then
            self.SelectID = i
        end
    end
    self.SelectArea = ClimbTowerLogic.GetLevelArea()

    self:DoClearListItems(self.ListSystem)
    self.AreaItem = {}
    for i in pairs(self.TbLevelID) do
        self.AreaItem[i] = {}
        for Area = 1, 3 do
            local tbParam = {tbData = {sName = "ui.TxtDungeonsTowerArea" .. ((i - 1) * 3 + Area)}, bSelect = i == self.SelectID and Area == self.SelectArea , fClick = function()
                if i == self.SelectID and Area == self.SelectArea then return end
                self.AreaItem[self.SelectID][self.SelectArea]:SetSelect(false)
                self.AreaItem[i][Area]:SetSelect(true)
                self.SelectID = i
                self.SelectArea = Area
                self:UpdateRightPanel()
            end}
            local pObj = self.ListFactory:Create(tbParam)
            self.AreaItem[i][Area] = pObj.Data
            self.ListSystem:AddItem(pObj)
        end
    end
    self:UpdateRightPanel()
end

function tbClass:UpdateRightPanel()
    local LevelID = self.TbLevelID[self.SelectID]
    local cfg = ClimbTowerLogic.GetLevelInfo(LevelID)
    if not cfg then return end

    self:DoClearListItems(self.ListMonster)
    if cfg.tbMonster[self.SelectArea] then
        for _, ID in pairs(cfg.tbMonster[self.SelectArea]) do
            -- 暂时不显示等级
            -- local minfo = {ID}
            -- if not ClimbTowerLogic.IsBasic(LevelID) then
            --     local diff = ClimbTowerLogic.GetLevelDiff()
            --     if diff ~= 0 and cfg.tbMonsterLevel[diff] then
            --         minfo[2] = cfg.tbMonsterLevel[diff]
            --     end
            -- end
            local pObj = self.ListFactory:Create(ID)
            self.ListMonster:AddItem(pObj)
        end
    end

    self.TxtDebuff:SetText(Text(cfg.sBuffDesc))
    if ClimbTowerLogic.IsAdvanced() then
        WidgetUtils.HitTestInvisible(self.PanelBuff)
        local timeCfg = ClimbTowerLogic.GetTimeCfg()
        if timeCfg then self.TxtBuff:SetText(Text(timeCfg.sBuffDesc)) end
    else
        WidgetUtils.Collapsed(self.PanelBuff)
    end

    if self.sType == "fight" and LevelID == ClimbTowerLogic.GetLevelID() and self.SelectArea == ClimbTowerLogic.GetLevelArea() then   --战斗界面打开 显示当前挑战
        local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelStarTaskManager)
        if pSubSys then
            local Infos = pSubSys:GetStarTaskProperties()
            if Infos:Length() > 0 then
                local Color = UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1)
                for i = 1, Infos:Length() do
                    local info = Infos:Get(i)
                    local pItem = self.Conditions:GetChildAt(i - 1)
                    if pItem then
                        pItem:Set(info.bFinished, info.Description, info.CurrentState, info.bFinished)
                        pItem.Des:SetColorAndOpacity(Color)
                    end
                end
                return
            end
        end
    end
    --显示历史记录
    local RID = ClimbTowerLogic.GetLevelID()
    ClimbTowerLogic.SetLevelID(LevelID)
    local tbStarInfo = ClimbTowerLogic.DidGotStars(LevelID, self.SelectArea)
    local ArrayPro = UE4.ULevelStarTaskManager.GetStarTaskProperties_OutTowerLevel(self.SelectArea)
    local Color = UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1)
    for i = 1, ArrayPro:Length() do
        local pItem = self.Conditions:GetChildAt(i - 1)
        if pItem then
            local pPro = ArrayPro:Get(i)
            pItem:Set(tbStarInfo[i], pPro.Description, pPro.CurrentState, tbStarInfo[i])
            pItem.Des:SetColorAndOpacity(Color)
        end
    end
    ClimbTowerLogic.SetLevelID(RID)
end

return tbClass