-- ========================================================
-- @File    : CompareMonsterNum.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local CompareMonsterNum = Class()

function CompareMonsterNum:OnActive()
    local pFunc = function ()
        self.TimerHandle =UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
                self,
                function()
                    if self:CheckTagMonsterNum() then
                        self:Finish()
                    end
                    self:SetExecuteDescription()
                end
            },
            0.5,
            true
        )

        if self:CheckTagMonsterNum() then
            self:Finish()
        end
        self:SetExecuteDescription()
    end

    if self.DelayTime > 0 then
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                pFunc
            },
            self.DelayTime,
            false
        )
    else
        pFunc()
    end
end

function CompareMonsterNum:OnActive_Client()
    --self:SetExecuteDescription()
end

function CompareMonsterNum:OnFail()
    
end

function CompareMonsterNum:OnFinish()
end

function CompareMonsterNum:OnEnd()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
end

return CompareMonsterNum
