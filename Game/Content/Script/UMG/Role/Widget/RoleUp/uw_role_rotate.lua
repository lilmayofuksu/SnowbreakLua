-- ========================================================
-- @File    : uw_role_rotate.lua
-- @Brief   : 角色模型旋转
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:SetModel(pModel)
    self.pModel = pModel
end

function tbClass:OnRotate(Value)
if IsValid(self.pModel) then
        self.RotateValue = Value * self.RoleRotateSpeed * -1
        if math.abs(self.RotateValue) > self.RoleRotateSpeedLimit then
            self.RotateValue = self.RotateValue/math.abs(self.RotateValue) * self.RoleRotateSpeedLimit
        end
        self.pModel:K2_AddActorWorldRotation(UE4.FRotator(0, self.RotateValue, 0))
        if not RoleCard.bRotate then
            RoleCard.bRotate = true
        end
    end
end

function tbClass:Tick()
    if self.bDown then
        return
    end
    if self.RoleRotateInertia == 0 then
        return
    end
    if not self.RotateValue or self.RotateValue == 0 then
        return
    end
    if IsValid(self.pModel) then
        if self.RotateValue > 0 then
            self.RotateValue = self.RotateValue - self.RoleRotateInertia
            if self.RotateValue < 0 then
                self.RotateValue = 0
            end
        else
            self.RotateValue = self.RotateValue + self.RoleRotateInertia
            if self.RotateValue > 0 then
                self.RotateValue = 0
            end
        end
        self.pModel:K2_AddActorWorldRotation(UE4.FRotator(0, self.RotateValue, 0))
    end
end

return tbClass
