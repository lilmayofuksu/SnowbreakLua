-- ========================================================
-- @File    : umg_success.lua
-- @Brief   : 战斗胜利界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:PlayCharacterAnim()
    local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(self)
    if not TaskActor then
        return
    end
    TaskActor.VictorySequenceFinish:Add(
        self,
        function()
            self:End()
        end
    )
    WidgetUtils.SelfHitTestInvisible(self.Node)
    self:BindToAnimationEvent(
            self.victory_00,
            {
                self,
                function()
                    if TaskActor.bPlayFinishAnim then
                        WidgetUtils.Collapsed(self)
                        self:OpenSuccessShow()
                    end
                    TaskActor:LevelFinishPerform()
                end
            },
            UE4.EWidgetAnimationEvent.Finished
        )
    self:PlayAnimation(self.victory_00)

    if self.nDelayLoadTimer then
        UE4.Timer.Cancel(self.nDelayLoadTimer)
        self.nDelayLoadTimer = nil
    end

    self.nDelayLoadTimer = UE4.Timer.Add(0.1, function()
        self.nDelayLoadTimer = nil
        local uMGStreamingSubsystem = UE4.UUMGStreamingSubsystem.GetAssetStreamingSubsystem()
        if not uMGStreamingSubsystem or (not uMGStreamingSubsystem.RequestStreamingByTag)  then return end
        local tbAsset = {
            '/Game/UI/UMG/SuccessShow/umg_successshow.umg_successshow_C',
            '/Game/UI/UMG/Settlement/umg_settlement.umg_settlement_C',
            '/Game/UI/UMG/Settlement/Widgets/uw_widgets_itemnum_list.uw_widgets_itemnum_list_C',
            '/Game/UI/UMG/Widgets/uw_widgets_item_list.uw_widgets_item_list_C',
        }

        local sSettlementUIPath = RuntimeState.GetLoadSettlementUIPath()
        if sSettlementUIPath then
            table.insert(tbAsset, sSettlementUIPath)
        end

        ---角色头像
        local nIdx = Formation.GetCurLineupIndex()
        if nIdx then
            local pLineup = me:GetLineup(nIdx)
            if pLineup then
                local members = pLineup.Members
                if members then
                    for i = 1, members:Length() do
                        local pCard = members:Get(i)
                        if pCard then
                            local nIcon = pCard:Icon()
                            if nIcon then
                                local sIconPath = Resource.Get(Resource.GetPaintingID(nIcon, 'p5'))
                                if sIconPath then
                                    table.insert(tbAsset, sIconPath)
                                end
                            end
                        end
                    end
                end
            end
        end

        ---获得道具
        for _, tbInfo in ipairs(Launch.tbAward or {}) do
            for _, info in ipairs(tbInfo) do
                local G, D, P, L, _, _, _ = table.unpack(info)
                local pTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(G, D, P, L)
                if pTemplate then
                    local nIcon = pTemplate.Icon
                   
                    if nIcon then
                        local sPath = Resource.Get(Resource.GetPaintingID(nIcon, 'p3'))
                        if sPath then
                            table.insert(tbAsset, sPath)
                        end
                    end
                end
            end
        end
        

        local sTag = 'FIGHT_SUCCESS'
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
    if Launch.GetType() ~= LaunchType.TOWER then
        if UI.IsOpen('MessageBox') and Reconnect.isShowReconnectBox then return end
        UI.Open("Settlement")
        self:CloseSuccessShow()
        Audio.PlaySounds(3010)
        UI.Close(self, nil, true)
    end

    -- 销毁所有角色
    UE4.ULevelLibrary.DestroyAllCharacter(GetGameIns());
end

function tbClass:TowerEnd()
    if Launch.GetType() == LaunchType.TOWER then
        if UI.IsOpen('MessageBox') then return end
        Launch.End()
    end
end

function tbClass:OpenSuccessShow()
    if UE4.AGameTaskActor.GetGameTaskActor(self):HasAuthority() then
        UI.Open("SuccessShow")
    end
end

function tbClass:CloseSuccessShow()
    UI.Close("SuccessShow")
end

function tbClass:CanEsc()
    return false
end


return tbClass
