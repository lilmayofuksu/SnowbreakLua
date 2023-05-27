-- ========================================================
-- @File    : Launch/Rogue/RogueLevel.lua
-- @Brief   : 章节关卡数据
-- ========================================================
RogueLevel = RogueLevel or {}

---临时变量
local var = {nNodeInfo = nil, nLevelID = nil}

---保存当前节点配置
function RogueLevel.SetNodeInfo(cfg)
    var.nNodeInfo = cfg
end
---获取当前节点配置
function RogueLevel.GetNodeInfo()
    return var.nNodeInfo
end

---保存关卡ID
function RogueLevel.SetLevelID(nLevelID)
    var.nLevelID = nLevelID
end
---获取关卡ID
function RogueLevel.GetLevelID()
    return var.nLevelID
end

---@class RogueLevelTemplate 数据设置逻辑
---@field nID integer 唯一ID
---@field nType integer 类型
---@field nMapID integer 加载地图ID，配置在map/map.txt中的唯一ID
---@field tbConsumeVigor integer[] 体力消耗，两部分
---@field tbMonster table 配置的怪物列表，用于显示
---@field nShowListType integer 关卡详情是否显示怪物列表 0或不配显示奖励列表 1显示怪物列表
---@field nRecommendPower integer 推荐的战力
---@field tbFirstDropID table 首通掉落ID
---@field tbBaseDropID table 固定掉落
---@field sTaskPath string 关卡任务配置路径
RogueLevelTemplate = {
    __GetFlag = function(self, nIdx)
        return GetBits(me:GetAttribute(Launch.GID, self.nID), nIdx, nIdx);
    end,

    ---是否首通
    IsFirstPass = function(self)
        return self:GetPassTime() == 0
    end,

    ---获得通关次数
    GetPassTime = function(self)
        return me:GetAttribute(Launch.GPASSID, self.nID)
    end,

    ---是否通关
    IsPass = function(self)
        return self:GetPassTime() > 0
    end,

    ---获取掉落
    GetDrop = function(self)
        local sInfo = me:GetStrAttribute(Launch.GID, self.nID)
        if sInfo and sInfo ~= '' then
            return json.decode(sInfo)
        end
        return nil
    end,
    ---是否完成
    --[[
        剧情：观看完/获取完奖励后，显示
        关卡：3星通关后，显示
    ]]
    IsCompleted = function(self)
        return self:GetPassTime() > 0
    end,

    ---获取附加选项
    GetOption = function(self)
        local sOption = 'TaskPath=%s?ReviveCount=%s?AutoReviveTime=%s?AutoReviveHealthScale=%s'
        sOption = string.format(sOption, self.sTaskPath, self.nReviveCount, self.nAutoReviveTime, self.nAutoReviveHealthScale)
        return sOption
    end,

    ---获取体力消耗
    GetConsumeVigor = function(self)
        return (self.tbConsumeVigor[1] or 0) + (self.tbConsumeVigor[2] or 0)
    end,

     -- 获取推荐战力ID
     GetRecommendPowerId = function(self)
        local powerId = self.nRecommendPower
        if not powerId or powerId == 0 then
            powerId = UE4.ULevelLibrary.GetPresetMonsterLevelById(self.nID)
        end
        return powerId
    end,

    -- 获取推荐战力
    GetRecommendPower = function(self)
        return ItemPower.GetRecommendPower(self:GetRecommendPowerId())
    end,

    -- 关卡名中'x-x'会被WPS替换为'x月x日'  故策划配置改为'x_x' 程序强行替换'_'为'-'
    GetName = function(self)
        local strName = Text(self.sName)
        strName = string.gsub(strName, '_', '-')
        return strName
    end,
};


---取得一个关卡配置
---@param nID int 唯一的关卡ID
---@return RogueLevelTemplate 关卡对象
function RogueLevel.Get(nID)
    if not nID or nID <= 0 then return nil end
    return RogueLevel.tbLevel[nID]
end

---加载配置
function RogueLevel.Load()
    ---肉鸽活动关卡配置
    RogueLevel.tbLevel = {}
    local tbConfig = LoadCsv("dlc/dlc1/rogue/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            Logic               = RogueLevelTemplate,
            nID                 = nID,
            sName               = 'chapter.level_' .. nID,
            nType               = tonumber(tbLine.Type) or 0,
            nMapID              = tonumber(tbLine.MapID) or 0,
            tbConsumeVigor      = Eval(tbLine.ConsumeVigor),
            tbMonster           = Eval(tbLine.Monster) or {},
            nShowListType       = tonumber(tbLine.ShowListType) or 0,
            nRecommendPower     = tonumber(tbLine.RecommendPower) or 0,
            tbBaseDropID        = Eval(tbLine.BaseDropID) or {},
            tbFirstDropID       = Eval(tbLine.FirstDropID) or {},
            tbShowAward         = Eval(tbLine.ShowAward) or {},
            tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            nPictureBoss        = tonumber(tbLine.PictureBoss),
            nPictureLevel       = tonumber(tbLine.PictureLevel),
            sTaskPath           = string.format('/Game/Blueprints/LevelTask/Tasks/%s', tbLine.TaskPath),
            LevelStrength      = tonumber(tbLine.LevelStrength) or 0,
        }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        RogueLevel.tbLevel[nID] = tbInfo;
    end
end

RogueLevel.Load()
