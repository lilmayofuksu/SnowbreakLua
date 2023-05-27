-- ========================================================
-- @File    : uw_arms_outer_decorsate.lua
-- @Brief   : 武器描述3D界面
-- ========================================================



local tbArmsDecor = Class("UMG.SubWidget")

function tbArmsDecor:Construct()
    -- body
end


function tbArmsDecor:OnOpen()
    -- body
end

--- 枪厂Icon
function tbArmsDecor:ShowTypeLogo(InWeapon)
    SetTexture(self.ImgLogo,InWeapon:Icon(),true)
end


return tbArmsDecor