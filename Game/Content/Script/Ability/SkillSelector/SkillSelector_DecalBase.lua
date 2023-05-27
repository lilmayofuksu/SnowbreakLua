local SkillSelector_DecalBase = Class()

function SkillSelector_DecalBase:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds);
    local CollisionComp = self:GetDecalCullCollision();
    if CollisionComp == nil then
        return;
    end
    local ObjectTypes = UE4.TArray(UE4.EObjectTypeQuery);
    ObjectTypes:Add(UE4.EObjectTypeQuery.Pawn);
    ObjectTypes:Add(UE4.EObjectTypeQuery.PhysicsBody);
    local ActorsToIgnore = UE4.TArray(UE4.AActor);
    -- 没有在OverlapActors中，则需要添加到OverlapActors里
    local NewOverlapActors = UE4.TArray(UE4.AActor);
    UE4.UKismetSystemLibrary.ComponentOverlapActors(CollisionComp, CollisionComp:K2_GetComponentToWorld(), ObjectTypes, nil, ActorsToIgnore, NewOverlapActors);
    -- print("NewOverlapActors Count", NewOverlapActors:Length());
    -- 在OverlapActors中且没有在NewOverlapActors中，则需要移除掉
    local OldOverlapActors = UE4.TArray(UE4.AActor);
    OldOverlapActors:Append(self.OverlapActors);
    local i = 1;
    while i <= OldOverlapActors:Length() and NewOverlapActors:Length() > 0 do
        local OldActor = OldOverlapActors:Get(i);
        local NewIndex = NewOverlapActors:Find(OldActor);
        if NewIndex > 0 then
            OldOverlapActors:Remove(i);
            NewOverlapActors:Remove(NewIndex);
            i = i - 1;
        end
        i = i + 1;
    end
    for i = 1, OldOverlapActors:Length() do
        local Actor = OldOverlapActors:Get(i);
        self.OverlapActors:RemoveItem(Actor);
        self:OnDecalEndOverlap(Actor);
    end
    for i = 1, NewOverlapActors:Length() do
        local Actor = NewOverlapActors:Get(i);
        self.OverlapActors:Add(Actor);
        self:OnDecalBeginOverlap(Actor);
    end
end

function SkillSelector_DecalBase:ReceiveEndPlay(EndPlayReason)
    self.Overridden.ReceiveEndPlay(self, EndPlayReason);

    for i = 1, self.OverlapActors:Length() do
        local Actor = self.OverlapActors:Get(i);
        self:OnDecalEndOverlap(Actor);
    end
    self.OverlapActors:Clear();
    -- print(self.OverlapActors:Length());
end

return SkillSelector_DecalBase