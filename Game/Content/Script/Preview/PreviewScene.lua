-- ========================================================
-- @File    : PreviewScene.lua
-- @Brief   : 场景预览
-- ========================================================


---@class PreviewScene 场景预览管理
---@field tbClasses table
PreviewScene = PreviewScene or { tbClasses = {} , tbScene = {}, sLastType = nil, tbCacheActor = {}, lightRot = nil}

PreviewScene.MainStreaming = {'Entry_06', "Entry_05"}

PreviewScene.bAsyncLoad = false

---逻辑模板
local tbTemplateLogic = {
    OnEnter     = function(self, fCallback)  end,
    OnLeave     = function(self)  end,
    OnLoading   = function(self)  end,
}

---设置光照方向
---@param rotation FRotator
function PreviewScene.SetLightDir(rotation)
    PreviewScene.lightRot = rotation
    PreviewScene.ModifyLight()
end

function PreviewScene.GetLightDir()
    return PreviewScene.lightRot or UE4.FRotator()
end


PreviewScene.SceneEffectName = "SceneEffect"
PreviewScene.LightActorName = "RoleLightActor"
PreviewScene.MainCameraActorName = "MainCameraActor"
PreviewScene.SelectUIEffect = "SelectUIEffect"

---缓存actor
function PreviewScene.CacheActor(sKey, pActor)
    --print('PreviewScene.CacheActor=======>', sKey, pActor:GetName())
    if not sKey or not IsValid(pActor) then return end
    PreviewScene.tbCacheActor[sKey] = pActor
end

function PreviewScene.RemoveActor(sKey)
    print('PreviewScene.RemoveActor=======>', sKey)
    if not sKey then return end
    PreviewScene.tbCacheActor[sKey] = nil
end

function PreviewScene.GetActor(sKey)
    return PreviewScene.tbCacheActor[sKey]
end


function PreviewScene.PrintLoadScene(bActive)
    local actives = UE4.UUMGLibrary.GetLoadStreamings(GetGameIns())
    for i = 1, actives:Length() do
        if bActive then
            if actives:Get(i):IsLevelVisible() then
                print("************ load scene:", actives:Get(i):GetWorldAssetPackageFName())
            end
        else
            print("************ load scene:", actives:Get(i):GetWorldAssetPackageFName())
        end
    end
end


function PreviewScene.HiddenAll()
    local actives = UE4.UUMGLibrary.GetLoadStreamings(GetGameIns())
    for i = 1, actives:Length() do
        actives:Get(i):SetShouldBeVisible(false)
    end
    UE4.UGameplayStatics.FlushLevelStreaming(GetGameIns())
end

---重置变量
function PreviewScene.Reset()
    PreviewScene.sLastType = nil
end

---是否在武器场景
---@return boolean
function PreviewScene.IsInWeaponScene()
    return PreviewScene.sLastType == PreviewType.weapon
end

---加载子地图，不切换
---@param InLevel string 场景名
---@param InCallback function 成功后的回调
function PreviewScene.LoadLevel(InLevel, InCallback, bShouldBlockOnLoad)
    local pLevel = UE4.UGameplayStatics.GetStreamingLevel(GetGameIns(), InLevel)

    if not pLevel then 
        if InCallback then InCallback() end
        return
    end

    pLevel.OnLevelShown:Clear()

    if pLevel:IsLevelVisible() then
        if InCallback then InCallback() end
        return
    end


    if bShouldBlockOnLoad == nil then bShouldBlockOnLoad = true end
    pLevel.bShouldBlockOnLoad = bShouldBlockOnLoad

    pLevel.OnLevelShown:Add(GetGameIns(), function()
        if InCallback then InCallback() end
    end)
    pLevel:SetShouldBeLoaded(true)
    pLevel:SetShouldBeVisible(true)
    UE4.UGameplayStatics.FlushLevelStreaming(GetGameIns())
end

---卸载子关卡
---@param InContext UE4.UObject WorldContext
---@param InLevel string 场景名
---@param InCallback function 完成后的回调
function PreviewScene.UnLoadLevel(InLevel, InCallback, bShouldBlockOnUnLoad)
    local pLevel = UE4.UGameplayStatics.GetStreamingLevel(GetGameIns(), InLevel)
    if not pLevel then 
        if InCallback then  InCallback() end
        return
    end
    if bShouldBlockOnUnLoad == nil then   bShouldBlockOnUnLoad = true end
    pLevel.bShouldBlockOnUnload = bShouldBlockOnUnLoad

    pLevel:SetShouldBeVisible(false)

    if InCallback then InCallback() end
end


--[[


]]
local CacheCallback = {tbCallback = {}}
function CacheCallback:Dispatch(nType)
    if self.tbCallback[nType] then
        self.tbCallback[nType]()
        self.tbCallback[nType] = nil
    end
end
function CacheCallback:Register(nType, fCallback)
    for _, pCallBack in pairs(self.tbCallback or {}) do
        if pCallBack then
            pCallBack()
        end
    end

    self.tbCallback = {}
    if nType then
        self.tbCallback[nType] = fCallback
    end
end

---类型切换
---@param sType PreviewType 
function PreviewScene.Enter(sType, fCallback)
    print('PreviewScene.Enter:', sType, PreviewScene.sLastType)
    
    local cfg = PreviewScene.tbScene[sType]
    if not cfg then 
        return 
    end

    CacheCallback:Register(sType, fCallback)

    local sLastType = PreviewScene.sLastType
    if sLastType == nil then
        PreviewScene.HiddenAll()
    end

    if sType == sLastType then
        CacheCallback:Dispatch(sType) 
        return 
    end

    if sLastType and PreviewScene.tbScene[sLastType] then
        local lastCfg =  PreviewScene.tbScene[sLastType]

        if lastCfg.sClass then
            PreviewScene.Class(lastCfg.sClass):OnLeave() 
        end

        if lastCfg.sScene ~= cfg.sScene then
            PreviewScene.UnLoadLevel(lastCfg.sScene, nil, true)
        end

        if lastCfg.sLightScene ~= cfg.sLightScene then
            PreviewScene.UnLoadLevel(lastCfg.sLightScene, nil, true)
        end
    end
    PreviewScene.sLastType = sType

    ---光照场景
    PreviewScene.LoadLevel(cfg.sLightScene, function()
        if cfg.tbLightRotation then
            local rotation = UE4.FRotator(cfg.tbLightRotation[1] or 0, cfg.tbLightRotation[2] or 0, cfg.tbLightRotation[3] or 0)
            PreviewScene.SetLightDir(rotation)
        end
    end, true)

    PreviewScene.LoadLevel(cfg.sScene, function()
        PreviewScene.ModifyScene(cfg)

        if cfg.sClass then
            PreviewScene.Class(cfg.sClass):OnEnter(function()
                CacheCallback:Dispatch(sType)
            end)
        else
            CacheCallback:Dispatch(sType)
        end
    end, true)
end


function PreviewScene.AsyncLoadMainMap()
    if UE4.UGMLibrary.WithEditor() then
        return
    end
    if PreviewScene.bAsyncLoad then return end
    PreviewScene.bAsyncLoad = true

    print('PreviewScene.AsyncLoadMainMap : start =============> ')
    UE4.UUMGLibrary.AsyncLoadMainMap()
    PreviewScene.UpdateCharacterCache()
end

function PreviewScene.ClearLoadMainMap()
    PreviewScene.bAsyncLoad = false
end

function PreviewScene.UpdateCharacterCache()
    if UE4.UGMLibrary.WithEditor() then
        return
    end
    UE4.UUMGStreamingSubsystem.GetAssetStreamingSubsystem():UpdateCharacterCache()
end


---后台缓存场景
function PreviewScene.BackgroundStreaming(tbScene)
    if not tbScene then return end
    for _, level in ipairs(tbScene) do
        local pLevel = UE4.UGameplayStatics.GetStreamingLevel(GetGameIns(), level)
        if pLevel and pLevel:IsLevelLoaded() == false then
            pLevel.bShouldBlockOnLoad = false
            pLevel:SetShouldBeLoaded(true)
            print('BackgroundStreaming:', level, pLevel)
        end
    end
end

---预加载场景
---@param sType PreviewType 
function PreviewScene.PreloadScene(sType)
    if UE4.UGMLibrary.WithEditor() then
        return
    end

    if not sType then return end
    local fLoad = function(t)
        local cfg = PreviewScene.tbScene[t]
        if not cfg then return end
    
        local tbSceneName = {}
    
        if cfg.sScene and cfg.sScene ~= ''  then
            table.insert(tbSceneName, cfg.sScene)
        end
    
        if cfg.sLightScene and cfg.sLightScene ~= '' then
            table.insert(tbSceneName, cfg.sLightScene)
        end
        if #tbSceneName <= 0 then return end
        PreviewScene.BackgroundStreaming(tbSceneName)
    end

    if type(sType) == 'table' then
        for _, t in ipairs(sType) do
            fLoad(t)
        end
    else
        fLoad(sType)
    end
end


function PreviewScene.ModifyScene(cfg)
    if not cfg then return end
    if cfg.sScene ~= 'Entry_05' then
        return
    end

    local findMesh = UE4.UUMGLibrary.FindActorByName(GetGameIns(), 'Env_mesh')
    if not findMesh then return end
    local pMesh = findMesh
    print('PreviewScene.ModifyScene :', pMesh, pMesh:GetName())

    if cfg.tbMeshScale then
        pMesh:SetActorScale3D(UE4.FVector(cfg.tbMeshScale[1] or 1, cfg.tbMeshScale[2] or 1, cfg.tbMeshScale[3] or 1))
    end

    if pMesh.StaticMeshComponent then
        if cfg.nRadius then
            pMesh.StaticMeshComponent:SetScalarParameterValueOnMaterials('Radius', cfg.nRadius)
        end
        if cfg.nTile then
            pMesh.StaticMeshComponent:SetScalarParameterValueOnMaterials('Tile', cfg.nTile)
        end
        if cfg.nLineRotate then
            pMesh.StaticMeshComponent:SetScalarParameterValueOnMaterials('Rotate', cfg.nLineRotate)
        end

        if cfg.nOffsetV then
            pMesh.StaticMeshComponent:SetScalarParameterValueOnMaterials('OffsetV', cfg.nOffsetV)
        end
    end
                    
    PreviewScene.ModifyEffect()
end

function PreviewScene.ModifyEffect()
    local sType = PreviewScene.sLastType
    if not sType then return end
    print('PreviewScene.ModifyEffect :', sType)

    local cfg = PreviewScene.tbScene[sType]
    if not cfg then return end

    if cfg.sScene ~= 'Entry_05' then
        return
    end

    local pEffect = PreviewScene.GetActor(PreviewScene.SceneEffectName)
    if IsValid(pEffect) then
        if cfg.tbEffectRotate then
            pEffect:SetActorHiddenInGame(false)
            pEffect:K2_SetActorRotation(UE4.FRotator(cfg.tbEffectRotate[1] or 0, cfg.tbEffectRotate[2] or 0, cfg.tbEffectRotate[3] or 0))

            pEffect.NiagaraComponent:SetNiagaraVariableFloat('size', cfg.nEffectSize)
            pEffect.NiagaraComponent:SetNiagaraVariableInt('X Count', cfg.nEffectXCount)
            pEffect.NiagaraComponent:SetNiagaraVariableVec3('XYZ Dimension', UE4.FVector(cfg.tbEffecteDimension[1] or 0, cfg.tbEffecteDimension[2] or 0, cfg.tbEffecteDimension[3] or 0))

        else
            pEffect:SetActorHiddenInGame(true)
        end
    end
end

function PreviewScene.ModifyLight()
    local rotation = PreviewScene.GetLightDir()
    if rotation == nil then return end

    local pLight = PreviewScene.GetActor(PreviewScene.LightActorName)

    print('PreviewScene.ModifyLight :', pLight)

    if IsValid(pLight) == false then return end

    local Component = pLight:K2_GetRootComponent()
    if Component and Component.Mobility ~= UE4.EComponentMobility.Movable then
        Component:SetMobility(UE4.EComponentMobility.Movable)
    end
    pLight:K2_SetActorRotation(rotation, true)
end


---注册Lua逻辑
---@param sClass string
function PreviewScene.Class(sClass)
    if sClass == nil then return tbTemplateLogic end
    if PreviewScene.tbClasses[sClass] then return PreviewScene.tbClasses[sClass] end;
    local tbLogic = Inherit(tbTemplateLogic);
    PreviewScene.tbClasses[sClass] = tbLogic;
    return tbLogic;
end

function PreviewScene.PlayDungeonsSeq(cameraIdx, bPoping)
    PreviewScene.Enter(PreviewType.Dungeons, function()
        local logic = PreviewScene.Class('Dungeons')
        if logic and logic.PlaySequence then
            if bPoping or PreviewScene.SkipDungeonsSeq then
                logic:PlaySequence(cameraIdx, true, nil, nil, 1)
                if PreviewScene.SkipDungeonsSeq then
                    local ui = UI.GetTop()
                    if ui and ui.Enter then
                        ui:PlayAnimation(ui.Enter)
                    end
                end
            else
                logic:PlaySequence(cameraIdx, true)
            end
        end
        PreviewScene.SkipDungeonsSeq = false
    end)
end

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---加载配置信息
function PreviewScene.LoadCfg()
    local tbInfo = LoadCsv("preview/scene_light.txt", 1)
    local bIOS = IsIOS()

    for _, tbLine in ipairs(tbInfo) do
       local sType = tbLine.Type
       local sClass = tbLine.Class
       PreviewScene.tbScene[sType] = { 
           sScene       = tbLine.Scene, 
           sLightScene  = tbLine.LightScene, 
           sClass       = sClass,
           tbMeshScale  = Eval(tbLine.Env_mesh_Scale),
           nRadius      = tonumber(tbLine.entry02_Line_Radius),
           nTile        = tonumber(tbLine.entry02_Line_Tile),
           tbLightRotation  = Eval(tbLine.RoleLighting_Rotation),
           nLineRotate  = tonumber(tbLine.entry02_Line_Rotate) or 5.5,
           nUnload = bIOS and 1 or (tonumber(tbLine.Unload) or 0),
           nOffsetV  = tonumber(tbLine.entry02_Line_OffsetV),

           ---特效参数
           tbEffectRotate = Eval(tbLine.e_Rotate),
           nEffectSize = tonumber(tbLine.e_size) or 0,
           nEffectXCount = tonumber(tbLine.e_x_count) or 0,
           tbEffecteDimension = Eval(tbLine.e_dimension)  or {0,0,0},
        }

        if sClass then
            require(string.format('Preview.Classes.%s', sClass))
        end
    end
end

if not SERVER_ONLY then
    PreviewScene.LoadCfg()
end