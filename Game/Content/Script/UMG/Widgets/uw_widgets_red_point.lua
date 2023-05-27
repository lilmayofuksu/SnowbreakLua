-- ========================================================
-- @File    : uw_widgets_red_point.lua
-- @Brief   : 通用红点
-- ========================================================
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    if self.Type ~= 0 then
        WidgetUtils.Collapsed(self)
        self:Init()
    end

    if self:IsVisible() then
        self:PlayAnimation(self.AllLoop, 0 , 0)
    end

    self.OnVisibilityChanged:Add(self, function(_, vis)
        if vis == UE4.ESlateVisibility.Collapsed or vis == UE4.ESlateVisibility.Hidden then
            self:StopAllAnimations()
        else
            self:PlayAnimation(self.AllLoop, 0 , 0)
        end
    end)
end

function tbClass:OnDestruct()
    if self.redNode then self.redNode:SetChangeEvent(self.sTag, nil) end
    self.redNode = nil
end

function tbClass:SetType(nType)
    self.Type = nType
    self:Init()
end

---设置标记
---@param sTag string 标记
function tbClass:SetTag(sTag)
    if not self.redNode then return end

    if sTag ~= nil then sTag = tostring(sTag) end
    
    if self.sTag then
        self.redNode:SetChangeEvent(self.sTag, nil)
    end

    self.sTag = sTag

    self.redNode:SetChangeEvent(sTag, function(nNum)
        self:OnChange(nNum)
    end)
    local n = sTag == nil and self.redNode:GetTotalNum() or self.redNode:GetTagNum(sTag)
    self:OnChange(n)
end

function tbClass:Init()
    self.redNode = RedPoint.GetLeafNode(self.Type)
    if not self.bHasTag then
        self:SetTag()
    end
end

function tbClass:OnChange(nNum)
    if type(self) ~= 'table' then
        return
    end
    if nNum > 0 then
        WidgetUtils.HitTestInvisible(self)
    else
        WidgetUtils.Collapsed(self)
    end
end

return tbClass
