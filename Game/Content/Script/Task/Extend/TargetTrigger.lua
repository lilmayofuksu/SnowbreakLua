-- ========================================================
-- @File    : TargetTrigger.lua
-- @Brief   : 怪物触发器
-- @Author  :
-- @Date    :
-- ========================================================

---@class TargetTrigger
local TargetTrigger = Class()

TargetTrigger.BindItem = nil
TargetTrigger.BindUIItem = nil

TargetTrigger.bActive = false

TargetTrigger.bFill = false

TargetTrigger.DeathHandle = nil

TargetTrigger.FillRate = 0

TargetTrigger.AreaID = ""

TargetTrigger.bIsSafe = true
---激活
function TargetTrigger:Active(InBindItem, InBindUIItem, InAreaID)
    if not InBindItem then
        return
    end
    self:OnActive()
    self.State = 0 -- 0 无人，1 争夺中，2 怪物占领中
    self.BindItem = InBindItem
    self.BindUIItem = InBindUIItem
    -- print("TargetTrigger:Active ", self.BindItem, self.BindUIItem)
    self.bActive = true
    self.AreaID = InAreaID
    self:UpdateUIItemState()
    self.DeathHandle =
        EventSystem.On(
        "CharacterDeath",
        function(InCharacter)
            if InCharacter then
                self:EndOverlapHandle(InCharacter)
            end
        end,
        false
    )
    local OverlappingActors = self:GetOverlappingActors()
    for i = 1,OverlappingActors:Length() do
        self:BeginOverlapHandle(OverlappingActors:Get(i))
    end
    if self.BindUIItem then
        if self.BindUIItem.BarBlue.SetPercent then
            self.BindUIItem.BarBlue:SetPercent(0)
        else
            local Mat = self.BindUIItem.BarBlue:GetDynamicMaterial()
            if Mat then
                Mat:SetScalarParameterValue("Percent", 0)
            end
        end
        WidgetUtils.Collapsed(self.BindUIItem.ImgDefeat)
        WidgetUtils.Collapsed(self.BindUIItem.ImgFight)
        WidgetUtils.Collapsed(self.BindUIItem.ImgFight.ImgFight1)
        WidgetUtils.Collapsed(self.BindUIItem.ImgFight.ImgFight2)
    end
end

function TargetTrigger:Deactive(bSuccess)
    self:OnDeactive()
    self.bActive = false
    self.FillRate = 0
    self.bFill = false
    self.BindItem = nil
    if self.BindUIItem and bSuccess then
        self.BindUIItem:Reset()
    end
    self.BindUIItem = nil
    EventSystem.Remove(self.DeathHandle)
end

function TargetTrigger:BeginOverlapHandle(OtherActor)
    if self.bActive and not self.bFill then
        if IsAI(OtherActor) and OtherActor:IsAlive() then
            self.EnterMonsters:AddUnique(OtherActor)
            if self.bIsSafe then
                self:OnSafeToDanger()
            end
            self.bIsSafe = false
        elseif IsPlayer(OtherActor) and OtherActor:IsAlive() then
            self.EnterPlayers:AddUnique(OtherActor)
        end
        -- print("TargetTrigger:BeginOverlapHandle")
        self:UpdateUIItemState()
    end
end

function TargetTrigger:ReceiveActorBeginOverlap(OtherActor)
    self:BeginOverlapHandle(OtherActor)
end

function TargetTrigger:EndOverlapHandle(OtherActor)
    if self.bActive and not self.bFill then
        if IsAI(OtherActor) then
            self.EnterMonsters:RemoveItem(OtherActor)
            if self.EnterMonsters:Length() == 0 then
                if not self.bIsSafe then
                    self:OnDangerToSafe()
                end
                self.bIsSafe = true
            end
        elseif IsPlayer(OtherActor) then
            self.EnterPlayers:RemoveItem(OtherActor)
        end
        -- print("TargetTrigger:EndOverlapHandle")
        self:UpdateUIItemState()
    end
end

function TargetTrigger:ReceiveActorEndOverlap(OtherActor)
    self:EndOverlapHandle(OtherActor)
end

function TargetTrigger:ReceiveTick(DeltaTime)
    -- print("TargetTrigger:ReceiveTick ", self.bActive, self.bFill, self.BindItem)
    if self.bActive and not self.bFill and self.BindItem then
        -- print("TargetTrigger:ReceiveTick PreTick-", self.FillRate)
        local RateAdd = 0
        if self.EnterMonsters:Length() > 0 then
            if not self.BindItem.bCanPrevent or (self.BindItem.bCanPrevent and self.EnterPlayers:Length() <= 0) then
                RateAdd = DeltaTime * self.BindItem.IncreaseRate
            end
        end
        self.FillRate = self.FillRate + RateAdd
        if self.FillRate >= 100 then
            self.bFill = true
            -- print("TargetTrigger:ReceiveTick")
            self:UpdateUIItemState()
            self.BindItem:TryFail()
        end
        -- print("TargetTrigger:ReceiveTick PostTick-", self.FillRate)
        self:UpdateUIItemPercent()
    end
end

function TargetTrigger:UpdateUIItemPercent()
    if not self.BindUIItem then
        return
    end
    -- print("TargetTrigger:UpdateUIItemPercent ", self.FillRate)
    if self.BindUIItem.BarRed.SetPercent then
        self.BindUIItem.BarRed:SetPercent(self.FillRate / 100)
    else
        local Mat = self.BindUIItem.BarRed:GetDynamicMaterial()
        if Mat then
            Mat:SetScalarParameterValue("Percent", self.FillRate / 100)
        end
    end
end

function TargetTrigger:UpdateUIItemState()
    if not self.BindUIItem then
        return
    end
    self:UpdateUIItemPercent()

    if self.bFill then
        WidgetUtils.SelfHitTestInvisible(self.BindUIItem.ImgDefeat)
        self:PlayUIAnimation(self.BindUIItem.GuardDefeat, 1)
        return
    end
    if self.EnterMonsters:Length() > 0 then
        if self.BindItem.bCanPrevent and self.EnterPlayers:Length() > 0 then
            --争夺
            WidgetUtils.SelfHitTestInvisible(self.BindUIItem.ImgFight)
            WidgetUtils.SelfHitTestInvisible(self.BindUIItem.ImgFight.ImgFight1)
            WidgetUtils.SelfHitTestInvisible(self.BindUIItem.ImgFight.ImgFight2)
            if self.State ~= 1 then
                -- print("TargetTrigger:UpdateUIItemState: Fight", self.BindUIItem.GuardFight)
                self:PlayUIAnimation(self.BindUIItem.GuardFight)
            end
            self.State = 1
        else
            --怪物占领
            --self.BindUIItem.TxtGuardName:SetText(self.AreaID)
            if self.State ~= 2 then
                WidgetUtils.Collapsed(self.BindUIItem.ImgFight)
                WidgetUtils.Collapsed(self.BindUIItem.ImgFight.ImgFight1)
                WidgetUtils.Collapsed(self.BindUIItem.ImgFight.ImgFight2)
                if self.FillRate > 50 then
                    -- print("TargetTrigger:UpdateUIItemState: Warn", self.BindUIItem.GuardWarn2)
                    self:PlayUIAnimation(self.BindUIItem.GuardWarn2)
                else
                    -- print("TargetTrigger:UpdateUIItemState: Warn", self.BindUIItem.GuardWarn2)
                    self:PlayUIAnimation(self.BindUIItem.GuardWarn1)
                end
                self.State = 2
            end
        end
    else
        --无人
        --self.BindUIItem.TxtGuardName:SetText(self.AreaID)
        self:PlayUIAnimation(nil)
        self.State = 0
    end
end

function TargetTrigger:PlayUIAnimation(InAnim, PlayTime) --PlayTime 播放次数
    if not self.BindUIItem then return end

    -- self.BindUIItem:StopAllAnimations()
    if InAnim then
        -- print("TargetTrigger:UpdatePlayUIAnimationUIItemState: ", self.BindUIItem, InAnim, PlayTime)
        -- self.BindUIItem:PlayAnimation(InAnim, 0, PlayTime)
        self.BindUIItem:PlayAnimation(InAnim, 0, PlayTime, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

function TargetTrigger:ReceiveEndPlay()
    self:Deactive()
end

return TargetTrigger
