-- ========================================================
-- @File    : PlaySimplePlotEvent.lua
-- @Brief   : 播放字幕语音
-- @Author  :
-- @Date    :
-- ========================================================
local tbClass = Class()

function tbClass:OnTrigger()
    local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
    subsytem:ApplyOpen(UE4.EUIDialogueType.SimplePlot,self.PlotID);
end

return tbClass
