-- ========================================================
-- @File    : umg_general_sell_tips.lua
-- @Brief   : 道具出售确认面板
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    self.ListFactory = Model.Use(self);

    self.yes.OnClicked:Add(self, function()
        -- 开始出售
        local tbParam = {};
        tbParam.tbItems = {};
        for _, tbItem in ipairs(self.tbRecycles) do
            local tmp = {};
            tmp.nId = tbItem.pItem:Id();
            tmp.nCount = tbItem.nCount;
            table.insert(tbParam.tbItems, tmp);
        end
        me:CallGS('Item_Recycle', json.encode(tbParam));

        if self.OnConfirm then self.OnConfirm() end;
        UI.Close(self);
    end);

    self.no.OnClicked:Add(self, function()
        if self.OnCancel then self.OnCancel() end;
        UI.Close(self);
    end);
end

---打开时的回调
---@param tbItems table 需要出售的道具列表,格式为{{pItem, nCount}...}
---@param OnConfirm function 确认的回调
---@param OnCancel function 取消时的回调
function tbClass:OnOpen(tbItems, OnConfirm, OnCancel)
    if not tbItems then return UI.Close(self); end;
    self.OnConfirm = OnConfirm;
    self.OnCancel = OnCancel;

    local tbRewards, tbRecycles = ItemRecycle.CalcRewards(tbItems); -- 预览分解所得

    -- 无合法出售的物品则弹出错误
    if not tbRecycles or #tbRecycles <= 0 then
        UI.Close(self);
        UI.ShowMessage('error.Recycle.ItemCanNotRecycle');
    else
        self.tbRecycles = tbRecycles;
    end

    self:DoClearListItems(self.rewards)
    local tbParam = {};
    for _, tbReward in ipairs(tbRewards) do
        tbParam.G = tbReward[1];
        tbParam.D = tbReward[2];
        tbParam.P = tbReward[3];
        tbParam.L = tbReward[4];
        tbParam.nHaveNum = tbReward[5];
        self.rewards:AddItem(self.ListFactory:Create(tbParam));
    end
end

return tbClass;