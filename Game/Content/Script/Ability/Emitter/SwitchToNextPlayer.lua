-- ========================================================
-- @File    : SwitchToNextPlayer.lua
-- @Brief   : 切换至下一个人物
-- @Author  : XiongHongJi
-- @Date    : 2021-12-29
-- ========================================================

---@class USkillEmitter_SwitchToNextPlayer:USkillEmitter
local SwitchToNextPlayer = Class()

function SwitchToNextPlayer:OnEmit()
    local CharacterOwner = self:GetInstigator();
    if CharacterOwner ~= nil then
        local Controller = CharacterOwner:GetController()
        if Controller then
            Controller = Controller:Cast(UE4.AGamePlayerController);
            if Controller then
                local NextCharacter = Controller:GetNextCharacter()
                if NextCharacter and NextCharacter:IsDead() == true then
                    Controller:SwitchPrePlayerCharacter();
                else
                    Controller:SwitchNextPlayerCharacter(false, true);
                end
            end
        end
    end
end

function SwitchToNextPlayer:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function SwitchToNextPlayer:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function SwitchToNextPlayer:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end


function SwitchToNextPlayer:EmitterDestroyLua()
    self:Destroy()
end

return SwitchToNextPlayer;