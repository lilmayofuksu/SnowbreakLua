-- ========================================================
-- @File    : umg_test.lua
-- @Brief   : 测试UI
-- ========================================================

---@class tbClass
---@field RoleList UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.ListFactory = Model.Use(self)
end


function tbClass:OnOpen()

    PreviewScene.Enter(PreviewType.main, function()
        self.RoleList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
        local allCards = me:GetCharacterCards()
    
        for i = 1, allCards:Length() do
            local tbParam = {pCard = allCards:Get(i), bSelect = (i == 1), fClick = function(SelectData)
                self:OnClick(SelectData)      
            end}
            if i == 1 then
                self.Current = tbParam
            end
    
            local pObj = self.ListFactory:Create(tbParam)
            self.RoleList:AddItem(pObj)
        end
    
        if self.Current then
            self:OnClick(self.Current)
        end
    end)
end

function tbClass:OnClose()
    self.pInfoActor:K2_DestroyActor()
    if self.pInfoActor then
    end
end


function tbClass:OnClick(SelectData)
    -- if self.Current == SelectData then
    --     return
    -- end

    if self.Current then
        self.Current.bSelect = false
        EventSystem.TriggerTarget(self.Current, 'SET_SELECTED', false)
    end

    self.Current = SelectData
    self.Current.bSelect = true
    EventSystem.TriggerTarget(self.Current, 'SET_SELECTED', true)

    if self.pInfoActor== nil then
        local ActorClass = UE4.UClass.Load("/Game/UI/UMG/Test3DUI/Widgets/bp_role_widget_actor.bp_role_widget_actor_C")
        self.pInfoActor = GetGameIns():GetWorld():SpawnActor(ActorClass)
        local pCameraMgr = UE4.UGameplayStatics.GetPlayerCameraManager(GetGameIns(), 0)
        self.pInfoActor:K2_AttachToActor(pCameraMgr)
    end

    local pWidget = self.pInfoActor:Get()
    pWidget:Set(SelectData.pCard)
   
end

return tbClass
