-- ========================================================
-- @File    : uw_login_spine.lua
-- @Brief   : 服务器条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Show(info)
    self:PlayCGSpine(true, info)
end

function tbClass:PlayCGSpine(bPlay, tbResourceInfo)

    local pCameraMgr = self:GetOwningPlayerCameraManager()
    if not pCameraMgr then return end

    local pCamera = pCameraMgr.AnimCameraActor
    if not pCamera then return end

    if pCamera.CameraComponent then
        pCamera.CameraComponent:SetConstraintAspectRatio(false)
    end

    if bPlay then
        if self.isPlayingCG then return end
        self.isPlayingCG = true
        UE4.UGameLocalPlayer.SetAutoAdapteToScreen(false)

        local sSpineRes = tbResourceInfo[2]
        local nTime = tbResourceInfo[3] or 1
        local startPos = tbResourceInfo[4] or {0, 0}
        local endPos = tbResourceInfo[5] or {0, 0}
        local scale = tbResourceInfo[6] or {1, 1}

        if sSpineRes then
            local pSoftPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(sSpineRes)
            local pLoadObj = UE4.UGameAssetManager.GameLoadAsset(pSoftPath)
            if pLoadObj then 
                UE4.UCGSpineLibrary.PlayCGSpine(pLoadObj, pCamera);
            end
        end
        UE4.UCGSpineLibrary.PlayCameraAnimation(nTime, UE4.FVector2D(startPos[1], startPos[2]), UE4.FVector2D(endPos[1], endPos[2]), UE4.FVector2D(scale[1], scale[2]))
    else
        if not self.isPlayingCG then return end
        UE4.UCGSpineLibrary.ClearCGSpine(pCamera);
        --UE4.UGameLocalPlayer.SetAutoAdapteToScreen(true)
        self.isPlayingCG = false
    end
end

function tbClass:OnDestruct()
    self:PlayCGSpine(false)
end


return tbClass