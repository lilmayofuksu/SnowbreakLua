-- ========================================================
-- @File    : uw_rolebreak_tips.lua
-- @Brief   : 突破提示确认界面
-- @Author  :
-- @Date    :
-- ========================================================

local BreakTip = Class("UMG.SubWidget")
BreakTip.BreakMatPath = "/Game/UI/UMG/Widgets/uw_general_props_list_item_data"
BreakTip.AttrItemPath = "UMG/Role/Widget/RoleBreak/uw_rolebreak_num_data"

function BreakTip:Construct()
    self.BreakMat = Model.Use(self)
    self.BreakAttr = Model.Use(self, self.AttrItemPath)
end

--- 突破需要的材料
function BreakTip:BreakMatList(InItem)
    self:DoClearListItems(self.MatList)
    local tbItem = RBreak.GetBreakMat(InItem)
    if not tbItem then
        UI.ShowTip("tip.Limit_Times")
        return
    end

    if #tbItem > 0 then
        for index, value in ipairs(tbItem) do
            local nNow = me:GetItemCount(value[1], value[2], value[3], value[4])
            local ncost = value[5]
            local tbParam = {
                G = value[1],
                D = value[2],
                P = value[3],
                L = value[4],
                N = value[5],
                pItem = InItem,
                Total = nNow,
                Name = "111"
            }
            local NewObj = self.BreakMat:Create(tbParam)
            self.MatList:AddItem(NewObj)
        end
    end
end

--- 突破属性变化表
function BreakTip:ShowAttrList(InCard)
    local tbAttr = RBreak.GetAttrs()
    self:DoClearListItems(self.AttrList)
    for key, value in pairs(tbAttr) do
        local tbParam = {
            sName = RBreak.Attrs(value, InCard).sName,
            nNow = RBreak.Attrs(value, InCard).nNow,
            nNew = RBreak.Attrs(value, InCard).nNew
        }
        local NewItem = self.BreakAttr:Create(tbParam)
        self.AttrList:AddItem(NewItem)
    end
end
--- 技能图标更新
function BreakTip:PreSkill(InID)
    if InID > 5 then
        self.PreviewSkill:CheckSkill(RBreak.MulState.None)
        return
    end
    self.PreviewSkill:CheckSkill(RBreak.MulState.On)
    self.PreviewSkill:SetSkillName("Skill-" .. InID)
end

--- 等级Icon刷新
function BreakTip:ShowBreakLv(InItem)
    self.StarIcon:ShowBreakLv(InItem, 2)
end
--- 预览Tip信息刷新
function BreakTip:UpData(InCard)
    -- self:ShowBreakLv(InCard)
    -- self:PreSkill(InCard:Break()+2)
    self:ShowAttrList(InCard)
    self:BreakMatList(InCard)
    self.BreakLv:SetText(InCard:Break()+2)
end

return BreakTip
