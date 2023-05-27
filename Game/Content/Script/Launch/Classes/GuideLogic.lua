-- ========================================================
-- @File    : GuideLogic.lua
-- @Brief   : 引导出击逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.GUIDE)

function tbClass:OnStart()
    local tbLevelCfg = ChapterLevel.Get(GuideLogic.PrologueMapID)
    if tbLevelCfg then
       Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
       --进入战斗界面需要隐藏技能按钮
       GuideLogic.IsHiddenSkillBt = true
    else
        Launch.End()
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    if nReason == UE4.ELevelFailedReason.ManualExit then
        return
    end
    me:SetAttribute(GuideLogic.GroupId, 0, 4)
    GuideLogic.nNowStep = 5
    GuideLogic.EnterGuideMap()
end

return tbClass