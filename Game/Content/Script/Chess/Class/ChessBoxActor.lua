----------------------------------------------------------------------------------
-- @File    : ClessBoxActor.lua
-- @Brief   : 棋盘 - 推箱子actor
-- @Author  : leiyong
----------------------------------------------------------------------------------

local tbClass = Class()

--- 开始交互
function tbClass:BeginInteraction()
    local ObjectId = self:GetObjectId()
    if ObjectId and ObjectId > 0 and ChessData:GetObjectIsUsed(self:GetObjectId()) == 1 then
        return
    end

    self.character = ChessClient:GetPlayerCharacter()
    self.regionActor = ChessClient:GetRegionActor()
    local posCharacter = self.character:GetPosition()
    local deltaX = self.PosX - posCharacter.X;
    local deltaY = self.PosY - posCharacter.Y;
    if deltaX ~= 0 and deltaY ~= 0 then 
        ChessTools:ShowTip("ui.TxtChessTips6", true)
        return false;
    end

    local newX = self.PosX + deltaX;
    local newY = self.PosY + deltaY;
    local nowGround = self.regionActor:FindGroundActor(self.PosX, self.PosY)
    local ground = self.regionActor:FindGroundActor(newX, newY)

    if not ground or not ground:IsWalkable() or ground:GetHasBlockObject() or ground:FindObjectByTag("blockbox") then 
        ChessTools:ShowTip("ui.TxtChessTips1", true)
        return false
    end

    self.move_grid_index = 0
    self.moveDistance = self:GetMoveDistance(ground)
    self.move_time = 0;
    self.move_delta = {x = deltaX, y = deltaY}
    self.boxStartPos = self:K2_GetActorLocation()

    self.playerStartPos = self.character:K2_GetActorLocation()
    local endPos = UE4.FVector(self.playerStartPos.X + deltaX, self.playerStartPos.Y + deltaY, self.playerStartPos.Z)
    local rotate = UE4.UKismetMathLibrary.FindLookAtRotation(self.playerStartPos, endPos)
    self.character:K2_SetActorRelativeRotation(rotate, false)
    self.bInPreActon = true
    self.character:GetController():UpdateWalkState(false, true)
    if nowGround then 
        self.boxDelta =  ground:TryGetBoxRecieverHeight() - nowGround:TryGetBoxRecieverHeight() 
    end
    if self.character.CurrentGroundActor and self.character.CurrentGroundActor.TryGetBoxRecieverHeight then
        self.characterPos = self.playerStartPos.Z + ground:TryGetBoxRecieverHeight() - self.character.CurrentGroundActor:TryGetBoxRecieverHeight() 
    end
    return true;
end

--- 结束交互
function tbClass:EndInteraction()
end
--- 交互中
function tbClass:DOInteraction(deltaSecond)
    if not self.hasPlayVoice then
        UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2005), self)
        self.hasPlayVoice = true
    end
    self.move_time = self.move_time + deltaSecond
    local time = math.min(1, self.move_time / self.MoveSpeed);
    local deltaPosX = time * self.moveDistance.x;
    local deltaPosY = time * self.moveDistance.y;
    local deltaPosZ = time * (self.boxDelta or 0)
    local characterDeltaZ = time * (self.characterDelta or 0)
    
    local newPos = UE4.FVector(self.boxStartPos.X + deltaPosX, self.boxStartPos.Y + deltaPosY, self.boxStartPos.Z + deltaPosZ)
    self:K2_SetActorLocation(newPos)
    local playerPos = self.character:K2_GetActorLocation()
    local playerNewPos
    if self.characterPos and self.characterPos ~= self.playerStartPos.Z then
        playerNewPos = UE4.FVector(self.playerStartPos.X + deltaPosX, self.playerStartPos.Y + deltaPosY, math.min(self.characterPos, playerPos.Z))
    else
        playerNewPos = UE4.FVector(self.playerStartPos.X + deltaPosX, self.playerStartPos.Y + deltaPosY, playerPos.Z)
    end
    local SweepResult = UE4.FHitResult()
    self.character:K2_SetActorLocation(playerNewPos, false, SweepResult, true)

    if time >= 1 then 
        self:SendDisappearEvent()
        self.PosX = self.PosX + self.move_delta.x;
        self.PosY = self.PosY + self.move_delta.y;
        self:SavePosition()
        self.regionActor:UpdatePathFinding()
        self:SendAppearEvent()
        

        local pos = self.character:GetPosition()
        self.character:MoveTo(self.regionActor, pos.X + self.move_delta.x, pos.Y + self.move_delta.y, false)
        self:EndInteraction()
        self.hasPlayVoice = false
        self.regionActor:UpdatePathFinding()
        ChessClient:SetInteractionActor(nil)
        if ChessData:GetObjectIsUsed(self:GetObjectId()) ~= 1 then 
            EventSystem.Trigger(Event.NotifyShowChessInteraction, self)
        end
    end
end

function tbClass:GetMoveDistance(destGround)
    local startGround = self.regionActor:FindGroundActor(self.PosX, self.PosY)
    local startLocation = startGround:K2_GetActorLocation()
    local endLocation = destGround:K2_GetActorLocation()
    return {x = endLocation.X - startLocation.X, y = endLocation.Y - startLocation.Y}
end

function tbClass:SendDisappearEvent()
    local regionId, tbTargetData, gridId = self:GetIds()
    ChessEvent:OnCheckGridObjectDisAppear(regionId, gridId, tbTargetData)
end

function tbClass:SendAppearEvent()
    local regionId, tbTargetData, gridId = self:GetIds()
    ChessEvent:OnCheckGridObjectAppear(regionId, gridId, tbTargetData)
end

function tbClass:SavePosition()
    local regionId, tbTargetData, gridId = self:GetIds()
    tbTargetData.pos = {ChessTools:GridIdToXY(gridId)}
    if tbTargetData.cfg.tbData and tbTargetData.cfg.tbData.id then 
        local index = tbTargetData.cfg.tbData.id[1]
        if index then 
            ChessData:SetObjectPosition(index, gridId)
        end
    end
end

function tbClass:GetIds()
    local regionId = self:GetRegionId()
    local uid = self:GetUID()
    local tbTargetData = ChessRuntimeHandler:GetRegionObject(regionId, uid)
    local gridId = ChessTools:GridXYToId(self.PosX, self.PosY)
    return regionId, tbTargetData, gridId
end

function tbClass:SetPlayerStartPos(StartPos)
    self.playerStartPos = CopyVector(StartPos)
end

function tbClass:GetObjectId()
    local regionId, tbTargetData, gridId = self:GetIds()
    if tbTargetData.cfg.tbData then
        return tbTargetData.cfg.tbData.id[1]
    end
end

return tbClass