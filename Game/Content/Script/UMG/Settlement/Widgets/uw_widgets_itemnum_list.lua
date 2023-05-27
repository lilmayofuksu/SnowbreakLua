-- ========================================================
-- @File    : uw_widgets_itemnum_list.lua
-- @Brief   : 多倍收益奖励
-- ========================================================
local tbClass = Class("UMG.SubWidget")
tbClass.sItemPath =  '/Game/UI/UMG/Widgets/uw_widgets_item_list.uw_widgets_item_list_C'

function tbClass:Construct()
    self.ListFactory = Model.Use(self)
end

function tbClass:OnListItemObjectSet(pObj)
    local tbData = pObj.Data
    local bShow = tbData.bShow

    if bShow then --多个
        self:ShowMultiple(tbData)
    else
        self:ShowOne(tbData)
    end
end

--显示单个
function tbClass:ShowOne(tbData)
    local tbAward = tbData.tbAward or {}
    WidgetUtils.Collapsed(self.TextBlock_93)
    WidgetUtils.Collapsed(self.Image_45)
    WidgetUtils.Visible(self.AwardListone)
    WidgetUtils.Collapsed(self.AwardList)

    local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.AwardListone)
    local MakePos = UE4.FVector2D()
    MakePos.Y = Slot:GetPosition().Y
    MakePos.X = Slot:GetPosition().X - 90
    Slot:SetPosition(MakePos)

    self.AwardListone:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.AwardListone)

    for _, tbInfo in ipairs(tbAward) do
        local G, D, P, L, N,dropType, id = table.unpack(tbInfo)
        local fCustomEvent = nil
        if G == 3 and id then
            local pItem = me:GetItem(id)
            if pItem then
                fCustomEvent = function()
                    UI.Open("ItemInfo", pItem)
                end
            end
        end
        local tbParam = {G = G, D = D, P = P, L = L, N = N,dropType = dropType, fCustomEvent = fCustomEvent}
        local pObj = self.ListFactory:Create(tbParam)
        self.AwardListone:AddItem(pObj)
    end
end

--显示多倍
function tbClass:ShowMultiple(tbData)
    local tbAward = tbData.tbAward or {}
    local nIdx = tbData.nIdx or 0

    self.TextBlock_93:SetText(nIdx)
    if tbData.bPlay then
        WidgetUtils.HitTestInvisible(self.TextBlock_93)
        WidgetUtils.Visible(self.Image_45)
    else
        WidgetUtils.Collapsed(self.TextBlock_93)
        WidgetUtils.Collapsed(self.Image_45)
    end

    WidgetUtils.Visible(self.AwardList)
    WidgetUtils.Collapsed(self.AwardListone)

    self.AwardList:ClearChildren()
    for _, tbInfo in ipairs(tbAward) do
        local G, D, P, L, N,dropType, id = table.unpack(tbInfo)
        local fCustomEvent = nil
        if G == 3 and id then
            local pItem = me:GetItem(id)
            if pItem then
                fCustomEvent = function()
                    UI.Open("ItemInfo", pItem)
                end
            end
        end
        local tbParam = {G = G, D = D, P = P, L = L, N = N,dropType = dropType, fCustomEvent = fCustomEvent}
        local pNewItem = LoadWidget(self.sItemPath)
        if pNewItem then
            self.AwardList:AddChild(pNewItem)
            pNewItem:Display(tbParam)
            if not tbData.bPlay then
                WidgetUtils.Collapsed(pNewItem)
            end
        end
        local pObj = self.ListFactory:Create(tbParam)
        self.AwardListone:AddItem(pObj)
    end

    if not tbData.bPlay then
        self:PlayStarInfoAnim(nIdx)
        tbData.bPlay = true
    end
end

---依次播放动画
function tbClass:PlayStarInfoAnim(nIdx)
    self.AnimTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
            local widgets = self.AwardList:GetAllChildren()
            for i = 1, widgets:Length() do
                local pWidget = widgets:Get(i)
                if pWidget then
                    WidgetUtils.Visible(pWidget)
                    pWidget:PlayAnimation(pWidget.Enter)
                end
            end

            WidgetUtils.HitTestInvisible(self.TextBlock_93)
            WidgetUtils.Visible(self.Image_45)

            UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.AnimTimer)
        end
        },
        0.1*nIdx,
        true
    )
end

return tbClass