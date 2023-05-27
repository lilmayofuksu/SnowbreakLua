-- ========================================================
-- @File    : uw_fightonline_shop_buffsmall.lua
-- @Brief   : 已获得Buffer信息
-- ========================================================
local uw_fightonline_shop_buffsmall = Class("UMG.SubWidget")

function uw_fightonline_shop_buffsmall:OnListItemObjectSet(pObj)
    local tbInfo = pObj.Data;
    if not tbInfo then return end;

    -- -- 设置图标
    SetTexture(self.Imgbuff, tbInfo.nIcon);
    self.Frame:SetColorAndOpacity(tbInfo.nColor);
    self.SmallLight:SetColorAndOpacity(tbInfo.nColor);

    WidgetUtils.Collapsed(self.PanelTxt)
    WidgetUtils.Collapsed(self.ImgSl)
    --WidgetUtils.Collapsed(self.BuffTxt)
    
    self.ShowPanel = false;
    self.Root = tbInfo.root

    if self.Root then
        self.BuffTxt = self.Root.BuffTxt
    end
    
    if self.Handle then
        EventSystem.Remove(self.Handle)
    end
    
    BtnClearEvent(self.BtnCheck)
    BtnAddEvent(self.BtnCheck, function ()
        EventSystem.Trigger(Event.OpenOrCloseBuffDesc, {not self.ShowPanel, tbInfo})
    end)

    self.Handle = EventSystem.On(
        Event.OpenOrCloseBuffDesc,
        function(tbParam)
            local isSelected = tbParam[2] and tbParam[2].name == tbInfo.name
            if not isSelected then
                self.ShowPanel = false;
            else
                self.ShowPanel = tbParam[1];
            end

            if self.ShowPanel and self.Root then
                self.BuffTxt.TxtName:SetText(tbInfo.name)
                self.BuffTxt.TxtBuffDetail:SetContent(tbInfo.desc)

                local ret = UE4.UUMGLibrary.WidgetLocalToOtherWidgetLocal(self.BtnCheck, self.Root.PanelBuffAll)
                self.BuffTxt:SetRenderTranslation(UE4.FVector2D(ret.X, 0))
            end

            if not UI.IsOpen('FightOnlineAllBuff') then
                self.ImgSl:SetVisibility(self.ShowPanel and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
                if isSelected then
                    self.BuffTxt:SetVisibility(self.ShowPanel and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
                end

                if not tbParam[2] then
                    self.BuffTxt:SetVisibility(UE4.ESlateVisibility.Collapsed)
                end
            end
        end
    )
end

function uw_fightonline_shop_buffsmall:ShowSl(isSl)
    self.ShowPanel = isSl
    if isSl and not UI.IsOpen('FightOnlineAllBuff') then
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
        WidgetUtils.SelfHitTestInvisible(self.BuffTxt)
    else
        WidgetUtils.Collapsed(self.ImgSl)
        WidgetUtils.Collapsed(self.BuffTxt)
    end
end

function uw_fightonline_shop_buffsmall:OnDestruct()
    EventSystem.Remove(self.Handle)
end

return uw_fightonline_shop_buffsmall
