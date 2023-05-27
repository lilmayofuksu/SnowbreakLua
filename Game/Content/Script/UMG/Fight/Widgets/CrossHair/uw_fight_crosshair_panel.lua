-- ========================================================
-- @File    : uw_fight_crosshair_panel.lua
-- @Brief   : 战斗界面 准心控制
-- @Author  :
-- @Date    :
-- ========================================================

---@class uw_fight_crosshair_panel :ULuaWidget
local uw_fight_crosshair_panel = Class("UMG.SubWidget")

-- local CrossType = {
--     ["EnergyGun"] = "/Game/UI/UMG/Fight/Widgets/CrossHair/uw_fight_plm_frame.uw_fight_plm_frame_C",
--     ["ShotGun"] = "/Game/UI/UMG/Fight/Widgets/CrossHair/uw_fight_ld_farme.uw_fight_ld_farme_C",
--     ["SniperRifle"] = "/Game/UI/UMG/Fight/Widgets/CrossHair/uw_fight_mla_frame.uw_fight_mla_frame_C",
--     ["SubmachineGun"] = "/Game/UI/UMG/Fight/Widgets/CrossHair/uw_fight_cross.uw_fight_cross_C"
-- }

local _W = uw_fight_crosshair_panel



function _W:Construct()
    self.Widget_Cross = nil
    self.CrossNodes = nil

    self.Widget_Ammunition = nil
    self.AmmunitionNodes = nil

    self.CurPlayer = nil
    self:ChangeType(UE4.EWeaponType.SubmachineGun)
    self.HitHanddel =
        EventSystem.On(
        Event.CharacterChange,
        function()
            self:ChangeType()
        end
    )
    
    self:RegisterEvent(Event.ShowReviveTime, function() WidgetUtils.Collapsed(self)  end)
    self:RegisterEvent(Event.HideReviveTime, function() WidgetUtils.SelfHitTestInvisible(self)  end)
    self:RegisterEvent(Event.ChangeAmmunitionUI, function() self:ChangeAmmunitionUI()  end)
end

function _W:OnDestruct()
    if self.CrossNodes then
        for _, item in pairs(self.CrossNodes) do
            if item then
                item:RemoveFromParent()
            end
        end
    end
    self.CacheWeapon = nil
    self.CrossNodes = nil
    self.Widget_Cross = nil
    self.CurPlayer = nil
    EventSystem.Remove(self.HitHanddel)
    self:RemoveRegisterEvent()
end

function _W:ChangeType()
    local Player = self:GetOwningPlayerPawn()
    if not Player then
        return
    end
    if self.CurPlayer then
        self.CurPlayer.OnNotifyEquipedWeapon:Remove(self, self.ChangeAmmunitionUI)
    end
    

    local OwnerPlayer = Player:Cast(UE4.AGameCharacter)    
    if not OwnerPlayer then return end
    local lpWeapon = OwnerPlayer:GetWeapon()
    if not lpWeapon then return end
    self.CurPlayer = OwnerPlayer    

    self:ChangeAmmunitionUI(lpWeapon)
    self.CurPlayer.OnNotifyEquipedWeapon:Add(self, self.ChangeAmmunitionUI)
end

function _W:ChangeAmmunitionUI(InWeapon)
    self.CacheWeapon = InWeapon
    if not self.CacheWeapon then return end
    local CurCrossSoftPath = self.CacheWeapon:GetCrossHairUIWidget()
    self:InitCross(CurCrossSoftPath)

    local CurAmmunitionSoftPath = self.CacheWeapon:GetAmmunitionUIWidget()
    self:InitAmmunition(CurAmmunitionSoftPath, self.CacheWeapon:GetAmmunitionUIOffset())
end

function _W:InitCross(CurCrossSoftPath)
    local strCurCrossSoftPath = UE4.UKismetSystemLibrary.BreakSoftClassPath(CurCrossSoftPath)
    if strCurCrossSoftPath == "" then return end
    if self.Widget_Cross then
        WidgetUtils.Collapsed(self.Widget_Cross)
    end
    if self.CrossNodes == nil then self.CrossNodes = {} end
    self.Widget_Cross = self.CrossNodes[strCurCrossSoftPath]
    
    if self.Widget_Cross then
        WidgetUtils.HitTestInvisible(self.Widget_Cross)
    else
        self.Widget_Cross = LoadUI(CurCrossSoftPath)
        if not self.Widget_Cross then
            return
        end
        self.CrossNodes[strCurCrossSoftPath] = self.Widget_Cross
        self.Root:AddChild(self.Widget_Cross)
        local Slot = UE4.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.Widget_Cross)
        Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
        Slot:SetVerticalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
    end
    -- self.Widget_Cross:ChangeType()
    self:UpdateCrossShow();
end

function _W:UpdateCrossShow()
    local UIFight = UI.GetUI("fight")
    if UIFight then
        if UIFight:GetPartShow(UE4.EFightWidgetPart.FightCross) then
            WidgetUtils.HitTestInvisible(self.Widget_Cross)
        else
            WidgetUtils.Collapsed(self.Widget_Cross)
        end
    end
end

function _W:InitAmmunition(CurSoftPath, OffsetPos)
  
    local strPath = UE4.UKismetSystemLibrary.BreakSoftClassPath(CurSoftPath)
    if strPath == "" then return end

    if self.Widget_Ammunition then
        -- self.Widget_Ammunition:ChangeType(false)
        WidgetUtils.Collapsed(self.Widget_Ammunition)
    end
    if self.AmmunitionNodes == nil then self.AmmunitionNodes = {} end
    self.Widget_Ammunition = self.AmmunitionNodes[strPath]
    if self.Widget_Ammunition then
        self.Widget_Ammunition:SetRenderTranslation(OffsetPos)
        self.Widget_Ammunition:ChangeType(true)
        WidgetUtils.HitTestInvisible(self.Widget_Ammunition)        
    else
        self.Widget_Ammunition = LoadUI(CurSoftPath)
        if not self.Widget_Ammunition then
            return
        end
        self.AmmunitionNodes[strPath] = self.Widget_Ammunition
        self.Root:AddChild(self.Widget_Ammunition)
        
        local Slot = UE4.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.Widget_Ammunition)
        Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
        Slot:SetVerticalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
        self.Widget_Ammunition:SetRenderTranslation(OffsetPos)
        self.Widget_Ammunition:ChangeType(true)
    end


	-- OnCharacterChangeInner(lpCharacter);
    self:UpdateAmmunitionShow();
end

function _W:UpdateAmmunitionShow()
    local UIFight = UI.GetUI("fight")
    if UIFight then
        if UIFight:GetPartShow(UE4.EFightWidgetPart.BulletCount) then
            WidgetUtils.HitTestInvisible(self.Widget_Ammunition)
        else
            WidgetUtils.Collapsed(self.Widget_Ammunition)
        end
    end
end

return _W
