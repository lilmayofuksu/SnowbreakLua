-- ========================================================
-- @File    : umg_general_gain_tips.lua
-- @Brief   : 道具出售确认面板
-- ========================================================

local tbClass = Class('UMG.BaseWidget')


function tbClass:Construct()
    self.nPlayEnd = false
    self.items.OnPlayAppearAnimFinish:Add(self, function()
        UE4.Timer.Add(1, function()
            self.nPlayEnd = true
        end) 
    end)
end

function tbClass:OnInit()
    self:DoClearListItems(self.items)
    self.ListFactory = Model.Use(self);
    BtnAddEvent(self.BtnClose, function()
        if not self.items then 
            UI.Close(self);
        end

        ---第一步 展示所有道具
        if not self.nPlayEnd then
            self.Items:ForceAppearAnimEnd()
            self.nPlayEnd = true
            return
        end

        ---关闭
        UI.Close(self);
    end)
end

---打开时的回调
---@param tbItems table 道具列表，格式为{{g, d, p, l, n}...}
---@param fCallback function 关闭回调
---@param bGet  bool  nil默认 true已获得
---@param bView  bool  nil默认 true查看(修改title文本为 查看详情)
function tbClass:OnOpen(tbItems, fCallback, bGet, bView, bRecycle)
    if not tbItems or #tbItems <= 0 then return UI.Close(self) end;
    self.fCallback = fCallback

    if bRecycle then
        self.TextBlock_129:SetText(Text("ui.TxtItemRecycle"))
    elseif bView then
        self.TextBlock_129:SetText(Text("ui.TxtItemDetail"))
    else
        self.TextBlock_129:SetText(Text("ui.TxtGainItem"))
    end


    if #tbItems <= 12 then
        WidgetUtils.SelfHitTestInvisible(self.ItemScrollBox)
    else
        WidgetUtils.Visible(self.ItemScrollBox)
    end


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

    --如果在指引先隐藏指引界面
    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(true)
    end

    Audio.PlaySounds(3021)
end

function tbClass:OnClose()
    if self.fCallback then
        self.fCallback()
    end
    Fashion.TryPopGainTips()
    --如果在指引恢复显示界面
    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(false)
    end
end

return tbClass;