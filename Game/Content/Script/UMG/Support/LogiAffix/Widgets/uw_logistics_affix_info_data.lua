
-- ========================================================
-- @File    : uw_logistics_affix_info_data.lua
-- @Brief   : 洗练界面信息展示
-- ========================================================

local AffixInfo = Class("UMG.SubWidget")
AffixInfo.OnClickFunc = nil
AffixInfo.nAffixIdx = 0
AffixInfo.sTxtTitle =''
AffixInfo.sTxtCont = ''
AffixInfo.sTxtDes = ''

function AffixInfo:OnInit(InParam)
    self.OnClickFunc = InParam.OnClick
    self.nAffixIdx = InParam.AffixIdx
    self.sTxtTitle =InParam.TxtTitle
    self.sTxtCont = InParam.TxtCont
    self.sTxtDes = InParam.TxtDes
end



return AffixInfo