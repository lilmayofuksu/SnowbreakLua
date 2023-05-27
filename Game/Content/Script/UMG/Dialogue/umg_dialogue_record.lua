-- ========================================================
-- @File    : umg_dialogue_record.lua
-- @Brief   : 剧情对话记录显示
-- @Author  :
-- @Date    :
-- ========================================================

local umg_dialogue_record = Class("UMG.BaseWidget")

function umg_dialogue_record:OnInit()
    BtnAddEvent(self.BtnClose, function()
        UI.Close(self, GuideLogic.RecoveryGuide)
    end)
end

function umg_dialogue_record:OnOpen(datas)
	self:DoClearListItems(self.TalksView)
	self.TalksView:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:SetListData(datas)

    local needCheck = UE4.UGameLibrary.IsWindowsPlatform() and (not IsEditor)
    if needCheck and self.preUIMode == nil then 
        local value = UE4.UUMGLibrary.IsInputUIMode_PC()
        if not value then 
            self.preUIMode = value
            UE4.UUMGLibrary.UpdatePCInputMode(true)
        end
    end
end

function umg_dialogue_record:OnClose()
    if self.preUIMode ~= nil then 
        UE4.UUMGLibrary.UpdatePCInputMode(self.preUIMode)
        self.preUIMode = nil
    end
end

return umg_dialogue_record
