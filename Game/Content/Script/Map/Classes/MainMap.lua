-- ========================================================
-- @File    : MainMap.lua
-- @Brief   : MainMap
-- ========================================================

---@class tbClass 
local tbClass = Map.Class('MainMap')

function tbClass:OnEnter(nMapID)
    self.bLeave = false
    UI.CloseAll()
    Online.CheckTeamUI()
    PreviewScene.HiddenAll()

    if not UI.RecoverUI() then
        PreviewScene.Enter(PreviewType.main, function() end)
        UI.Open('Main')
    else
        PreviewScene.PreloadScene(PreviewType.main)
    end

    self:EnterEvent()
    UE4.UGameLocalPlayer.SetAutoAdapteToScreen(true)

    FunctionRouter.UpdateOpenFunction()
    PreviewScene.AsyncLoadMainMap()
end

function tbClass:OnLeave(nMapID)
    if self.bLeave then return end
    self.bLeave = true

    self:LeaveEvent()
    UI.CloseAll(true)
    PreviewScene.Reset()
    PreviewMain.Clear()
    UE4.UGameLocalPlayer.SetAutoAdapteToScreen(false)
    PreviewScene.tbCacheActor = {}
    PreviewScene.ClearLoadMainMap()
end

function tbClass:EnterEvent()
    if not self.EventNextDay then
        self.EventNextDay = EventSystem.On(Event.ServerNextDay, function()
            UI.ServerNextDay()
            me:FriendlistRefresh()
        end)
    end

    if not self.nLevelUpHandle then
        self.nLevelUpHandle = EventSystem.On(Event.LevelUp, function(nNewLevel, nOldLevel);
           UE4.Timer.Add(0.2, function()
            FunctionRouter.ShowLevelUpTip(nNewLevel, nOldLevel)
           end)
        end)
    end
end

function tbClass:LeaveEvent()
    if self.nLevelUpHandle then
        EventSystem.Remove(self.nLevelUpHandle)
        self.nLevelUpHandle = nil
    end

    if self.EventNextDay then
        EventSystem.Remove(self.EventNextDay)
        self.EventNextDay = nil
    end
end

function tbClass:OnlineEvent(bLeave)
    if bLeave then
        self:LeaveEvent()
    else
        self:EnterEvent()
    end
end

return tbClass
