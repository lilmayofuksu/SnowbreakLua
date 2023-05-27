-- ========================================================
-- @File    : umg_photograph.lua
-- @Brief   : 角色特写
-- ========================================================

---@class tbClass : UUserWidget
---@field ListRole UListView
---@field SliderLight USlider
---@field TxtBoxFOV UEditableTextBox
local tbClass = Class("UMG.BaseWidget")

local DefaultLight = 195

function tbClass:OnInit()
    WidgetUtils.Collapsed(self.ListRole)
    BtnAddEvent(self.BtnReset, function() self:ResetPos() end)
    BtnAddEvent(self.BtnChangeRole, function() 
        if self.ListRole:IsVisible() then
            WidgetUtils.Collapsed(self.ListRole)
        else
            WidgetUtils.Visible(self.ListRole) 
        end
    end)
    self.Factory = Model.Use(self);
    self.ListRole.BP_OnItemClicked:Add(self, function(pList, pItem) self:OnClick(pItem)  end)
    self.SliderLight.OnValueChanged:Add(self, function(Slider, Value)  self:UpdateLight(Value) end)

    self.TxtBoxFOV.OnTextCommitted:Add(self, function(pBox, Value)  self:GetOwningPlayer():FOV(tonumber(Value) or 35) end)
end

function tbClass:OnOpen()
    --DataTable'/Game/UI/UMG/Photograph/TestCharacterCfg.TestCharacterCfg'
    local SoftPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath('/Game/UI/UMG/Photograph/TestCharacterCfg.TestCharacterCfg')
    local AllTestCharacter = UE4.UTestLibrary.GetAllTestCharacter(SoftPath)

    print('test cards num:',  AllTestCharacter:Length())

    for i = 1, AllTestCharacter:Length() do
        local Test = AllTestCharacter:Get(i)

        local bSelect = false
        if i == 1 then
            bSelect = true
            self.pCard = Test
        end
        local tbParam = { pCard = Test, fClick = self.OnSelect, bSelect = bSelect}
        local pObj = self.Factory:Create(tbParam)
        if bSelect then
            self.pObj = pObj
        end
        self.ListRole:AddItem(pObj);
    end

    PreviewScene.Enter(PreviewType.role_lvup, function()  self:OnLoad() end)
end

function tbClass:OnLoad()
    self:SetFov() 
    self:ShowCard()
    self.Interaction:Init(self) 
    self:UpdateLight(DefaultLight)
end

function tbClass:UpdateLight(nAngle)
    self.SliderLight:SetValue(nAngle)
    local LightArray = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.ADirectionalLight)
    for i = 1, LightArray:Length() do
       local pPointLight = LightArray:Get(i)
        pPointLight:K2_GetRootComponent().Mobility = UE4.EComponentMobility.Movable
       local Now = pPointLight:K2_GetActorRotation()
        Now.Yaw = nAngle
       pPointLight:K2_SetActorRotation(Now)
    end
end

function tbClass:UpdateLightArgs(nX)
    local LightArray = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.ADirectionalLight)
    for i = 1, LightArray:Length() do
        local pPointLight = LightArray:Get(i)
        local nValue = (nX - self.MinX) / (self.MaxX - self.MinX)
        local nPercent = UE4.UKismetMathLibrary.FClamp(nValue, 0, 1)
        local nD = Lerp(self.MinDistanceValue, self.MaxDistanceValue, nPercent)
        pPointLight.LightComponent:SetDynamicShadowDistanceMovableLight(nD)
        local nS = Lerp(self.MinScale, self.MaxScale, nPercent)
        pPointLight.LightComponent:SetCascadeBoundScale(nS)
    end
end


function tbClass:OnClick(pItem)
    if self.pObj == pItem then return end
    if self.pObj and self.pObj.pItem then
        self.pObj.pItem:OnSelect(false)
    end
    self.pObj = pItem
    if self.pObj.pItem then
        self.pObj.pItem:OnSelect(true)
    end

    self.pCard = self.pObj.Data.pCard
    self:ShowCard()
    WidgetUtils.Collapsed(self.ListRole)
end


function tbClass:OnClose()
   self:Test()
end

function tbClass:Test()
    self:Clear()
end

function tbClass:ShowCard()
    if not self.pCard then return end
    self:LoadModel()
    self.TxtChangename:SetText(self.pCard.ShowName)
end

function tbClass:LoadModel()
    if self.pCard == nil then return end
    self:Clear()

    UE4.UTestLibrary.LoadModel(self, self.pCard, self.CacheActors)

    if self.CacheActors:Length() == 0 then
        return
    end

    local Role = self.CacheActors:Get(1)

    if Role then
        Role:K2_SetActorRotation(UE4.FRotator(0, 180, 0))
        self.Interaction:SetActor(Role)
    end
end


function tbClass:SetFov()
    local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)

    self.DefaultFov = 35--pCameraManger:GetFOVAngle()
    self.TxtBoxFOV:SetText(self.DefaultFov)
end


function tbClass:ResetPos()
    self:ShowCard()
    self.SliderLight:SetValue(DefaultLight)
    self:GetOwningPlayer():FOV(self.DefaultFov)
    self.TxtBoxFOV:SetText(self.DefaultFov)
    self:UpdateLight(DefaultLight)
end

return tbClass