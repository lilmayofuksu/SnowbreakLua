-- ========================================================
-- @File    : Entry.lua
-- @Brief   : Entry
-- ========================================================
---
---@class tbClass
local tbClass = Class()

function tbClass:ReceiveBeginPlay()
    if IsAndroid() or IsIOS() then
        UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, 'Slate.EnableSyntheticCursorMoves  0')
    end

    if not CheckStandalone() then return end

    UE4.UUMGLibrary.UpdateApplicationScale(false);
    UI.CloseAll(true)

    GM.TryOpenAdin();
      

    -- 全局变量，标识是否从entry运行游戏
    RunFromEntry = true;

    UI.Open('Login')
    PlayerSetting.UseSoundData(true)

    Login.bFirstEnterMainUI = true
    -- 上传PSO数据（只有开启了PSO日志统计才会有PSOSystem）
    -- 只在游戏启动时执行一次检测
    if not IsUploadPSOPipelineCache then 
        IsUploadPSOPipelineCache = true;
        local PSOSystem = UE4.UGameLibrary.GetAutoPSOSystem(self);
        if PSOSystem then 
            local content = LoadSetting("build_info.txt");
            local tbLine = Split(content, "\n")
            local number = tonumber(tbLine[2]) or 0
            PSOSystem:AutoUploadPipelinecache(number)
        end
    end

    -- 如果禁用pso采集，则强行关闭
    local isDisable = UE4.UUserSetting.GetBool("DisablePSOCache", false)
    if isDisable then 
        UE4.UPSOUtilities.Shutdown();
    end
end

return tbClass
