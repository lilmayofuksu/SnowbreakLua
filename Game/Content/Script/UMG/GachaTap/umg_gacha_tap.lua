-- ========================================================
-- @File    : umg_gacha_tap.lua
-- @Brief   : 抽奖
-- ========================================================

---@class tbClass
---@field pGachaActor AActor
---@field Touch UBorder
local tbClass = Class("UMG.BaseWidget")

---抽奖表现流程
local STAGE = {}
STAGE.Begin     = 0
STAGE.CircleSpread = 1 
STAGE.Spread    = 2 ---扩散开
STAGE.Click     = 3 ---点击物品过程

local CacheInfo = {}


local DisplayData = nil

local DebugOneData = {{1,1,1,1}}
local DebugTenData = {{1,1,1,1}, {1,1,2,1}, {1,2,1,1},{1,2,2,1}, {1,3,1,1}, {1,4,2,1},{1,5,2,1}, {1,7,1,1}, {1,8,2,1}, {1,6,1,1}}
local DebugTenWeaponData = {{2,3,1,1}, {2,1,2,1}, {2,1,3,1},{2,1,4,1}, {2,1,5,1}, {2,1,6,1},{2,1,7,1}, {2,1,8,1}, {2,1,9,1}, {2,1,10,1}}

---抽奖禁止ESC
function tbClass:CanEsc()  return false end

local myLog = function(...)
    print('Gacha Tap ******:', ...)
end

local fClampQuality = function(c)
    --- 3 4 5
    c = c - 3
    return UE4.UKismetMathLibrary.Clamp(c, 0, 2)
end

function tbClass:OnInit()
    self.bPlayEnd = false
    self.Touch.OnMouseButtonDownEvent:Bind(self, tbClass.Down)
    self.Touch.OnMouseMoveEvent:Bind(self, tbClass.Move)
    self.Touch.OnMouseButtonUpEvent:Bind(self, tbClass.Up)

    WidgetUtils.HitTestInvisible(self.BtnNext)
    WidgetUtils.Collapsed(self.TxtInfo)

    BtnAddEvent(self.BtnSkip, function()
        UE4.UWwiseLibrary.ClearSequcneWwiseComponents(true)
        UE4.UVoiceManager.Stop(1000, false)
        local pParticlSys = UE4.UParticleSystemManager.GetPtr()
        if pParticlSys then
            pParticlSys:DestroyAll_UI()
        end
        WidgetUtils.Collapsed(self.BtnSkip)
        WidgetUtils.Collapsed(self.Node)

        if self.pGachaActor then
            self.pGachaActor.OnSpreadEnd:Clear()
        end
        self.nShowIndex = 100
        self.bShowing = false
        WidgetUtils.Collapsed(self.BtnNext)
        self:Next()
    end)

    BtnAddEvent(self.BtnNext, function()
        local nJumpCD = 2
        if self.pGachaActor then
            nJumpCD = self.pGachaActor.JumpCD
        end

        local nNowTime  = UE4.UKismetSystemLibrary.GetGameTimeInSeconds(self)
        if self.nLastClickTime then
            if nNowTime - self.nLastClickTime < nJumpCD then
                return
            end
        end

        self.nLastClickTime = nNowTime
        self:Next() 
    end)

    WidgetUtils.Visible(self.BtnSkip)
end

function tbClass:Down(MyGeometry, InTouchEvent)
    if self.bTrigger then
        return UE4.UWidgetBlueprintLibrary.Handled()
    end
    self.nNow = 0
    self.nTarget = 0
    self.bDown = true
    self.DownY = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent).Y
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:Move(MyGeometry, InTouchEvent)
    if not self.bDown or self.bTrigger or not self.pGachaActor then
        return UE4.UWidgetBlueprintLibrary.Handled()
    end
    local nY = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent).Y
    local nDis = (nY - self.DownY) * 0.005
    if nDis < 0 then nDis = 0 end
    if nDis > 1 then nDis = 1 end
    if nDis == 1 then
        self.bTrigger = true
        WidgetUtils.Collapsed(self.Node)
    end
    self.nTarget = nDis
    return UE4.UWidgetBlueprintLibrary.Handled() 
end

function tbClass:Up(MyGeometry, InTouchEvent)
    if self.bTrigger then
        return UE4.UWidgetBlueprintLibrary.Handled()
    else
        self.nTarget = 0
        WidgetUtils.HitTestInvisible(self.Node)
    end

    self.bDown = false
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:SpawnActor()
    if self.pGachaActor then return end
    local World = self:GetWorld()
    local ActorClass = UE4.UClass.Load("/Game/UI/UMG/GachaTap/BP_GachaActor.BP_GachaActor_C")
    if not World or not ActorClass then return end
    self.pGachaActor = World:SpawnActor(ActorClass)
end

function tbClass:GetEffectIndex(sIdx)
    if not sIdx or not self.tbPointMap then return -1 end
    return self.tbPointMap[sIdx] or -1
end

function tbClass:OnOpen()
    self.bCleaned = false
    DisplayData = Gacha.tbResult

    if DisplayData == nil then return end

    self.bCircleShow = true
    PlayerSetting.MuteMusic(true)
    Audio.PlaySounds(3013)

    self.bShowing = false
    self.nTarget = 0
    self.nNow = 0
    self.bSuc = false
    WidgetUtils.HitTestInvisible(self.Node)
    WidgetUtils.SelfHitTestInvisible(self)
    self.bTrigger = false

    ---当前显示索引
    self.nShowIndex = 1

    self:SpawnActor()

    if self.pGachaActor then
         self.pGachaActor.OnSpreadEnd:Add(self, function()
                self.pGachaActor:SetStage(STAGE.Click)
        end)

        self.pGachaActor.BlackEnd:Add(self, function()
            if not self.bPlayEnd then
                self:ShowItemInfo()
                WidgetUtils.Visible(self.BtnNext) 
            end
        end)

        ---计算品质
        --[[
            在进行扭蛋抽奖特效表现时，仅会依据武器和角色的品质来进行判定。
            1.SSR品质角色和武器任一≥1时，显示为金色。
            2.SSR品质和武器全部=0，且SR品质角色和武器≥1时，显示为紫色。
            3.非1和2则为蓝色。
        ]]
        local tbData = DisplayData or {}
        self.nMaxCount = #tbData
        self.tbPointMap = {}

        ---单抽
        if self.nMaxCount == 1 then
            local g, d, p, l = table.unpack(tbData[1])
            local pTemplate =  UE4.UItem.FindTemplate(g, d, p, l)
            self.tbPointMap['2'] = fClampQuality(pTemplate.Color)
        else
            local tb5Point = self:Shuffle({'2', '3', '11'})
            local tb4Point = self:Shuffle({'4', '5', '6', '7', '9', '10', '12'})
            for _, v in ipairs(tb5Point) do
                table.insert(tb4Point, 1, v)
            end
            local tbTempData = {}
            for nIdx, GDPL in ipairs(tbData) do
                local g, d, p, l = table.unpack(GDPL)
                local pTemplate =  UE4.UItem.FindTemplate(g, d, p, l)
                local nColor = pTemplate.Color
                table.insert(tbTempData, {nIdx = nIdx, nColor = nColor})
            end
            table.sort(tbTempData, function(a, b) return a.nColor > b.nColor end)
            for idx, v in ipairs(tbTempData) do
                self.tbPointMap[tb4Point[idx]] = fClampQuality(v.nColor)
            end
        end
        self.pGachaActor:SetStage(STAGE.Begin)
    end
end

function tbClass:Shuffle(t)
    local tab ={}
    local index = 1
    while #t ~= 0 do
        local n = math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index = index+1
        end
    end
    return tab
end

function tbClass:ShowUI()
    if self.bShowing == false then return end
    self.ShowNode:PlayInfo(function()
        self:OneEnd()
    end)
end

function tbClass:UpdateCircle(bShow)
    if self.bCircleShow == bShow then
        return
    end
    self.bCircleShow = bShow

    if self.pGachaActor then
        self.pGachaActor:HideCircle(bShow)
    end
end

function tbClass:PlayCircle()
    if self.pGachaActor then
        self.pGachaActor:PlayCircle()
    end
end

function tbClass:OneEnd()
    myLog('One End ')
    self.bShowing = false
end

function tbClass:OnClose()
    CacheInfo = {}
    DisplayData = nil
    self:ClearScene()
end

function tbClass:OnDisable()
    CacheInfo = {}
    self:ClearScene()
    UI.Close(self, nil, true)
end

function tbClass:ClearScene()
    print('gacha tap clear scene')

    if self.bCleaned then return end
    self.bCleaned = true

    if IsValid(self.pGachaActor) then
        self.pGachaActor:K2_DestroyActor()
        self.pGachaActor = nil
    end
    if self.nStoneDelayTimer then
        UE4.Timer.Cancel(self.nStoneDelayTimer)
        self.nStoneDelayTimer = nil
    end

    if self.nChangeDelayTime then
        UE4.Timer.Cancel(self.nChangeDelayTime)
        self.nChangeDelayTime = nil
    end

    Preview.CancelTimer()
    self:ClearMode()
    --
    EventSystem.TriggerTarget(
        Survey,
        Survey.POST_SURVEY_EVENT,
        Survey.GACHA
    )
end

 function tbClass:ClearMode()
    Preview.Destroy()
    if self.pCreateWeapon then
        self.pCreateWeapon:K2_DestroyActor()
        self.pCreateWeapon = nil
    end
 end


function tbClass:ShowItemInfo()
    if not self.nLastClickTime then
        self.nLastClickTime = UE4.UKismetSystemLibrary.GetGameTimeInSeconds(self)
    end

    self.bShowing = true
    self.pGachaActor:TurnBlackCircle()
    local GDPL = DisplayData[self.nShowIndex]
    if not GDPL then return end
    local g, d, p, l = table.unpack(GDPL)

    local pTemplate =  UE4.UItem.FindTemplate(g, d, p, l)

    CacheInfo.tbGDPL = GDPL
    CacheInfo.nQuality = pTemplate.Color

    WidgetUtils.HitTestInvisible(self.ShowNode)

    if self.pGachaActor.StoneDelayTime > 0 then
        self.nStoneDelayTimer = UE4.Timer.Add(self.pGachaActor.StoneDelayTime, function()
            self.nStoneDelayTimer = nil
            self.pGachaActor:PlayStoneEffect(fClampQuality(pTemplate.Color))
        end)
    else
        self.pGachaActor:PlayStoneEffect(fClampQuality(pTemplate.Color))
    end

    if pTemplate.Color == 5 then
        if self.pGachaActor.ChangeDelayTime > 0 then
            self.nChangeDelayTime = UE4.Timer.Add(self.pGachaActor.ChangeDelayTime, function()
                self.nChangeDelayTime = nil
                self.pGachaActor:ChangeBlackAsset(false)
            end)
        else
            self.pGachaActor:ChangeBlackAsset(false)
        end
    end


    WidgetUtils.HitTestInvisible(self.ShowNode)
    self.ShowNode:Set(g, d, p, l)

    if g == 1 then
        self.ShowNode:PlayShow(function()
            if pTemplate.Color ~= 5 then
                self.ShowNode:PlayInfo(function()
                    self:OneEnd()
                end)
            end   
        end)  
    else
        self.ShowNode:PlayShow(function()
            self.ShowNode:PlayInfo(function()
                self:OneEnd()
            end)
        end)
    end
end

function tbClass:PlaySSR()
    myLog('Play SSR', CacheInfo.nQuality)

    if CacheInfo.tbGDPL == nil then return end

    if self.bPlayEnd then return end

    local g, d, p, l =  table.unpack(CacheInfo.tbGDPL)
    if CacheInfo.nQuality == 5 then
        local nTemplateID = UE4.UItemLibrary.GetTemplateId(g, d, p, l)
        local sResName = UE4.UItemLibrary.GetCharacterAtrributeTemplate(nTemplateID).ResNameDec or ''
        local sAssetPath = string.format("/Game/Cinematics/gacha/%s_gacha/Sequence/%s_gacha_show01_Master.%s_gacha_show01_Master", sResName, sResName, sResName)
        self.pGachaActor:PlaySSR(sAssetPath)
    else
        Audio.PlaySounds(3031)
        self.pGachaActor:PlayCardEffect()
        Preview.Destroy()
        Preview.ShowModel(UE4.EItemType.CharacterCard,  g, d, p, l, self.pGachaActor.CharacterPos, UE4.FRotator(0, 180, 0), UE4.FVector(1, 1, 1), UE4.EUIWidgetAnimType.Role_Gacha)
        local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
        
        UE4.UVoiceManager.Play(GetGameIns(), pTemplate.AppearID, 'gacha')
    end
end

function tbClass:PlayWeapon()
    myLog('Play Weapon')
    if CacheInfo.tbGDPL == nil then return end

    if self.bPlayEnd then return end

    local g, d, p, l = table.unpack(CacheInfo.tbGDPL)
    local pWeapon = me:GetDefaultItem(g, d, p, l, 1)
    if not pWeapon then return end
    local ActorClass = UE4.UClass.Load("/Game/UI/UMG/GachaTap/BP_GachaPreviewWeapon.BP_GachaPreviewWeapon_C")
    self.pCreateWeapon = GetGameIns():GetWorld():SpawnActor(ActorClass)
    if not self.pCreateWeapon then return end
    self.pCreateWeapon:GachaLoadWeapon(pWeapon, UE4.FRotator(0, 0, 0), {self, function()
        if self.bPlayEnd then return end
        if IsValid(self.pGachaActor) and IsValid(self.pCreateWeapon) then
            self.pGachaActor:AttachToNode(self.pCreateWeapon)
        end
    end})
end

function tbClass:Next()
    myLog('next', self.bShowing)
    if self.bShowing then
        self:ClearMode()
        self.pGachaActor:ClearNext()
        self.bShowing = false
        WidgetUtils.Collapsed(self.ShowNode)
        self:Next()
        return
    end
    self.bShowing = true
    self:UpdateCircle(true)

    local fEnd = function()
        self.nShowIndex = self.nShowIndex + 1
        if self.nShowIndex > self.nMaxCount then
            self.bPlayEnd = true
            self:ClearMode()
            self.pGachaActor:Clear()
            WidgetUtils.Collapsed(self.Touch)
            WidgetUtils.Collapsed(self.Node)
            WidgetUtils.Collapsed(self.BtnNext)
            WidgetUtils.Collapsed(self.BtnSkip)
            WidgetUtils.Collapsed(self.ShowNode)
     
            if self.Result == nil then
                self.Result = WidgetUtils.AddChildToPanel(self.ContentNode, '/Game/UI/UMG/GachaTap/Widgets/uw_gacha_tap_result.uw_gacha_tap_result_C', 5)
            end

            if self.Result then
                WidgetUtils.SelfHitTestInvisible(self.Result)
                self.Result:OnOpen(DisplayData)
            else
                print('create result node fail***************************')
            end
            return
        end
        self:ShowItemInfo()
    end

    if CacheInfo.tbGDPL then
        if  CacheInfo.tbGDPL[1] == 2 then
            self.pGachaActor:PlayWeaponOut()
        else
            self.pGachaActor:PlayDisEffect()
        end
        self.ShowNode:PlayClose(function()
            self:ClearMode()
            fEnd()
        end)
    else
        fEnd()
    end
end


 function tbClass:Tick(MyGeometry, InDeltaTime)
    if self.pGachaActor and not self.bSuc then
        self.nNow = self.nTarget
        if self.nNow > 0.99 then
            self.bSuc = true
            self.pGachaActor:SetStage(STAGE.CircleSpread)
            Audio.PlaySounds(3015)
            return
        end
        self.pGachaActor:OnSizeChange(self.nNow)
    end
 end

return tbClass