-- ========================================================
-- @File    : uw_dlcrogue_random_item.lua
-- @Brief   : 肉鸽活动 事件item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnChoose, function ()
        if self.FuncClick then
            self.FuncClick()
        end
    end)
end

function tbClass:Show(data, funcClick)
    self.FuncClick = funcClick
    self.Des = data.Des
    self:SetTextContent()
    self.Effect:ActivateSystem(true)
end

function tbClass:SetSelect(bSelect)
    if bSelect then
        WidgetUtils.Collapsed(self.PanelRandom)
        self.PanelRandomSl:SetRenderScale(UE4.FVector2D(1, 1))
    else
        self.PanelRandomSl:SetRenderScale(UE4.FVector2D(0, 0))
        WidgetUtils.SelfHitTestInvisible(self.PanelRandom)
    end
end

function tbClass:SetTextContent()
    self.HyperTextBlock:SetContent(self.Des)
    self.HyperTextBlock_1:SetContent(self.Des)
end

function tbClass:Close()
    self.Effect:DeactivateSystem()
end

return tbClass
