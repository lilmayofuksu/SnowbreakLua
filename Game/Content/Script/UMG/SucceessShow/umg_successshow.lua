-- ========================================================
-- @File    : umg_successshow.lua
-- @Brief   : 战斗胜利表现
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.EventHandle = self:RegisterEvent(Event.LevelSuccessShow, function()
        self:SpecialShow()
    end)
end

function tbClass:OnOpen()
    RuntimeState.ChangeInputMode(true)
    self:PlayAnimation(self.AllEnter)
    local Character = UE4.UGameplayStatics.GetPlayerCharacter(GetGameIns(), 0)
    local CharacterCard = Character:K2_GetPlayerMember()
    if not CharacterCard then
        return
    end
    self.TxtName:SetText(Text(CharacterCard:I18N()))
    self.TxtTitle:SetText(Text(CharacterCard:I18N().."_title"))
end


function tbClass:SpecialShow()
    self:SceneOn()
    WidgetUtils.HitTestInvisible(self.CustomPostProcess_46)
    self.TxtName:SetRenderOpacity(1)
    self.TxtTitle:SetRenderOpacity(1)
    EventSystem.Remove(self.EventHandle)
end

function tbClass:OnClose()
    if self.EventHandle then
        EventSystem.Remove(self.EventHandle)
    end
end

function tbClass:CanEsc()
    return false
end

return tbClass
