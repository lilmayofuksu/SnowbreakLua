-- ========================================================
-- @File    : DestroyTrap.lua
-- @Brief   : 
-- ========================================================

local DestroyTrap = Class()
DestroyTrap.DestroyNum = 0

---死亡回调函数
DestroyTrap.DeathFunc = nil

function DestroyTrap:OnActive()
    ---注册怪死亡
    self.DeathHook =
        EventSystem.On(
        Event.CharacterDeath,
        function(InCharacter)
            if InCharacter then
                --延迟执行  防止立即注册立即调用
                UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                            self:OnDeath(InCharacter)
                        end
                    },
                    0.01,
                    false
                )
            end
        end
    )
    TaskCommon.AddHandle(self.DeathHook)

    

    self:SetExecuteDescription()
end

function DestroyTrap:OnActive_Client()
    self.AllCharAndPoint = {}
    if self.ShowTips then
        local allChar = self:FindAllChar()
        local FightUMG = UI.GetUI("Fight")
        if FightUMG and FightUMG.uw_fight_monster_tips then
            for i=1,allChar:Length() do
                local one = allChar:Get(i)
                if self:CheckCondition(one) then
                    local point = FightUMG.uw_fight_monster_tips:CreateItem(one, UE4.EFightMonsterTipsType.Attack)
                    self.AllCharAndPoint[one] = point
                end
            end
        end

        self.DeathHook = EventSystem.On(
            Event.CharacterDeath,
            function(InCharacter)
                if InCharacter then
                    --延迟执行  防止立即注册立即调用
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                        {
                            self,
                            function()
                                local point = self.AllCharAndPoint[InCharacter];
                                if point then 
                                    point:Reset()
                                    self.AllCharAndPoint[InCharacter] = nil
                                end
                                
                            end
                        },
                        0.01,
                        false
                    )
                end
            end
        )
    end
end

function DestroyTrap:OnDeath(InCharacter)
    if not InCharacter or not self:CheckCondition(InCharacter) then
        return
    end
    self.DestroyNum = self.DestroyNum + 1
    if self:Check() then
        self:Finish()
        EventSystem.Remove(self.DeathHook)
    end

    self:SetExecuteDescription()
end

---子类复写 怪物死亡检查  组  类型 等
function DestroyTrap:CheckCondition(InCharacter)
    local bCheckTrapSuc = self.CheckTrap and CheckCharacterType(InCharacter, UE4.ECharacterType.Trap)
    local bCheckDestructibleSuc = self.CheckDestructible and CheckCharacterType(InCharacter, UE4.ECharacterType.Destructible)
    local bCheckBunker = self.CheckBunker and CheckCharacterType(InCharacter, UE4.ECharacterType.Bunker)
    return bCheckTrapSuc or bCheckDestructibleSuc or bCheckBunker
end

function DestroyTrap:Check()
    return self.DestroyNum >= self.Num
end

function DestroyTrap:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.DestroyNum)
        self.DescArgs:Add(self.Num)
    elseif self:IsClient() then
        self.DestroyNum = self.DescArgs:Get(1)
        self.Num = self.DescArgs:Get(2)
    end

    local Title = string.format(self:GetUIDescription(),self.DestroyNum .. "/" .. self.Num)
    return Title
end

function DestroyTrap:OnFail()
    
end

function DestroyTrap:OnFail_Client()
    
end

function DestroyTrap:OnFinish()
    EventSystem.Remove(self.DeathHook)
end

function DestroyTrap:OnFinish_Client()

end

function DestroyTrap:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function DestroyTrap:OnEnd_Client()
    for _,v in pairs(self.AllCharAndPoint) do
        if IsValid(v) then
            v:Reset()
        end
    end
    UI.Call("Fight", "HiddenTaskCountDown", self)
end

return DestroyTrap
