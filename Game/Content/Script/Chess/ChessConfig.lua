----------------------------------------------------------------------------------
-- @File    : ChessConfig.lua
-- @Brief   : 棋盘配置表加载相关 
----------------------------------------------------------------------------------

---@class ChessConfig 棋盘配置表相关
ChessConfig = ChessConfig or { 
    tbModuleMaps        = {},   -- 存储模块对应的地图
    tbModuleArtMaps     = {},   -- 存储模块对应的美术地图
    tbModuleGridDefs    = {},   -- 存储模块对应的格子定义
    tbModuleItems       = {},   -- 存储模块对应的物件定义
    tbModuleFights      = {},   -- 战斗地图配置
    tbModulePlots       = {},   -- 剧情列表
    tbModuleParticle    = {},   -- 特效
    tbModuleSequence    = {},   -- 动画
    tbModuleParams      = {},   -- 各种参数，比如奔跑速度，走路速度
    tbModuleArtMapId    = {},   -- 得到美术地图id
    tbModuleNpcCfg      = {},   -- npc
}


----------------------------------------------------------------------------------
--- 得到模块列表
function ChessConfig:GetModuleList()
    local tbList = {}
    local dir = "Settings/chess/";
    local dirLen = string.len(dir);
    local allFiles = UE4.UUMGLibrary.FindFilesRecursive(dir, ".txt");
    for i = 1, allFiles:Length() do
        local path = allFiles:Get(i);
        if string.find(path, "grids.txt") then 
            local pos1 = string.find(path, dir) + dirLen;
            local pos2 = string.find(path, "/", pos1) - 1;
            local name = string.sub(path, pos1, pos2)
            table.insert(tbList, name)
        end
    end
    table.sort(tbList)
    return tbList
end

--- 得到模块下所有地图（如果是服务器，得启动时就加载）
function ChessConfig:GetMapListByModuleName(moduleName)
    local tb = self.tbModuleMaps[moduleName]
    if not tb then 
        tb = {}
        local dir = "Settings/chess/" .. moduleName;
        local dirLen = string.len(dir) + 1;
        local allFiles = UE4.UUMGLibrary.FindFilesRecursive(dir, ".txt");
        
        for i = 1, allFiles:Length() do
            local path = allFiles:Get(i);
            local pos1 = string.find(path, dir) + dirLen
            local pos2 = string.find(path, ".txt", pos1) - 1
            local name = string.sub(path, pos1, pos2)
            if string.find(name, "map") and not string.find(name, "_art")  then 
                local mapId = string.gsub(name, "map", "")
                local content = LoadSetting(string.format("chess/%s/%s.txt", moduleName, name))
                local tbData = {}
                if content and content ~= "" then tbData = json.decode(content) end
                ChessConfigHandler:FixMapData(tbData)
                table.insert(tb, {Id = tonumber(mapId), Name = tbData.Name or name, tbData = tbData });
            end
        end
        table.sort(tb, function(a, b) return a.Id < b.Id end)
        self.tbModuleMaps[moduleName] = tb
    end
    return tb
end

--- 得到美术地图
function ChessConfig:GetArtMap(moduleName, mapId) 
    local tbList = self.tbModuleArtMaps[moduleName] or {}
    self.tbModuleArtMaps[moduleName] = tbList

    local data = tbList[mapId]
    if not data then 
        local content = LoadSetting(string.format("chess/%s/map%s_art.txt", moduleName, mapId))
        data = json.decode(content) or {}
        tbList[mapId] = data
    end
    return data
end

--- 得到模块下格子定义（如果是服务器，得启动时就加载）
function ChessConfig:GetGridDefineByModuleName(moduleName)
    local tbDef = self.tbModuleGridDefs[moduleName] 
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/grids.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                local tb = {}
                tb.Id = Id
                tb.Name = string.gsub(tbLine.Nul, "\\n", "\n");
                tb.Background = self:GetLineColor(Eval(tbLine.Background))
                tb.BackgroundSlate = self:GetSlateColor(Eval(tbLine.Background)) 
                tb.TxtColor = self:GetSlateColor(Eval(tbLine.TxtColor)) 
                tb.Layer = tonumber(tbLine.Layer) or 0;
                tb.ModelPath = tbLine.ModelPath
                tb.Size = Eval(tbLine.Size) or {1, 1}
                tb.NameKey = tbLine.Name;
                tb.DescKey = tbLine.Desc;
                tb.Icon = tbLine.Icon;
                tb.State0 = Eval(tbLine.State0) or {};
                tb.State1 = Eval(tbLine.State1) or {};
                tb.Interaction = tonumber(tbLine.Interaction) == 1
                tb.Tags = Split(tbLine.Tags, ",")
                tb.ClassName = tbLine.ClassName
                tb.ParticleId = tonumber(tbLine.ParticleId) or 0
                tb.PageIndex = tonumber(tbLine.PageIndex) or 1
                
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleGridDefs[moduleName]  = tbDef
    end
    return tbDef;
end

--- 得到模块下道具定义
function ChessConfig:GetItemDefineByModuleName(moduleName)
    local tbDef = self.tbModuleItems[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/items.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                assert(Id <= ChessData.MaxItemIndex, "由于数据存储限制，Id不能超过" .. ChessData.MaxItemIndex);
                local tb = {}
                tb.Id = Id
                tb.Name = tbLine.Name or "" 
                tb.Desc = tbLine.Nul or ""
                tb.Icon = tbLine.Icon
                tb.Type = tonumber(tbLine.Type) or 1;
                
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleItems[moduleName]  = tbDef
    end
    return tbDef
end

--- 得到模块下战斗地图配置
function ChessConfig:GetFightDefineByMoudleName(moduleName)
    local tbDef = self.tbModuleFights[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/fight.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do
            local Id = tonumber(tbLine.Id) or 0
            if Id > 0 then
                local tb = {}
                tb.Id = Id
                tb.nLevelId = tonumber(tbLine.LevelId) or 0
                tb.Name = tbLine.Nul or ""
                tb.nMapId = tonumber(tbLine.MapId) or 0
                tb.sName = tbLine.Name or ""
                tb.sTaskPath = tbLine.TaskPath
                tb.nTeamRuleID = tonumber(tbLine.TeamRuleID)
                tb.FirstDropID = tonumber(tbLine.FirstDropID) or 0
                tb.BaseDropID = tonumber(tbLine.BaseDropID) or 0
                tb.RandomDropID = tonumber(tbLine.RandomDropID) or 0
                tb.Desc = tbLine.Desc
                tb.Rank = tonumber(tbLine.Rank) or 0

                tb.GetOption = function(self)
                    local sOption = ''
                    if self.sTaskPath and self.sTaskPath ~= '' then
                        sOption = string.format('TaskPath=/Game/Blueprints/LevelTask/Tasks/%s', self.sTaskPath)
                    end
                    return sOption
                end

                ---是否首通
                tb.IsFirstPass = function(self)
                    return self:GetPassTime() == 0;
                end

                ---获得通关次数
                tb.GetPassTime = function(self)
                    local actType = ChessClient.GetCurActType()
                    if actType == ChessActivityType.DLC1 then
                        local GID, FightStart, FightEnd = ChessLogic.GetFightPassTask()
                        assert(FightStart + self.Id <= FightEnd, "棋盘活动关卡id超上限")
                        return me:GetAttribute(GID, FightStart + self.Id)
                    else
                        return me:GetAttribute(Launch.GPASSID, self.nLevelId)
                    end
                end

                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleFights[moduleName] = tbDef
    end
    return tbDef
end

--- 得到模块下剧情列表
function ChessConfig:GetPlotDefineByModuleName(moduleName)
    local tbDef = self.tbModulePlots[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/plot.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                local tb = {}
                tb.Id = Id
                tb.Name = tbLine.Nul or "" 
                tb.PlotId = tonumber(tbLine.PlotId) or 0
                
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModulePlots[moduleName] = tbDef
    end
    return tbDef 
end

--- 得到模块下动画列表
function ChessConfig:GetSequenceDefineByModuleName(moduleName)
    local tbDef = self.tbModuleSequence[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/sequence.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                local tb = {}
                tb.Id = Id
                tb.Name = tbLine.Nul or "" 
                tb.Path = tbLine.Path;
                tb.Loop = tonumber(tbLine.Loop) == 1
                tb.Desc = GetFileNameByPath(tb.Path)
                
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleSequence[moduleName] = tbDef
    end
    return tbDef 
end

--- 得到模块下特效列表
function ChessConfig:GetParticleDefineByModuleName(moduleName)
    local tbDef = self.tbModuleParticle[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/particle.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                local tb = {}
                tb.Id = Id
                tb.Name = tbLine.Nul or "" 
                tb.Path = tbLine.Path;
                tb.Loop = tonumber(tbLine.Loop) == 1
                tb.Offset = Eval(tbLine.Offset) or {}
                tb.Desc = GetFileNameByPath(tb.Path)
                
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleParticle[moduleName] = tbDef
    end
    return tbDef 
end

--- 得到模块下npc列表
function ChessConfig:GetNpcDefineByModuleName(moduleName)
    local tbDef = self.tbModuleNpcCfg[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/npc.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                local tb = {}
                tb.Id = Id
                tb.Name = tbLine.Name or "" 
                tb.ModelPath = tbLine.ModelPath or "" 
                tb.Icon = tonumber(tbLine.Icon) or tbLine.Icon
                tb.ParticleId = tonumber(tbLine.ParticleId) or 0
                tb.Desc = tbLine.Desc or ""
                
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleNpcCfg[moduleName] = tbDef
    end
    return tbDef 
end

--- 得到模块参数（走路速度等）
function ChessConfig:GetModuleParams(moduleName)
    local tbDef = self.tbModuleParams[moduleName]
    if not tbDef then 
        local path = string.format("chess/%s/cfg/params.txt", moduleName)
        local content = LoadSetting(path);
        tbDef = Eval(content or "{}");
        self.tbModuleParams[moduleName] = tbDef
    end
    return tbDef 
end

--- 得到逻辑地图对应的美术地图id 
function ChessConfig:GetArtMapId(moduleName, mapId)
    local tbDef = self.tbModuleArtMapId[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbId2Data = {}}
        local path = string.format("chess/%s/cfg/map_art_ids.txt", moduleName)
        local tbFile = LoadCsv(path, 1);
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                local tb = {}
                tb.Id = Id
                tb.ArtMapId = tonumber(tbLine.ArtMapId) or 0
                tbDef.tbId2Data[Id] = tb
                table.insert(tbDef.tbList, tb)
            end
        end
        self.tbModuleArtMapId[moduleName] = tbDef
    end
    local tb = tbDef.tbId2Data[mapId]
    return tb and tb.ArtMapId or 0
end


--- 通过美术地图反查逻辑地图
function ChessConfig:GetLogicMapIdByArtMapId(moduleName, mapId)
    self:GetArtMapId(moduleName, 1)

    local tbDef = self.tbModuleArtMapId[moduleName]
    for _, tb in ipairs(tbDef.tbList) do 
        if tb.ArtMapId == mapId then 
            return tb.Id
        end
    end
end


--- 地图是否存在
function ChessConfig:IsMapExist(moduleName, mapId)
    local path = string.format("Settings/chess/%s/map%d.txt", moduleName, mapId)
    return UE4.UUMGLibrary.IsFileExist(path);
end

--- 创建地图
function ChessConfig:CreateMap(moduleName, mapId, tbParam)
    local tb = {}
    tb.Name = tbParam.Name;
    tb.Type = tbParam.Type;
    tb.PathType = tbParam.PathType
    tb.CharacterScale = tbParam.CharacterScale
    tb.DefaultGroundId = tbParam.DefaultGroundId
    ChessConfigHandler:FixMapData(tb)
    local tbMaps = self.tbModuleMaps[moduleName]
    local tbData = {Id = tonumber(mapId), Name = tb.Name or "", tbData = tb }
    table.insert(tbMaps, tbData);
    table.sort(tbMaps, function(a, b) return a.Id < b.Id end)

    local path = string.format("Settings/chess/%s/map%d.txt", moduleName, mapId)
    UE4.UGameLibrary.SaveFile(path, json.encode(tb))
end

--- 保存地图
function ChessConfig:SaveMap(moduleName, mapId, tbMapData)
    local path = string.format("Settings/chess/%s/map%d.txt", moduleName, mapId)
    UE4.UGameLibrary.SaveFile(path, json.encode(tbMapData.tbData))
end

--- 保存美术地图地图
function ChessConfig:SaveArtMap(moduleName, mapId, tbArtData)
    local tbList = self.tbModuleArtMaps[moduleName] or {}
    self.tbModuleArtMaps[moduleName] = tbList
    tbList[mapId] = tbArtData

    local path = string.format("Settings/chess/%s/map%s_art.txt", moduleName, mapId)
    UE4.UGameLibrary.SaveFile(path, json.encode(tbArtData))
end

--- 重新加载地图
function ChessConfig:ReloadMap(moduleName, mapId)
    local content = LoadSetting(string.format("chess/%s/map%d.txt", moduleName, mapId))
    local tbData = {}
    if content and content ~= "" then 
        tbData = json.decode(content) 
    end
    ChessConfigHandler:FixMapData(tbData)

    local tbMaps = self.tbModuleMaps[moduleName]
    for _, tb in ipairs(tbMaps) do 
        if tb.Id == mapId then 
            tb.Name = tbData.Name or ("map" .. mapId)
            tb.tbData = tbData
            break
        end
    end
end

-- 得到颜色
function ChessConfig:GetLineColor(tb)
    if tb and #tb >= 3 then 
        return UE.FLinearColor(tb[1] / 255, tb[2] / 255, tb[3] / 255, (tb[4] or 255) / 255);
    end 
    return UE.FLinearColor(1, 1, 1, 1); 
end

-- 得到Slate Color 
function ChessConfig:GetSlateColor(tb)
    if tb and #tb >= 3 then 
        return UE4.UUMGLibrary.GetSlateColor(tb[1] / 255, tb[2] / 255, tb[3] / 255, (tb[4] or 255) / 255);
    end 
    return UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1); 
end

----------------------------------------------------------------------------------
