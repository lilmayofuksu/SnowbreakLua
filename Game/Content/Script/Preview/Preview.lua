-- ========================================================
-- @File    : Preview.lua
-- @Brief   : 模型预览
-- ========================================================

---@class Preview 模型预览
Preview = Preview or { var = {nTimer = nil, nLinkTimer = nil}}
local var = Preview.var

require 'Preview.PreviewMain'

---通用
Preview.COMMONID = 999999 
Preview.DEFAULT_TYPE = 'DEFAULT'

---预览类型缓存 模型和相机
---@class CachePreviewType
local CachePreviewType = { sModelType = nil, sCameraType = nil}

function Preview.GetCameraType()
    return CachePreviewType.sCameraType or Preview.DEFAULT_TYPE
end

--#region

---@class CacheModel 缓存创建的预览模型
local CacheModel = { tbModel = {}, tbDestroy = {} }

---获取第一个
function CacheModel:Get(sType)
    if self.tbModel[sType] then return self.tbModel[sType][1] end
end

---添加模型
---@param sType PreviewType
---@param pModel AActor
function CacheModel:Add(sType, pModel)
    self.tbModel[sType] =  self.tbModel[sType] or {}
    table.insert(self.tbModel[sType], pModel)
end

---移除模型
---@param sType PreviewType
function CacheModel:Remove(sType)
    if not sType then return end
    local tbRemove = self.tbModel[sType] or {}
    for _, pModel in ipairs(tbRemove) do
       self:Destroy(pModel)
    end
    self.tbModel[sType] = nil
end

---移除所有
function CacheModel:RemoveAll()
   for sType, _ in pairs(self.tbModel) do  self:Remove(sType) end
   self.tbModel = {}
end

function CacheModel:Destroy(pModel)
    if not IsValid(pModel) then return end
    pModel:Clear()
    pModel:K2_DestroyActor()

    -- if pModel:GetModel() then
    --     pModel:GetModel():Hide(true)
    --     table.insert(self.tbDestroy, pModel)
    -- else
    --     pModel:K2_DestroyActor()
    -- end

    -- if self.nDestroyTimer then return end

    -- self.nDestroyTimer = UE4.Timer.Add(3, function()
    --     for _, m in ipairs(self.tbDestroy or {}) do
    --         if IsValid(m) then
    --             m:Clear()
    --             m:K2_DestroyActor()
    --         end
    --     end
    --     self.nDestroyTimer = nil
    --     self.tbDestroy = {}
    -- end)
end

--#endregion
-----------------------------------------------------------------

---取消Timer
---@param nTimer Integer 
function Preview.CancelTimer()
    if var.nTimer then UE4.Timer.Cancel(var.nTimer) var.nTimer = nil end
end

---获取镜头配置ID
---@param nItemID Integer 道具ID
function Preview.GetCameraIDByItemID(nItemID)
    if nItemID == Preview.COMMONID then return nItemID  end
    local pItem = UE4.UItemLibrary.GetItem(nItemID)
    if not pItem then return nil end
    return Preview.GetCameraIDByItemType(pItem.Type, pItem:TemplateId())
end

---获取镜头配置ID
---@param nItemType EItemType
---@param nTemplateID Integer
function Preview.GetCameraIDByItemType(nItemType, nTemplateID)
    if nItemType == UE4.EItemType.CharacterCard then
       return UE4.UItemLibrary.GetCharacterAtrributeTemplate(nTemplateID).UICameraID
    elseif nItemType == UE4.EItemType.Weapon then
       return UE4.UItemLibrary.GetWeaponTemplate(nTemplateID).UICameraID
    end
    return nil
end

---获取当前显示的模型
---@param sType PreviewType 预览类型
function Preview.GetModel(sType)
    sType = sType or CachePreviewType.sModelType
    return sType and CacheModel:Get(sType) or nil
 end


---播放相机动画
---@param nCameraID Integer
---@param sFromType PreviewType
---@param sToType PreviewType
local function PlayCameraAnim(nCameraID, sFromType, sToType)
        local pCameraInfo = UE4.UUICameraLibrary.GetCameraInfo(nCameraID)
        if not pCameraInfo.CameraAnimMetaDataInfo then return end
        local pLoadObj = UE4.UGameAssetManager.GameLoadAsset(pCameraInfo.CameraAnimMetaDataInfo)
        if not pLoadObj then return end

        local playList = UE4.UUICameraLibrary.GetPlayList(nCameraID, sFromType, sToType)
        local nLength = playList:Length()
        if nLength < 2 then return end

        local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(GetGameIns(), 0)
        if not pCameraManger then return end

        local nPlayIndex = 1
        
        local fPlay;
        fPlay = function()
            local nStart = playList:Get(nPlayIndex)
            local nEnd = playList:Get(nPlayIndex + 1)
            pCameraManger:AddCustomCameraAnimation(pLoadObj, nStart, nEnd)
            nPlayIndex = nPlayIndex + 1
            
            if nPlayIndex < nLength then
                local nTime = pLoadObj:GetAnimationPathTotalTime(nStart, nEnd)
                var.nLinkTimer = UE4.Timer.Add(nTime, function()
                    var.nLinkTimer = nil
                    fPlay() 
                end)
            end
        end
        fPlay()
end

---播放特殊镜头ID的动画
---@param nCameraID Integer 镜头配置ID
---@param sToType PreviewType 功能类型
function Preview.PlayCameraAnimByCfgByID(nCameraID, sToType)
    PlayCameraAnim(nCameraID, Preview.DEFAULT_TYPE, sToType)
end

---播放特殊镜头ID的动画
---@param nID Integer 道具ID
---@param sCameraType PreviewType 功能类型
function Preview.PlayCameraAnimByCallback(nID, sToType, fCallback)
    local nCameraID = Preview.GetCameraIDByItemID(nID)
    if not nCameraID then return end
    local sFromType = CachePreviewType.sCameraType or Preview.DEFAULT_TYPE
    local nAnimLength = UE4.UUICameraLibrary.GetCameraAnimTime(nCameraID, sFromType, sToType)
    if nAnimLength > 0 then
        var.nTimer = UE4.Timer.Add(nAnimLength, function()  var.nTimer = nil if fCallback then fCallback() end end)
    else
        if fCallback then fCallback() end
    end

    CachePreviewType.sCameraType = sToType
    PlayCameraAnim(nCameraID, sFromType, sToType)
end


---获取模型位置信息
---@param nItemType EItemType 道具类型
---@param nTemplateID Integer 道具模板ID
---@param sTargetType PreviewType 预览类型
---@return FUICameraInfoItem
function Preview.GetPreviewModelCfg(nItemType, nTemplateID, sTargetType)
    local nCameraID = Preview.GetCameraIDByItemType(nItemType, nTemplateID)
    if not nCameraID then return end
    return UE4.UUICameraLibrary.GetCameraInfoItem(nCameraID, sTargetType)
end


---根据道具ID显示模型
---@param nID Integer 道具ID
---@param sToType PreviewType 类型
---@param bPlayCameraAnim boolean 是否播放相机动画
---@param fComplete function 加载完成回调
function Preview.PreviewByItemID(nID, sToType, bPlayCameraAnim, fComplete)
    local pItem = me:GetItem(nID)
    if not pItem then return end
    local nCameraID = Preview.GetCameraIDByItemID(nID)
    if not nCameraID then return end
    Preview.Destroy()

    ---加载模型
    local sModelFromType = CachePreviewType.sModelType or Preview.DEFAULT_TYPE
    local ModelInfo = UE4.UUICameraLibrary.GetPreviewModelInfo(pItem.Type, pItem:TemplateId(), nCameraID, sModelFromType, sToType)

    local pCreateModel = nil

    if fComplete then
        pCreateModel = UE4.UPreviewLibrary.PreviewByItemByCallback(GetGameIns(), nID, ModelInfo, {GetGameIns(), function()
            print('Preview.PreviewByItemID Complate : ', nID, sToType)
           if fComplete then fComplete() end
            
        end})
    else
        pCreateModel = UE4.UPreviewLibrary.PreviewByItem(GetGameIns(), nID, ModelInfo)
    end

    PreviewScene.SetLightDir(ModelInfo.LightRotation)
    CachePreviewType.sModelType = sToType
    CacheModel:Add(sToType, pCreateModel)

    ---相机动画
    if bPlayCameraAnim ~= false then
        local sCameraFromType = CachePreviewType.sCameraType or Preview.DEFAULT_TYPE
        PlayCameraAnim(nCameraID, sCameraFromType, sToType)
        CachePreviewType.sCameraType = sToType
    end
end

---根据GDPL显示模型
---@param nItemType EItemType
---@param g Integer
---@param d Integer
---@param p Integer
---@param l Integer
---@param sToType PreviewType 功能类型
---@param nLevel Integer 等级信息
---@param fComplete function 加载完成回调
function Preview.PreviewByGDPL(nItemType, g, d, p, l, sToType, nLevel, bPlayCameraAnim, fComplete)
    local pDefaultItem = me:GetDefaultItem(g, d, p, l, 1)
    if not pDefaultItem then return end
    Preview.PreviewByItemID(pDefaultItem:Id(), sToType, bPlayCameraAnim, fComplete)
end

---根据道具ID显示模型
---@param nID Integer 道具ID
---@param sToType PreviewType 功能名称
---@param fComplete function 加载完成回调
function Preview.PreviewByCardAndWeapon(nID, nWeaponID, sToType, bPlayCameraAnim, fComplete)
    local pItem = me:GetItem(nID)
    if not pItem then return end
    local nCameraID = Preview.GetCameraIDByItemID(nID)
    if not nCameraID then return end
    Preview.Destroy()

    local sModelFromType = CachePreviewType.sModelType or Preview.DEFAULT_TYPE
    local ModelInfo = UE4.UUICameraLibrary.GetPreviewModelInfo(pItem.Type, pItem:TemplateId(), nCameraID, sModelFromType, sToType)

    local pCreateModel = nil
    if fComplete then
        pCreateModel = UE4.UPreviewLibrary.PreviewCardAndWeaponIDByCallback(GetGameIns(), nID, nWeaponID, ModelInfo, {GetGameIns(), function()
            if fComplete then fComplete() end
         end})
    else
        pCreateModel = UE4.UPreviewLibrary.PreviewCardAndWeaponID(GetGameIns(), nID, nWeaponID, ModelInfo)
    end
    if not pCreateModel then return end

    PreviewScene.SetLightDir(ModelInfo.LightRotation)
    CacheModel:Add(sToType, pCreateModel)
    CachePreviewType.sModelType = sToType

    if bPlayCameraAnim ~= false then
        local sCameraFromType = CachePreviewType.sCameraType or Preview.DEFAULT_TYPE
        PlayCameraAnim(nCameraID, sCameraFromType, sToType)
        CachePreviewType.sCameraType = sToType
    end
end

---根据怪物ID显示怪物模型
---@param ID Integer 怪物ID
---@param sToType PreviewType 功能名称
---@param pos UE4.FVector 位置
---@param rot UE4.FRotator 旋转
---@param scale UE4.FVector 缩放
function Preview.PreviewByMonsterID(ID, sToType, pos, rot, scale)
    Preview.Destroy()
    local ModelInfo = UE4.FPreviewModelInfo()
    ModelInfo.Position = pos
    ModelInfo.StartRotation = rot
    ModelInfo.Scale = scale
    ModelInfo.AnimType = UE4.EUIWidgetAnimType.Default
    local pCreateModel = UE4.UPreviewLibrary.PreviewByMonsterID(GetGameIns(), ID, ModelInfo)
    CachePreviewType.sModelType = sToType
    CacheModel:Add(sToType, pCreateModel)
end


---显示模型
---@param g Integer
---@param d Integer
---@param p Integer
---@param l Integer
---@param pos UE4.FVector
---@param rot UE4.FRotator
---@param scale UE4.FVector
function Preview.ShowModel(nItemType, g, d, p, l, pos, rot, scale, animType)
    local nTemplateID = UE4.UItemLibrary.GetTemplateId(g, d, p, l)
    local pModelInfo = UE4.FPreviewModelInfo()
    pModelInfo.Position = pos or UE4.FVector(0, 0, 0)
    pModelInfo.StartRotation = rot or UE4.FRotator(0, 0, 0)
    pModelInfo.Scale = scale or UE4.FVector(1, 1, 1)
    pModelInfo.AnimType = (animType or UE4.EUIWidgetAnimType.Default)
    local pCreateModel = UE4.UPreviewLibrary.PreviewByGDPL(GetGameIns(), nItemType, nTemplateID, pModelInfo)
    local sToType = Preview.DEFAULT_TYPE
    CacheModel:Add(sToType, pCreateModel)
    CachePreviewType.sModelType = sToType
end

---删除模型
---@param bAll boolean 是否删除所有模型
function Preview.Destroy(bAll)
    Preview.CancelTimer()
    if var.nLinkTimer then UE4.Timer.Cancel(var.nLinkTimer) var.nLinkTimer = nil end
    if bAll then 
        CacheModel:RemoveAll()
    else  
        CacheModel:Remove(CachePreviewType.sModelType)
    end
end

---更新武器
---@param nID Integer 武器ID
function Preview.UpdateWeapon(nID)
    local pModel = Preview.GetModel()
    if pModel and pModel:GetModel() then
        pModel:GetModel():UpdateWeapon(nID)
    end
end

---隐藏武器
---@param bHide boolean 是否隐藏
function Preview.HideWeapon(bHide)
    local pModel = Preview.GetModel()
    if pModel and pModel:GetModel() then
        pModel:GetModel():HideWeapon(bHide)
    end
end

---更新皮肤
---@param InTemplate Integer 模板ID
function Preview.UpdateCharacterSkin(InTemplate)
    if not InTemplate then
        return
    end
    local pModel = Preview.GetModel()
    if pModel and pModel:GetModel() then
        pModel:GetModel():UpdateCharacterSkin(InTemplate)
    end
end

---修正武器位置
function Preview.FixPosition()
    local pModel = Preview.GetModel(PreviewType.weapon)
    if pModel and pModel:GetModel() then pModel:GetModel():FixPosition() end
end


---日志输出
function Preview.Print()
    print('预览信息')
    Dump(CachePreviewType)
    Dump(CacheModel.tbModel)
end