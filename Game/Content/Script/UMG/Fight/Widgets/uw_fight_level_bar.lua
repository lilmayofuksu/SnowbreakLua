-- ========================================================
-- @File    : uw_fight_level_guard.lua
-- @Brief   : 战斗界面 摧毁任务进度
-- @Author  : 
-- @Date    :
-- ========================================================

local LevelGuard = Class("UMG.SubWidget")
LevelGuard.DestroyExecute = nil

function LevelGuard:Active(DestroyExecuteNode)
    WidgetUtils.Collapsed(self.TxtName)
    if DestroyExecuteNode then
        self.DestroyExecute = DestroyExecuteNode
        self:Update(DestroyExecuteNode)
        WidgetUtils.SelfHitTestInvisible(self)
    end
end

function LevelGuard:Update(DestroyExecuteNode)
    if DestroyExecuteNode == nil or DestroyExecuteNode ~= self.DestroyExecute then
        return
    end
    local num = math.floor(DestroyExecuteNode:GetDesc_Num() * 100)
    self.TxtNum:SetText(tostring(num)..'%')
    self.BarNum:SetPercent(DestroyExecuteNode:GetDesc_Num())
end

function LevelGuard:Deactive(DestroyExecuteNode)
    if DestroyExecuteNode == self.DestroyExecute then
        self.DestroyExecute = nil
        WidgetUtils.Collapsed(self)
    end
end

function LevelGuard:OnDestruct()
    self.DestroyExecute = nil
end

return LevelGuard
