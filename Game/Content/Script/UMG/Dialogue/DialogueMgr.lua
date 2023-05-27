-- ========================================================
-- @File    : DialogueMgr.lua
-- @Brief   : 剧情
-- @Author  :
-- @Date    :
-- ========================================================

DialogueMgr = DialogueMgr or {}

-- DialogueMgr.CurrentData = nil
function DialogueMgr.Play(InData)
    print('Start Play Plot')
    -- DialogueMgr.CurrentData = InData
    local PlotWidget = UI.GetUI("Dialogue")
    if not PlotWidget then
        PlotWidget = UI.Open("Dialogue")
    end

    DialogueMgr.OnOpenDialogue(InData, PlotWidget)
end

function DialogueMgr.OnOpenDialogue(InData, PlotWidget)
    if InData then
        InData:SetWidget(PlotWidget)
        InData:Start()
        print('start plot')
    end
end

function DialogueMgr.Stop(InPlotCompleteType)
    print('Stop Plot')
    local PlotWidget = UI.GetUI("Dialogue")
    if PlotWidget then
        PlotWidget:EndPlot(InPlotCompleteType or UE4.EPlotCompleteType.Skip)
    end
end

function DialogueMgr.SetPause(bPause)
    local PlotWidget = UI.GetUI("Dialogue")
    if PlotWidget then
        print("DialogueMgr setplotpause : " .. tostring(bPause))
        UE4.UGameplayStatics.SetGamePaused(PlotWidget, bPause or false)
        PlotWidget:SetPaused(bPause and 1 or 0)
    end
end

function DialogueMgr.GetPlotName()
    local PlotWidget = UI.GetUI("Dialogue")
    if PlotWidget then
        local CurrentPlot = PlotWidget:GetPlot()
        if CurrentPlot then 
            return CurrentPlot.PlotConfig or ''
        end
    end
    return ''
end

------------------------------------------------------------------------
--- 战斗剧情/simple剧情/碎片化叙事框 排队显示
------------------------------------------------------------------------
function DialogueMgr.Begin(Type, Id, Param)
    local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
    if subsytem then
        if Type == UE4.EUIDialogueType.SimplePlot then 
            local ui = UI.Open("SimpleDialogue", Id)
            if ui then
                ui.IsFromFight=true
                subsytem:SetUIData(Type,ui,ui.CanvasPanel_143);
            end
        end
    
        if Type == UE4.EUIDialogueType.Plot then  
            local ui = UI.GetUI("Dialogue")
            if ui then
                ui.IsFromFight=true
                subsytem:SetUIData(Type,ui,ui.FightStyle.CanvasPanel_143);
            end 
        end
    
        if Type == UE4.EUIDialogueType.FragmentStory then 
            FragmentStory.Show(tonumber(Id), Param == "1")
            local ui = UI.GetUI("DialoguePieces")
            if ui then
                ui.IsFromFight=true
                subsytem:SetUIData(Type,ui,ui.CanvasPanel_143);
            end
        end
    end
end

function DialogueMgr.OnClose(Type,IsFromFight)
    if IsFromFight then
        local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
        if subsytem then
            subsytem:NotifyCloseUI(GetGameIns(),Type)
        end
    end
end

function DialogueMgr.CloseUI(ui)
    if ui then
        UI.Close(ui)
    end
end

------------------------------------------------------------------------
--- 协议动画 （SequenceUserWidget）
------------------------------------------------------------------------
function DialogueMgr.SetSequencePause(value)
    local seq = UE4.UPlotLibrary.GetCurrentSequencer(GetGameIns());
    if seq then 
        seq:SetPause(value)
    end
    return seq;
end

function DialogueMgr.IsPlayingSequence()
    local seq = UE4.UPlotLibrary.GetCurrentSequencer(GetGameIns());
    return seq and true or false
end



return DialogueMgr
