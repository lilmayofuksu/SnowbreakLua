local SkillSelector_Girl014a_QTE = Class()

function SkillSelector_Girl014a_QTE:SortTargets(QueryResults, CenterPosition)
    local ResultsTable = QueryResults:ToTable();
    table.sort(ResultsTable, function(a, b)
        local DistSquaredA = UE4.FVector.DistSquared(CenterPosition, a.QueryTarget:K2_GetActorLocation());
        local DistSquaredB = UE4.FVector.DistSquared(CenterPosition, b.QueryTarget:K2_GetActorLocation());
        return DistSquaredA < DistSquaredB;
    end)
    local SortedResults = UE4.TArray(UE4.FQueryResult);
    for k, v in pairs(ResultsTable) do
        SortedResults:Add(v);
    end
    return SortedResults;
end

return SkillSelector_Girl014a_QTE