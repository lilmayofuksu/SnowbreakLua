-- ========================================================
-- @File    : RuntimeState.lua
-- @Brief   : 运行时状态记录
-- ========================================================

RuntimeState = RuntimeState or {}

---切换输入
function RuntimeState.ChangeInputMode(bShow)
    print('RuntimeState.ChangeInputMode', bShow)
    UE4.UUMGLibrary.ChangeInputMode(GetGameIns(), bShow)
end

function RuntimeState.GetLoadSettlementUIPath()
    local nType = Launch.GetType()
    if nType == LaunchType.BOSS then
        return "/Game/UI/UMG/Settlement/Widgets/uw_settlement_boss.uw_settlement_boss_C"
    elseif nType == LaunchType.DAILY then
        return "/Game/UI/UMG/Settlement/Widgets/uw_settlement_info.uw_settlement_info_C"
    elseif nType == LaunchType.ONLINE then
        return "/Game/UI/UMG/Settlement/Widgets/uw_settlement_online.uw_settlement_online_C"
    elseif nType == LaunchType.Challenge then
        return "/Game/UI/UMG/Settlement/Widgets/uw_settlement_record.uw_settlement_record_C"
    elseif nType == LaunchType.DEFEND then
        return "/Game/UI/UMG/Settlement/Widgets/uw_settlement_round.uw_settlement_round_C"
    end
end

function RuntimeState.GetSafeZoneSaveValue()
    if me and me:IsLogined() then
        local nValue = PlayerSetting.GetOne(PlayerSetting.SSID_OTHER, OtherType.UI_SAFE_ZONE_SCALE)
        return nValue
    end
    return UE4.UUserSetting.GetInt('PLAYER_SETTING_SAFE_ZONE', -1)
end

function RuntimeState.GetDefaultSafeZoneValue()
    local tbDefault = PlayerSetting.GetDefault(PlayerSetting.SSID_OTHER, OtherType.UI_SAFE_ZONE_SCALE)
    return tbDefault[2] or 100
end