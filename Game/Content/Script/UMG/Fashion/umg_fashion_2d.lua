-- ========================================================
-- @File    : umg_fashion_2d.lua
-- @Brief   : 皮肤立绘预览界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
end

function tbClass:OnOpen(InParam, InCloseCallback)
    local pRole = InParam.pRole
    self.InCloseCallback = InCloseCallback
    local pSkinTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(7, pRole:Detail(), pRole:Particular(), InParam.Index)
    self.TxtInitiate:SetText(Text(pRole:I18N()))
    self.TxtName:SetText(Text(pSkinTemplate.I18N))
    SetTexture(self.ImgFashionPose, pSkinTemplate.Icon)
end

function tbClass:OnClose()
    if self.InCloseCallback then
        self.InCloseCallback()
    end
end

return tbClass 