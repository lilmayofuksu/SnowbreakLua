-- ========================================================
-- @File    : uw_fight_ammunition3.lua
-- @Brief   : 弹药控制
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_ammunition3 = Class("UMG.SubWidget")

local Widget = uw_fight_ammunition3
Widget.nValue = 0

function Widget:Construct()
    WidgetUtils.HitTestInvisible(self.ProgressBar_Overheated_1)
    WidgetUtils.Collapsed(self.ProgressBar_Cooling)
    self:SetPercent(self.ProgressBar_Overheated_1,0)
    self:SetPercent(self.ProgressBar_Cooling,0)
end

function Widget:Tick(MyGeometry, InDeltaTime)
    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if Pawn then
        local Weapon = Pawn:GetWeapon()
        if Weapon and Weapon.AccessoryAbility then
            local nCurValue = Weapon.m_fOverloadValue
            if self.nValue ~= nCurValue then
                self.nValue = nCurValue
                self:SetPercent(self.ProgressBar_Overheated_1, nCurValue)
                self:SetPercent(self.ProgressBar_Cooling, nCurValue)   
                if Weapon.bActive then
                    WidgetUtils.HitTestInvisible(self.ProgressBar_Overheated_1)
                    WidgetUtils.Collapsed(self.ProgressBar_Cooling)
                else
                    WidgetUtils.Collapsed(self.ProgressBar_Overheated_1)
                    WidgetUtils.HitTestInvisible(self.ProgressBar_Cooling)
                end
            end
        end
    end
end


return uw_fight_ammunition3
