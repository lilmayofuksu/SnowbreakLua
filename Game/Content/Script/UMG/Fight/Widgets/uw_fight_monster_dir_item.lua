-- ========================================================
-- @File    : uw_fight_monster_dir_item.lua
-- @Brief   : 战斗界面 NPC 方位显示条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_monster_dir_item = Class("UMG.SubWidget")

local MonsterDirItem = uw_fight_monster_dir_item

---@field Mon AGameCharacter
MonsterDirItem.Mon = nil

MonsterDirItem.TargetValue = 0
MonsterDirItem.CurrentValue = 0
MonsterDirItem.LastHitTime = 0
MonsterDirItem.SubSpeed = 50

function MonsterDirItem:Init(InMon)
    self.Mon = InMon
    self:Reset()
end

function MonsterDirItem:Tick(MyGeometry, InDeltaTime)
    if self.Mon then
        if self.Mon:IsDead() then
            self:RemoveFromParent()
        else
            self:UpdateDir()
            ---
            if self.LastHitTime > 0 then
                self.LastHitTime = self.LastHitTime - InDeltaTime
                self.SubSpeed = 50
            else
                if self.TargetValue > 0 then
                    self.SubSpeed = 150
                end
            end
            self.TargetValue = math.max(0, self.TargetValue - InDeltaTime * self.SubSpeed)
            self.CurrentValue = UE4.UKismetMathLibrary.FInterpTo(self.CurrentValue, self.TargetValue, InDeltaTime, 10)
            local HitSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HitNode)
            local Size = HitSlot:GetSize()
            HitSlot:SetSize(UE4.FVector2D(Size.X, self.CurrentValue))
            if self.CurrentValue > 6 then
                WidgetUtils.HitTestInvisible(self.HitNode)
            else
                WidgetUtils.Hidden(self.HitNode)
            end
        end
    end
end


function MonsterDirItem:Hit(InValue)
    if InValue > 30 then
        self:PlayHard()
    else
        WidgetUtils.HitTestInvisible(self.HitEffect)
        self:PlayAnimation(self.underattack_ordinary, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
    self.LastHitTime = 2
    self.TargetValue = math.min(self.TargetValue + 80, 200)
end

---更新方向
function MonsterDirItem:UpdateDir()
    ---
    if self.Mon and self:GetOwningPlayerPawn() then
        local MonLoc = self.Mon:K2_GetActorLocation()
        local SelfLoc = self:GetOwningPlayerPawn():K2_GetActorLocation()
        local Dir = UE4.UKismetMathLibrary.Subtract_VectorVector(MonLoc, SelfLoc)
        local CameraFor = self:GetOwningPlayer().PlayerCameraManager:GetActorForwardVector()
        local CameraDir = UE4.UKismetMathLibrary.MakeVector(CameraFor.X, CameraFor.Y, 0)
        local Angle = UE4.UMathLibrary.VectorAngleXY(Dir, CameraDir)
        self:SetRenderTransformAngle(Angle)
    end
end

function MonsterDirItem:OnDestruct()
    self.Mon = nil
end

return MonsterDirItem
