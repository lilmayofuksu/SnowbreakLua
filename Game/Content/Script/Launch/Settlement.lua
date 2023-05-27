-- ========================================================
-- @File    : Settlement.lua
-- @Brief   : 结算配置
-- @Author  :
-- @Date    :
-- ========================================================


Settlement = Settlement or {tbSettlement = {}}

--- 获取结算光照
--- @param InGirlName string 结算的少女I18N
--- @return Int 使用第几个光照
function Settlement.GetSettlementLight(InGirlName)
    local nMapID = Map.GetCurrentID()
    if not nMapID then
        return 1
    end
    local tbNowLevel = Settlement.tbSettlement[nMapID]
    if not tbNowLevel then
        return 1
    end
    return tbNowLevel[InGirlName] or 1
end

function Settlement.LoadSeqLevel(CallBack)
    local nMapID = Map.GetCurrentID()
    --- 非entry进入 获取当前地图ID
    if not RunFromEntry then
        nMapID = UE4.UMapManager.GetMapIdByLevelPath(self:GetWorld());
    end
    if not nMapID or nMapID <= 0 then
        return false
    end
    local tbNowLevel = Settlement.tbSettlement[nMapID]
    if not tbNowLevel then
        return false
    end
    --- 加载结算点的子关卡
    local SeqLevel = tbNowLevel['SeqLevel']
    if not SeqLevel or SeqLevel == "" then
        return false
    end
    local LevelStream = UE4.ULevelLibrary.AddLevelStreaming(GetGameIns(), string.format("/Game/Blueprints/LevelTask/Level/SeqLevel/%s.%s", SeqLevel, SeqLevel))
    if LevelStream then
        LevelStream.OnLevelShown:Add(GetGameIns(), function()
            if CallBack then
                CallBack()
            end
        end)
        return true
    end
    return false
end


function Settlement.Load()
    local tbFile = LoadCsv("settlement/settlement.txt", 1)
    for _, tbLine in pairs(tbFile) do
        local Id = tonumber(tbLine.Id) or 0
        Settlement.tbSettlement[Id] = Settlement.tbSettlement[Id] or {}
        if Id then
            for ParamName, ParamValue in pairs(tbLine) do
                if ParamName == "SeqLevel" then
                    Settlement.tbSettlement[Id][ParamName] = ParamValue or ""
                elseif ParamName ~= "Id" and ParamName ~= "Null" then
                    Settlement.tbSettlement[Id][ParamName] = tonumber(ParamValue) or 1 
                end
            end
        end
    end
end

Settlement.Load()