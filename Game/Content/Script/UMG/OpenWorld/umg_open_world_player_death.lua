-- ========================================================
-- @File    : umg_open_world_player_death.lua
-- @Brief   : 开放世界角色死亡
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
tbClass.tbUsedTip = {}
tbClass.tbUnusedTip = {}

function tbClass:OnInit()
    print("open world player death")
    BtnAddEvent(self.BtnRevive, function() self:OnBtnClickClose() end)
end

function tbClass:OnOpen()
    print("onopen world player death")
    self:PlayAnimation(self.AnimOpen, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end

function tbClass:OnClose()
    
end

function tbClass:OnBtnClickClose()
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    OwnerPlayer:Server_ReviveAllCharacter(0.3)

    local Pawn = OwnerPlayer:K2_GetPawn();
    local location = Pawn:K2_GetActorLocation();
    local tbPoints = OpenWorldMgr.GetPointCfg();

    -- 寻找一个最近的传送点
    local pointName;
    local distance;
    for key, tb in pairs(tbPoints.points) do 
        if OpenWorldMgr.IsTransPoint(key) then
            local isUnlock = OpenWorldMgr.IsUnlockTransPoint(key)
            if isUnlock then 
                local deltaX = tb.pos[1] - location.X
                local deltaY = tb.pos[2] - location.Y
                local deltaZ = tb.pos[3] - location.Z
                local dis = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ;
                if not distance or  dis < distance then 
                    distance = dis;
                    pointName = key;
                end
            end
        end
    end

    if pointName then
        local pos = tbPoints.points[pointName].pos
        local newPos = UE4.FVector(pos[1], pos[2], pos[3] + 80)
        local SweepResult = UE4.FHitResult()
        Pawn:K2_SetActorLocation(newPos, false, SweepResult, true);
    end

    self:PlayAnimation(self.AnimClose, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    UE4.Timer.Add(2, function()
        if UI.IsOpen(self.sName) then
            UI.Close(self)
        end
    end)
end


return tbClass