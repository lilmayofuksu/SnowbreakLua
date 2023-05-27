-- ========================================================
-- @File    : Launch/Online/OnlineLevel.lua.lua
-- @Brief   : 联机关卡数据
-- ========================================================

---@field tbLevel table 联机关卡配置
OnlineLevel = OnlineLevel or {
   -- tbLevel = {}
}

---关卡信息存放通过次数   暂时没用
OnlineLevel.GID = 24;

---@class OnlineLevelTemplate 数据设置逻辑
---@field nId int 唯一Id
---@field sName string 关卡显示名，配置在language/chapter.txt中的字串ID
---@field nType int 类型
---@field nMapID int 加载地图ID，配置在map/map.txt中的唯一ID
---@field sTaskPath string 关卡任务配置路径
---@field tbCondition table 解锁条件
---@field tbConsumeVigor int[] 体力消耗，两部分
---@field tbMonster table 配置的怪物列表，用于显示
---@field nRecommendPower int 推荐的战力
---@field tbTeamRule table 队伍规则
---@field nPlayerExp int 通关后奖励帐号经验值
---@field nRoleExp int 通关后奖励上场角色经验值
---@field tbBaseDropID table 固定掉落
---@field tbFirstDropID table 首通掉落ID
---@field tbRandomDropID table 随机掉落ID
local OnlineLevelTemplate = {

    ---是否首通
    ---@param self OnlineLevelTemplate
    IsFirstPass = function(self)
        return self:GetPassTime() == 1;
    end,

    ---获得通关次数
    GetPassTime = function(self)
        return me:GetAttribute(OnlineLevel.GID, self.nId)
    end,

    ---是否通关
    IsPass = function(self)
        return self:GetPassTime() > 0
    end,

    ---获取掉落
    GetDrop = function(self)
        local sInfo = me:GetStrAttribute(OnlineLevel.GID, self.nId)
        if sInfo and sInfo ~= '' then
            return json.decode(sInfo)
        end
        return nil
    end,
};

---加载配置
function OnlineLevel.Load()
    OnlineLevel.tbLevel = {}
    OnlineLevel.tbMapType = {}

    local tbConfig = LoadCsv("online/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nId = tonumber(tbLine.Id) or 0
        if nId > 0 then
            local tbInfo = {
                Logic = OnlineLevelTemplate,
                nId = nId,
                sName = "chapter.level_" .. nId,
                sFlag = "chapter.level_name_" .. nId,
                sDes = "chapter.level_des_" .. nId,
                nType = tonumber(tbLine.Type) or 0,
                nMapType = tonumber(tbLine.MapType) or 0,
                sLevelName = tbLine.LevelName,
                nLevelIcon = tonumber(tbLine.LevelIcon) or 0,
                nMapID = tonumber(tbLine.MapID) or 0,
                nRecommendPower = tonumber(tbLine.RecommendPower) or 0,
                bMultipleFight = tonumber(tbLine.MultipleFight) == 1,
                sTaskPath = tbLine.TaskPath,
                nPlayerExp =  tonumber(tbLine.PlayerExp) or 0,

                tbBaseDropID         = Eval(tbLine.BaseDropID) or {},
                tbFirstDropID        = Eval(tbLine.FirstDropID) or {},
                tbRandomDropID       = Eval(tbLine.RandomDropID) or {},
                tbShowAward         = Eval(tbLine.ShowAward) or {},
                tbShowRandomAward   = Eval(tbLine.ShowRandomAward) or {},
                tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},

                tbMonster           = Eval(tbLine.Monster) or {},
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

            if tbInfo.nMapType > 0 then
                local typeList = OnlineLevel.tbMapType[tbInfo.nMapType]
                if not typeList then
                    OnlineLevel.tbMapType[tbInfo.nMapType] = {}
                    typeList = OnlineLevel.tbMapType[tbInfo.nMapType]
                end

                table.insert(typeList, tbInfo)
            end

            OnlineLevel.tbLevel[nId] = tbInfo
        end
    end
end

--获取配置信息
function OnlineLevel.GetConfig(nId)
    if not nId then return end

    return OnlineLevel.tbLevel[nId]
end

--获取配置信息
function OnlineLevel.GetConfigByMapType(nMapType)
    if not nMapType then return end

    return OnlineLevel.tbMapType[nMapType]
end

OnlineLevel.Load()
