-- ========================================================
-- @File    : DestroyTraget.lua
-- @Brief   : 
-- ========================================================

local DestroyTraget = Class()
DestroyTraget.DestroyNum = 0

function DestroyTraget:OnActive()
    local pFunc = function ()
        self.target = self:GetTarget()
        if not self.target then
            return
        end
        self.maxHp = self.target:GetMaxHp()

        ---注册物体摧毁
        self.DestroyHook =
            EventSystem.On(
            "DestructibleOnDestroy",
            function(InObject)
                if InObject then
                    --延迟执行  防止立即注册立即调用
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                        {
                            self,
                            function()
                                self:OnDestroy(InObject)
                            end
                        },
                        0.01,
                        false
                    )
                end
            end
        )

        ---注册物体受到伤害
        self.OnDamageHook =
            EventSystem.On(
            "DestructibleOnReceiveDamage",
            function(InObject)
                if InObject then
                    local FightUMG = UI.GetUI("Fight")
                    if FightUMG and FightUMG.LevelBar then
                        FightUMG.LevelBar:Update(self)
                    end
                end
            end
        )
        TaskCommon.AddHandle(self.DestroyHook)
        TaskCommon.AddHandle(self.OnDamageHook)
        self:Init()
    end

    if self.Delay > 0 then
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                pFunc
            },
            self.Delay,
            false
        )
    else
        pFunc()
    end
end

function DestroyTraget:Init()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_monster_tips then
        self.RedPoint = FightUMG.uw_fight_monster_tips:CreateItem(self.target, UE4.EFightMonsterTipsType.Attack)
    end

    if FightUMG and FightUMG.LevelBar then
        FightUMG.LevelBar:Active(self)
    end

    self:SetExecuteDescription()
end

function DestroyTraget:OnDestroy(InObject)
    if not InObject or not InObject == self.target then
        return
    end
    self:Finish()
    EventSystem.Remove(self.DestroyHook)
    self.RedPoint:Reset()
end

function DestroyTraget:GetDesc_Num()
    return self.target:GetCurrentHp() / self.maxHp
end

function DestroyTraget:GetTargetHp()
    return math.ceil(self.target:GetCurrentHp())
end

function DestroyTraget:OnFail()
    EventSystem.Remove(self.DestroyHook)
    EventSystem.Remove(self.OnDamageHook)
    self.RedPoint:Reset()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelBar then
        FightUMG.LevelBar:Deactive(self)
    end
end

function DestroyTraget:OnFinish()
    EventSystem.Remove(self.DestroyHook)
    EventSystem.Remove(self.OnDamageHook)
    self.RedPoint:Reset()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelBar then
        FightUMG.LevelBar:Deactive(self)
    end
end


return DestroyTraget
