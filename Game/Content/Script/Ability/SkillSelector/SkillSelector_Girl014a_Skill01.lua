local SkillSelector_Girl014a_Skill01 = Class()

-- function SkillSelector_Girl014a_Skill01:RemoveOutOfViewTarget()
--     for i = self.AllPartitionResults:Length(), 1, -1 do
--         local Partition = self.AllPartitionResults:Get(i);
--         if not self:CheckTargetInView(nil, Partition) then
--             self.AllPartitionResults:Remove(i);
--             self:ShowUI(Partition, false);
--         end
--     end
-- end

function SkillSelector_Girl014a_Skill01:GetAllowGameCharacters()
    local CachedCharacters = UE4.AGameCharacter.K2_GetCachedGameCharacters();
    local AllowCharacters = UE4.TArray(UE4.AGameCharacter);
    for i = 1, CachedCharacters:Length() do
        local GameCharacter = CachedCharacters:Get(i);
        if self:CheckCharacterAllow(GameCharacter) then
            AllowCharacters:Add(GameCharacter);
        end
    end
    return AllowCharacters;
end

function SkillSelector_Girl014a_Skill01:CheckCharacterAllow(GameCharacter)
    if not GameCharacter then
        return false;
    end
    if not GameCharacter:IsDead() then
        -- 距离检测？如果是大体型AI可能出现角色到胶囊体中心点的距离比范围大，但区块在范围内的情况
        -- 阵营检测
        local Relation = UE4.UAbilityFunctionLibrary.GetRelationBetweenAWithB(self.OwnerCharacter, GameCharacter);
        if (Relation == UE4.ECampRelation.UnFriendly or Relation == UE4.ECampRelation.Enermy) then
            if GameCharacter:IsAI() then
                return true;
            elseif GameCharacter:IsSummon() then
                return true;
            elseif GameCharacter:IsTrap() then
                -- Trap对象池，可能会存在没有死亡但其实已经被回收的情况
                return GameCharacter:GetAbilityComponent():IsActive();
            end
        end
    end
    return false;
end

function SkillSelector_Girl014a_Skill01:GetSortedPartitions(GameCharacter)
    local PartitionsTable = GameCharacter:GetAllPartition():ToTable();
    local Pos = self.OwnerCharacter:K2_GetActorLocation();
    table.sort(PartitionsTable, function(a, b)
        local BoneResultA = UE4.FBoneResult();
        local GameCharacterA;
        local bIsValidA, BoneResultA, GameCharacterA = self:GetPartitionMainBone(a);
        if not bIsValidA then
            return false;
        end
        local DistSquaredA = UE4.FVector.DistSquared(Pos, BoneResultA.MeshComp:GetSocketLocation(BoneResultA.ValueName));

        local BoneResultB = UE4.FBoneResult();
        local GameCharacterB;
        local bIsValidB, BoneResultB, GameCharacterB = self:GetPartitionMainBone(b);
        if not bIsValidB then
            return true;
        end
        local DistSquaredB = UE4.FVector.DistSquared(Pos, BoneResultB.MeshComp:GetSocketLocation(BoneResultB.ValueName));
        return DistSquaredA < DistSquaredB;
    end)
    local Partitions = UE4.TArray(UE4.FBoneResult);
    for k, v in pairs(PartitionsTable) do
        Partitions:Add(v);
    end
    return Partitions;
end

function SkillSelector_Girl014a_Skill01:CheckPartitionAllow(GameCharacter, PartitionResult)
    -- if GameCharacter == nil then
    --     return false;
    -- end
    -- 无敌判断
    if self:CheckStateGod(PartitionResult.OwnerActor) then
        return false;
    end
    local bIsValid, BoneResult, GameCharacter = self:GetPartitionMainBone(PartitionResult);
    if not bIsValid then
        return false;
    end
    local BoneLocation = BoneResult.MeshComp:GetSocketLocation(BoneResult.ValueName);
    local SelfLocation = self.OwnerCharacter:K2_GetActorLocation();
    -- 距离判断
    local Distance = UE4.FVector.Dist(BoneLocation, SelfLocation);
    if Distance > self.MaxDistance then
        return false;
    end
    if self.PlayerController == nil then
        return false;
    end
    local bInScreen, ScreenPosition = UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(self.PlayerController, BoneLocation, false);
    if not bInScreen then
        return false;
    end
    if ScreenPosition.X >= 0 and ScreenPosition.X <= self.ViewportSize.X and ScreenPosition.Y >= 0 and ScreenPosition.Y <= self.ViewportSize.Y then
        local Scales = (self.ViewportSize - ScreenPosition) / self.ViewportSize;
        if Scales.X >= self.ViewScaleXRange.X and Scales.X <= self.ViewScaleXRange.Y and Scales.Y >= self.ViewScaleYRange.X and Scales.Y <= self.ViewScaleYRange.Y then
            -- 射线检测
            local IgnoreActors = UE4.TArray(UE4.AActor);
            IgnoreActors:Add(self.OwnerCharacter);
            self.OwnerCharacter:GetAttachedActors(IgnoreActors, false);
            if GameCharacter ~= nil then
                IgnoreActors:Add(GameCharacter);
                GameCharacter:GetAttachedActors(IgnoreActors, false);
            end
            -- local HitResult = UE4.UAbilityFunctionLibrary.LineTraceSingle(SelfLocation, BoneLocation, UE4.ECollisionChannel.ECC_GameTraceChannel5, self.OwnerCharacter, IgnoreActors);
            local OutHit = UE4.FHitResult();
            local ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self);
            local WorldPosition = UE4.FVector();
            local WorldDirection = UE4.FVector();
            UE4.UGameplayStatics.DeprojectScreenToWorld(self.PlayerController, ViewportSize / 2, WorldPosition, WorldDirection)
            local bHit = UE4.UKismetSystemLibrary.LineTraceSingleByProfile(self, WorldPosition, BoneLocation, "BulletIgnorePawn", false, IgnoreActors, UE4.EDrawDebugTrace.None, OutHit, true);
            if bHit then
                -- local Name = UE4.UKismetSystemLibrary.GetDisplayName(OutHit.Actor);
                -- print("Hit:   ", Name);
                return false;
            end
            local ScreenCenterDist = UE4.UKismetMathLibrary.Distance2D(ScreenPosition, self.ViewportSize / 2);
            -- print(UE4.UKismetSystemLibrary.GetDisplayName(GameCharacter), ScreenPosition, self.ViewportSize / 2);
            return true, Distance, ScreenCenterDist;
        end
    end
    return false;
end

function SkillSelector_Girl014a_Skill01:GetAllTargetWithWeakResults()
    local Results = UE4.TArray(UE4.FBoneResult);
    -- 获取满足条件的角色
    local GameCharacters = self:GetAllowGameCharacters();
    local AllowPartitionsTable = {};
    for i = 1, GameCharacters:Length() do
        local GameCharacter = GameCharacters:Get(i);
        local Partitions = GameCharacter:GetAllPartition();
        for j = 1, Partitions:Length() do
            local Partition = Partitions:Get(j);
            local bAllow, Dist, ScreenCenterDist = self:CheckPartitionAllow(GameCharacter, Partition);
            if bAllow then
                local OnePartition = {
                    Partition = Partition,
                    Dist = Dist,
                    ScreenCenterDist = ScreenCenterDist,
                };
                table.insert(AllowPartitionsTable, OnePartition);
            end
        end
    end
    table.sort(AllowPartitionsTable, self.SortPartitions);
    for k, v in pairs(AllowPartitionsTable) do
        Results:Add(v.Partition);
        -- print(UE4.UKismetSystemLibrary.GetDisplayName(v.Partition.OwnerActor), v.Dist, v.ScreenCenterDist);
        if k >= self.MaxTargetCount then
            break;
        end
    end
    return Results;
end

function SkillSelector_Girl014a_Skill01:GetAllQueryResults()
    local Results = UE4.TArray(UE4.FQueryResult);
    for i = 1, self.AllPartitionResults:Length() do
        local Partition = self.AllPartitionResults:Get(i);
        local bIsValid, BoneResult, GameCharacter = self:GetPartitionMainBone(Partition);
        if bIsValid and BoneResult.MeshComp then
            local bIsPartValid, PartResult = self:GetPartitionMainPart(Partition);
            if bIsPartValid then
                local BoneLocation = BoneResult.MeshComp:GetSocketLocation(BoneResult.ValueName);
                local QueryResult = UE4.FQueryResult();
                QueryResult.bValid = true;
                QueryResult.QueryTarget = BoneResult.OwnerActor;
                QueryResult.QueryPoint = BoneLocation;
                QueryResult.PartitionResult = Partition;
                QueryResult.PartResult = PartResult;
                Results:Add(QueryResult);
            end
        end
    end
    return Results;
end

function SkillSelector_Girl014a_Skill01:GetPartitionMainBone(PartitionResult)
    local GameCharacter = PartitionResult.OwnerActor:Cast(UE4.AGameCharacter);
    if GameCharacter then
        return true, GameCharacter:K2_GetPartitionMainBone(PartitionResult.ValueName), GameCharacter;
    end
    local Accessory = PartitionResult.OwnerActor:Cast(UE4.AAccessory_Destructible);
    if Accessory and Accessory.bAsBodyPendant then
        return true, Accessory:K2_GetPartitionMainBone(PartitionResult.ValueName), Accessory.OwnGameCharacter;
    end
    return false, UE4.FBoneResult(), nil;
end

function SkillSelector_Girl014a_Skill01:GetPartitionMainPart(PartitionResult)
    local GameCharacter = PartitionResult.OwnerActor:Cast(UE4.AGameCharacter);
    if GameCharacter then
        return true, GameCharacter:K2_GetPartitionMainPart(PartitionResult.ValueName);
    end
    local Accessory = PartitionResult.OwnerActor:Cast(UE4.AAccessory_Destructible);
    if Accessory and Accessory.bAsBodyPendant then
        return true, Accessory:K2_GetPartitionMainPart(PartitionResult.ValueName);
    end
    return false, UE4.FBoneResult();
end

function SkillSelector_Girl014a_Skill01:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds);
    -- print("0    ", self.AllPartitionResults:Length());
    if self.bIsFinish then
        return;
    end
    if self.CurTime == nil then
        self.CurTime = 0;
    end
    self.CurTime = self.CurTime + DeltaSeconds;
    if self.CurTime < self.DelayTickTime then
        return;
    end
    -- 设置屏幕大小
    self.ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self) / UE4.UWidgetLayoutLibrary.GetViewportScale(self);
    self.PlayerController = self.OwnerCharacter:GetController():Cast(UE4.AGamePlayerController);
    -- print("1    ", self.AllPartitionResults:Length());
    -- 移除视野外的，并且根据屏幕中心距离以及与角色的距离进行排序
    self:RemoveOutOfViewAndSortTarget();
    -- print("2    ", self.AllPartitionResults:Length());
    -- 获取当前排序后的目标
    local CurrentTargets = self:GetAllTargetWithWeakResults();
    -- print("CurrentTargets    ", CurrentTargets:Length());
    local NewCount = 0;
    for i = 1, CurrentTargets:Length() do
        local Partition = CurrentTargets:Get(i);
        -- 不在目标数组中
        if not self.AllPartitionResults:Contains(Partition) then
            -- 如果当前数组达到最大数量，则移除最后一个
            local ResultsCount = self.AllPartitionResults:Length();
            if ResultsCount >= self.MaxTargetCount then
                local LastPartition = self.AllPartitionResults:Get(ResultsCount);
                self:ShowUI(LastPartition, false);
                self.AllPartitionResults:Remove(ResultsCount);
            end
            self.AllPartitionResults:Insert(Partition, 1);
            self:ShowUI(Partition, true);
            NewCount = NewCount + 1;
            if NewCount >= self.MaxTargetCountPerSearch then
                break;
            end
        end
    end
    -- print("3    ", self.AllPartitionResults:Length());
    self:DecideQueryResults(self:GetAllQueryResults());
end

function SkillSelector_Girl014a_Skill01:RemoveOutOfViewAndSortTarget()
    local AllowPartitions = {};
    for i = self.AllPartitionResults:Length(), 1, -1 do
        local Partition = self.AllPartitionResults:Get(i);
        local bAllow, Dist, ScreenCenterDist = self:CheckPartitionAllow(nil, Partition);
        if not bAllow then
            -- self.AllPartitionResults:Remove(i);
            self:ShowUI(Partition, false);
        else
            local OnePartition = {
                Partition = Partition,
                Dist = Dist,
                ScreenCenterDist = ScreenCenterDist,
            };
            table.insert(AllowPartitions, OnePartition);
        end
    end
    table.sort(AllowPartitions, self.SortPartitions);
    self.AllPartitionResults:Clear();
    for k, v in pairs(AllowPartitions) do
        self.AllPartitionResults:Add(v.Partition);
    end
end

function SkillSelector_Girl014a_Skill01.SortPartitions(PartitionA, PartitionB)
    if PartitionA.ScreenCenterDist ~= PartitionB.ScreenCenterDist then
        return PartitionA.ScreenCenterDist < PartitionB.ScreenCenterDist;
    end
    return PartitionA.Dist < PartitionB.Dist;
end

-- 判断是否是无敌状态
function SkillSelector_Girl014a_Skill01:CheckStateGod(Actor)
    while Actor ~= nil do
        local Interface = Actor:Cast(UE4.UAbilityCharacterInterface);
        if Interface then
            local AbilityComp = Interface:GetAbilityComponent();
            if AbilityComp then
                return not AbilityComp:IsActive() or AbilityComp:IsInState(UE4.EAbilityState.God);
            end
            return false;
        else
            Actor = Actor:GetOwner();
        end
    end
    return false;
end

return SkillSelector_Girl014a_Skill01