-- ========================================================
-- @File    : uw_dlcrogue_buffbar.lua
-- @Brief   : 肉鸽活动 增益buff列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListBuff)
    self.Factory = Model.Use(self)
end

function tbClass:UpdatePanel(tbBuff, SelectID, bShowText, funShowBtnClose)
	self.ListBuff:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.tbBuffObj = {}
    self:DoClearListItems(self.ListBuff)
    if #tbBuff == 0 then
        WidgetUtils.HitTestInvisible(self.TxtBuff)
        return
    else
        WidgetUtils.Collapsed(self.TxtBuff)
    end
    self.SelectID = SelectID or nil
    for k, v in pairs(tbBuff) do
        local data = {}
        data.tbParam = v
        if bShowText then
            data.bShowText = true
            data.PanelBuffAll = self.PanelBuffAll
            data.BuffTxt = self.BuffTxt
        else
            data.bShowText = false
        end
        data.bSelect = self.SelectID == k
        data.funClick = function ()
            if not self.SelectID then
                self.tbBuffObj[k]:SetSelect(true)
                self.SelectID = k
                funShowBtnClose(true, k)
            elseif self.SelectID == k then
                if bShowText then
                    self.tbBuffObj[k]:SetSelect(false)
                    self.SelectID = nil
                    funShowBtnClose(false, k)
                end
            else
                self.tbBuffObj[self.SelectID]:SetSelect(false)
                self.tbBuffObj[k]:SetSelect(true)
                self.SelectID = k
                funShowBtnClose(true, k)
            end
        end
        local pObj = self.Factory:Create(data)
        self.ListBuff:AddItem(pObj)
        self.tbBuffObj[k] = pObj.Data
    end
end

function tbClass:CloseTip()
    if self.SelectID then
        self.tbBuffObj[self.SelectID]:SetSelect(false)
        self.SelectID = nil
    end
end

return tbClass
