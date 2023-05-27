-- ========================================================
-- @File    : umg_thread_info
-- @Brief   : 线程信息
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

local TICK_GAP = 1
local nAddTime = 0




function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
    nAddTime = 0
end

function tbClass:OnOpen(nType)
    self:SetType(nType)
end

function tbClass:SetType(nType)
    self.nType = nType or 1

    if self.nType == 1 then
        WidgetUtils.Visible(self.Thread)
        WidgetUtils.Collapsed(self.ClaimedNum)
    else
        WidgetUtils.Collapsed(self.Thread)
        WidgetUtils.HitTestInvisible(self.ClaimedNum)
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if self.nType == nil then return end

    if self.nType == 1 then
        if nAddTime <= 0 then
            nAddTime = TICK_GAP
            local str = self:GatherThreadInfo()
            str = string.gsub(str, '\\n', '\n')
            self.TxtThreadInfo:SetText(str)
        else
            nAddTime = nAddTime - InDeltaTime 
        end
    elseif self.nType == 2 then
        self.ClaimedNum:SetText(UE4.UGMLibrary.GetObjectArrayNumMinusAvailable())
    elseif self.nType == 3 then
        self.ClaimedNum:SetText(UE4.UGMLibrary.GetAliveMonsterCount())
    end
end

return tbClass