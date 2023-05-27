--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class BulletRecover_C
local BulletRecover = UnLua.Class()

function BulletRecover:K2_ReceiveActive()
    self:InitConfig()
    
    self.DelayCountFight = 0
    self.DelayCountSwitch = 0
    self.DelayCountFire = 0
    
    self.DelayTimeFight = 0
    self.DelayTimeSwitch = 0
    self.DelayTimeFire = 0
    
    self.RecoverCount = 0
    self.RecoverTime = 0
    self.RecoverCalcType = UE.EAttributeChangeType.Add
    self.RecoverFixedValue = 0
    self.RecoverPercentageValue = 0
    
    self.MyCharacter = UE4.UKismetSystemLibrary.GetOuterObject(self):GetOwner()
end

function BulletRecover:K2_ReceiveDeActive()
    if self.OnWeaponFireState then
        self.OnWeaponFireState:Remove(self, self.OnWeaponFire)
        self.OnWeaponFireState = nil
    end 
end

function BulletRecover:CheckBindWeaponFire()
    if self.MyCharacter.Controller and not self.OnWeaponFireState then
        self.OnWeaponFireState = self.MyCharacter.Controller.OnWeaponFireState
        self.OnWeaponFireState:Add(self, self.OnWeaponFire)
    end
end

function BulletRecover:OnWeaponFire(bFire)
    if bFire then
        if self.MyCharacter.Controller then
            self.DelayCountFire = self.DelayTimeFire
        end
    end
end

function BulletRecover:UpdateConfig(Controller)
    local WeaponType = self.MyCharacter:GetWeapon().WeaponInfo.WeaponType
    if Controller then
        self.DelayTimeFight = self.Config.Foreground.DelayTimeFight
        self.DelayTimeSwitch = self.Config.Foreground.DelayTimeSwitch
        self.DelayTimeFire = self.Config.Foreground.DelayTimeFire
        for i = 1, self.Config.Foreground.WeaponConfig:Length() do
            local WeaponConfig = self.Config.Foreground.WeaponConfig:Get(i)
            if WeaponConfig.WeaponType == WeaponType then
                self.RecoverTime = WeaponConfig.Interval
                self.RecoverCalcType = WeaponConfig.CalcType
                self.RecoverFixedValue = WeaponConfig.FixedValue
                self.RecoverPercentageValue = WeaponConfig.PercentageValue
                break
            end
        end
    else
        self.DelayTimeFight = self.Config.Background.DelayTimeFight
        self.DelayTimeSwitch = self.Config.Background.DelayTimeSwitch
        self.DelayTimeFire = self.Config.Background.DelayTimeFire
        for i = 1, self.Config.Background.WeaponConfig:Length() do
            local WeaponConfig = self.Config.Background.WeaponConfig:Get(i)
            if WeaponConfig.WeaponType == WeaponType then
                self.RecoverTime = WeaponConfig.Interval
                self.RecoverCalcType = WeaponConfig.CalcType
                self.RecoverFixedValue = WeaponConfig.FixedValue
                self.RecoverPercentageValue = WeaponConfig.PercentageValue
                break
            end
        end
    end
end

function BulletRecover:K2_RecoverAttribute(AbilityComp, Value)
    self:CheckBindWeaponFire()
    
    local Controller = self.MyCharacter.Controller

    -- 切换角色
    if self.LastController ~= Controller then
        self:UpdateConfig(Controller)
        self.LastController = Controller
        self.DelayCountSwitch = self.DelayTimeSwitch
        if self.DelayTimeSwitch > 0 then
            self.bRecover = false
            EventSystem.Trigger(Event.StopRecoverBullet, self.MyCharacter)
        end
    end
    
    local PreventRecover = false
    if not self.Config.Foreground.Enable and Controller then
        PreventRecover = true
        --print("PreventRecover 前台角色禁止恢复", self.MyCharacter)
    end
    if not self.Config.Background.Enable and not Controller then
        PreventRecover = true
        --print("PreventRecover 后台角色禁止恢复", self.MyCharacter)
    end

    if not PreventRecover then
        if self.DelayCountSwitch > 0 then
            self.DelayCountSwitch = self.DelayCountSwitch - self.IntervalTime
            self.RecoverCount = 0
            PreventRecover = true
            --print("PreventRecover 切换角色", self.DelayCountSwitch, self.MyCharacter)
        end    
    end
    
    -- 是否战斗
    if not PreventRecover then
        if self.MyCharacter:IsInFight() then
            self.DelayCountFight = self.DelayCountFight
            self.RecoverCount = 0
            PreventRecover = true
        else
            if self.DelayCountFight > 0 then
                self.DelayCountFight = self.DelayCountFight - self.IntervalTime
                self.RecoverCount = 0
                PreventRecover = true
                --print("PreventRecover 角色战斗", self.DelayCountFight, self.MyCharacter)
            end
        end
    end
    
    -- 角色开枪
    if not PreventRecover then
        if self.DelayCountFire > 0 then
            self.DelayCountFire = self.DelayCountFire - self.IntervalTime
            self.RecoverCount = 0
            PreventRecover = true
            --print("PreventRecover 角色开枪", self.DelayCountFire, self.MyCharacter)
        end    
    end

    -- 弹药是否补满
    if not PreventRecover then
        local CurBullet = self.MyCharacter:GetWeapon().AccessoryAbility:GetRolePropertieValue(UE.EAttributeType.Bullet);
        local MaxBullet = self.MyCharacter:GetWeapon().AccessoryAbility:GetRolePropertieMaxValue(UE.EAttributeType.Bullet)
        if CurBullet >= MaxBullet then
            self.RecoverCount = 0
            PreventRecover = true
            --print("PreventRecover 弹药已满", self.MyCharacter)
        end
    end

    -- 计算恢复
    if not PreventRecover then
        self.RecoverCount = self.RecoverCount + self.IntervalTime
        if self.RecoverCount >= self.RecoverTime then
            self.RecoverCount = 0
            local RecoverValue = 0
            local CurBullet = self.MyCharacter:GetWeapon().AccessoryAbility:GetRolePropertieValue(UE.EAttributeType.Bullet);
            local MaxBullet = self.MyCharacter:GetWeapon().AccessoryAbility:GetRolePropertieMaxValue(UE.EAttributeType.Bullet)
            if self.RecoverCalcType == UE.EAttributeChangeType.Add then
                RecoverValue = RecoverValue + self.RecoverFixedValue
                RecoverValue = RecoverValue + MaxBullet * self.RecoverPercentageValue / 100
            elseif self.RecoverCalcType == UE.EAttributeChangeType.Set then
                if self.RecoverFixedValue ~= 0 then
                    RecoverValue = self.RecoverFixedValue - CurBullet
                end
                if self.RecoverPercentageValue ~= 0 then
                    RecoverValue = self.RecoverPercentageValue / 100 * MaxBullet - CurBullet
                end
            end
            RecoverValue = math.ceil(RecoverValue)
            AbilityComp:BulletRecoverFunc(RecoverValue)
            if not self.bRecover then
                self.bRecover = true
                EventSystem.Trigger(Event.StartRecoverBullet, self.MyCharacter)
            end  
        end
    else
        if self.bRecover then
            self.bRecover = false
            EventSystem.Trigger(Event.StopRecoverBullet, self.MyCharacter)
        end
    end
end

return BulletRecover
