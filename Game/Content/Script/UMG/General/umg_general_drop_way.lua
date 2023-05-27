-- ========================================================
-- @File    : umg_general_drop_way.lua
-- @Brief   : 养成界面提示
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

tbClass.DefTextKey = '';

function tbClass:OnInit()
    self.mask.OnMouseButtonDownEvent:Bind(self, tbClass.DownFun)
end

function tbClass:DownFun()
    UI.Close(self)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

---打开时操作
---@param nG integer
---@param nD integer
---@param nP integer
---@param nL integer
---@param sTextKey string 说明文本的KEY,不填则默认
function tbClass:OnOpen(nG, nD, nP, nL, sTextKey)
    self.ItemNum:SetText(me:GetItemCount(nG, nD, nP, nL))
    if sTextKey then
        self.text:SetText(Text(sTextKey))
    end
end

return tbClass
