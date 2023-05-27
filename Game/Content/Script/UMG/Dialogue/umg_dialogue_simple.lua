-- ========================================================
-- @File    : umg_dialogue_simple.lua
-- @Brief   : 简化版剧情对话栏
-- ========================================================
local tbClass = Class("UMG.BaseWidget")


function tbClass:Construct()
    self.OnLevelFinishHandle = EventSystem.On(Event.OnLevelFinish , function(nResult, nTime, nReason)
        self:CloseBindWwise()
    end)
 end

function tbClass:ReplacePlayerName(InContent)
    if not string.find(InContent, "playername") then
        return InContent
    end
    local Account = UE4.UAccount.Get(0)
    if Account then
        return string.gsub(InContent, 'playername', Account:Nick())
    end
    return InContent
end

function tbClass:OnOpen(InId)
    self.InId = InId or self.InId
    self.Data = Dialogue.tbData[InId] or self.Data
    if not self.Data then return end
    local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    local StartTime = TaskActor and TaskActor:GetLevelTime() or 4
    if InId then
        if StartTime >= 4 then
            self:PlayPlot(1)
        else
            WidgetUtils.Collapsed(self.CanvasPanel_143)
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
                self,
                function()
                    WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_143)
                    self:PlayPlot(1)
                end,
            }, 4 - StartTime, false)
        end
    end
end

-- 打开时不聚焦
function tbClass:DontFocus()
    return true;
end

function tbClass:PlayPlot(InIndex)
    if not self.Data then return end
    if InIndex > #self.Data or not self.Data[InIndex] then
        UI.Close(self)
        return
    end
    local data = self.Data[InIndex]
    local Content= data[Localization.sLanguage]
    if not Content or Content == "" then
        if GM.__IsOpen and Dialogue.ShowDialog then
            local msg = string.format("未在%s找到指定剧情 剧情名:%s - 剧情Id%s \n若选择关闭本次登录不再显示", Localization.sLanguage, self.InId, InIndex);
            print(msg)
            local Type = UE4.UGMLibrary.ShowDialogWithMsgType(UE4.EAppMsgType.OkCancel, "Simple Dialogue未找到剧情", msg);
            if Type == UE4.EAppReturnType.Cancel then
                Dialogue.ShowDialog = false
            end
        end
        UI.Close(self)
        return
    end
    self.TalkText:SetContent(self:ReplacePlayerName(data[Localization.sLanguage]))
    
    if self.ScrollPageBoxSimple then
        self.ScrollPageBoxSimple:ScrollToStart()
        if self.nTimer then
            UE4.Timer.Cancel(self.nTimer)
            self.nTimer = nil
        end
        self.nTimer = UE4.Timer.Add(0.05, function()
            self.nTimer = nil
            if self then
                self.ScrollPageBoxSimple:MoveToEnd(2, UE4.EMoveInterpType.CircularOut)
            end
        end)
    end

    local PlotRoleColumn = UE4.UPlotLibrary.GetPlotName2ImageData(data.Speaker)
    if PlotRoleColumn then
        --self.Speaker:SetText(string.format("%s:", PlotRoleColumn[Localization.sLanguage]))
        local sName = Localization.Get("plotrolename." .. PlotRoleColumn.RoleName)
        self.Speaker:SetText(self:ReplacePlayerName(sName) .. ":")
    else
        self.Speaker:SetText("")
    end
    if data.WwiseEventID then
        local StartTime = GetAccurateRealTime()
        self.Conponent = UE4.UWwiseLibrary.PostEvent2DWithCallback(GetGameIns(), data.WwiseEventID, {
            self,
            function()
                local EndTime = GetAccurateRealTime()
                if EndTime - StartTime < 0.2 then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
                        self,
                        function()
                            self:PlayPlot(InIndex + 1);
                        end,
                    }, 3, false)
                    return
                end
                self:PlayPlot(InIndex + 1);
            end
        })
    else
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
            self,
            function()
                self:PlayPlot(InIndex + 1);
            end,
        }, 3, false)
    end
end

function tbClass:CloseBindWwise()
    if self.Conponent then
        self.Conponent:Stop(false)
        UI.Close(self)
    end
end

function tbClass:OnGamePause(IsPause)
    if not self.Conponent then
        return
    end
    if IsPause then
        self.Conponent:PauseWithTransition()
    else
        self.Conponent:ResumeWithTransition()
    end
end

function tbClass:OnClose()
    EventSystem.Remove(self.OnLevelFinishHandle)
    DialogueMgr.OnClose(UE4.EUIDialogueType.SimplePlot,self.IsFromFight)
    if self.nTimer then
        UE4.Timer.Cancel(self.nTimer)
        self.nTimer = nil
    end
end

return tbClass
