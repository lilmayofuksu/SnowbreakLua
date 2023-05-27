-- ========================================================
-- @File    : uw_star_award_list_item.lua
-- @Brief   : 章节星级奖励条目
-- ========================================================

---@class tbClass : UUserWidget
---@field ListItem UListView
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnOn, function()
        if self.nGetNum < self.nNeedNum then
            UI.ShowTip('tip.star_not_enough')
            return
        end
        if self.fClick then
            self.fClick(self.Data)
        end
    end)

    self.ListFactory = Model.Use(self)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListItem)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nHandleId)
end

function tbClass:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Data == nil then
        return
    end
    self.Data = InObj.Data
    self.nIndex = InObj.Data.nIndex
    self.tbInfo = InObj.Data.tbInfo
    self.nGetNum = InObj.Data.nGetNum
    self.fClick = InObj.Data.fClick

    ---显示奖励
    self:DoClearListItems(self.ListItem)
    local tbAward = self.tbInfo[2]
    if tbAward then
        for _, v in ipairs(tbAward) do
            local pObj = self.ListFactory:Create({G = v[1], D = v[2], P = v[3], L = v[4], N = v[5]})
            self.ListItem:AddItem(pObj)
        end
    end

    self.nNeedNum = self.tbInfo[1]
    self.TxtPlayerStar:SetText(self.nGetNum)
    self.TxtNeedStar:SetText(self.nNeedNum)

    EventSystem.Remove(self.nHandleId)
    self.nHandleId = EventSystem.OnTarget(InObj.Data, 'ON_DATA_CHANGE', function()
        self:Update()
    end)

    self:Update()
end

function tbClass:Update()
    local bGet = false
    if Launch.GetType() ~= LaunchType.DLC1_CHAPTER then
        local tbCfg = Chapter.GetCurrentChapterCfg()
        bGet = tbCfg:DidGotStarAward(self.nIndex)
    else
        bGet = DLC_Chapter.DidGotStarAward(DLC_Chapter.GetChapterID(), self.nIndex)
    end
    
    ---领取了奖励
    if bGet then
        WidgetUtils.Collapsed(self.PanelOn)
        WidgetUtils.Collapsed(self.PanelNotGet)
        WidgetUtils.SelfHitTestInvisible(self.PanelGet)
    else
        if self.nGetNum < self.nNeedNum then
            WidgetUtils.Collapsed(self.PanelOn)
            WidgetUtils.SelfHitTestInvisible(self.PanelNotGet)
            WidgetUtils.Collapsed(self.PanelGet) 
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelOn)
            WidgetUtils.Collapsed(self.PanelNotGet)
            WidgetUtils.Collapsed(self.PanelGet)
        end
    end
end

return tbClass