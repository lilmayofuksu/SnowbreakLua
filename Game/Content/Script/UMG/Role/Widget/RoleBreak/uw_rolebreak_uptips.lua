-- ========================================================
-- @File    : uw_rolebreak_uptips.lua
-- @Brief   : 突破提示确认界面
-- @Author  :
-- @Date    :
-- ========================================================

local ComfirmTip=Class("UMG.SubWidget")
ComfirmTip.AttrItemPath = "UMG/Role/Widget/RoleBreak/uw_rolebreak_num_data"

function ComfirmTip:Construct()
    self.BreakAttr = Model.Use(self, self.AttrItemPath)
end

--- 天启等级Icon展示
function ComfirmTip:ShowQualLv(InItem)
    self.StarIcon:ShowBreakLv(InItem,1)
end

--- 解锁技能图标
function ComfirmTip:UnLockSkill()
    self.IconSkill:CheckSkill(RBreak.MulState.On)
end

function ComfirmTip:ShowAttrs(InCard)
    local tbAttr=RBreak.GetAttrs()
    self:DoClearListItems(self.AttrList)
    for key, value in pairs(tbAttr) do
        local tbParam = {
            sName = RBreak.Attrs(value,InCard,true).sName,
            nNow = RBreak.Attrs(value,InCard,true).nNow,
            nNew = RBreak.Attrs(value,InCard,true).nNew
        }
        local NewItem = self.BreakAttr:Create(tbParam)
        self.AttrList:AddItem(NewItem)
    end
end

--- 刷新确认界面信息
function ComfirmTip:UpData(InCard)
    self:ShowQualLv(InCard)
    self:UnLockSkill()
    self:ShowAttrs(InCard)
end

return ComfirmTip