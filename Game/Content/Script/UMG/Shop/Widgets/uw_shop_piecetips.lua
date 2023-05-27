-- ========================================================
-- @File    : uw_shop_piecetips.lua
-- @Brief   : 角色碎片兑换规则界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()

end

function tbClass:OnInit()
	BtnAddEvent(
        self.BtnClose,
        function()
            UI.Close(self)
        end
    )
    WidgetUtils.Collapsed(self.Piece1)
    WidgetUtils.Visible(self.Piece2)
    WidgetUtils.Visible(self.Piece3)
    WidgetUtils.Collapsed(self.Item3)
    WidgetUtils.Collapsed(self.Icon3)
    WidgetUtils.Collapsed(self.TxtName3)
    WidgetUtils.Collapsed(self.TxtNum3)
end

function tbClass:PreOpen()
    return true
end

function tbClass:OnOpen()
	--读取碎片稀有度兑换配置

	for nColor,tbConvert in pairs(Item.tbPiecesConvert) do
		local tbItem = tbConvert.tbItem[1]
		local iteminfo = UE4.UItem.FindTemplate(tbItem[1], tbItem[2], tbItem[3], tbItem[4])
		-- print("iteminfo.Icon:",iteminfo.Icon," I18N:",iteminfo.I18N," iteminfo.Color:",iteminfo.Color)
		if nColor == 5 then
			SetTexture(self.Icon1, iteminfo.Icon)
			self.TxtNum1:Settext("X"..tbItem[5])
			self.TxtName1:Settext(Text(iteminfo.I18N))
		elseif nColor == 4 then
			SetTexture(self.Icon2, iteminfo.Icon)
			self.TxtNum2:Settext("X"..tbItem[5])
			self.TxtName2:Settext(Text(iteminfo.I18N))
		-- elseif nColor == 3 then
		-- 	SetTexture(self.Icon3, iteminfo.Icon)
		-- 	self.TxtNum3:Settext("X"..tbItem[5])
		-- 	self.TxtName3:Settext(Text(iteminfo.I18N))
		else

			print("no this color ",nColor)
		end
	end
	self.TxtTips:Settext(Text('TxtPieceExchangeTip'))
end

function tbClass:OnClose()

end

return tbClass;