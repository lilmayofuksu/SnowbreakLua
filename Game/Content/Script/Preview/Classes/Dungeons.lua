-- ========================================================
-- @File    : Dungeons.lua
-- @Brief   : 章节场景
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Dungeons')

function tbClass:OnEnter(fCallback)
    local ActorClass = UE4.UClass.Load("/Game/UI/UMG/Dungeons/BP_DungeonsSeqPlayer.BP_DungeonsSeqPlayer_C")
    self.PlayerActor = GetGameIns():GetWorld():SpawnActor(ActorClass)
    if fCallback then fCallback() end
    if UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() <= 0 then
        local Actors = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(), UE4.APostProcessVolume)
        for i = 1, Actors:Length() do
            Actors:Get(i).bEnabled = false
        end
    end
end

function tbClass:OnLeave()
    if self.PlayerActor then
        self.PlayerActor:ClearSeq()
        self.PlayerActor:K2_DestroyActor()
        self.PlayerActor = nil
    end
    PreviewMain.ResetCamera()
    if UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() <= 0 then
        local Actors = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(), UE4.APostProcessVolume)
        for i = 1, Actors:Length() do
            Actors:Get(i).bEnabled = true
        end
    end
end

function tbClass:PlaySequence(cameraIdx, bForward, endStateIndex, lightIdx, offset)
    if self.PlayerActor then
        self.PlayerActor:PlaySeq(cameraIdx, bForward, endStateIndex, lightIdx, offset)
    end
end

function tbClass:ClearSequence()
    if self.PlayerActor then
        self.PlayerActor:ClearSequence()
    end
end

return tbClass
