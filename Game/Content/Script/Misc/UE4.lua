-- ========================================================
-- @File    : UE4.lua
-- @Brief   : UE4 Gameplay相关操作封装
-- ========================================================

WithEditor = UE4.UGMLibrary.WithEditor();

---是否是移动平台
---@return boolean 是否是移动平台
function IsMobile()
    return UE4.UGameLibrary.IsMobilePlatform() or UE4.UGameLibrary.IsEditorMobile()
end

---是否是安卓平台
function IsAndroid()
    return UE4.UGameplayStatics.GetPlatformName() == 'Android'
end

---是否是IOS平台
function IsIOS()
    return UE4.UGameplayStatics.GetPlatformName() == 'IOS'
end

--- 裁剪
function SetClippingTeure(InImage,InPath,InPos,InScale,bMatch)
    SetTexture(InImage,InPath,bMatch)
    local Pos = UE4.FVector2D(InPos[1],InPos[2])
    UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InImage):SetPosition(Pos)
    local Size = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InImage):GetSize()
    UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InImage):SetSize(Size*InScale)

end


local function ConvertTexturePath(pImg, path)
    if not pImg then
        print('SetTexture Error: 请检查图片控件是否存在', pImg, path)
        return
    end

    if not path then
        print('SetTexture Error: 请检查资源ID是否正确', pImg:GetName(), path)
        return 
    end

    local isStrPath = type(path) == 'string'
    local sRealPath = isStrPath and Resource.GetByStrId(path) or nil

    if isStrPath and not sRealPath then
        return UE4.UKismetSystemLibrary.MakeSoftObjectPath(path)
    elseif sRealPath or type(path) == 'number' then
        if path == 0 then
            print('SetTexture Error: Invalid ID', pImg:GetName())
            return
        end
        if pImg and pImg.PaintingType and pImg.PaintingType ~= "" then
            local nPaintingID = Resource.GetPaintingID(path, string.lower(pImg.PaintingType))
            if nPaintingID and nPaintingID ~= 0 then 
                sRealPath = Resource.Get(nPaintingID)
            else
                print('SetTexture Error: 请检查Painting表是否配置对应ID', path, nPaintingID, pImg.PaintingType, pImg:GetName())
                return
            end
        else
            sRealPath = sRealPath or Resource.Get(path)
        end
        if sRealPath then
           return UE4.UKismetSystemLibrary.MakeSoftObjectPath(sRealPath)
        else
            print('SetTexture Error: 请检查资源表是否配置对应ID或者是否配置PaintingType', path, pImg:GetName())
            return
        end
    else
        return path
    end
end

function GetTexture(pImg, nID)
    local softPath = ConvertTexturePath(pImg, nID)
    if not softPath then return end
    return UE4.UGameAssetManager.GameLoadAsset(softPath)
end

---加载并设置图片
---@param pImg UImage 图片控件
---@param nID Integer 资源ID
---@param bMatch boolean 大小控制
function SetTexture(pImg, nID, bMatch)
    if WidgetUtils.bForceAsyncLoadTexture then
        AsynSetTexture(pImg, nID, bMatch)
        return
    end
    local softPath = ConvertTexturePath(pImg, nID)
    if not softPath then
        return
    end
    local pTexture = UE4.UGameAssetManager.GameLoadAsset(softPath)
    if pTexture then
        if pTexture:Cast(UE4.UPaperSprite) or pTexture:Cast(UE4.ULocalizedTexture) then
            pImg:SetBrushFromAtlasInterface(pTexture, bMatch)
        else
            pImg:SetBrushFromTexture(pTexture, bMatch)
        end
    end
end

---异步加载并设置图片
---@param pImg UImage 图片控件
---@param nID Integer 资源ID
---@param bMatch boolean 大小控制
function AsynSetTexture(pImg, nID, bMatch)
    if not pImg then return end

    local softPath = ConvertTexturePath(pImg, nID)
    if not softPath then
        return
    end
    if pImg.AsyncSetTexture then
        pImg:AsyncSetTexture(softPath)
    else
        UE4.UGameAssetManager.GameAsyncLoadAsset(softPath, {pImg, function(_, pTexture)
            if pTexture and pImg then
                if pTexture:Cast(UE4.UPaperSprite) or pTexture:Cast(UE4.UVtaSlateTexture) then
                    pImg:SetBrushFromAtlasInterface(pTexture, bMatch)
                else
                    pImg:SetBrushFromTexture(pTexture, bMatch)
                end
            end
        end})
    end
end

function SetBtnTexture(Btn, Path)
    if type(Path) == 'number' then
        if Path == 0 then
            return
        end
        Path = Resource.Get(Path)
    end
    if (not Path) or (not Path) then printf('SetBtnTexture: Error, Btn= %s, InPath= %s', Btn or 'nil', Path or 'nil' ) return end;
    if type(Path) == 'string' then
        Path = UE4.UKismetSystemLibrary.MakeSoftObjectPath(Path)
    end
    local pTexture = UE4.UGameAssetManager.GameLoadAsset(Path)
    if pTexture then
        UE4.UUMGLibrary.SetButtonImage(pTexture, Btn)
    end
end

---播放特效
---@param pContent UCanvasPanel 放置特效节点
---@param nID Integer   资源ID
---@param position FVector2D 位置
---@param bActive boolean   是否激活
function PlayEffect(pContent, nID, position , bActive)
    if not pContent then print('PlayEffect Content Is nil')  return end

    pContent:ClearChildren()
    local cfg = Resource.GetEffectCfg(nID)
    if not cfg or not cfg.sPath then return end

    local softPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(cfg.sPath .. '_C')
    UE4.UGameAssetManager.GameAsyncLoadAsset(softPath, {pContent:GetOuter(), function(_, loadClass)
        if not loadClass then return end
        local pWidget = NewObject(loadClass, pContent:GetOuter())
        if not pWidget or not pContent then return end
        pWidget.AutoActivate = false
        pContent:AddChild(pWidget)
        WidgetUtils.HitTestInvisible(pWidget)
        pWidget:ActivateSystem(true)
        local pSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(pWidget)
        if pSlot then
            pSlot:SetPosition(position or UE4.FVector2D(0, 0))
        end
    end})
end

---设置Button图片
function SetButtonTexture(InButton, InTexture)
end

---加载组件
---@param InPath string 路径
---@return UUserWidget 加载出来的组件
function LoadWidget(InPath)
    local pWidget = LoadUI(UE4.UKismetSystemLibrary.MakeSoftClassPath(InPath))
    if not pWidget then
        print("LoadWidget Error:", InPath, debug.traceback())
    end
    return pWidget
end

---返回主场景
function GoToMainLevel(pCall)
    if RunFromEntry then 
        Map.Open(2, nil, pCall)
    else
        GoToLoginLevel()
    end
end

---返回登录场景
function GoToLoginLevel()
    local call = function() 
        GuideLogic.SetCanBeginGuide(true)
        UI.CloseAll(true)
        Reconnect.ClearSettleInfo()
        Reconnect.SetConnectBreaken(false)
        me:Clear()
        UI.tbRecover = {}
        DataPost.StopGetRTL()
        ---可能本身就在登录场景
        UE4.UMapManager.Open(1, '')
    end
    UE4.Timer.Add(0.01, call);
end

---复制Vector
---@param pVector FVector 原始值
---@return FVector 复制体
function CopyVector(pVector)
    return UE4.FVector(pVector.X, pVector.Y, pVector.Z)
end

---设置相机的位置和旋转
---@param InContext UObject WorldContext
---@param InPosition FVector 位置
---@param InRotate FRotator 旋转 
function SetCameraPosition(InContext, InPosition, InRotate, BlendTime)
    local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(InContext, 0)
    if not pCameraManger then return end
    local FirstCamera = pCameraManger:Cast(UE4.AThirdPersonPlayerCameraManager)
    if not FirstCamera then return end
    FirstCamera:ChangeCurrentViewTargetTransformWithBlend(UE4.FVector(0,0,0), UE4.FRotator(0,0,0), InPosition, InRotate or UE4.FRotator(0, 0, 0), BlendTime or 0, 0)
end

--- 按钮绑定事件
---@param pBtn UButton
---@param fClickEvent function 
function BtnAddEvent(pBtn, fClickEvent)
    local pOuter = UE4.UUMGLibrary.GetWidgetOuter(pBtn)
    if pBtn and pOuter then
        pBtn.OnClicked:Add(pOuter, fClickEvent)
    end
end

--- 按钮移除绑定事件
---@param pBtn UButton
---@param fClickEvent function 
function BtnRemoveEvent(pBtn, fClickEvent)
    if not pBtn or not fClickEvent then return end
    local pOuter = UE4.UUMGLibrary.GetWidgetOuter(pBtn)
    if pOuter  then
        pBtn.OnClicked:Remove(pOuter, fClickEvent)
    end
end

--- 按钮清除绑定事件
---@param pBtn UButton
---@param fClickEvent function 
function BtnClearEvent(pBtn)
    if pBtn then
        pBtn.OnClicked:Clear()
    end
end

---停止相机动画
function StopAllCustomAnimation(InContext)
    local pCameraMgr = UE4.UGameplayStatics.GetPlayerCameraManager(InContext, 0)
    if pCameraMgr then 
        pCameraMgr:StopAllCustomAnimation()
    end
end

---获取游戏GameInstance
function GetGameIns()
    if GGameInstance then return GGameInstance end

    local pSubSystem = UE4.UUIGameInstanceSubsystem.Get()
    if pSubSystem then
        return pSubSystem:GetApp()
    end
    return nil
end

---
---是否是玩家
---@param InPlayer AActor
---@return boolean
---
function IsPlayer(InPlayer)
    if (not IsValid(InPlayer)) then
        return false
    end

    local Character = InPlayer:Cast(UE4.AGameCharacter)
    return Character ~= nil and Character.Type == UE4.ECharacterType.Player
end

---
---是否是AI
---@param InAI AActor
---@return boolean
---
function IsAI(InAI)
    if (not IsValid(InAI)) then
        return false
    end

    local Character = InAI:Cast(UE4.AGameCharacter)
    return Character ~= nil and Character.Type == UE4.ECharacterType.AI
end

---
---是否是召唤物
---@param InAI AActor
---@return boolean
---
function IsSummon(InSummon)
    if (not IsValid(InSummon)) then
        return false
    end

    local Character = InSummon:Cast(UE4.AGameCharacter)
    return Character ~= nil and Character.Type == UE4.ECharacterType.Summon
end

---
---检查角色类型
---@param InCharacter UE4.AGameCharacter
---@param CharacterType UE4.ECharacterType
---@return boolean
---
function CheckCharacterType(InCharacter, CharacterType)
    if (not IsValid(InCharacter)) then
        return false
    end

    if (CharacterType == nil) then
        return false
    end

    local Character = InCharacter:Cast(UE4.AGameCharacter)
    return Character ~= nil and Character.Type == CharacterType
end

---
---对象是否有效
---@param Object Any 包含所有Lua对象类型或UObject对象类型
---@return boolean
---
function IsValid(Object)
    if Object == nil then return false end
    return UE4.UObject.IsValid(Object)
end

function UINiagaraPlay(InKey,WorldContextObject,InLoc)
    local Niagara =UE4.UUINiagara.GetNiagaraValue(InKey)
    UE4.UGameParticleBlueprintLibrary.SpawnGameNiagaraAtLocation(WorldContextObject, nil, Niagara,InLoc)
end

function GetUINiagaraPlay(InKey,InName,InLoc)
    local Niagara = UE4.UUINiagara.GetNiagarasValue(InKey,InName)
    local tbTrans = UE4.UUINiagara.GetNiagaraTrans(InKey,InName)
    return Niagara,InLoc + tbTrans:ToTable()[1].Translation
end

function GetUINiagaraDelay(InKey)
    -- GetUINiagaras(InKey)
    return UE4.UUINiagara.GetDelay(InKey)
end

function GetUINiagaraValue(InKey)
    return UE4.UUINiagara.GetNiagaraValue(InKey)
    -- body
end

function GetUINiagaras(InKey,InName)
    local NiagaraVal = UE4.UUINiagara.GetNiagarasValue(InKey,InName)
    return NiagaraVal
end


---向屏幕输出信息
function PrintScreen(sTxt, pColor, nDuration)
    pColor = pColor or UE.FLinearColor(1, 1, 1, 1)
    nDuration = nDuration or 100
    UE.UKismetSystemLibrary.PrintString(nil, sTxt, true, false, pColor, nDuration)
end

function DestroyListObj(pList)
    --[[
    if not pList then return end
    local allObj = pList:GetListItems()
    for i = 1, allObj:Length() do 
        local obj = allObj:Get(i);
        if obj then 
            obj:Destroy() 
        end
    end
    ]]
end

function DestroyListObjInWidget(widget)
    --[[
    if not widget then
        return
    end
    if IsEditor then
        local lists = UE4.UUMGLibrary.GetListsInWidget(widget)
        for i = 1, lists:Length() do
            if lists:Get(i):GetNumItems()>0 then
                if not widget.tbCacheListView or not widget.tbCacheListView[lists:Get(i)] then
                    print(string.format("Lua error message:\n%s界面的%s控件有内存泄露,请在初始化时调用基类的DoClearListItems方法", 
                    UE4.UGameLibrary.GetWidgetClassName(widget), lists:Get(i):GetName() ))
                end
            end
        end
    end
    
    for pList, _ in pairs(widget.tbCacheListView or {}) do 
        DestroyListObj(pList) 
    end
    
    widget.tbCacheListView = nil
    ]]
end

function DestroyUITable(widget)
    --[[    
    if (type(widget) ~= "table") then return end 

    for key, v in pairs(widget) do 
        if type(v) == "table" then 
            widget[key] = nil
        end
    end
    ]]
end

---息屏控制
function SetScreenSaver(bSaver)
    if not IsMobile() then return end
    local bNowState = UE4.UKismetSystemLibrary.IsScreensaverEnabled()
    if bNowState == bSaver then return end
    UE4.UKismetSystemLibrary.ControlScreensaver(bSaver)
end