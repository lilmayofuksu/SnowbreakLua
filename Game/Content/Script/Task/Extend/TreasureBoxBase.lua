-- ========================================================
-- @File    : TreasureBoxBase.lua
-- @Brief   : 宝箱基类
-- @Author  :
-- @Date    :
-- ========================================================

---@class TreasureBoxBase : AActor
local TreasureBoxBase = Class()

---箱子状态 0 禁用 1 可打开 2 已经打开

function TreasureBoxBase:Initialize()
    self.TaskItem = {}
end

--激活宝箱
function TreasureBoxBase:DoActive(InItem)
    self.TaskItem = self.TaskItem or {}
    local HasBindInItem = false
    for k,v in pairs(self.TaskItem) do
        if v == InItem then
            HasBindInItem = true
        end
    end
    if not HasBindInItem then
        table.insert(self.TaskItem,InItem)
    end
    self:SetActive(true)
    self:SetInteractable()
    --显示交互图标
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_monster_tips and self.bShowGuideIcon and not self.UIItem then
        self.UIItem = FightUMG.uw_fight_monster_tips:CreateInteractionItem(self)
    end
end

---清除绑定数据
function TreasureBoxBase:Clear()
    self.TaskItem = {}
    if self.UIItem then
        self.UIItem:Reset()
    end
    self.UIItem = nil;
    self:SetActive(false)
end

function TreasureBoxBase:BoxOpenFinish()
    if self.TaskItem then
        for k,v in pairs(self.TaskItem) do
            v:BoxOpen()
        end
    end
    if self.UIItem then
        self.UIItem:Reset()
        self.UIItem = nil;
    end
end

---进入
function TreasureBoxBase:OnTrigger_Client(bIsBeginOverlap, OtherActor)
    self:TriggerHandle(bIsBeginOverlap, OtherActor)
end

function TreasureBoxBase:TriggerHandle(bIsBeginOverlap, OtherActor)
    -- print("TreasureBoxBase:TriggerHandle")
    if self:IsLocalPlayer(OtherActor) then
        if bIsBeginOverlap then
            EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass, 1, self)
        else
            EventSystem.Trigger(Event.EndOverlapTaskBox, self)
        end
        -- print("TreasureBoxBase:TriggerHandle bLastAngleCheckResult", self.bLastAngleCheckResult)
    end
end

function TreasureBoxBase:IsLocalPlayer(OtherActor)
    if IsPlayer(OtherActor) and OtherActor:GetController() and OtherActor:GetController():IsLocalController() then
        return true
    end
    return false
end

return TreasureBoxBase
