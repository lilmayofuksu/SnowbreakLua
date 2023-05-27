-- ========================================================
-- @File    : umg_common_levelup.lua
-- @Brief   : 升级提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.CloseBtn, function() UI.Close(self) end)
end

---打开时的回调
---@param nBefore integer 旧等级
---@param nAfter integer 新等级
function tbClass:OnOpen(nBefore, nAfter, fCloseCallback)
    self.fCloseCallback = fCloseCallback
    self.TxtBefore:SetText(nBefore)
    self.TxtAfter:SetText(nAfter)
    local beforeCfg = Player.tbLevelCfg[nBefore]
    local afterCfg = Player.tbLevelCfg[nAfter]

    if beforeCfg == nil or afterCfg == nil then
        UI.Close(self)
        return
    end

    ---如果显示了对应节点就在特定时候播放音效
    self.tbSoundIsPlay = {}
    ---感知上限
    if beforeCfg.nMaxVigor == afterCfg.nMaxVigor then
        WidgetUtils.Collapsed(self.EnergyUp)
        self.tbSoundIsPlay[1] = false
    else
        WidgetUtils.HitTestInvisible(self.EnergyUp)
        self.TxtBeforeVigor:SetText(beforeCfg.nMaxVigor)
        self.TxtAfterVigor:SetText(afterCfg.nMaxVigor)
        self.tbSoundIsPlay[1] = true
    end

    local nBeforeVigor = me:Vigor() - (afterCfg.nGainVigor or 0)
    local nNowVigor = me:Vigor()
    if nBeforeVigor == nNowVigor then
        WidgetUtils.Collapsed(self.EnergyNow)
        self.tbSoundIsPlay[2] = false
    else
        WidgetUtils.HitTestInvisible(self.EnergyNow)
        self.TxtBeforeCurr:SetText(nBeforeVigor)
        self.TxtAfterCurr:SetText(nNowVigor)
        self.tbSoundIsPlay[2] = true
    end

    ---好友上限
    if beforeCfg.nMaxFriends == afterCfg.nMaxFriends then
        WidgetUtils.Collapsed(self.Friend)
        self.tbSoundIsPlay[3] = false
    else
        WidgetUtils.HitTestInvisible(self.Friend)
        self.TxtBeforeFriend:SetText(beforeCfg.nMaxFriends)
        self.TxtAfterFriend:SetText(afterCfg.nMaxFriends)
        self.tbSoundIsPlay[3] = true
    end

    ---功能解锁
    WidgetUtils.Collapsed(self.Function)
    local bHasFuncTip = false
    if afterCfg.nFunctionID then
        local funCfg = FunctionRouter.Get(afterCfg.nFunctionID)
        if funCfg and funCfg.sUnlocktip and funCfg.sUnlocktip ~= '' then
            WidgetUtils.HitTestInvisible(self.Function)
            SetTexture(self.FunctionIcon, funCfg.nUnlockpic)
            self.TxtOpenDes:SetText(Text(funCfg.sUnlocktip))
        end
    end

    Audio.PlaySounds(3020)
end

function tbClass:PlaySoundByIndex(Index)
    if self.tbSoundIsPlay and self.tbSoundIsPlay[Index] then
        Audio.PlaySounds(3050)
    end
end


function tbClass:OnClose()
    if self.fCloseCallback then
        self.fCloseCallback()
        self.fCloseCallback = nil
    end
end

return tbClass
