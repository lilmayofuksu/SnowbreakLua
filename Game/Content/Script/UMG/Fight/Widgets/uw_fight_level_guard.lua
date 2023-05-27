-- ========================================================
-- @File    : uw_fight_level_guard.lua
-- @Brief   : 战斗界面 坚守任务进度
-- @Author  : cms
-- @Date    : 2021/7/27
-- ========================================================

local LevelGuard = Class("UMG.SubWidget")
LevelGuard.DefendExecute = nil

function LevelGuard:Active(DefendExecuteNode)
    if DefendExecuteNode then
        self.DefendExecute = DefendExecuteNode
        self:Update(DefendExecuteNode)
        WidgetUtils.SelfHitTestInvisible(self)
    end
end

function LevelGuard:Show(bShow)
    if bShow then
        WidgetUtils.SelfHitTestInvisible(self)
    else
        WidgetUtils.Collapsed(self)
    end
end

function LevelGuard:Update(DefendExecuteNode)
    if DefendExecuteNode == nil or DefendExecuteNode ~= self.DefendExecute then
        return
    end
    self.TxtGuardNum:SetText(DefendExecuteNode:GetDefendDesc_Num())
end

function LevelGuard:SpecialUpdate(DefendExecuteNode,Desc_Name,Desc_Num,Percent)
    if DefendExecuteNode == nil or DefendExecuteNode ~= self.DefendExecute then
        return
    end
    self.TxtGuardNum:SetText(Desc_Num)
end

function LevelGuard:Deactive(DefendExecuteNode)
    if DefendExecuteNode == self.DefendExecute then
        self.DefendExecute = nil
        WidgetUtils.Collapsed(self)
    end
end

--1:monter  2:Time
function LevelGuard:SetGuardType(gType)
    gType = gType or 0
    if gType == 1 then
        WidgetUtils.HitTestInvisible(self.ImgMonter)
    else
        WidgetUtils.Collapsed(self.ImgMonter)
    end

    if gType == 2 then
        WidgetUtils.HitTestInvisible(self.ImgTime)
    else
        WidgetUtils.Collapsed(self.ImgTime)
    end
end

function LevelGuard:UpdateText(str)
    self.TxtGuardNum:SetText(str)
end

function LevelGuard:OnDestruct()
    self.DefendExecute = nil
end

function LevelGuard:PlayTimeWarn(bPlay)
    if bPlay then
        self:PlayAnimFromAnimation(self.TimeWarn, 0, 99, UE4.EUMGSequencePlayMode.PingPong)
        --self:PlayAnimation(self.TimeWarn, 0, 99, UE4.EUMGSequencePlayMode.PingPong, 1, false)
    else
        self:StopAnimation(self.TimeWarn, 0)
        self.ImgTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1) )
    end
end

function LevelGuard:AddTime(time)
    self.TxtTimeChange:SetText('+'..tostring(time))
    -- self:PlayAnimation(self.TimeAdd)
    self:PlayAnimFromAnimation(self.TimeAdd)
end

function LevelGuard:TryCountDown(Execute, nCountDown)
    self.lastCountDown = self.lastCountDown or nCountDown
    if self.CountDownExecute and self.CountDownExecute ~= Execute or DefendExecuteNode then
        return
    end

    self.CountDownExecute = Execute
    if not nCountDown or nCountDown < 0 or nCountDown > 9999 then
        self:TryCollapsed(Execute)
        return
    end

    self:SetGuardType(2)
    WidgetUtils.SelfHitTestInvisible(self)
    self:UpdateText(string.format(Text("taskdes.1000002"), os.date("%M:%S",nCountDown)))
    if nCountDown <= 10 and self.lastCountDown > 10 then
        self:PlayTimeWarn(true)
    end
    if self.lastCountDown <= 10 and nCountDown > 10 then
        self:PlayTimeWarn(false)
    end
    self.lastCountDown = nCountDown
end

function LevelGuard:TryCollapsed(Execute)
    if self.CountDownExecute ~= Execute or DefendExecuteNode then
        return 
    end
    WidgetUtils.Collapsed(self)
    self.CountDownExecute = nil
end

function LevelGuard:ShowDefendMoneyEffect(AddNum)
    if self:IsAnimPlayingFromAnimation(self.animation_revert) then
        self:StopAnimFromAnimation(self.animation_revert)
    end
    self:PlayAnimFromAnimation(self.animation_out_effect)
    UE4.Timer.Add(0.2,function ()
        local UIMain = UI.GetUI('Fight')
        if UIMain and UIMain.LevelNumbers and UIMain.LevelNumbers.Num2 and UIMain.LevelNumbers.Num2.ImgMoney then
            self.AllMoneyFlyTime = 0.8;
            self.NowMoneyFlyTime = 0;
            self.InDefendMoneyFly = true;

            --local TargetPos = UE4.UUMGLibrary.WidgetLocalToOtherWidgetLocal(UIMain.LevelNumbers.Num2.BtnCheck,self.CanvasPanel_0)
            local Panel3D = UE4.UUMGLibrary.FindParentCanvasPanel3D(UIMain.LevelNumbers)
            local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(UIMain.LevelNumbers)
            local offset = UE4.UUMGLibrary.WidgetLocalToAbsolute3D(Panel3D,UIMain.LevelNumbers,Slot:GetPosition())
            local offset2 = UE4.UUMGLibrary.AbsoluteToWidgetLocal3D(Panel3D,offset)
            local NumSize = Slot:GetSize()

            local TargetPos = UE4.UUMGLibrary.WidgetLocalToOtherWidgetLocal(self,Panel3D)
            WidgetUtils.Collapsed(self.NiagaraSystemWidget_61)
            WidgetUtils.SelfHitTestInvisible(self.NiagaraSystemWidget_61)

            if UIMain.LevelNumbers.Num2 and UIMain.LevelNumbers.Num2.TxtOnlineNum_1 then
                UIMain.LevelNumbers.Num2.TxtOnlineNum_1:SetText('+'..AddNum)
            end
            self.TargetFlyPos = offset2 + UE4.FVector2D(NumSize.X * 0.8,NumSize.Y*0.5) - TargetPos;
        else
            self:Show(false)
        end

        --[[UE4.Timer.Add(1.0,function ( ... )
            local UIMain = UI.GetUI('Fight')
            if UIMain and UIMain.LevelNumbers and UIMain.LevelNumbers.Num2 then
                UIMain.LevelNumbers.Num2:PlayAnimation(UIMain.LevelNumbers.Num2.GetMoney)
            end
        end)]]
    end)
end

function LevelGuard:ShowDefendTimeWithAnim()
    if not WidgetUtils.IsVisible(self) then
        self:Show(true)
    end
    if self:IsAnimPlayingFromAnimation(self.animation_out_effect) then
        self:StopAnimFromAnimation(self.animation_out_effect)
    end
    self:PlayAnimFromAnimation(self.animation_revert)
end

function LevelGuard:K2_OnUpdate(InDeltaTime)
    if self.InDefendMoneyFly then
        self.NowMoneyFlyTime = self.NowMoneyFlyTime + InDeltaTime;
        local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.NiagaraSystemWidget_61)
        if self.NowMoneyFlyTime <= self.AllMoneyFlyTime and Slot then
            Slot:SetPosition(self.TargetFlyPos * (self.NowMoneyFlyTime/self.AllMoneyFlyTime))
        else
            self.InDefendMoneyFly = false
        end
    end
end

return LevelGuard
