-- ========================================================
-- @File    : uw_setup_list.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(
        self.BtnClick,
        function()
            if self.fOnClick then
                self.fOnClick(self.Obj)
            end
        end
    )
end


function tbClass:OnListItemObjectSet(InObj)
    self.Obj = InObj
    InObj.pUI = self
    local tbData = InObj.Data.tbData
    self.fOnClick = InObj.Data.fClick

    self.TxtName:SetText(Text(tbData.sName))
    self.TxtName_1:SetText(Text(tbData.sName))

    self:OnSelectChange(InObj.Data.bSelect)
    self:OnShowRedPointChange(InObj.Data.bShowRed)
    self.Obj.Data.SetSelect = function(_, bSelect)
        self:OnSelectChange(bSelect)
    end
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.Collapsed(self.PanelNormal)
        WidgetUtils.HitTestInvisible(self.PanelSelect)
    else
        WidgetUtils.HitTestInvisible(self.PanelNormal)
        WidgetUtils.Collapsed(self.PanelSelect)
    end
end

function tbClass:OnShowRedPointChange(bShowRed)
    if bShowRed then
        WidgetUtils.HitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

return tbClass
