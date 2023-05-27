-- ========================================================
-- @File    : uw_formation_online.lua
-- @Brief   : 联机阵容界面 显示自己信息
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(self.BtnInvite, function()
        self:DoChangeMem(0)
    end)

    BtnAddEvent(self.BtnCard1, function()
        self:DoChangeMem(1)
    end)

    BtnAddEvent(self.BtnCard2, function()
        self:DoChangeMem(2)
    end)

    BtnAddEvent(self.BtnOnline, function()
        self:DoFight()
    end)

    BtnAddEvent(self.BtnUnable, function()
        UI.ShowTip("error.714")
    end)

    BtnAddEvent(self.BtnInfo, function()
        self:ShowLevelInfo()
    end)

    BtnAddEvent(self.BtnClose, function()
        self:ShowBuffBtn(false)
    end)

    self.MatchCheck.OnCheckStateChanged:Add(
         self,
         function(_, bChecked)
            self:ClickMatchBtn(bChecked)
         end
     )

    -- self.EnergyCheck.OnCheckStateChanged:Add(
    --      self,
    --      function(_, bChecked)
    --         if not self:CheckGameStatus() then
    --             return
    --         end

    --         Online.VigourSwitch(bChecked)
    --      end
    --  )

    self.ListFactory = self.ListFactory or Model.Use(self)
end

---UI打开
function tbClass:OnOpen(nTeamId)
    self.ListFactory = self.ListFactory or Model.Use(self)
    self.tbCaptain = Online.GetCaptain()
    self.tbStateFlag = Online.GetStateFlag()
	self.Index = 0 --主位少女
    self.TeamId = nTeamId

    local  tbConfig = Online.GetConfig(Online.GetOnlineId())
    if tbConfig and tbConfig.sName then
        self.TxtTitle:SetText(Text(tbConfig.sName))
    end

    self:UpdateRoomInfo()

    WidgetUtils.Collapsed(self.LevelInfo)
    WidgetUtils.Collapsed(self.Player)
    WidgetUtils.Collapsed(self.EnergyCheck)
    WidgetUtils.Collapsed(self.Tips)

    if Online.GetMatchState() then 
        self.MatchCheck:SetCheckedState(1)
        self:DoCheckMatch(true, true)
    else
        self.MatchCheck:SetCheckedState(0)
        self:DoCheckMatch(false, true)
    end

    self:ShowGainRole(tbConfig)

    EventSystem.TriggerTarget(
        Survey,
        Survey.POST_SURVEY_EVENT,
        Survey.ONLINE
    )

    SetScreenSaver(false)
end

--获取当前匹配按钮状态
function tbClass:GetMatchCheckState()
    return self.MatchCheck:GetCheckedState()
end

function tbClass:OnClose()
    if WidgetUtils.IsVisible(self.Player2) then
        self.Player2:OnClose()
    end

    if WidgetUtils.IsVisible(self.Player3) then
        self.Player3:OnClose()
    end
    
    SetScreenSaver(true)
    self.ShowInfo = nil
end

function tbClass:OnDisable()
    if WidgetUtils.IsVisible(self.Player2) then
        self.Player2:OnDisable()
    end

    if WidgetUtils.IsVisible(self.Player3) then
        self.Player3:OnDisable()
    end

    self.ShowInfo = nil
end

--显示关卡信息
function tbClass:ShowLevelInfo()
    -- local tbLevelInfo = Online.GetConfig(Online.GetOnlineId())
    -- if not WidgetUtils.IsVisible(self.LevelInfo) and tbLevelInfo then
    --     self.LevelInfo:Show(tbLevelInfo, function() end )
    --     self.LevelInfo:CollapsedBtn()
    --     WidgetUtils.SelfHitTestInvisible(self.LevelInfo)
    -- else
    --   WidgetUtils.Collapsed(self.LevelInfo)
    -- end
end

--显示自己信息
function tbClass:ShowMeInfo()
    Formation.SetCurLineupIndex(self.TeamId)
    --Preview.SetLightDir(UE4.FRotator(0, -42, 0))

	self.TextBlock_88:SetText(me:Nick())
	self.TextLvNum:SetText(me:Level())

    if self.tbCaptain[self.Index+1] then
        WidgetUtils.SelfHitTestInvisible(self.Leader)
       -- WidgetUtils.SelfHitTestInvisible(self.MatchCheck)

        local bAllReady = true
        for i=2,#self.tbStateFlag do
            if self.tbStateFlag[i] ~= Online.Player_State_Ready then
                bAllReady = false
                break
            end
        end

        if bAllReady then
            WidgetUtils.Collapsed(self.BtnUnable)
            WidgetUtils.Visible(self.BtnOnline)
        else
            WidgetUtils.Visible(self.BtnUnable)
            WidgetUtils.Collapsed(self.BtnOnline)
        end
    else 
        WidgetUtils.Collapsed(self.Leader)
      --  WidgetUtils.Collapsed(self.MatchCheck)
        WidgetUtils.Collapsed(self.BtnUnable)
        WidgetUtils.Visible(self.BtnOnline)
    end

    local nStateFlag = self.tbStateFlag[self.Index+1]
    if nStateFlag > Online.Player_State_Empty then
        if self.tbCaptain[self.Index+1] then --自己是队长
            self.TextBlock_166:SetText(Text("ui.TxtOnlineFight"))
        else
            self.TextBlock_166:SetText(Text("ui.TxtOnlineCancel"))
        end

        WidgetUtils.Collapsed(self.Prepare)
        WidgetUtils.SelfHitTestInvisible(self.Completed)

        self.TxtCompleted:SetText(Online.GetStateText(nStateFlag))
    else
        self.TextBlock_166:SetText(Text("ui.TxtOnlineFight"))
        if self.tbCaptain[self.Index+1] then --自己是队长 队长 始终准备完毕
            WidgetUtils.Collapsed(self.Prepare)
            WidgetUtils.SelfHitTestInvisible(self.Completed)
            self.TxtCompleted:SetText(Online.GetStateText(Online.Player_State_Ready))
        else
            if #self.tbCaptain > 1 then
                self.TextBlock_166:SetText(Text("ui.TxtOnlineCompleted"))
            end

            WidgetUtils.Collapsed(self.Completed)
            WidgetUtils.SelfHitTestInvisible(self.Prepare)
        end
    end

    self.TeamRuleID = 0
    local Member = Formation.GetMember(self.Index)
    if not Member then return end
    if self.TeamRuleID > 0 then --留着队伍规则
        ---读取配置
        self.tbLimitConfig = TeamRule.tbTeamRule[self.TeamRuleID]
        if self.tbLimitConfig == nil then
            return 
        end
    end

    self:ShowMemberInfo()
end

---显示队员信息
function tbClass:ShowMemberInfo()
    if Online.MaxTeammate >= 2 then
        WidgetUtils.SelfHitTestInvisible(self.SubCard1)
    else
        WidgetUtils.Collapsed(self.SubCard1)
    end
    if Online.MaxTeammate >= 3 then
        WidgetUtils.SelfHitTestInvisible(self.SubCard2)
    else
        WidgetUtils.Collapsed(self.SubCard2)
    end

    local Member = Formation.GetMember(self.Index)
    --显示首位的模型
    if Member then
        local pCardInfo = Formation.GetCardByIndex(self.TeamId, 0)
        local nWeaponId = pCardInfo and pCardInfo:GetSlotWeapon() or 0

        if UI.IsOpen("Formation") and (not self.ShowInfo or self.ShowInfo[1] ~= Member:GetUID() or self.ShowInfo[2] ~= nWeaponId) then
            Formation.UpdateModel(self.Index, Member:GetUID())
            self.ShowInfo = {Member:GetUID(), nWeaponId}
        end
    end

    --1号位
    local pCard = Formation.GetCardByIndex(self.TeamId, 1)
    if pCard and Online.MaxTeammate >= 2 then
        WidgetUtils.SelfHitTestInvisible(self.Mask1)
        WidgetUtils.SelfHitTestInvisible(self.Img2)
        SetTexture(self.Girl1, pCard:Icon(), true)
        self.Image_709:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("FFFFFFFF"))
    else
        WidgetUtils.Collapsed(self.Mask1)
        WidgetUtils.Collapsed(self.Img2)
        self.Image_709:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("03061F66"))
    end

    --2号位
    pCard = Formation.GetCardByIndex(self.TeamId, 2)
    if pCard and Online.MaxTeammate >= 3 then
        WidgetUtils.SelfHitTestInvisible(self.Mask2)
        WidgetUtils.SelfHitTestInvisible(self.Img2_1)
        SetTexture(self.Girl2, pCard:Icon(), true)
        self.Image_6:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("FFFFFFFF"))
    else
        WidgetUtils.Collapsed(self.Mask2)
        WidgetUtils.Collapsed(self.Img2_1)
        self.Image_6:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("03061F66"))
    end
end


--点击更换少女
function tbClass:DoChangeMem(nPos)
    if not nPos then return end

    if Online.GetOnlineState() >= Online.STATUS_READY then
        UI.ShowTip("tip.online_RoomReadyError")
        return 
    end

    Formation.SetMemberPos(nPos)

    local Member = Formation.GetMember(nPos)
    self.pCard = Member:GetCard()

    Online.UpdatePlayerState(Online.Player_State_Change)
    UI.Open("Role", 2, self.pCard, self:GetTbCard())
end

function tbClass:GetCards()
    local Cards = UE4.TArray(UE4.UCharacterCard)
    ---试玩角色
    if self.tbLimitConfig and #self.tbLimitConfig.tbTrailID > 0 then
        for _, v in ipairs(self.tbLimitConfig.tbTrailID) do
            Cards:Add(UE4.UTrailItem.GetTrialCard(v))
        end
    else
        me:GetCharacterCards(Cards)
    end
    return Cards
end
function tbClass:GetTbCard()
    local Cards = self:GetCards()
    local tbCard = {}
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        table.insert(tbCard, card)
    end
    return tbCard
end

---显示其他玩家
function tbClass:ShowOthers()
    local getInfo = function (nIndex)
        if not nIndex then return end

        local tbParam = {
            nTeamId = self.TeamId,
            nIndex = nIndex,
            bCaptain = self.tbCaptain and self.tbCaptain[nIndex+1] or false,
            nStateFlag = self.tbStateFlag and self.tbStateFlag[nIndex+1] or 0,
            bMyCaptain = self.tbCaptain and self.tbCaptain[1] or false,
            fInviteFunc = function(nIdx) self:ShowInviteInfo() end
        }
        return tbParam
    end

    local  tbConfig = Online.GetConfig(Online.GetOnlineId())
    if tbConfig and tbConfig.nMaxPlayer >= 2 then
        WidgetUtils.SelfHitTestInvisible(self.Player2)
        self.Player2:OnOpen(getInfo(1))
    else
        WidgetUtils.Collapsed(self.Player2)
    end

    if tbConfig and tbConfig.nMaxPlayer >= 3 then
        WidgetUtils.SelfHitTestInvisible(self.Player3)
        self.Player3:OnOpen(getInfo(2))
    else
        WidgetUtils.Collapsed(self.Player3)
    end
    
    self:ShowGainRole(tbConfig)
end

--进入战斗
function tbClass:DoFight()
    if not self:CheckGameStatus() then
        return
    end

    --没有队长
    if not Formation.GetCaptain() then
        UI.ShowTip("tip.not_captain")
        return
    end

    --关卡信息
    if not Online.CheckOnlineLevel(Online.GetOnlineId()) then
        UI.ShowTip("tip.congif_err")
        return
    end

    --判断体力是否不足
    local  tbConfig = Online.GetConfig(Online.GetOnlineId())
    if tbConfig and tbConfig.nConsumeVigor > 0 and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < tbConfig.nConsumeVigor then
        if not UI.IsOpen("PurchaseEnergy") then
            UI.Open("PurchaseEnergy", "Energy")
        end
        return
    end

    if #self.tbCaptain == 1 then
        UI.Open(
                "MessageBox",
                string.format(Text("ui.TxtOnlineSingleFight"),sName),
                function()
                    Online.ReadyRoom(self.tbStateFlag[self.Index+1])
                end,
                function()
                end
            )
    else
        --其他判断
        Online.ReadyRoom(self.tbStateFlag[self.Index+1])
    end
end

--打开匹配
function tbClass:DoCheckMatch(nState, bSkip, bNewUp)
    if nState then
        local bNewShow = WidgetUtils.IsVisible(self.CheckMark)
        WidgetUtils.SelfHitTestInvisible(self.CheckMark)
        WidgetUtils.Collapsed(self.Backgroud)
        WidgetUtils.SelfHitTestInvisible(self.Time)

        if not bNewShow or bNewUp then
            self.TxtMatch:SetText(Text("TxtOnlineMatch2"))
            self.nShowSec = 0
            self.detime = 0
            self.TxtTime:SetText(string.format("%s%s", self.nShowSec, Text("ui.TxtTimeSec")))
        end
    else
        WidgetUtils.Collapsed(self.CheckMark)
        WidgetUtils.SelfHitTestInvisible(self.Backgroud)
        WidgetUtils.Collapsed(self.Time)
        self.TxtMatch:SetText(Text("TxtOnlineMatch"))
    end

    Online.SetMatchState(nState)

    if not bSkip then
        Online.MatchSwitch(nState)
    end
end

--打开消耗
function tbClass:DoCheckEnergy(nState, bSkip)
    if not bSkip then
        if not Online.VigourSwitch(nState) then
            self.EnergyCheck:SetCheckedState(Online.GetVigorSwitch())
            return
        end
    end

    if nState then
        WidgetUtils.SelfHitTestInvisible(self.CheckMark_1)
        WidgetUtils.Collapsed(self.Backgroud_1)
    else
        WidgetUtils.Collapsed(self.CheckMark_1)
        WidgetUtils.SelfHitTestInvisible(self.Backgroud_1)
    end
end

--服务器返回房间信息 参看 Online.lua 调用的地方
function tbClass:UpdateRoomInfo(nState, nParam1, nParam2, nParam3, nParam4)
    if  nState == 2 then
        self:SetCheckBtnState(nParam1)
        self:DoCheckMatch(nParam1, true)

        if nParam1  then
            UI.ShowTip("tip.online_OpenMatch")

            if UI.IsOpen("OnlineInvite") and #Online.tbReceiveInviteList == 0 then
                UI.Close("OnlineInvite")
            end
        end
    elseif nState == 5 then
        local bNewUp = false
        if nParam1  then
            local nOldNum = #self.tbCaptain
            for i = 1, nParam1:Length() do
                self.tbCaptain[i] = nParam1:Get(i)
            end

            if #self.tbCaptain > nParam1:Length() then
                for i=nParam1:Length()+1,#self.tbCaptain do
                    self.tbCaptain[i] = nil
                end
            end

            local  tbConfig = Online.GetConfig(Online.GetOnlineId())
            if nOldNum ~= #self.tbCaptain then
                bNewUp = true

                if self.tbCaptain[1] then
                    if self.MatchCheck:GetCheckedState() == 0 and tbConfig  and tbConfig.nMaxPlayer == nOldNum then
                        if not UI.IsOpen("OnlineInvite") then
                            UI.Open("OnlineInvite", nil, nil, function () self:ClickMatchBtn(true) end)
                        end
                    end
                end
            end


            if tbConfig  and tbConfig.nMaxPlayer == #self.tbCaptain then
                if UI.IsOpen("OnlineInvite") and #Online.tbReceiveInviteList == 0 then
                    UI.Close("OnlineInvite")
                end
            end
        end

        if nParam2 then
            local nSelfReady = self.tbStateFlag[1]
            for i = 1, nParam2:Length() do
                self.tbStateFlag[i] = nParam2:Get(i)
            end

            if #self.tbStateFlag > nParam2:Length() then
                for i=nParam2:Length()+1,#self.tbStateFlag do
                    self.tbStateFlag[i] = nil
                end
            end
            if nSelfReady ~= self.tbStateFlag[1] then
                if  self.tbStateFlag[1] < Online.Player_State_Ready and Online.GetOnlineState() < Online.STATUS_ENTER then
                    Online.SetOnlineState(Online.STATUS_OPEN)
                end
            end
        end

        self:SetCheckBtnState(nParam3)
        self:DoCheckMatch(nParam3, true, bNewUp)
        if nParam3 and not self.tbCaptain[self.Index+1] and not WidgetUtils.IsVisible(self.CheckMark) then
            UI.ShowTip("tip.online_OpenMatch")
        end

        if nParam4 then
            Online.SetWeekBuff(nParam4)
        end
    elseif nState == 6 then
        if nParam1 == nil then
            if  self.tbCaptain[self.Index+1] then
                Online.SetOnlineState(Online.STATUS_OPEN)
            else
                Online.SetOnlineState(Online.STATUS_READY)
            end

            if #self.tbStateFlag > 0 then
                for i=1,#self.tbStateFlag do
                    if self.tbCaptain[i] then
                        self.tbStateFlag[i] = Online.Player_State_Empty
                        break
                    end
                end
            end
        elseif nParam1 ~= nil then
            self:SetCheckBtnState(nParam1)
            self:DoCheckMatch(nParam1, true)

            if #self.tbStateFlag > 0 then
                for i=1,#self.tbStateFlag do
                    self.tbStateFlag[i] = Online.Player_State_Ready
                end
            end
        end
    elseif nState == 10 then
        self:ShowInviteInfo(true)
        return
    elseif nState == 15 then
        if nParam1 and nParam1 > 0 then
            local bFlag = nParam1 == 2
            self:SetCheckBtnState(bFlag)
            self:DoCheckMatch(bFlag, true, true)
        end

        if nParam2 then
            for i = 1, nParam2:Length() do
                local nReadyFlag = nParam2:Get(i)
                if nReadyFlag >= 0 then
                    self.tbStateFlag[i] = nReadyFlag
                end
            end
        end

        self:ShowKickOutTips()
    end

    -- 更新自己信息
    self:ShowMeInfo()

    --更新其他玩家信息
    self:ShowOthers()

    --体力开关
   -- self.EnergyCheck:SetCheckedState(Online.GetVigorSwitch())
   -- self:DoCheckEnergy(Online.GetVigorSwitch() > 0, true)
end

--显示邀请界面 
function tbClass:ShowInviteInfo(bForced)
    if not WidgetUtils.IsVisible(self.Player) and not bForced then
        self.Player:OnOpen()
        WidgetUtils.SelfHitTestInvisible(self.Player)
    else
        WidgetUtils.Collapsed(self.Player)
    end
end

--设置 check按钮
function tbClass:SetCheckBtnState(nState)
    if self.MatchCheck:GetCheckedState() == 0 and nState then
        self.MatchCheck:SetCheckedState(1)
    elseif self.MatchCheck:GetCheckedState() == 1 and not nState then
        self.MatchCheck:SetCheckedState(0)
    end
end

--当游戏开始后 不能进行其他操作
function tbClass:CheckGameStatus()
    if Online.GetOnlineState() >= Online.STATUS_ENTER then
        UI.ShowTip("tip.online_RoomStateError")
        return false
    end

    return true
end

function tbClass:Tick(InDeltaTime)
    self:ShowTime(InDeltaTime)

    --跟单机 编队保持一致
    self.TickTime = self.TickTime or 5
    if self.TickTime > 0 then
        self.TickTime = self.TickTime - 0.1
    else
        return
    end

    if not Formation.Actor then return end
    
    local WorldPos = Formation.GetPos(0)
    if WorldPos then
        -- local NewTransform = UE4.FTransform()
        -- NewTransform.Translation = Formation.Actor:K2_GetActorLocation()
        -- NewTransform.Rotation = Formation.Actor:K2_GetActorRotation()
        -- Preview.GetModel():UpdateTransform(NewTransform)

        -- WorldPos.Y = WorldPos.Y - 20
        local ScreenPos = UE4.FVector2D()
        UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(self:GetOwningPlayer(), WorldPos, ScreenPos, true)

        local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Player1)
        local MakePos = UE4.FVector2D()
        MakePos.Y = Slot:GetPosition().Y
        MakePos.X = ScreenPos.X - math.floor(Slot:GetSize().X / 3)
        Slot:SetPosition(MakePos)
    end

    self.Player2:Tick()
    self.Player3:Tick()
end

--刷新时间  每秒
function tbClass:ShowTime(InDeltaTime)
    if not self.detime then self.detime = 0 end

    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end

    self.detime = 0

    Online.CheckForKickCaptain()
    self:ShowKickOutTips()
    if self.MatchCheck:GetCheckedState() == 0 or not self.nShowSec then
        return
    end

    self.nShowSec = self.nShowSec + 1
    if self.nShowSec >= 3600 then
        self.TxtTime:SetText(Text("ui.TxtOneHour"))
        self.detime = 0.1 --不用计时了
        return
    end

    local nMin = math.floor(self.nShowSec / 60)
    local nSec = math.floor(self.nShowSec % 60)

    local strTime = ""
    if nMin > 0 then
        strTime = strTime .. string.format("%s%s", nMin, Text("ui.TxtTimeMin"))
    end
  
    strTime = strTime .. string.format("%s%s", nSec, Text("ui.TxtTimeSec"))

    self.TxtTime:SetText(strTime)
end

--点击匹配按钮
function tbClass:ClickMatchBtn(bChecked)
    if not self:CheckGameStatus() then
        self:SetCheckBtnState(not bChecked)
        return
    end

    if not self.tbCaptain[self.Index+1] then
        UI.ShowTip("error.715")
        self:SetCheckBtnState(not bChecked)
        return
    end

    if bChecked then
        --判断体力是否不足
        local  tbConfig = Online.GetConfig(Online.GetOnlineId())
        if tbConfig and tbConfig.nConsumeVigor > 0 and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < tbConfig.nConsumeVigor then
            if not UI.IsOpen("PurchaseEnergy") then
                UI.Open("PurchaseEnergy", "Energy")
            end
            return
        end
    end

    Online.MatchSwitch(bChecked)
end

--显示被踢倒计时
function tbClass:ShowKickOutTips()
    if not Online.CheckMemberAllReady() then
        WidgetUtils.Collapsed(self.Tips)
        return
    end

    local nTime = Online.GetReadyTime()
    if nTime <= 0 then
        WidgetUtils.Collapsed(self.Tips)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.Tips)

    local nLeftTime = math.floor(nTime + Online.Ready_Kick_Time - GetTime())
    if nLeftTime < 0 then
        return
    end

    local leftTime = string.format(Text("ui.TxtOnlineTip"), tostring(nLeftTime))
    self.TxtTips:SetContent(leftTime)
end

--显示关闭buff按钮
function tbClass:ShowBuffBtn(bFlag)
    WidgetUtils.SetVisibleOrCollapsed(self.BtnClose, bFlag)

    if not bFlag then
        self.Buff1:CloseInfo()
        self.Buff2:CloseInfo()
    end
end

--显示buff信息
function tbClass:ShowBuffInfo()
    local tbBuffInfo = Online.GetBuffInfo()
    for i=1,2 do
        local buffInfo = tbBuffInfo and {tbBuffInfo[(i-1)*2+1], tbBuffInfo[(i-1)*2+2]}
        local buffName = "Buff"..i
        if buffInfo then
            WidgetUtils.SelfHitTestInvisible(self[buffName])
            self[buffName]:ShowBuff(buffInfo, function(bFlag) self:ShowBuffBtn(bFlag)  end)
        else
            WidgetUtils.Collapsed(self[buffName])
        end
    end
end

--联机显示上阵加成角色
function tbClass:ShowGainRole(tbCfg)
    if not tbCfg then 
        WidgetUtils.Collapsed(self.TxtRoleUp)
        WidgetUtils.Collapsed(self.ListRoleUp)
        return 
    end

    WidgetUtils.SelfHitTestInvisible(self.ListRoleUp)

    local findCard = function(tbParam, tbPickCard)
        if not tbParam or not  tbPickCard then return end
        for _, member in ipairs(tbPickCard) do
            if member and #member >= 4 and 1 == member[1] and tbParam[1] == member[2] and tbParam[2] == member[3] then
                return true
            end
        end
    end

    self.ListRoleUp:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListRoleUp)
    local tbRoles = Online.GetWeekGainRole(tbCfg) or {}
    local tbPickCard = Online.GetPickCard() or {}
    local nFindNum = 0
    for _, info in ipairs(tbRoles) do
        local itemTemp = UE4.UItem.FindTemplate(1, info[1], info[2], 1)
        if itemTemp then
            local nRet = findCard(info, tbPickCard)
            local data = {
                nIcon = itemTemp.Icon,
                bGray = not nRet,
                FunClick = function() UI.Open("ItemInfo", 1, info[1], info[2], 1) end
            }

            if nRet then
                nFindNum = nFindNum + 1
            end

            local pObj = self.ListFactory:Create(data)
            self.ListRoleUp:AddItem(pObj)
        end
    end

    WidgetUtils.SelfHitTestInvisible(self.TxtRoleUp)
    self.TxtRoleUp:SetText(string.format(Text("ui.TxtRoleUp"), nFindNum * tbCfg.nGainRoleRate))
end

return tbClass
