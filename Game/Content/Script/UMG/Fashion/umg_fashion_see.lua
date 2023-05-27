-- ========================================================
-- @File    : umg_fashion_see.lua
-- @Brief   : 角色特写
-- ========================================================

---@class tbClass : UUserWidget
---@field SliderLight USlider
---@field TxtBoxFOV UEditableTextBox
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    -- BtnAddEvent(
    --     self.BtnSeeUI,
    --     function()
    --         self:SetUIVisible(true)
    --     end
    -- )

    BtnAddEvent(
        self.BtnNoUI,
        function()
            self:SetUIVisible(false)
        end
    )

    BtnAddEvent(
        self.BackBtn,
        function()
            self:OnClose()
            UI.Close(self)
        end
    )

    self.Slider_447.OnValueChanged:Add(self, function(_, Value)
        local ValueOffset = self.Slider_447.MaxValue - Value
        local NewPos = self.DefaultPos +  UE4.FVector(0, 0, 1) * ValueOffset * 8
        local SweepResult = UE4.FHitResult()
        self.Actor:K2_SetActorLocation(NewPos,true, SweepResult, true)
    end)

    WidgetUtils.Collapsed(self.BtnSeeUI)
    WidgetUtils.Visible(self.BtnNoUI)
end

function tbClass:OnOpen(OnCloseCallBack)
    self.OnCloseCallBack = OnCloseCallBack
    self.Visible = true
    self:SetUIVisible(true)
    self:OnLoad()
end

function tbClass:OnLoad()
    self.Actor = Preview.GetModel()
    self.DefaultPos = self.Actor:K2_GetActorLocation()
    self.DefaultRot = self.Actor:K2_GetActorRotation()
    self:SetFov() 
    self.Interaction:Init(self, self.Actor, function() self:SetUIVisible(true) end)
end


function tbClass:SetFov()
    self:GetOwningPlayer():FOV(self.NowFov)
end

function tbClass:SetUIVisible(Visible)
    if self.Visible == Visible then
        return
    end
    self.Visible = Visible
    if not Visible then
        WidgetUtils.Collapsed(self.Title)
        WidgetUtils.Collapsed(self.BtnNoUI)
        -- WidgetUtils.Collapsed(self.BtnSeeUI)
    else
        WidgetUtils.Visible(self.Title)
        WidgetUtils.Visible(self.BtnNoUI)
        -- WidgetUtils.Visible(self.BtnSeeUI)
    end
end

function tbClass:OnClose()
    local OwningPlayer = self:GetOwningPlayer()
    if OwningPlayer then
        OwningPlayer:FOV(0)
    end
    local SweepResult = UE4.FHitResult()
    self.Actor:K2_SetActorLocation(self.DefaultPos, true, SweepResult, true)
    self.Interaction:OnClose()
    if self.OnCloseCallBack then
        self.OnCloseCallBack()
        self.OnCloseCallBack = nil
    end
end
return tbClass