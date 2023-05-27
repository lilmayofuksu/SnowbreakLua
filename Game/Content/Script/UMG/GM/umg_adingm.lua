-- ========================================================
-- @File    : GM控制台
-- @Brief   : Entry
-- ========================================================


local tbClass = Class("UMG.BaseWidget")
function tbClass:OnInit()
    -- self.BtnCommon.OnClicked:Add(self.BtnCommon, function ()
    --     self.SwitcherWidget:SetActiveWidgetIndex(0)
    -- end)
    -- self.BtnFight.OnClicked:Add(self.BtnFight, function ()
    --     self.SwitcherWidget:SetActiveWidgetIndex(1)
    -- end)
    -- self.BtnCallNPC.OnClicked:Add(self.BtnCallNPC, function ()
    --     self.SwitcherWidget:SetActiveWidgetIndex(2)
    -- end)
    -- self.BtnDebug.OnClicked:Add(self.BtnDebug, function ()
    --     self.SwitcherWidget:SetActiveWidgetIndex(3)
    -- end)

    BtnAddEvent(self.BtnTransparent, function()
        self:ShowAllUI()
    end)

    BtnAddEvent(self.BtnGM, function() 
        if WidgetUtils.IsVisible(self.PnlGM) then
            WidgetUtils.Hidden(self.PnlGM)
        else 
            WidgetUtils.Visible(self.PnlGM)
            self.uw_newGM.uw_adingm_common:RefreshResolution()
            self:SetAttributePreviewShow(false);
        end
    end)
    WidgetUtils.Hidden(self.PnlGM)
end

function tbClass:Test()
    
end

function tbClass:OnOpen()
    print("open adin gm");
end

function tbClass:OnClose()
    print("close adin gm")
end

function tbClass:ApplyClose()
    WidgetUtils.Hidden(self.PnlGM)
end

function tbClass:SetAttributePreviewShow(value)
    if value then 
        if not self.uw_adingm_attribute_preview then 
            local widget = LoadWidget("/Game/UI/UMG/GM/Widget/uw_adingm_attribute_preview.uw_adingm_attribute_preview_C")
            self.PanelRoot:AddChild(widget)
            self.uw_adingm_attribute_preview = widget
        end
        WidgetUtils.Visible(self.uw_adingm_attribute_preview)
    else 
        WidgetUtils.Hidden(self.uw_adingm_attribute_preview)
    end
end


function tbClass:HideAllUI(showTip)
    self.isHideAllUI = true;
    WidgetUtils.SelfHitTestInvisible(self.PanelTransparent)
    WidgetUtils.Collapsed(self.PanelData)

    self.tbHideUIs = {}
    for _, pWidget in pairs(UI.tbWidget) do
        if pWidget ~= self then 
            table.insert(self.tbHideUIs, pWidget)
            WidgetUtils.Collapsed(pWidget)
        end
    end
    if showTip then 
        UI.ShowTip("UI已隐藏，点击屏幕左上角可恢复")
    end
end

function tbClass:ShowAllUI()
    if not self.isHideAllUI then return end

    self.isHideAllUI = false;
    WidgetUtils.Collapsed(self.PanelTransparent)
    WidgetUtils.SelfHitTestInvisible(self.PanelData)

    for i, v in ipairs(self.tbHideUIs) do 
        WidgetUtils.SelfHitTestInvisible(v)
    end
end

return tbClass