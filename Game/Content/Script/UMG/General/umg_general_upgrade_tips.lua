-- ========================================================
-- @File    : umg_general_upgrade_tips.lua
-- @Brief   : 通用升级提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
function tbClass:OnInit()
    self.AttrItemFactory = Model.Use(self)
end

---@param tbInfo 变化的数据
---@param pItem UItem 升级的道具
---@param nAddExp float 增加的经验
---@param tbInfo table 变化的属性 {sDes = "攻击" , nAdd = 10 , nValue = 10 }
---@param pCallBack function 关闭回调
function tbClass:OnOpen(pItem, nAddExp, tbInfo, pCallBack)
    self.CloseCallBack = pCallBack
    local nLevel = pItem:EnhanceLevel()
    local nNowMaxExp = Item.GetUpgradeExp(pItem)
    local nNowExp = pItem:Exp()
    --(InLv, InExp, InAddExp, InMaxExp)
    self.DeltaInfo:Set(nLevel, nNowExp, nAddExp, nNowMaxExp)
    self.TxtLevelNum:SetText(nLevel)
    self:DoClearListItems(self.ListView_Upgrade)
    if #tbInfo>0 then
        for _, info in ipairs(tbInfo) do
            info.ShowAnim = true
            local NewObj = self.AttrItemFactory:Create(info)
            self.ListView_Upgrade:AddItem(NewObj)
        end
    end
    self.DeltaInfo:ShowIcon(pItem:Icon())
end
return tbClass
