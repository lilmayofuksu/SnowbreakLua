-- ========================================================
-- @File    : umg_fail.lua
-- @Brief   : 失败动画
-- ========================================================
---@class tbClass : ULuaWidget

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnOpen()
    RuntimeState.ChangeInputMode(true)

    if self.nDelayLoadTimer then
        UE4.Timer.Cancel(self.nDelayLoadTimer)
        self.nDelayLoadTimer = nil
    end

    self.nDelayLoadTimer = UE4.Timer.Add(0.1, function()
        self.nDelayLoadTimer = nil
        local uMGStreamingSubsystem = UE4.UUMGStreamingSubsystem.GetAssetStreamingSubsystem()
        if not uMGStreamingSubsystem or (not uMGStreamingSubsystem.RequestStreamingByTag)  then return end

        local sOther = ''
        if Launch.GetType() == LaunchType.DEFEND or Launch.GetType() == LaunchType.ONLINE then
            sOther = '/Game/UI/UMG/Settlement/umg_settlement.umg_settlement_C'
        else
           sOther = '/Game/UI/UMG/Defead/umg_defead.umg_defead_C'
        end

        local tbAsset = { sOther, }
        local sTag = 'FIGHT_FAIL'
        for _, path in ipairs(tbAsset) do
            uMGStreamingSubsystem:RequestStreamingByTag(sTag, path)
        end
    end)
end

function tbClass:OnClose()
    if self.nDelayLoadTimer then
        UE4.Timer.Cancel(self.nDelayLoadTimer)
        self.nDelayLoadTimer = nil
    end
end

function tbClass:End()
    if UI.IsOpen('MessageBox') and Reconnect.isShowReconnectBox then return end
    -- 联机或死斗活动失败视为成功
    if Launch.GetType() == LaunchType.DEFEND or Launch.GetType() == LaunchType.ONLINE then
        UI.Open("Settlement")
        Audio.PlaySounds(3010)
        UI.Close(self, nil, true)
    else
        UI.Open("Defead")
        UI.Close(self, nil, true)
    end

    UE4.ULevelLibrary.DestroyAllCharacter(GetGameIns());
end

function tbClass:CanEsc()
    return false
end


return tbClass