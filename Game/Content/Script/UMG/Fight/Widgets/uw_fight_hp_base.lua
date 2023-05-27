-- ========================================================
-- @File    : uw_fight_hp_base.lua
-- @Brief   : 血条基类
-- @Author  :
-- @Date    :
-- ========================================================

local State = {
    Normal = 1,
    Hit = 2,
    Recover = 3
}

--暂定基类  美术还没统一风格

local uw_fight_hp_base = Class("UMG.SubWidget")

local HPWidget = uw_fight_hp_base

---上次受击时间
HPWidget.LastHitTime = 0
---上次值
HPWidget.HitValue = 1

---上次值
HPWidget.LastHitValue = 1

---当前状态
HPWidget.CurrentState = State.Normal

---当前时间
HPWidget.NowTime = 0

---当前值
HPWidget.CurrentValue = 0

---最大值
HPWidget.MaxValue = 0

HPWidget.RecoverTime = 0

HPWidget.RecoverLerpTime = 0.3

HPWidget.bInit = false
HPWidget.bPlayEndAnim = false

function HPWidget:GetProgress()
    return nil
end

function HPWidget:GetDamage()
    return nil
end

function HPWidget:GetEffect()
    return nil
end

function HPWidget:OnRecover(InSize)
end

function HPWidget:OnHit(InCurrent, InTarget)
end

function HPWidget:End()
end

function HPWidget:Construct()
    self.bPlayEndAnim = false
end

---清理
function HPWidget:Clear()
    self.LastHitTime = 0
    self.LastHitValue = 1.0
    self.HitValue = 1.0
    self.CurrentValue = 1.0
    self.RecoverTime = 0
end

---设置
function HPWidget:SetPercent(InValue)
    if not self.bInit then
        self:Clear()
        self.bInit = true
        local PSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self:GetProgress())
        self.MaxValue = PSlot:GetSize().X
        self.CurrentState = State.Normal
    end

    if InValue == self.CurrentValue then
        return
    end
    if InValue <= 0.0 and not self.bPlayEndAnim then
        self.bPlayEndAnim = true
        self:End()
    end
    self:OnHit(self.CurrentValue, InValue)
    self.CurrentValue = InValue

    self:GetProgress():SetPercent(InValue)
    self:SetWidgetPos(self:GetEffect(), self.CurrentValue * self.MaxValue + 4)
    if self.CurrentState ~= State.Hit then
        self.CurrentState = State.Hit
        self.HitValue = self.LastHitValue
        self.LastHitValue = InValue
        self.RecoverTime = 0
    end
    self.LastHitTime = UE4.UGameplayStatics.GetTimeSeconds(self)
end

function HPWidget:Tick(MyGeometry, InDeltaTime)
    self.NowTime = UE4.UGameplayStatics.GetTimeSeconds(self)
    if self.CurrentState == State.Hit then
        if self.NowTime - self.LastHitTime > 0.5 and self.CurrentState ~= State.Recover then
            self.CurrentState = State.Recover
            self.RecoverTime = self.RecoverLerpTime
            local V = (self.HitValue - self.CurrentValue) * self.MaxValue
            self:OnRecover(V)
        end
    end

    if self.RecoverTime > 0 then
        self.RecoverTime = self.RecoverTime - InDeltaTime
    end

    if self.CurrentState == State.Recover then
        if self.HitValue > self.CurrentValue then
            self.HitValue =
                UE4.UKismetMathLibrary.Lerp(self.CurrentValue, self.HitValue, self.RecoverTime / self.RecoverLerpTime)
        else
            self.HitValue = self.CurrentValue
        end
        if self.RecoverTime < 0 then
            self.CurrentState = State.Normal
        end
    end
    self:Update()
end

---更新
function HPWidget:Update()
    local DamageNode = self:GetDamage()
    if not DamageNode then
        return
    end
    if self.CurrentState == State.Normal then
        WidgetUtils.Collapsed(DamageNode)
        self.LastHitValue = self.CurrentValue
    elseif self.CurrentState == State.Hit then
        WidgetUtils.SelfHitTestInvisible(DamageNode)
        local V = (self.HitValue - self.CurrentValue) * self.MaxValue
        self:SetWidgetPos(DamageNode, self.CurrentValue * self.MaxValue, V)
    elseif self.CurrentState == State.Recover then
        WidgetUtils.SelfHitTestInvisible(DamageNode)
        local V = (self.HitValue - self.CurrentValue) * self.MaxValue
        self:SetWidgetPos(DamageNode, self.CurrentValue * self.MaxValue, V)
    end
end

---设置位置 和长度
function HPWidget:SetWidgetPos(InWidget, InPos, InSize)
    if not InWidget then
        return
    end
    local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InWidget)
    local Pos = Slot:GetPosition()
    local Size = Slot:GetSize()
    Slot:SetPosition(UE4.FVector2D(InPos, Pos.Y))
    if InSize then
        Slot:SetSize(UE4.FVector2D(InSize, Size.Y))
    end
    local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InWidget)
end

return HPWidget
