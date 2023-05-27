-- ========================================================
-- @File    : Launch/Role/RoleLevel.lua.lua
-- @Brief   : 角色碎片本关卡数据
-- ========================================================
RoleLevel = RoleLevel or { tbLevel = {} }

---@class RoleLevelType 关卡类型
RoleLevelType = {}
RoleLevelType.NORMAL    = 0
RoleLevelType.BOSS      = 1
RoleLevelType.PLOT      = 2

---@class RoleLevelTemplate 数据设置逻辑
---@field nID integer 唯一ID
---@field sName string 关卡显示名，配置在language/chapter.txt中的字串ID
---@field nType integer 类型
---@field nMapID integer 加载地图ID，配置在map/map.txt中的唯一ID
---@field sGameMode string 游戏模式，默认BP_GameBaseMode
---@field sTaskPath string 关卡任务配置路径
---@field tbCondition table 解锁条件
---@field tbConsumeVigor integer[] 体力消耗，两部分
---@field tbStarCondition integer[] 配置的星级条件列表
---@field tbMonster table 配置的怪物列表，用于显示
---@field nShowListType integer 关卡详情是否显示怪物列表 0或不配显示奖励列表 1显示怪物列表
---@field nRecommendPower integer 推荐的战力
---@field bMultipleFight boolean 是否允许多重战斗
---@field bAgainFight boolean 是否显示【再次挑战】按钮
---@field nTeamRuleID table 队伍规则ID
---@field nNextID integer 下一关ID
---@field nPlayerExp integer 通关后奖励帐号经验值
---@field nRoleExp integer 通关后奖励上场角色经验值
---@field tbBaseDropID table 固定掉落
---@field tbFirstDropID table 首通掉落ID
---@field tbStarAward table 首次达成星级奖励
---@field tbRandomDropID table 随机掉落ID
---@field nNum integer 限制次数
---@field nConsume integer 积分消耗
RoleLevelTemplate = {

    __GetFlag = function(self, nIdx)
        return GetBits(me:GetAttribute(Launch.GID, self.nID), nIdx, nIdx);
    end,

    ---是否首通
    ---@param self RoleLevelTemplate
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

    ---取得星级历史达成标记
    DidGotStar = function(self, nIdx)
        return nIdx < 8 and self:__GetFlag(nIdx) == 1 or false;
    end,

    ---获取星级历史达成标记
    DidGotStars = function(self)
        local tbInfo = {}
        for i = 0, 2 do
            tbInfo[i] = self:DidGotStar(i)
        end
        return tbInfo
    end,

    ---统计星级历史达成数量
    CountGotStar = function(self)
        local nOld = me:GetAttribute(Launch.GID, self.nID);
        local nCount = 0;
        for i = 0, 7 do
            nCount = nCount + GetBits(nOld, i, i);
        end
        return nCount;
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
    IsCompleted = function(self)
        return self:GetPassTime() > 0
    end,

    ---获取附加选项
    GetOption = function(self)
        local sOption = ''
        if self.sTaskPath and self.sTaskPath ~= '' then
            sOption = string.format('TaskPath=/Game/Blueprints/LevelTask/Tasks/%s', self.sTaskPath)
        end
        ---Add Other Option
        return sOption
    end,

    ---获取体力消耗
    GetConsumeVigor = function(self)
        return (self.tbConsumeVigor[1] or 0) + (self.tbConsumeVigor[2] or 0)
    end,

    ---判定是否01关卡
    IsLevel01 = function(self)
        if self.nType == 0 and self.nConsume == 0 then
            return true
        end
        return false
    end,

    ---判定是否02关卡
    IsLevel02 = function(self)
        if self.nType == 0 and self.nConsume > 0 then
            return true
        end
        return false
    end
};


---取得一个关卡配置
---@param nID int 唯一的关卡ID
---@return RoleLevelTemplate 关卡对象
function RoleLevel.Get(nID)
    if not nID then return nil end
    return RoleLevel.tbLevel[nID];
end

---是否剧情关
function RoleLevel.IsPlot(nID)
    local level = RoleLevel.Get(nID)
    return level and level.nType == 2
end

---加载配置
function RoleLevel.Load()
    local tbConfig = LoadCsv("challenge/role/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            Logic               = RoleLevelTemplate,
            nID                 = nID,
            sName               = 'role.level_' .. nID,
            sFlag               = 'role.level_name_' .. nID,
            sDes                = 'role.level_des_' .. nID,
            nNum                = tonumber(tbLine.Num) or -2,
            nConsume            = tonumber(tbLine.Consume) or 0,
            nType               = tonumber(tbLine.Type) or 0,
            nMapID              = tonumber(tbLine.MapID) or 0,
            sTaskPath           = tbLine.TaskPath or '',
            tbBuffID            = Eval(tbLine.BuffID) or {},
            tbCondition	        = Eval(tbLine.Condition) or {},
            tbConsumeVigor      = Eval(tbLine.ConsumeVigor),
            tbStarCondition     = Eval(tbLine.StarCondition) or {},
            sStarCondition      = tbLine.StarCondition or '', -- 关卡用
            tbMonster           = Eval(tbLine.Monster) or {},
            nShowListType       = tonumber(tbLine.ShowListType) or 0,
            nRecommendPower     = tonumber(tbLine.RecommendPower) or 0,
            bMultipleFight      = tonumber(tbLine.MultipleFight) == 1,
            nNextID             = tonumber(tbLine.NextID),
            nPlayerExp          = tonumber(tbLine.PlayerExp) or 0,
            nRoleExp            = tonumber(tbLine.RoleExp) or 0,
            bAgainFight         = tonumber(tbLine.AgainFight) == 1,
            nTeamRuleID          = tonumber(tbLine.TeamRuleID),
            tbBaseDropID         = Eval(tbLine.BaseDropID) or {},
            tbFirstDropID        = Eval(tbLine.FirstDropID) or {},
            tbRandomDropID       = Eval(tbLine.RandomDropID) or {},
            tbStarAward         = Eval(tbLine.StarAward) or {},
            tbShowAward         = Eval(tbLine.ShowAward) or {},
            tbShowRandomAward   = Eval(tbLine.ShowRandomAward) or {},
            tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            nPictureBoss        = tonumber(tbLine.PictureBoss),
            nPictureLevel       = tonumber(tbLine.PictureLevel),
            LevelStrength      = tonumber(tbLine.LevelStrength) or 0,
        }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        RoleLevel.tbLevel[nID] = tbInfo;
    end
    print('load dungeonsrole/level.txt')
end

RoleLevel.Load()