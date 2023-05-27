----------------------------------------------------------------------------------
-- @File    : BossSequenceConfig.lua
-- @Brief   : boss sequence 相关配置
----------------------------------------------------------------------------------

---@class BossSequenceConfig 
BossSequenceConfig = BossSequenceConfig or {}

----------------------------------- 加载配置表 ------------------------------------

--- 加载场景物件
function BossSequenceConfig:LoadCfg()
    local tbFile = LoadCsv("setting/boss_sequence.txt", 1);
    self.tbConfig = {}
    for _, tbLine in ipairs(tbFile) do 
        local id = tbLine.Id;
        if id then 
            local tb = {}
            tb.nId = id
            tb.SceneName = tbLine.SceneName;  -- 由于要在游戏中切语言，所以需要在用到时再取
            tb.SceneDesc = tbLine.SceneDesc;
            tb.BossName = tbLine.BossName;
            tb.BossDesc = tbLine.BossDesc;
            tb.BossIcon = tonumber(tbLine.BossIcon) or 0;
            self.tbConfig[id] = tb
        end
    end
end 

function BossSequenceConfig.Get(name)
    return BossSequenceConfig.tbConfig[name]
end

BossSequenceConfig:LoadCfg()
----------------------------------------------------------------------------------