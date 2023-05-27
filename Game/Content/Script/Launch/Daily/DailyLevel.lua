-- ========================================================
-- @File    : Launch/Daily/DailyLevel.lua
-- @Brief   : 关卡数据
-- ========================================================
DailyLevel = DailyLevel or { tbLevel = {} }


---关卡信息存放组，每一个LevelID对应一个uint32，第0-7位存放星级达成Flag，第8位存放首通Flag
DailyLevel.GID = 21;

--教学关卡类型
DailyLevel.TeachingLevelType = 99;


---@class DailyLevelType 关卡类型
DailyLevelType = {}
DailyLevelType.NORMAL    = 0
DailyLevelType.BOSS      = 1
DailyLevelType.MAIN      = 2


---@class DailyLevelTemplate 数据设置逻辑
---@field nID int 唯一ID
---@field sName string 关卡显示名，配置在language/chapter.txt中的字串ID
---@field nType int 类型
---@field nMapID int 加载地图ID，配置在map/map.txt中的唯一ID
---@field sGameMode string 游戏模式，默认BP_GameBaseMode
---@field sTaskPath string 关卡任务配置路径
---@field tbCondition table 解锁条件
---@field tbConsumeVigor int[] 体力消耗，两部分
---@field tbStarCondition int[] 配置的星级条件列表
---@field tbMonster table 配置的怪物列表，用于显示
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
local DailyLevelTemplate = {

    __GetFlag = function(self, nIdx)
        return GetBits(me:GetAttribute(DailyLevel.GID, self.nID), nIdx, nIdx);
    end,

    ---是否首通
    ---@param self DailyLevelTemplate
    IsFirstPass = function(self)
        return self:__GetFlag(8) == 0;
    end,

    ---获得通关次数
    GetPassTime = function(self)
        return me:GetAttribute(Launch.GPASSID, self.nID)
    end,

    ---是否通关
    IsPass = function(self)
        return self:GetPassTime() > 0
    end,

    ---获取附加选项
    GetOption = function(self)
        local sOption = 'TaskPath=%s'
        sOption = string.format(sOption, self.sTaskPath)
        ---Add Other Option
        return sOption
    end,

    ---条件检查
    CheckCondition = function(self)
       return Condition.Check(self.tbCondition or {})
    end,

    ---获取体力消耗
    GetConsumeVigor = function(self)
        return (self.tbConsumeVigor[1] or 0) + (self.tbConsumeVigor[2] or 0)
    end,

    -- 获取推荐战力ID
    GetRecommendPowerId = function(self)
        local powerId = self.nRecommendPower
        if not powerId or powerId == 0 then
            local monLevel = UE4.ULevelLibrary.GetPresetMonsterLevelById(self.nID)
            powerId = monLevel + self.nRecommendLevelOffset
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
---@return DailyLevelTemplate 关卡对象
function DailyLevel.Get(nID)
    return DailyLevel.tbLevel[nID];
end

-- 是否新解锁未查看
function DailyLevel.IsNew(tbCfg)
    if tbCfg:IsPass() or not tbCfg:CheckCondition() then return false end
    if tbCfg.nType == DailyLevel.TeachingLevelType then
        return true
    else
        return UE4.UUserSetting.GetBool(string.format('DailyLevelNew_%d_%d', me:Id(), tbCfg.nID), true)
    end
end

function DailyLevel.SetFirstCheck(tbCfg)
    if tbCfg.nType == DailyLevel.TeachingLevelType then return end
    UE4.UUserSetting.SetBool(string.format('DailyLevelNew_%d_%d', me:Id(), tbCfg.nID), false)
    UE4.UUserSetting.Save()
end

---加载配置
function DailyLevel.Load()
    local tbConfig = LoadCsv("daily/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            Logic               = DailyLevelTemplate,
            nID                 = nID,
            nType               = tonumber(tbLine.Type) or 0,
            sName               = 'chapter.level_' .. nID,
            sFlag               = 'chapter.level_name_' .. nID,
            sDes                = 'chapter.level_des_' .. nID,
            nMapID              = tonumber(tbLine.MapID) or 0,
            nFightID            = tonumber(tbLine.FightID),
            sTaskPath           = string.format('/Game/Blueprints/LevelTask/Tasks/%s', tbLine.TaskPath),  
            tbCondition	        = Eval(tbLine.Condition) or {},
            tbConsumeVigor      = Eval(tbLine.ConsumeVigor),
            nRecommendPower     = tonumber(tbLine.RecommendPower) or 0,
            nRecommendLevelOffset = tonumber(tbLine.RecommendLevelOffset) or 0,
            bMultipleFight      = tonumber(tbLine.MultipleFight) == 1,
            nNextID             = tonumber(tbLine.NextID),
            nPlayerExp          = tonumber(tbLine.PlayerExp) or 0,
            nRoleExp            = tonumber(tbLine.RoleExp) or 0,
            bAgainFight         = tonumber(tbLine.AgainFight) == 1,
            nTeamRuleID          = tonumber(tbLine.TeamRuleID),
            tbBaseDropID        = Eval(tbLine.BaseDropID) or {},
            tbFirstDropID       = Eval(tbLine.FirstDropID) or {},
            tbRandomDropID      = Eval(tbLine.RandomDropID) or {},
            tbShowAward         = Eval(tbLine.ShowAward) or {},
            tbShowRandomAward   = Eval(tbLine.ShowRandomAward) or {},
            tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            nGuarantee          = tonumber(tbLine.Guarantee) or 0,
            tbMonster           = Eval(tbLine.Monster) or {},
            nShowListType       = tonumber(tbLine.ShowListType) or 0,
            LevelStrength      = tonumber(tbLine.LevelStrength) or 0,
        }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        DailyLevel.tbLevel[nID] = tbInfo;
    end
end

DailyLevel.Load()