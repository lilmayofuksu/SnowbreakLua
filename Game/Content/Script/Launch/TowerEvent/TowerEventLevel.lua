-- ========================================================
-- @File    : Launch/TowerEvent/TowerEventLevel.lua
-- @Brief   : 爬塔关卡数据
-- ========================================================
TowerEventLevel = TowerEventLevel or { tbLevel = {} }


---关卡信息存放组，每一个LevelID对应一个uint32，第0-7位存放星级达成Flag，第8位存放首通Flag
TowerEventLevel.GID = 21;

---@class TowerEventLevelTemplate 数据设置逻辑
---@field nID int 唯一ID
---@field sName string 关卡显示名
---@field nType integer 类型
---@field tbBuffID table buffID
---@field nMapID int 加载地图ID，配置在map/map.txt中的唯一ID
---@field sGameMode string 游戏模式，默认BP_GameBaseMode
---@field sTaskPath string 关卡任务配置路径
---@field tbCondition table 解锁条件
---@field tbConsumeVigor int[] 体力消耗，两部分
---@field tbStarCondition int[] 配置的星级条件列表
---@field tbMonster table 配置的怪物列表，用于显示
---@field nShowListType integer 关卡详情是否显示怪物列表 0或不配显示奖励列表 1显示怪物列表
---@field nRecommendPower int 推荐的战力
---@field bMultipleFight bool 是否允许多重战斗
---@field bAgainFight bool 是否显示【再次挑战】按钮
---@field tbTeamRule table 队伍规则
---@field nNextID int 下一关ID
---@field nPlayerExp int 通关后奖励帐号经验值
---@field nRoleExp int 通关后奖励上场角色经验值
---@field tbBaseDropID table 固定掉落
---@field tbFirstDropID table 首通掉落ID
---@field tbStarAward table 首次达成星级奖励
---@field tbRandomDropID table 随机掉落ID
TowerEventLevelTemplate = {

    __GetFlag = function(self, nIdx)
        return GetBits(me:GetAttribute(TowerEventLevel.GID, self.nID), nIdx, nIdx);
    end,

    ---是否首通
    ---@param self TowerEventLevelTemplate
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
            powerId = UE4.ULevelLibrary.GetPresetMonsterLevelById(self.nID) + self.nRecommendLevelOffset
        end
        return powerId
    end,

    -- 获取推荐战力
    GetRecommendPower = function(self)
        return ItemPower.GetRecommendPower(self:GetRecommendPowerId())
    end,
};


---取得一个关卡配置
---@param nID int 唯一的关卡ID
---@return TowerEventLevelTemplate 关卡对象
function TowerEventLevel.Get(nID)
    if not nID then return end
    local cfg = TowerEventLevel.tbLevel[nID];
    if not cfg then
        print('TowerEventLevel: Not Find Level Config ID =', nID)
    end
    return cfg
end

---------------------------------------- 配置加载 --------------------------------------------------
---加载配置
function TowerEventLevel.Load()
    local tbConfig = LoadCsv("challenge/tower_event/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            Logic               = TowerEventLevelTemplate,
            nID                 = nID,
            sName               = 'chapter.level_' .. nID,
            --sFlag               = 'chapter.level_name_' .. nID,
            sDes                = 'chapter.level_des_' .. nID,
            nType               = tonumber(tbLine.Type) or 0,
            tbBuffID            = Eval(tbLine.BuffID) or {},
            nMapID              = tonumber(tbLine.MapID) or 0,
            sTaskPath           = string.format('/Game/Blueprints/LevelTask/Tasks/%s', tbLine.TaskPath),  
            tbCondition	        = Eval(tbLine.Condition) or {},
            tbConsumeVigor      = Eval(tbLine.ConsumeVigor),
            tbStarCondition     = Eval(tbLine.StarCondition) or {},
            sStarCondition      = tbLine.StarCondition or '', -- 关卡用
            tbMonster           = Eval(tbLine.Monster) or {},
            nShowListType       = tonumber(tbLine.ShowListType) or 0,
            nRecommendPower     = tonumber(tbLine.RecommendPower) or 0,
            nRecommendLevelOffset = tonumber(tbLine.RecommendLevelOffset) or 0,
            bMultipleFight      = tonumber(tbLine.MultipleFight) == 1,
            nNextID             = tonumber(tbLine.NextID),
            nPlayerExp          = tonumber(tbLine.PlayerExp) or 0,
            nRoleExp            = tonumber(tbLine.RoleExp) or 0,
            bAgainFight         = tonumber(tbLine.AgainFight) == 1,
            tbTeamRule          = Eval(tbLine.TeamRule) or {0, 0, 0},
            tbBaseDropID         = Eval(tbLine.BaseDropID) or {},
            tbFirstDropID        = Eval(tbLine.FirstDropID) or {},
            tbRandomDropID       = Eval(tbLine.RandomDropID) or {},
            tbStarAward         = Eval(tbLine.StarAward) or {},
            tbShowAward         = Eval(tbLine.ShowAward) or {},
            tbShowRandomAward   = Eval(tbLine.ShowRandomAward) or {},
            tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            nPictureBoss        = tonumber(tbLine.PictureBoss),
            nBossId             = tonumber(tbLine.BossId),
            nPictureLevel       = tonumber(tbLine.PictureLevel),
            nReviveCount      = tonumber(tbLine.ReviveCount) or 0,
            nAutoReviveTime      = tonumber(tbLine.AutoReviveTime) or 0,
            nAutoReviveHealthScale      = tonumber(tbLine.AutoReviveHealthScale) or 0,
            nBuffOnlyAddToPlayer = tonumber(tbLine.BuffOnlyAddToPlayer) or 0,
            LevelStrength      = tonumber(tbLine.LevelStrength) or 0,
        }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        TowerEventLevel.tbLevel[nID] = tbInfo;
    end
end

TowerEventLevel.Load()
