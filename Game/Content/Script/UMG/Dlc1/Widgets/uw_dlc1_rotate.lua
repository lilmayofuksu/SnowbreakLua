-- ========================================================
-- @File    : uw_dlc1_rotate.lua
-- @Brief   : 模型旋转
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.lastVal1, self.lastVal2 = 0, 0
end

function tbClass:SetModel(pModel)
    self.pModel = pModel
    self.lastSoundTime = 0
end

function tbClass:OnRotateOrMove(Value1, Value2)
    if self.pModel then
        self.pModel.bManual = true
        self.pModel:K2_AddActorWorldRotation(UE4.FRotator(Value2 * self.RotateSpeed, Value1 * self.RotateSpeed * -1, 0))
        self.lastVal1, self.lastVal2 = Value1, Value2
        -- if os.clock() > self.lastSoundTime + 1 then
        --     self.lastSoundTime = os.clock()
        --     Audio.PlaySounds(3047)
        -- end
    end
end

function tbClass:OnButtonUp()
    if (self.lastVal1 ~= 0 or self.lastVal2 ~= 0) and self.pModel and self.pModel.StartFreeRotate then
        self.pModel.bManual = false
        self.pModel:StartFreeRotate(self.lastVal2 * self.RotateSpeed, self.lastVal1 * self.RotateSpeed * -1)
        self.lastVal1, self.lastVal2 = 0, 0
        Audio.PlaySounds(3047)
    end
end

return tbClass
