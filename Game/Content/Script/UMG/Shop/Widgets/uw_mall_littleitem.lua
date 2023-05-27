-- ========================================================
-- @File    : uw_mall_littleitem.lua
-- @Brief   : 商城分类列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)

    BtnAddEvent(self.BtnSelect, function()
        if not self.tbParam then return end

        self.tbParam.UpdateSelect(self.tbParam.nGroupId)
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    function self.tbParam.SetSelect(owner, bSelect)
        if bSelect then
            self:OnSelect()
            self:PlayAnimation(self.select)
            self:PlayAnimation(self.allloop)
        else
            self:UnSelect()
        end
        self.tbParam.isSele = bSelect
    end

    function self.tbParam.UpdateLabel()
        self:UpdateLabel()
    end

    self:UpdateLabel()
    self.tbParam:SetSelect(self.tbParam.isSele)
    if self.tbParam.nGroupIcon then
        SetTexture(self.Icon, self.tbParam.nGroupIcon)
        SetTexture(self.Icon1, self.tbParam.nGroupIcon)
    end
end

function tbClass:OnSelect()
    WidgetUtils.HitTestInvisible(self.Check)
    WidgetUtils.Collapsed(self.Bg)
end

function tbClass:UnSelect()
    WidgetUtils.HitTestInvisible(self.Bg)
    WidgetUtils.Collapsed(self.Check)
end

function tbClass:UpdateLabel()
    local tbGroupList = IBLogic.GetGroupList(self.tbParam.nGroupId)
    if not tbGroupList or  #tbGroupList == 0 then return end

    local label = 0
    for _, v in pairs(tbGroupList) do
        if IBLogic.CheckShopBox(v.nShopId) then
            label = 1
            break
        end
    end
    
    if label == 1 then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.tbParam.isSele then self.detime = 0 return end
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0
    self:PlayAnimation(self.allloop)
end

return tbClass
