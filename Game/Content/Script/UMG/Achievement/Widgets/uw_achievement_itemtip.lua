-- ========================================================
-- @File    : uw_achievement_itemtip.lua
-- @Brief   : 任务界面  奖励提示界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.CommonBg:Init(function() WidgetUtils.Collapsed(self) end)
    self:DoClearListItems(self.ListItem)
end

function tbClass:Init(tbRewards, nstate)
   -- print("uw_achievement_itemtip Init",#tbRewards)
    self:DoClearListItems(self.ListItem)

    local tbSorted = {};
    for _, tbItem in ipairs(tbRewards) do
        local key = string.format('%d-%d-%d-%d', tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
        if tbSorted[key] then
            tbSorted[key][5] = tbSorted[key][5] + tbItem[5];
        else
            tbSorted[key] = tbItem;
        end
    end

    local tbTmpList = {}
    for _, v in pairs(tbSorted) do
        table.insert(tbTmpList, v)
    end

    --按品质排序
    tbTmpList = Item.HandleItemListRank(tbTmpList)

    for _, v in ipairs(tbTmpList) do
        local cfg = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5], bGeted = nstate == 2}
        local pObj = self.Factory:Create(cfg)
        self.ListItem:AddItem(pObj)
    end

    Audio.PlaySounds(3021)
end

return tbClass
