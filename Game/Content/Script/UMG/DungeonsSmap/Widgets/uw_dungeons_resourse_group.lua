-- ========================================================
-- @File    : uw_dungeons_resourse_support.lua
-- @Brief   : 后勤素材
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self:DoClearListItems(self.List)
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BackBtn, function() UI.Close(self) end)
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnSelectListItem(InItem)
    if self.NowItem == InItem then
        return
    end

    if self.NowItem and self.NowItem.SetSelect then
        self.NowItem:SetSelect(false)
    end

    if InItem and InItem.SetSelect then
        InItem:SetSelect(true)
        self.NowItem = InItem
        self:UpdateSuitInfo(InItem.Data.tbSuit)
    end
    self.IsDirty = true
end

function tbClass:UpdateSuitInfo(tbSuit)
    if tbSuit and #tbSuit > 0 then
        local tbSuit = tbSuit[1]
        if tbSuit then
            local SkillTemplate = UE4.USupporterCard.FindSuitSkillTemplate(tbSuit.SuitSkillID)
            if SkillTemplate.TwoSkillID:Length() > 0 then
                local nSkillId = SkillTemplate.TwoSkillID:Get(1)
                self.TxtSuitName:SetText(SkillName(nSkillId))
                self.TxtSuitInfo2:SetContent(SkillDesc(nSkillId))
            end
            if SkillTemplate.ThreeSkillID:Length() > 0 then
                local nSkillId = SkillTemplate.ThreeSkillID:Get(1)
                self.TxtSuitInfo3:SetContent(SkillDesc(nSkillId))
            end
        end
    end
end

function tbClass:OnOpen(Selected, OnOk)
    self.OnOk = OnOk
    for SuitId, _ in pairs(Daily.tbSupportDrop) do
        local tbSuit = Logistics.tbAllLogiSuit[SuitId]
        if tbSuit then
            local tbParam = {
                tbSuit = tbSuit,
                bInitSelect = Selected == SuitId,
                Index = SuitId,
                OnClick = function(InItem)
                    self:OnSelectListItem(InItem)
                    if self.OnOk then
                        self.OnOk(InItem.Data.Index)
                    end
                end,
                GetIsDirty = function()
                    return self.IsDirty
                end
            }
            local item = self.Factory:Create(tbParam)
            self.List:AddItem(item)
            if Selected == _ then
                self:UpdateSuitInfo(tbSuit)
            end
        end
    end
end

return tbClass