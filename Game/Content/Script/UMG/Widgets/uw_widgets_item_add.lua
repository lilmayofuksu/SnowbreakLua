-- ========================================================
-- @File    : uw_widgets_item_add.lua
-- @Brief   : 消耗道具选择
-- ========================================================
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function() self:OnClick() end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nDataChangeEvent)
end

function tbClass:OnListItemObjectSet(InObj)
    if (not InObj) or (not InObj.Data) then
        return
    end
    self:Display(InObj.Data)
end

function tbClass:Display(tbParam)
    self.tbParam = tbParam
    EventSystem.Remove(self.nDataChangeEvent)
    self.nDataChangeEvent = EventSystem.OnTarget(self.tbParam, "ON_DATA_CHANGE", function()
        self:Update()
    end)
    self:Update()
end

function tbClass:OnClick()
    if self.tbParam and self.tbParam.fClick then
        self.tbParam.fClick()
    end
end

function tbClass:Update()
    if self.tbParam.pItem then
        WidgetUtils.SelfHitTestInvisible(self.Item)
        WidgetUtils.Collapsed(self.Select)
        local pItem = self.tbParam.pItem
        local N = {}
        if self.tbParam.nNeedNum then
            N.nSelectNum = self.tbParam.nNeedNum
            N.nHaveNum = self.tbParam.nNum or pItem:Count()
        else
            N.nSelectNum = self.tbParam.nNum or 0
            N.nHaveNum = pItem:Count()
        end
        if not pItem:CanStack() then N = nil end
        local tbData = {
            G = pItem:Genre(),
            D = pItem:Detail(),
            P = pItem:Particular(),
            L = pItem:Level(),
            N = N,
            CanStack = pItem:CanStack(),
            ShowBreakImg = Item.IsBreakMax(pItem),
            fCustomEvent = function()
                self:OnClick()
            end
        }
        self.Item:Display(tbData)
        return
    elseif self.tbParam.nNeedNum and self.tbParam.nNeedNum > 0 then
        WidgetUtils.Collapsed(self.Select)
        WidgetUtils.SelfHitTestInvisible(self.Item)
        local tbData = {
            G = self.tbParam.G, 
            D = self.tbParam.D, 
            P = self.tbParam.P, 
            L = self.tbParam.L, 
            N = {nNeedNum = self.tbParam.nNeedNum, nHaveNum = self.tbParam.nNum},
            -- nNeedNum = self.tbParam.nNeedNum,
            -- nHaveNum = self.tbParam.nNum,
        }
        self.Item:Display(tbData)
        return

    elseif self.tbParam.G and self.tbParam.D and self.tbParam.P and self.tbParam.L then
        WidgetUtils.Collapsed(self.Select)
        WidgetUtils.SelfHitTestInvisible(self.Item)
        local tbData = {
            G = self.tbParam.G, 
            D = self.tbParam.D, 
            P = self.tbParam.P, 
            L = self.tbParam.L, 
        }
        self.Item:Display(tbData)
        return
    else
        WidgetUtils.Collapsed(self.Item)
        WidgetUtils.SelfHitTestInvisible(self.Select)
    end
end

return tbClass