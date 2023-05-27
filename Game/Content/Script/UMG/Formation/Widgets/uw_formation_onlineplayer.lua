-- ========================================================
-- @File    : uw_formation_onlineplayer.lua
-- @Brief   : 联机编队  单个角色界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(self.BtnInvite, function()
        self:DoInvite()
    end)

    BtnAddEvent(self.BtnExit, function()
        self:DoKick()
    end)
end

---UI打开
function tbClass:OnOpen(tbParam)
    self.tbParam = tbParam
    local tbPlayerInfo = UE4.UAccount.Find(self.tbParam.nIndex, true)
    if not tbPlayerInfo or tbPlayerInfo:Id() == 0 or not self.tbParam then
        self:ShowEmptyInfo()
    else
        self.tbParam.tbPlayerInfo = tbPlayerInfo
        self:ShowMemberInfo(tbPlayerInfo)
    end
end

--空信息
function tbClass:ShowEmptyInfo()
    self:ClearModel()
    WidgetUtils.Collapsed(self.Mask1)
    WidgetUtils.Collapsed(self.Mask2)
    WidgetUtils.Collapsed(self.BtnExit)
    WidgetUtils.Collapsed(self.Prepare)
    WidgetUtils.Collapsed(self.Completed)
    WidgetUtils.Collapsed(self.Info)
    WidgetUtils.Collapsed(self.SubCard1)
    WidgetUtils.Collapsed(self.SubCard2)

    WidgetUtils.Collapsed(self.TextBlock_88)
    WidgetUtils.Collapsed(self.TextLvNum)

    WidgetUtils.Collapsed(self.Leader)

    WidgetUtils.Visible(self.CanvasPanel_200)
end

---显示队员信息
function tbClass:ShowMemberInfo(tbPlayerInfo)
   WidgetUtils.Collapsed(self.CanvasPanel_200)

   WidgetUtils.SelfHitTestInvisible(self.Info)
    WidgetUtils.SelfHitTestInvisible(self.TextBlock_88)
    WidgetUtils.SelfHitTestInvisible(self.TextLvNum)
    if Online.MaxTeammate >= 2 then
        WidgetUtils.SelfHitTestInvisible(self.SubCard1)
    end
    if Online.MaxTeammate >= 3 then
        WidgetUtils.SelfHitTestInvisible(self.SubCard2)
    end
    
    self.TextBlock_88:SetText(tbPlayerInfo:Nick())
    self.TextLvNum:SetText(tbPlayerInfo:Level())

    WidgetUtils.Collapsed(self.BtnExit)

    if self.tbParam.bCaptain then
        WidgetUtils.SelfHitTestInvisible(self.Leader)
    else 
        WidgetUtils.Collapsed(self.Leader)
    end

    if self.tbParam.nStateFlag > Online.Player_State_Empty then
        WidgetUtils.Collapsed(self.Prepare)
        WidgetUtils.SelfHitTestInvisible(self.Completed)

        self.TxtCompleted:SetText(Online.GetStateText(self.tbParam.nStateFlag))
    elseif self.tbParam.bCaptain then -- 队长 始终准备完毕
        WidgetUtils.Collapsed(self.Prepare)
        WidgetUtils.SelfHitTestInvisible(self.Completed)
        self.TxtCompleted:SetText(Online.GetStateText(Online.Player_State_Ready))
    else
        WidgetUtils.Collapsed(self.Completed)
        WidgetUtils.SelfHitTestInvisible(self.Prepare)
    end

    local tbLineup = nil
    local lineupsData = tbPlayerInfo:GetLineups()
    local LineupLogic = Formation.GetLineupLogic()
    for i = 1, lineupsData:Length() do
        local pLineup = lineupsData:Get(i)
        if pLineup.Index == self.tbParam.nTeamId then
            tbLineup = LineupLogic.New(pLineup)
            local MemberLogic = tbLineup:GetMemberLogic()
            tbLineup.tbMember = {}
            local memsData = tbPlayerInfo:GetLineupMembers(pLineup.Index)
            for i = 1, memsData:Length() do
                tbLineup.tbMember[i-1] =  MemberLogic.New(i-1, memsData:Get(i))
            end
            break
        end
    end

    self:ShowCardInfo(tbLineup, self.tbParam.nIndex)
end

---显示队员信息
function tbClass:ShowCardInfo(tbLineup, nIndex)
    if not tbLineup then
        WidgetUtils.Collapsed(self.Mask1)
        WidgetUtils.Collapsed(self.Mask2)
        WidgetUtils.Collapsed(self.Img2)
        WidgetUtils.Collapsed(self.Img2_1)

        self.Image_709:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("03061F66"))
        self.Image_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("03061F66"))
        return
    end

    local Member = tbLineup:GetMember(0)
    --显示首位的模型
    if Member and Member:GetUID() > 0  then
        local pCardInfo = Member and Member:GetCard()
        local nWeaponId = pCardInfo and pCardInfo:GetSlotWeapon() or 0

        if UI.IsOpen("Formation") and (not self.ShowInfo or self.ShowInfo[1] ~= Member:GetUID() or self.ShowInfo[2] ~= nWeaponId) then
            self:LoadPreviewModel(nIndex, Member:GetUID())
            self.ShowInfo = {Member:GetUID(), nWeaponId}
        end        
    else
        self:ClearModel()
    end

    --1号位
    Member = tbLineup:GetMember(1)
    local pCard = Member and Member:GetCard()
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
    Member = tbLineup:GetMember(2)
    pCard = Member and Member:GetCard()
    if pCard and Online.MaxTeammate >= 3 then
        WidgetUtils.SelfHitTestInvisible(self.Mask2)
        WidgetUtils.SelfHitTestInvisible(self.Img2_1)
        SetTexture(self.Girl2, pCard:Icon(), true)
        self.Image_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("FFFFFFFF"))
    else
        WidgetUtils.Collapsed(self.Mask2)
        WidgetUtils.Collapsed(self.Img2_1)
        self.Image_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex("03061F66"))
    end
end

function tbClass:OnClose()
    self:ClearModel()
    self.ShowInfo = nil
end

function tbClass:OnDisable()
    self:ClearModel()
    self.ShowInfo = nil
end

function tbClass:ClearModel()
    if IsValid(self.pModel) then
        self.pModel:Clear() 
        self.pModel:SetActorHiddenInGame(true)  
        self.pModel:K2_DestroyActor()
    end
    self.pModel = nil
end

function tbClass:DoInvite()
    if not self.tbParam then return end
    if self.tbParam.tbPlayerInfo and self.tbParam.tbPlayerInfo:Id() > 0 then 
        if self.tbParam.bMyCaptain then
            if not WidgetUtils.IsVisible(self.BtnExit)  then
                WidgetUtils.Visible(self.BtnExit)
            else
                WidgetUtils.Collapsed(self.BtnExit)
            end
        end
    else
        if self.tbParam.fInviteFunc then
            self.tbParam.fInviteFunc(self.tbParam.nIndex)
        end
    end
end

function tbClass:DoKick()
    if not self.tbParam then return end
    if not self.tbParam.tbPlayerInfo then return end
    if self.tbParam.tbPlayerInfo:Id() == 0 then return end

    Online.ExitRoom(self.tbParam.tbPlayerInfo:Id())
end

function tbClass:LoadPreviewModel(nIndex, itemId)
    if not me or not me.GetOtherCardId then
        return
    end

    local cardId = me:GetOtherCardId(nIndex);
    me:BuildTrialCharacters(nIndex, itemId);

    local pItem = me:GetItem(cardId)
    if not pItem then return end
    if not Formation.Actor then return end

    self:ClearModel()

    local sPreviewType = Preview.Online_Player
    local nItemType = UE4.EItemType.CharacterCard
    local pModelInfo = UE4.FPreviewModelInfo()
    local localPos = Formation.Actor:GetPos(self.tbParam.nIndex)

    pModelInfo.Position = UE4.FVector(localPos.X, localPos.Y, localPos.Z)
    pModelInfo.StartRotation = UE4.FRotator(0, 180, 0)
    pModelInfo.Scale = UE4.FVector(1, 1, 1)
    pModelInfo.AnimType = UE4.EUIWidgetAnimType.Role_Fomation

   self.pModel = UE4.UPreviewLibrary.PreviewByItemObj(GetGameIns(), pItem, pModelInfo)
end

function tbClass:Tick()
    if not Formation.Actor or not self.tbParam then return end

     local WorldPos = Formation.Actor:GetPos(self.tbParam.nIndex)
    -- if self.tbParam.nIndex == 1 then
    --     WorldPos.Y = WorldPos.Y - 30
    -- elseif self.tbParam.nIndex == 2 then
    --     WorldPos.Y = WorldPos.Y
    -- end

    if WorldPos then
        local ScreenPos = UE4.FVector2D()
        UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(self:GetOwningPlayer(), WorldPos, ScreenPos, true)

        local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
        local MakePos = UE4.FVector2D()
        MakePos.Y = Slot:GetPosition().Y
        MakePos.X = ScreenPos.X - Slot:GetSize().X - math.floor(Slot:GetSize().X / 2)
        Slot:SetPosition(MakePos)
    end
end

return tbClass
