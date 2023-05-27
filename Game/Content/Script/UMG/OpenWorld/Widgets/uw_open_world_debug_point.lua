-- ========================================================
-- @File     uw_open_world_debug_point.lua
-- @Brief    开放世界地标列表Item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.bShow = true;
    BtnAddEvent(self.Btnchoose, function() self:Toggle(); end)
end

function tbClass:Toggle()
    self.bShow = not self.bShow;
    self:UpdateState();
    self.tbData.pToggle(self.bShow);
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data;
    self.TxtTitle:SetText(self.tbData.sName);
    self:UpdateState();
    local r,g,b = table.unpack(self.tbData.rgb)
    UE4.UGMLibrary.SetBrushTintColor(self.Img_enable, r, g, b)
    -- self.Img_enable:SetBrushTintColor(UE4.FSlateColor(UE4.FLinearColor(r, g, b)))
end

function tbClass:UpdateState()
    if self.bShow then
        WidgetUtils.Visible(self.Img_enable);
        WidgetUtils.Hidden(self.Img_disable);
    else
        WidgetUtils.Visible(self.Img_disable);
        WidgetUtils.Hidden(self.Img_enable);
    end
end

function tbClass:OnDestruct()
end

return tbClass;