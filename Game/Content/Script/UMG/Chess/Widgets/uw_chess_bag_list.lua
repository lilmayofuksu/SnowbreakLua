-- ========================================================
-- @File    : uw_chess_bag_list.lua
-- @Brief   : 背包分类条目
-- ========================================================

local view = Class("UMG.SubWidget")


function view:Construct()
    BtnAddEvent(self.BtnUnchecked, function() self:OnBtnClickSelect() end)
end


function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.tbData.ui = self
    self:UpdateState()
end

function view:UpdateState()
    WidgetUtils.Collapsed(self.Checked)
    WidgetUtils.Collapsed(self.Unchecked)
    WidgetUtils.Collapsed(self.Disable)
    if self.tbData.selected then    
        WidgetUtils.SelfHitTestInvisible(self.Checked)
        self.TxtBtn:SetText(self.tbData.name)
    else 
        WidgetUtils.SelfHitTestInvisible(self.Unchecked)
        self.TxtBtnUnCheck:SetText(self.tbData.name)
    end
end

function view:OnBtnClickSelect()
    self.tbData.parent:OnTypeSelect(self.tbData.id)
end

return view