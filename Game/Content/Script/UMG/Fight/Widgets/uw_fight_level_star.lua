-- ========================================================
-- @File    : uw_fight_level_star.lua
-- @Brief   : 战斗界面 星级条件显示
-- @Author  : 
-- @Date    : 
-- ========================================================
local uw_fight_level_star = Class("UMG.SubWidget")

local LevelStar = uw_fight_level_star

function LevelStar:Construct()
    self.tbItems = {}
    self:DoClearListItems(self.ListStar)
    self.ListFactory = Model.Use(self)
    self.StarTaskChangeHandle = EventSystem.On(Event.OnStarTaskChange,
        function(bSettlement, bUpdate, bShow)
            self:OnStarTaskChange(bSettlement, bUpdate, bShow)
        end
    )
    self:UpdateStarTask()
end

---星级刷新
---@param bSettlement boolean 是否是结算的时候
function LevelStar:OnStarTaskChange(bSettlement, bUpdate, bShow)
    local IsTower = Launch.GetType() == LaunchType.TOWER
    if bSettlement then
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    WidgetUtils.Collapsed(self)
                    if self.UpdataTimeHandle then
                        
                    end
                end
            },
            2,
            false
        )
    elseif IsTower and not WidgetUtils.IsVisible(self) then
        WidgetUtils.HitTestInvisible(self)
    end

    local StarTaskSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
    if not StarTaskSubSys then return end
    
    local tbStar = StarTaskSubSys:GetDetailStarTaskProperties()

    if #self.tbItems > 0 and bUpdate then
        for i, v in ipairs(self.tbItems) do
            local info = tbStar:Get(i)
            local data = {
                Description = info.Description,
                CurrentState = info.CurrentState,
                bFinished = info.bFinished,
                Progress = info.Progress,
                bAchieveFailed = info.bAchieveFailed,
                bHasFinished = info.bHasFinished,
                bPlayAnim = bShow
            }
            if v.Data.Refresh then
                v.Data.Refresh(data)
            else
                v.Data = data
            end
        end
        if bShow then
            WidgetUtils.SelfHitTestInvisible(self)
        end
        return
    end

    self.tbItems = {}
    self:DoClearListItems(self.ListStar)

    for i = 1, tbStar:Length() do
        local info = tbStar:Get(i)
        local pObj = self.ListFactory:Create({
            Description = info.Description,
            CurrentState = info.CurrentState,
            bFinished = info.bFinished,
            Progress = info.Progress,
            bAchieveFailed = info.bAchieveFailed,
            bHasFinished = info.bHasFinished
        })
        self.ListStar:AddItem(pObj)
        table.insert(self.tbItems, pObj)
    end

    if Launch.GetType() == LaunchType.TOWER then
        ---爬塔关卡控制倒计时显示
        if Launch.GetType() == LaunchType.TOWER then
            local ui = UI.GetUI("fight")
            if ui and ui:IsOpen() then
                if bSettlement then
                    WidgetUtils.Collapsed(ui.Time)
                else
                    WidgetUtils.HitTestInvisible(ui.Time)
                end
            end
        end
    end
end

function LevelStar:PlayAnim()
    for _, value in ipairs(self.tbItems) do
        if value.Data.Play then
            value.Data:Play()
        end
    end
end

---爬塔出生点刷新星级完成情况
function LevelStar:UpdateStarTask()
    -- local Infos = UE4.ULevelStarTaskManager.GetStarTaskProperties_OutTowerLevel(ClimbTowerLogic.GetLevelArea())
    -- for i = 1, Infos:Length() do
    --     local info = Infos:Get(i)
    --     local tbParam = {
    --         Description = info.Description,
    --         bFinished = false,
    --     }
    --     local pObj = self.ListFactory:Create(tbParam)
    --     self.ListStar:AddItem(pObj)
    -- end
    WidgetUtils.Collapsed(self)

    ---爬塔关卡控制倒计时显示
    local ui = UI.GetUI("fight")
    if ui and ui:IsOpen() then
        WidgetUtils.Collapsed(ui.Time)
    end
end

function LevelStar:OnDestruct()
    EventSystem.Remove(self.StarTaskChangeHandle)
end

return LevelStar
