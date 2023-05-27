-- ========================================================
-- @File    : OutputDamageExecute.lua
-- @Brief   : 输出伤害统计
-- @Author  :
-- @Date    :
-- ========================================================

local OutputDamageExecute = Class()

OutputDamageExecute.NowDamage = 0;


function OutputDamageExecute:OnActive()
    self.DamageReceiveHandle =
        EventSystem.On(
        Event.DamageReceive,
        function(DamageParam)
            if DamageParam.Launcher then
                if DamageParam.Launcher:Cast(UE4.AGamePlayer) then
                    self.NowDamage = self.NowDamage + UE4.UKismetMathLibrary.FCeil(DamageParam.DamageResult.ShieldDamageValue + DamageParam.DamageResult.RealHealthDamageValue);
                    self:SetExecuteDescription(self:GetFormatTitle())
                    if self.NowDamage >= self.NeedDamage then 
                        self:Finish();
                    end
                end
            end
        end
    )
    self:SetExecuteDescription()
    TaskCommon.AddHandle(self.DamageReceiveHandle)
end

function OutputDamageExecute:OnActive_Client()
    --self:SetExecuteDescription()
end

function OutputDamageExecute:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.NowDamage)
        self.DescArgs:Add(self.NeedDamage)
    elseif self:IsClient() then
        self.NowDamage = self.DescArgs:Get(1)
        self.NeedDamage = self.DescArgs:Get(2)
    end

    local Title = string.format(self:GetUIDescription(),self.NowDamage .. "/" .. self.NeedDamage)
    return Title
end

function OutputDamageExecute:OnFail()
    EventSystem.Remove(self.DamageReceiveHandle);
end

function OutputDamageExecute:OnFinish()
    EventSystem.Remove(self.DamageReceiveHandle);
end

return OutputDamageExecute
