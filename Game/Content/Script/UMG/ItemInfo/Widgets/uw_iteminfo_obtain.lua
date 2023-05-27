-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj.Data;
	if not tbParam then return end;
	local name = (tbParam.preFormat or '')..Text(tbParam.format)
	self.TxtName:SetText(name)
	self.TxtNameNot:SetText(name)
	self.BtnJump.OnClicked:Clear()
	local canJumpTo = tbParam.isOpen and tbParam.isUnlock and tbParam.canJumpTo
	if canJumpTo then
		WidgetUtils.Visible(self.PanelJump_1);
		WidgetUtils.Hidden(self.PanelNot);
		WidgetUtils.Visible(self.BtnJump)
		self.BtnJump.OnClicked:Add(self,function ( ... )
			if tbParam.openUI then
				tbParam.openUI()
			end
		end)
	else
		WidgetUtils.Hidden(self.BtnJump)
		WidgetUtils.Hidden(self.PanelJump_1);
		WidgetUtils.Visible(self.PanelNot);
	end
end

return tbClass;
