-- ========================================================
-- @File    : uw_fight_special_ui.lua
-- @Brief   : 战斗界面特效UI显示
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---打开界面
function tbClass:Construct()
    self.tbList = {}

    local CurPawn = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if CurPawn then
        local tbKey = CurPawn.SpecialFightUIs:Keys()
        for i = 1, tbKey:Length() do
            local Id = tbKey:Get(i)
            local ParamInfos = CurPawn.SpecialFightUIs:Find(Id)
            self:ShowOrHideSpecialFightUI(Id, ParamInfos, true);
        end
    end
    self.HandleShowFightUI = self:RegisterEvent(Event.ShowSpecialFightUI,function (InModifier, ParamInfos, bShow)
        self:ShowOrHideSpecialFightUI(InModifier, ParamInfos, bShow);
    end)
end

function tbClass:OnDestruct()
    self:RemoveRegisterEvent(self.HandleShowFightUI)
end

function tbClass:ShowOrHideSpecialFightUI(InModifier, ParamInfos, bShow)
    if self.Root == nil then
        return;
    end
    local ParamInfo = ParamInfos.Params
    local UIName = ParamInfo:Get(1).ParamValue    
    if bShow then
        local Minimum = UE4.FVector2D(0.5, 0.5)
        local Maximum = UE4.FVector2D(0.5, 0.5)
        local length = ParamInfo:Length()
        if length > 1 then
            Minimum = UE4.UAbilityFunctionLibrary.GetFVector2DValue(ParamInfo:Get(2))
        end
        if length > 2 then
            Maximum = UE4.UAbilityFunctionLibrary.GetFVector2DValue(ParamInfo:Get(3))
        end

        local SpecialUI = UE4.UUMGLibrary.GetWidgetFromName(self, UIName)
        if not SpecialUI then
            local strPath = string.format("/Game/UI/UMG/Fight/Widgets/%s.%s_C" , UIName , UIName);
            local SoftPath = UE4.UKismetSystemLibrary.MakeSoftClassPath(strPath)
            SpecialUI = LoadUIAndSetName(SoftPath, UIName)
            if not SpecialUI then
                return
            end

            self.Root:AddChild(SpecialUI)

            local Margin = UE4.FMargin()
            local Anchors = UE4.FAnchors()
            Anchors.Minimum = Minimum
            Anchors.Maximum = Maximum
            local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(SpecialUI)
            Slot:SetAnchors(Anchors)
            Slot:SetOffsets(Margin)
        else
            WidgetUtils.HitTestInvisible(SpecialUI)
        end
    else
        local SpecialUI = UE4.UUMGLibrary.GetWidgetFromName(self, UIName)
        if SpecialUI then
            if SpecialUI.EndPlay then
                SpecialUI:EndPlay()
            else
                WidgetUtils.Collapsed(SpecialUI)
            end
        end
    end
end

return tbClass
