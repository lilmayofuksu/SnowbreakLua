-- ========================================================
-- @File    : uw_dlcrogue_rolehead.lua
-- @Brief   : 肉鸽活动 增益角色头像
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnCheck, function()
        if self.funcClick then
            self.funcClick()
        end
    end)
end

function tbClass:Show(InCard, InTbCard)
    if not InCard then
        return
    end
    SetTexture(self.icon, InCard:Icon())
    self.funcClick = function ()
        UI.Open("ItemInfo", InCard:Genre(), InCard:Detail(), InCard:Particular(), InCard:Level())
        UI.Call2("ItemInfo", "ShowBtnObtain", false)
    end
    -- if InTbCard and #InTbCard>0 then
    --     self.funcClick = function ()
    --         UI.Open("Role", 5, InCard, InTbCard)
    --     end
    -- end
end

return tbClass
