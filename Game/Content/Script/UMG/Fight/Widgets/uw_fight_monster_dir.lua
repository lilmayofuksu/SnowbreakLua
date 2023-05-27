-- ========================================================
-- @File    : uw_fight_monster_dir.lua
-- @Brief   : 战斗界面 NPC 方位显示
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_monster_dir = Class("UMG.SubWidget")

local MonsterDir = uw_fight_monster_dir

MonsterDir.tbMonsters = {}

function MonsterDir:Construct()
    self.tbMonsters = {}
    self.AITargetChangeHandel =
        EventSystem.On(
        Event.AISwitchTarget,
        function(InActor, bActive)
            if not bActive then
                local Item = self.tbMonsters[InActor]
                if Item then
                    Item:RemoveFromParent()
                end
                self.tbMonsters[InActor] = nil
            else
                self:AddMonster(InActor)
            end
        end
    )
    self.HitHanddel =
        EventSystem.On(
        Event.CharacterChange,
        function()
            self:OnChange()
        end
    )
    self:OnChange()
end

function MonsterDir:OnChange()
    local Character = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if not Character then
        return
    end
    Character.Ability.OnReceiveDamage:Remove(self, MonsterDir.OnHit)
    Character.Ability.OnReceiveDamage:Add(self, MonsterDir.OnHit)
end

function MonsterDir:OnHit(InValue, InType, InMonster)
    local Item = self.tbMonsters[InMonster]
    if Item then
        Item:Hit(InValue)
    end
end

function MonsterDir:AddMonster(InMonster)
    local Item = self.tbMonsters[InMonster]
    if not Item then
        Item = self:NewItem()
        if Item then
            Item:Init(InMonster)
        end
        self.tbMonsters[InMonster] = Item
    end
end

function MonsterDir:Tick(MyGeometry, InDeltaTime)
    local Character = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if not Character then
        return
    end
    local Health = Character.Ability:GetRolePropertieValue(UE4.EAttributeType.Health)
    local MaxHealth = Character.Ability:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
    local Percent = Health / MaxHealth

    local Shield = Character.Ability:GetRolePropertieValue(UE4.EAttributeType.Shield)

    self:SetState(Percent < 0.7 and Shield <= 0)
end

MonsterDir.bWarning = false
function MonsterDir:SetState(InWarning)
    if self.bWarning == InWarning then
        return
    end
    self.bWarning = InWarning

    local All = self.Container:GetAllChildren()

    for i = 1, All:Length() do
        All:Get(i):Play(InWarning)
    end
end

function MonsterDir:OnDestruct()
    EventSystem.Remove(self.AITargetChangeHandel)
    EventSystem.Remove(self.HitHanddel)
    self.tbMonsters = nil
end

function MonsterDir:NewItem()
    local Widget =
        LoadUI(
        UE4.UKismetSystemLibrary.MakeSoftClassPath(
            "/Game/UI/UMG/Fight/Widgets/uw_fight_monster_dir_item.uw_fight_monster_dir_item_C"
        )
    )
    if not Widget then
        return nil
    end
    self.Container:AddChild(Widget)
    return Widget
end

return MonsterDir
