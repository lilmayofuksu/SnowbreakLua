-- ========================================================
-- @File    : Challenge/TargetShoot/TargetShoot.lua
-- @Brief   : 打靶活动逻辑
-- ========================================================

TargetShootLogic = TargetShootLogic or {}
require 'Challenge.TargetShoot.TargetShootMessageHandle'

TargetShootLogic.nGroupId = 106
TargetShootLogic.HighestScoreId = 1
TargetShootLogic.ShownInfo = 0

TargetShootLogic.CanEnterRound = false

function TargetShootLogic.LoadConfig()
    TargetShootLogic.LoadConf()
end

function TargetShootLogic.LoadConf()
    print("TargetShootLogic:LoadConf")
    TargetShootLogic.tbInfo = {}
    local tbFile = LoadCsv('dlc/dlc1/chapter/targetdes.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine['ID']) or 0
        if Id > 0 then
            local tb = {}
            tb.nId = Id
            tb.nPicId = tonumber(tbLine.Pic)
            tb.nName = tbLine.Name
            tb.nDesc = tbLine.Desc
            TargetShootLogic.tbInfo[Id] = tb
            print("TargetShootLogic:LoadConf", tb.nId, tb.nPicId, tb.nName, tb.nDesc)
        end
    end
    print('dlc/dlc1/chapter/targetdes.txt')
end

function TargetShootLogic.SetCanEnterRound(bCan)
    TargetShootLogic.CanEnterRound = bCan
end

function TargetShootLogic.GetCanEnterRound()
    return TargetShootLogic.CanEnterRound
end

TargetShootLogic.LoadConfig()