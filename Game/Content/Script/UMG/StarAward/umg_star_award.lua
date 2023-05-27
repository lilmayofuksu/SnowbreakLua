-- ========================================================
-- @File    : umg_star_award.lua
-- @Brief   : 章节星级奖励
-- ========================================================

---@class tbClass : ULuaWidget
---@field ListNum UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Popup:Init('STAR AWARD', function() UI.Close(self) end, 1701001)
    self.ListFactory = Model.Use(self);
    self.nHandleId = EventSystem.OnTarget(Chapter, Chapter.REQ_GET_STAR_AWARDC, function()
        if #self.tbNeedUpdate > 0 then
            local tbData = self.tbNeedUpdate[1]
            Item.Gain(tbData.tbInfo[2])
            EventSystem.TriggerTarget(tbData, 'ON_DATA_CHANGE')
            table.remove(self.tbNeedUpdate, 1)
            Chapter.UpdateStarAwardTip(Chapter.IsMain(), Chapter.GetChapterDifficult(), Chapter.GetChapterID())
        end
    end)

    self.nHandleId1 = EventSystem.OnTarget(DLC_Chapter, DLC_Chapter.REQ_GET_STAR_AWARDC, function()
        if #self.tbNeedUpdate > 0 then
            local tbData = self.tbNeedUpdate[1]
            Item.Gain(tbData.tbInfo[2])
            EventSystem.TriggerTarget(tbData, 'ON_DATA_CHANGE')
            table.remove(self.tbNeedUpdate, 1)
            DLC_Chapter.UpdateStarAwardTip(Chapter.GetChapterID())
        end
    end)
    self.tbNeedUpdate = {}
end


function tbClass:OnOpen(isDlc)
    self:DoClearListItems(self.ListNum)
    self.ListNum:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    local tbCfg = Chapter.GetCurrentChapterCfg()
    if isDlc then
        tbCfg = DLC_Chapter.GetCurrentChapterCfg()
    end
    if tbCfg == nil then return end
    local tbAward = tbCfg.tbStarAward
    if tbAward == nil then return end
    if isDlc then
        self.TxtName:SetText(Text("ui.TxtDLC1Name"))
    else
        self.TxtName:SetText(Text(tbCfg.sName))
    end
    local nAllNum, nGetNum = Chapter.GetChapterStarInfo()
    if isDlc then
        nAllNum, nGetNum = DLC_Chapter.GetChapterStarInfo()
    end

    local fClickEvent = function(InData)
        table.insert(self.tbNeedUpdate, InData)
        if isDlc then
            DLC_Chapter.Req_GetStarAward(DLC_Chapter.GetChapterID(), InData.nIndex)
        else
            Chapter.Req_GetStarAward(Chapter.IsMain(), Chapter.GetChapterDifficult(), Chapter.GetChapterID(), InData.nIndex)
        end
        
    end

    for i = 1, #tbAward do
        local tbParam = {nIndex = i, nGetNum = nGetNum, tbInfo = tbAward[i], fClick = fClickEvent}
        local NewObj = self.ListFactory:Create(tbParam)
        self.ListNum:AddItem(NewObj)
    end
end

function tbClass:OnClose()
    EventSystem.Remove(self.nHandleId)
    EventSystem.Remove(self.nHandleId1)
    self.tbNeedUpdate = {}
end

return tbClass