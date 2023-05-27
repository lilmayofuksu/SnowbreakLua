-- ========================================================
-- @File    : uw_widgets_item_select.lua
-- @Brief   : 消耗道具选择
-- ========================================================
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
   BtnAddEvent(self.BtnReduce, function() self:Sub() end)
   self.BtnReduce.bLong = true
   self.BtnReduce.OnLongPressed:Add(self, function(_, _, n)
        local bSuc =  self:Sub()
        if not bSuc then
            self.BtnReduce:StopLongPress()
        end
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nDataChangeEvent)
end

function tbClass:Add()
    if not self.tbParam then return false end

    if self.tbParam.bCanStack then
        local nNewNum = (self.tbParam.nNum or 0) + 1
        if nNewNum > self.nMaxCount then
            return false
        end
        if self.tbParam.fAdd then
            local bSuc = self.tbParam.fAdd(self.tbParam.pItem, nNewNum)
            if bSuc then
                self.tbParam.nNum = nNewNum
                self:Update()
            end
            return bSuc
        end
    else
        local nNum = self.tbParam.pItem:Count()
        local bSuc = self.tbParam.fAdd(self.tbParam.pItem, nNum)
        if bSuc then
            self.tbParam.nNum = nNum
            self:Update()
        end
    end

    return true
end

function tbClass:Sub()
    if not self.tbParam then return false end

    if self.tbParam.bCanStack then
        local nNewNum = (self.tbParam.nNum or 0) - 1
        if nNewNum < 0 then
            return false
        end

        self.tbParam.nNum = nNewNum
        if self.tbParam.fSub then
            self.tbParam.fSub(self.tbParam.pItem, nNewNum)
        end

        self:Update()
    else
        self.tbParam.fSub(self.tbParam.pItem, 0)
        self.tbParam.nNum = 0
        self:Update()
    end
    return true
end

function tbClass:OnListItemObjectSet(InObj)
    if (not InObj) or (not InObj.Data) then
        return
    end
    self.tbParam = InObj.Data

    local pItem =  self.tbParam.pItem
    if pItem == nil then return end
    local tbData = {
        G = pItem:Genre(),
        D = pItem:Detail(),
        P = pItem:Particular(),
        L = pItem:Level(),
        N = pItem:Count(),
        pitem = pItem,
        ShowBreakImg = Item.IsBreakMax(pItem),
        ClickNum = self.tbParam.nClick or 1,
        fCustomEvent = function()
            if not self.tbParam.bCanStack and self.tbParam.nNum%2 > 0 then
                return self:Sub()
            end
            return self:Add()
        end
     }
    self.Item:Display(tbData)

    ---长按处理
    if self.Item.BtnClick then
        if self.tbParam.bCanStack then
            self.Item.BtnClick.bLong = true
            self.Item.BtnClick.OnLongPressed:Clear()
            self.Item.BtnClick.OnLongPressed:Add(self, function(_, _, n)
                local bSuc = self:Add()
                if not bSuc then
                    self.Item.BtnClick:StopLongPress()
                end
            end)
        else
            self.Item.BtnClick.bLong = false
        end
    end
    self.nMaxCount = pItem:Count()

    EventSystem.Remove(self.nDataChangeEvent)
    EventSystem.OnTarget(self.tbParam, "ON_DATA_CHANGE", function()
        self:Update()
    end)
    self:Update()
end

function tbClass:Update()
    if not self.tbParam then return end

    self.nMaxCount = self.tbParam.pItem:Count()

    self.Item.tbParam.N = self.nMaxCount
    self.Item:SetNum(self.Item.tbParam)

    if self.tbParam.nNum and self.tbParam.nNum > 0 then
        ---可以堆叠
        if self.tbParam.bCanStack then
            WidgetUtils.Collapsed(self.ImgSelect)
            WidgetUtils.HitTestInvisible(self.TxtSelectNum)
            self.TxtSelectNum:SetText(self.tbParam.nNum)
        else
            WidgetUtils.SelfHitTestInvisible(self.ImgSelect)
            WidgetUtils.Collapsed(self.TxtSelectNum)
        end
        WidgetUtils.SelfHitTestInvisible(self.PanelSelectCount)
    else
        WidgetUtils.Collapsed(self.PanelSelectCount)
    end
end

return tbClass
