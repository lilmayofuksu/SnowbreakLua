-- ========================================================
-- @File    : uw_level_info.lua
-- @Brief   : 关卡详情界面 - boss和奖励详情
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
function tbClass:Construct()
    self.Popup:Init("", function () UI.Close(self) end)
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.ListItem)
    self:DoClearListItems(self.ListMonster)
end

function tbClass:OnOpen(tbListItem, tbMonster)
    self.tbListItem = tbListItem or self.tbListItem
    self.tbMonster = tbMonster or self.tbMonster
    self:UpdatePanel(self.tbListItem, self.tbMonster)
end

function tbClass:UpdatePanel(tbListItem, tbMonster)
    self.tbListItem = tbListItem
    self.tbMonster = tbMonster
    if self.tbListItem then
        self:UpdateItemList(self.tbListItem)
    end
    if self.tbMonster then
        self:UpdateMonsterList(self.tbMonster)
    end
    if Launch.GetType() == LaunchType.DLC1_ROGUE then
        local _, MBuff = RogueLogic.GetTbMonsterBuffID()
        if MBuff then
            WidgetUtils.HitTestInvisible(self.PanelMonsterBuff)
            SetTexture(self.ImgIcon, MBuff.nIcon)
            self.TxtName:SetText(Text(MBuff.sName))
            self.TxtBuffDetail:SetText(Text(MBuff.sDesc, table.unpack(MBuff.tbBuffParamPerCount or {})))
        else
            WidgetUtils.Collapsed(self.PanelMonsterBuff)
        end
    else
        WidgetUtils.Collapsed(self.PanelMonsterBuff)
    end
end

function tbClass:UpdateItemList(tbListItem)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListItem)

    -- 整理列表，同类归类
    -- local tbSorted = {};
    -- local tbCash = {}
    -- for _, tbItem in ipairs(tbListItem) do
    --     if #tbItem == 2 then    --货币
    --         local key = tostring(tbItem[1])
    --         if tbCash[key] then
    --             tbCash[key].nNum = tbCash[key].nNum + tbItem[2];
    --         else
    --             local tmp = {};
    --             tmp.nCashType = tbItem[1];
    --             tmp.nNum = tbItem[2];
    --             tbCash[key] = tmp;
    --         end
    --     else
    --         local key = string.format('%d-%d-%d-%d', tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
    --         if tbSorted[key] then
    --             tbSorted[key].N = tbSorted[key].N + tbItem[5];
    --         else
    --             local tmp = {};
    --             tmp.G = tbItem[1];
    --             tmp.D = tbItem[2];
    --             tmp.P = tbItem[3];
    --             tmp.L = tbItem[4];
    --             tmp.N = tbItem[5];
    --             if bGet then
    --                 tmp.bGeted = bGet
    --             end
    --             tbSorted[key] = tmp;
    --         end
    --     end
    -- end

    -- local tbTmpList = {}
    -- for _, v in pairs(tbSorted) do
    --     table.insert(tbTmpList, v)
    -- end

    --按品质排序
    -- tbTmpList = Item.HandleItemListRank(tbTmpList, true)

    -- for _, tbParam in pairs(tbCash) do
    --     self.ListItem:AddItem(self.ListFactory:Create(tbParam))
    -- end

    for _, tbParam in ipairs(tbListItem) do
        self.ListItem:AddItem(self.ListFactory:Create(tbParam))
    end
end

function tbClass:UpdateMonsterList(tbMonster)
    if not tbMonster then return end
    self.ListMonster:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListMonster)
    for _, tbParam in ipairs(tbMonster) do
        self.ListMonster:AddItem(self.ListFactory:Create(tbParam))
    end
end

return tbClass
