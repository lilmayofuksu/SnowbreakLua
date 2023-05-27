-- ========================================================
-- @File    : PlotMap.lua
-- @Brief   : PlotMap
-- ========================================================

---@class tbClass 
local tbClass = Map.Class('PlotMap')

function tbClass:OnEnter()
    --新手指引剧情
    if GuideLogic.nNowStep and GuideLogic.nNowStep <= 5 then
        self:ToNextStep()
    end
end

function tbClass:ToNextStep()
    if Launch.GetType() ~= LaunchType.GUIDE then
        return
    end
    if GuideLogic.nNowStep == 1 then
        --打点
        Adjust.DoRecord("rgx12m");
        UE4.ULevelLibrary.ShowMouseCursorInLevel(GetGameIns(), true)  --强行显示鼠标
        UE4.UGameLocalPlayer.SetAutoAdapteToScreen(false)
        UE4.UUMGLibrary.PlayPlot(GetGameIns(), 1005, {GetGameIns(), function(lication, CompleteType)
        end})
        -- 由于sequence结束时执行视频的close操作会卡顿50ms以上，所以加了一个新的事件来打开起名界面，避免中途出现黑屏
        local plot = UE4.UUMGLibrary.GetCurrentPlot()
        plot:SetSequenceBeforeEndCallBack({GetGameIns(), function()
            print("SetSequenceBeforeEndCallBack")
            GuideLogic.RecordStep(2)
            self:ToNextStep()
        end});
    elseif GuideLogic.nNowStep == 2 then
        local funToNext = function ()
            GuideLogic.RecordStep(3)
            self:ToNextStep()
        end
        if me:GetAttribute(99, 6) > 0 then  --取过名
            funToNext()
        else
            UE4.ULevelLibrary.ShowMouseCursorInLevel(GetGameIns(), true)  --强行显示鼠标
            UI.CloseAll(true)
            UI.Open("Bename", funToNext)
            UE4.Timer.Add(0.01, function()
                GM.TryOpenAdin()
                ---显示水印
                if WaterMarkLogic.IsShowWaterMark() then
                    UI.SafeOpen("WaterMark")
                end
            end)
        end
    elseif GuideLogic.nNowStep == 3 then
        UE4.ULevelLibrary.ShowMouseCursorInLevel(GetGameIns(), true)  --强行显示鼠标
        UE4.UUMGLibrary.PlayPlot(GetGameIns(), 1001, {GetGameIns(), function(lication, CompleteType)
            if CompleteType ~= UE4.EPlotCompleteType.Close then GuideLogic.RecordStep(4) end
            GuideLogic.EnterGuideMap()
        end})
    elseif GuideLogic.nNowStep == 4 then
        GuideLogic.EnterGuideMap()
    elseif GuideLogic.nNowStep == 5 then
        UE4.ULevelLibrary.ShowMouseCursorInLevel(GetGameIns(), true)  --强行显示鼠标
        UE4.UUMGLibrary.PlayPlot(GetGameIns(), 1003, {GetGameIns(), function(lication, CompleteType)
            if CompleteType ~= UE4.EPlotCompleteType.Close then GuideLogic.RecordStep(6) end
            GuideLogic.EnterGuideMap()
        end})
        if not GuideLogic.WwiseComponent then
            GuideLogic.WwiseComponent = UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), "Play_BGM_Story_001")
        end
    end
end

return tbClass
