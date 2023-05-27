

local tbClass=Class("UMG.SubWidget")

function tbClass:Construct()
    UI.GetUI('AdinGM'):PlayAnimation(UI.GetUI('AdinGM').NewAnimation,UI.GetUI('AdinGM'):GetAnimationCurrentTime(UI.GetUI('AdinGM').NewAnimation),1,UE4.EUMGSequencePlayMode.Reverse,1,false)
    self:InitList()
    self.BtnClear.OnClicked:Add(self,function ()
        UE4.UGMRefresLog.GetGMRefresLogPtr().Logs:Clear()
        self:InitList()
    end)

    self.BtnNormal.OnClicked:Add(self,function ()
        self.GMWidgetSwitcher:SetActiveWidgetIndex(1)
    end)
    self.BtnCommand.OnClicked:Add(self,function ()
        self.GMWidgetSwitcher:SetActiveWidgetIndex(2)
    end)
    self.BtnWarning.OnClicked:Add(self,function ()
        self.GMWidgetSwitcher:SetActiveWidgetIndex(3)
    end)
    self.BtnError.OnClicked:Add(self,function ()
        self.GMWidgetSwitcher:SetActiveWidgetIndex(4)
    end)

    self.BtnClose.OnClicked:Add(self,function ()
        self:RemoveFromParent()
    end)

end

function tbClass:InitList()
    self.Error.LogScrollBox:ClearChildren()
    self.Normal.LogScrollBox:ClearChildren()
    self.Command.LogScrollBox:ClearChildren()
    self.Warning.LogScrollBox:ClearChildren()
    local Logs=UE4.UGMRefresLog.GetGMRefresLogPtr().Logs
    print(Logs:Length())
    for i = 1, Logs:Length() do
        self:AddChlid(Logs:Get(i))   
    end
end

function tbClass:AddChlid(info)
    local Widget=UE4.UWidgetBlueprintLibrary.Create(self,UE4.UClass.Load("/Game/UI/UMG/GM/Widget/uw_adingm_text_item"))
    local textbox=Widget.TextBox
    textbox:SetText(info.LogText)
    local RGBA=UE4.FLinearColor(0,0,0,1)
    local Color=textbox.ColorAndOpacity--UE4.FSlateColor(RGBA,UE4.ESlateColorStylingMode.SpecifiedColor)
    if info.type==UE4.EGMLogEmun.Command then 
        --判定是否过长
        if self.Command.LogScrollBox:GetChildrenCount()>500 then
            self.Command.LogScrollBox:RemoveChildAt(0)
        end
        self.Command.LogScrollBox:AddChild(Widget)
        self.Command.LogScrollBox:ScrollToEnd()
        RGBA.G=1
        Color.SpecifiedColor=RGBA
        textbox:SetColorAndOpacity(Color)
        local Padd=UE4.FMargin()
        Padd.Top=10
        Padd.Left=10
        Padd.Right=10
        Padd.Bottom=10
        Widget:SetPadding(Padd)
    end 
    if info.type==UE4.EGMLogEmun.Error then 
        --判定是否过长
        if self.Error.LogScrollBox:GetChildrenCount()>500 then
            self.Error.LogScrollBox:RemoveChildAt(0)
        end
        self.Error.LogScrollBox:AddChild(Widget)
        self.Error.LogScrollBox:ScrollToEnd()
        RGBA.R=1
        Color.SpecifiedColor=RGBA
        textbox:SetColorAndOpacity(Color)
        local Padd=UE4.FMargin()
        Padd.Top=10
        Padd.Left=10
        Padd.Right=10
        Padd.Bottom=10
        Widget:SetPadding(Padd)
    end 
    if info.type==UE4.EGMLogEmun.Warning then 
        --判定是否过长
        if self.Warning.LogScrollBox:GetChildrenCount()>500 then
            self.Warning.LogScrollBox:RemoveChildAt(0)
        end
        self.Warning.LogScrollBox:AddChild(Widget)
        self.Warning.LogScrollBox:ScrollToEnd()
        RGBA.G=1
        RGBA.R=1
        Color.SpecifiedColor=RGBA
        textbox:SetColorAndOpacity(Color)
        local Padd=UE4.FMargin()
        Padd.Top=10
        Padd.Left=10
        Padd.Right=10
        Padd.Bottom=10
        Widget:SetPadding(Padd)
    end 
    if info.type==UE4.EGMLogEmun.Normal then 
        --判定是否过长
        if self.Normal.LogScrollBox:GetChildrenCount()>500 then
            self.Normal.LogScrollBox:RemoveChildAt(0)
        end
        self.Normal.LogScrollBox:AddChild(Widget)
        self.Normal.LogScrollBox:ScrollToEnd()
        RGBA.G=1
        RGBA.R=1
        RGBA.B=1
        Color.SpecifiedColor=RGBA
        textbox:SetColorAndOpacity(Color)
        local Padd=UE4.FMargin()
        Padd.Top=10
        Padd.Left=10
        Padd.Right=10
        Padd.Bottom=10
        Widget:SetPadding(Padd)
        --print(self.Normal.LogScrollBox)
    end 
end
function tbClass:RefreshLogs(Message)
    self:AddChlid(Message)
end

return tbClass