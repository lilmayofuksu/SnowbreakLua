-- ========================================================
-- @File    : WidgetUtils.lua
-- @Brief   : 界面工具
-- @Author  :
-- @Date    :
-- ========================================================

---通用按钮状态
BtnState = BtnState or {Select = 1, Normal = 2 }

WidgetUtils = WidgetUtils or {}

---强制异步加载图片
WidgetUtils.bForceAsyncLoadTexture = false


----------- 显示 隐藏 触发 禁用-------------------------------
function WidgetUtils.SelfHitTestInvisible(InWidget)
    if InWidget then
        InWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
end

function WidgetUtils.Collapsed(InWidget)
    if InWidget then
        InWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
end

function WidgetUtils.Hidden(InWidget)
    if InWidget then
        InWidget:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
end

function WidgetUtils.HitTestInvisible(InWidget)
    if InWidget then
        InWidget:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
end

function WidgetUtils.Visible(InWidget)
    if InWidget then
        InWidget:SetVisibility(UE4.ESlateVisibility.Visible)
    end
end

function WidgetUtils.IsVisible(InWidget)
    if InWidget then
        return InWidget:IsVisible()
    end
    return false
end

function WidgetUtils.SetVisibleOrCollapsed(InWidget, value)
    if not InWidget then return end 
    if value then 
        InWidget:SetVisibility(UE4.ESlateVisibility.Visible)
    else 
        InWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
end

function WidgetUtils.SetCollapsedOrSelfHitTestInvisible(InWidget, value)
    if not InWidget then return end 
    if value then 
        InWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else 
        InWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
end



-------------------------------------------------------------

---对其  设置padding
function WidgetUtils.AlignmentCenter(InWidget, InPadding)
    local Slot = UE4.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(InWidget)
    if Slot then
        Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
        Slot:SetVerticalAlignment(UE4.EVerticalAlignment.VAlign_Center)
        if InPadding then
            Slot:SetPadding(InPadding)
        end
    end
end

---显示鼠标
function WidgetUtils.ShowMouseCursor(InWidget, bShow)
    RuntimeState.ChangeInputMode(bShow)
end

---是否已经显示鼠标
---@return boolean
function WidgetUtils.MouseCursorStatus(InWidget)
    local Controller = InWidget:GetOwningPlayer()
    if Controller then
        return Controller.bShowMouseCursor
    end
    return false
end

---隐藏
function WidgetUtils.HideAllChildren(InNode)
    local Count = InNode:GetChildrenCount()
    for i = 1, Count do
        local Item = InNode:GetChildAt(i)
        if Item then
            WidgetUtils.Hidden(Item)
        end
    end
end

---显示Item列表 默认Set方法
---@param pContent UPanelWidget 条目容器
---@param tbData table  数据列表
---@param fEachFun function 
---@param sClassPath string Class Path
function WidgetUtils.DisplayItems(pContent, tbData, fEachFun, sClassPath)
    for nIdx, data in ipairs(tbData) do
        local pWidget = pContent:GetChildAt(nIdx - 1)
        if pWidget == nil and sClassPath then
            pWidget = LoadWidget(sClassPath)
        end
        if pWidget then
            WidgetUtils.SelfHitTestInvisible(pWidget)
            if fEachFun then
                fEachFun(pWidget, data)
            else
                pWidget:Set(data)
            end
        end
    end
    for i = #tbData + 1, pContent:GetChildrenCount() do
        WidgetUtils.Collapsed(pContent:GetChildAt(i - 1))
    end
end

---播放进入动画
---@param pWidget UUserWidget
function WidgetUtils.PlayEnterAnimation(pWidget)
    if pWidget and pWidget.AllEnter then
        pWidget:PlayAnimation(pWidget.AllEnter)
    end
end

---创建子节点
---@param pContent UCanvasPanel 容器节点
---@param sChildPath string 路劲
---@param nOrder integer 层级
function WidgetUtils.AddChildToPanel(pContent, sChildPath, nOrder)
    if not pContent or not sChildPath then return end
    nOrder = nOrder or 0
    return UE4.UUMGLibrary.AddChildToPanel(pContent, sChildPath, nOrder)
end

function WidgetUtils.CollapsedWidgets(tbWidgets)
    for _, w in pairs(tbWidgets) do
        WidgetUtils.Collapsed(w)
    end
end
