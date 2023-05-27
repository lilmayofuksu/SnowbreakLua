-- ========================================================
-- @File    : PreviewMain.lua
-- @Brief   : 主界面模型预览
-- ========================================================

---@class PreviewMain 主界面模型
PreviewMain = PreviewMain or {nCacheCardID = nil, bValid = false, pBgActor = nil}

PreviewMain.bLoadBg = false

function PreviewMain.MainMapEndPlayCall()
    Map.Class('MainMap'):OnLeave(2)
end

function PreviewMain.Clear()
    PreviewMain.DestroyBG()
    PreviewMain.DestroyCard()
end

function PreviewMain.ResetCamera()
    local pCamera = PreviewMain.GetCamera()
    if pCamera then
        local player = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        if player then
            player:SetViewTargetWithBlend(pCamera)
        end
    end
end

function PreviewMain.GetCamera()
   return PreviewScene.GetActor(PreviewScene.MainCameraActorName)
end

function PreviewMain.GetBG()
    return PreviewMain.pBgActor
end

---加载背景
function PreviewMain.LoadBG(fCallback, bVisible)
    if Map.GetCurrentID() ~= 2 then return end

    if PreviewMain.bLoadBg then
        if fCallback then
            fCallback() 
        end
        return
    end

    PreviewMain.DestroyBG()

    PreviewMain.bLoadBg = true

    local BGActorClassPath
    if IsMobile() then
        BGActorClassPath = "/Game/UI/UMG/Main/Widgets/BP_GyroActor.BP_GyroActor_C"
    else
        BGActorClassPath = "/Game/UI/UMG/Main/Widgets/BP_GyroActorPC.BP_GyroActorPC_C"
    end
    local softPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(BGActorClassPath)

    local pClass = UE4.UGameAssetManager.GameLoadAsset(softPath)
    if pClass then
        PreviewMain.pBgActor = GetGameIns():GetWorld():SpawnActor(pClass)
    else
        PreviewMain.pBgActor = nil
        print('load bg err **********************')
    end

    PreviewMain.SetBgVisble(bVisible or true)

    if fCallback then
        fCallback()
    end
end

---删除
function PreviewMain.DestroyBG()
    if IsValid(PreviewMain.pBgActor) then
        PreviewMain.pBgActor:K2_DestroyActor() 
    end
    PreviewMain.pBgActor = nil
    PreviewMain.bLoadBg = false
end

---@param bChangeSkin 是否从换装界面进 是的话刷新一遍皮肤
function PreviewMain.LoadCard(nCardID, fComplete, bChangeSkin)
    if Map.GetCurrentID() ~= 2 then return end

    local pCard = Preview.GetModel(PreviewType.main)
    if pCard and nCardID == PreviewMain.nCacheCardID then
        PreviewMain.HiddenCard(false)
        if bChangeSkin then
            local pItem = me:GetItem(nCardID)
            local pSkin = pItem:GetSlotItem(5)
            if pSkin then
                Preview.UpdateCharacterSkin(pSkin:AppearID())
            end
        end
        return
    end

    if not nCardID then return end
    Preview.Destroy(true)
    Preview.PreviewByCardAndWeapon(nCardID, -1 , PreviewType.main, true, function()
        if fComplete then fComplete() end
        UI.Call2('Main', 'UpdateGyroCard')
    end)

    PreviewMain.nCacheCardID = nCardID
end

function PreviewMain.DestroyCard()
    Preview.Destroy(true)
    PreviewMain.nCacheCardID = nil
end

function PreviewMain.HiddenCard(bHide)
    local pModel = Preview.GetModel(PreviewType.main)
    if pModel == nil then return end
    if pModel:GetModel() then
        pModel:GetModel():Hide(bHide)
    end
end

---是否激活陀螺仪
function PreviewMain.ActiveGyro(bActive)
    if not IsValid(PreviewMain.pBgActor) then
        return
    end
    if bActive then
        PreviewMain.pBgActor:SetState(UE4.EGyroState.Active)
    else
        PreviewMain.pBgActor:SetState(UE4.EGyroState.None)
    end
end

---模糊背景是否显示
function PreviewMain.SetBlurBgVisible(bVisible)
    if not IsValid(PreviewMain.pBgActor) then
        return
    end

    local bgWidget = PreviewMain.pBgActor:GetWidget()
    if bgWidget then
        if bVisible then
            WidgetUtils.HitTestInvisible(bgWidget.Blur)
        else
            WidgetUtils.Collapsed(bgWidget.Blur)
        end
    end
end

function PreviewMain.SetBgVisble(bVisible)
    if not IsValid(PreviewMain.pBgActor) then
        return
    end
    PreviewMain.pBgActor:SetActorHiddenInGame(not bVisible)
end



function PreviewMain.EnabledBGTick(bEnable)
    if not IsValid(PreviewMain.pBgActor) then
        return
    end

    local pBGComponent = PreviewMain.pBgActor.GyroWidget2
    if pBGComponent then
        if bEnable then
            pBGComponent:SetTickMode(UE4.ETickMode.Enabled)
        else
            pBGComponent:SetTickMode(UE4.ETickMode.Disabled)
        end
    end
end

---隐藏特效
function PreviewMain.HideEffect(bHide)

    --低端机直接不显示
    if UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() <= 0 then
        return
    end

    local pEffect = PreviewScene.GetActor(PreviewScene.SelectUIEffect)
    if not pEffect then return end
    pEffect:SetActorHiddenInGame(bHide)
end


