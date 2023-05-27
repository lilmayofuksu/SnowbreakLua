-- ========================================================
-- @File    : uw_gacha_info_rule.lua
-- @Brief   : 抽奖记录展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnActive(nId)
    if not nId then return end
    self.nId = nId
    local cfg = Gacha.GetCfg(nId)
    if not cfg then return end

    local tbDetail = cfg.tbDetail
    if not tbDetail then return end

    self:Display(self.List, tbDetail[1], self.TxtTitle1)

    self:Display(self.List2, tbDetail[2], self.TxtTitle2)

    self:Display(self.List3, tbDetail[3], self.TxtTitle3)
end

function tbClass:Display(list, tbData, txt)
    if not list or not tbData then return end
    self:DoClearListItems(list)

    self.Factory = self.Factory or Model.Use(self)
    for i = 2, #tbData do
        local param = {sTxt = Text('gacha.' .. tbData[i])}
        local pObj = self.Factory:Create(param)
        list:AddItem(pObj)
    end

    if txt then
        txt:SetText(Text('gacha.' .. tbData[1]))
    end
end



return tbClass