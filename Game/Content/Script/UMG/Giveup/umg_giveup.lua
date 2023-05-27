-- ========================================================
-- @File    : umg_giveup.lua
-- @Brief   : 放弃战斗
-- ========================================================
---@class tbClass : ULuaWidget

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnCancel, function()
        UI.Close(self)
    end)
    BtnAddEvent(self.BtnConfirm, function()
        if (self == nil) then return end
        self:ClearTimer()
        self.nTimer = UE4.Timer.Add(0.05, function()
             self.nTimer = nil
             self:OnGiveUp()
        end)
    end)
end

function tbClass:OnGiveUp()
    if (self == nil) then return end
    -- 联机直接放弃
    if Launch.GetType() ~= LaunchType.ONLINE then
        local pTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
        if pTaskActor then
            pTaskActor:LevelFinishBroadCast(UE4.ELevelFinishResult.Failed, UE4.ELevelFailedReason.ManualExit)

            pTaskActor:RPC_PlayCharacterVoice('giveup')
        end
    else
        Online.DoGiveUp()
        Launch.End()
    end

    --UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), 'giveup');

end

function tbClass:ClearTimer()
    if self == nil then return end
    if self.nTimer then
        UE4.Timer.Cancel(self.nTimer)
        self.nTimer = nil
    end
end

function tbClass:OnOpen()
    if Launch.GetType() == LaunchType.DEFEND then
        self.Text:SetText(Text("ui.Defense_Level_Quit"))
    else
        self.Text:SetText(Text("ui.TxtFightGiveup"))
    end
end

function tbClass:OnClose()
    self:ClearTimer()
end

return tbClass