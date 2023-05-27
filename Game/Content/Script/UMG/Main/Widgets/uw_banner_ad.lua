-- ========================================================
-- @File    : uw_banner_ad.lua
-- @Brief   : 登录公告打脸界面
-- ========================================================

local  tbBannerAd = Class("UMG.SubWidget")

function tbBannerAd:Construct()
    self.BtnJump.OnClicked:Add(
        self,
        function()
            self.Param.ClickFun(self.Param.Idx)
        end
    )
end

function tbBannerAd:OnInit(tbParam)
    self.Param = tbParam
    SetTexture(self.AdImg,self.Param.Data.nBg,true)
end

return tbBannerAd