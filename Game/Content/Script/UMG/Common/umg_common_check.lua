-- ========================================================
-- @File    : umg_common_check.lua
-- @Brief  : 任务奖励查看界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self:DoClearListItems(self.items)
    self.ListFactory = Model.Use(self);

    BtnAddEvent(self.BtnOK, function()
        ---关闭
        UI.Close(self);
    end)
end

---打开时的回调
---@param tbItems table 道具列表，格式为{{g, d, p, l, n}...}
---@param bGet  bool  nil默认 true已获得
function tbClass:OnOpen(tbItems, bGet)
    if not tbItems or #tbItems <= 0 then return UI.Close(self) end;
    -- 整理列表，同类归类
    local tbSorted = {};
    local tbCash = {}
    for _, tbItem in ipairs(tbItems) do
        if #tbItem == 2 then    --货币
            local key = tostring(tbItem[1])
            if tbCash[key] then
                tbCash[key].nNum = tbCash[key].nNum + tbItem[2];
            else
                local tmp = {};
                tmp.nCashType = tbItem[1];
                tmp.nNum = tbItem[2];
                tbCash[key] = tmp;
            end
        else
            local key = string.format('%d-%d-%d-%d', tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
            if tbSorted[key] then
                tbSorted[key].N = tbSorted[key].N + tbItem[5];
            else
                local tmp = {};
                tmp.G = tbItem[1];
                tmp.D = tbItem[2];
                tmp.P = tbItem[3];
                tmp.L = tbItem[4];
                tmp.N = tbItem[5];
                if tbItem[6] and tbItem[6] > 0 then
                    tmp.pItem = me:GetItem(tbItem[6])
                end
                if tmp.G == 7 then
                    table.insert(Fashion.tbGainSkins, tmp)
                end
                if bGet then
                    tmp.bGeted = bGet
                end
                tbSorted[key] = tmp;
            end
        end
    end

    local tbTmpList = {}
    for _, v in pairs(tbSorted) do
        table.insert(tbTmpList, v)
    end

    --按品质排序
    tbTmpList = Item.HandleItemListRank(tbTmpList, true)

    for _, tbParam in pairs(tbCash) do
        self.items:AddItem(self.ListFactory:Create(tbParam));
    end

    for _, tbParam in ipairs(tbTmpList) do
        self.items:AddItem(self.ListFactory:Create(tbParam));
    end
end

function tbClass:OnClose()

end

function tbClass:OnDestruct()

end


return tbClass
