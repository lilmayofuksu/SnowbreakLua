-- ========================================================
-- @File    : uw_mall_tips_littleitem.lua
-- @Brief   : 商城商品列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

--打开显示 商店打开
function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data

    local pItemTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(tbParam.G,tbParam.D,tbParam.P,tbParam.L)
    if not pItemTemplate then
        self.TextName:SetText("")
        self.TextNum:SetText("0")
        return
    end

    self.TextName:SetText(Text(pItemTemplate.I18N))
    self.TextNum:SetText(tbParam.N or 0)
end

return tbClass;