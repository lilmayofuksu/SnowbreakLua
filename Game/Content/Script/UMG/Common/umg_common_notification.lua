-- ========================================================
-- @File    : umg_common_notification.lua
-- @Brief   : 跑马灯
-- ========================================================

---@class tbClass
---@field Content UCanvasPanel
---@field TxtContent UTextBlock
local tbClass = Class("UMG.BaseWidget")
local MOVE_SPEED = 150

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() CacheBroadcast.Stop() UI.Close(self)  end)
end

function tbClass:OnOpen(nIndex)
    self.nIndex = nIndex
    UE4.Timer.NextFrame(function()
        self:RecivePlay(nIndex)
    end)
end

function tbClass:OnClose()
    self:ClearTimer()
end

function tbClass:RecivePlay(nIndex)
    if self == nil then return end
    local tbInfo = CacheBroadcast.Get(nIndex)
    if tbInfo == nil then
        UI.Close(self)
        return
    end

    if self.TxtContent == nil then return end

    self.TxtContent:SetText(LocalContent(tbInfo.sContent))
    self:Stop()

    self.tbInfo = tbInfo
    self:Play()
end

function tbClass:Play()
    UE4.Timer.NextFrame(function()
        self.ContentSizeX = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Content):GetSize().X
        self.TxtSizeX = self.TxtContent:GetDesiredSize().X
        self.bPlay = true
        self.nMoveDis = 0
        WidgetUtils.SelfHitTestInvisible(self)
    end)
end

---
function tbClass:Stop()
    self.Pos = UE4.FVector2D()
    self.bPlay = false
    self.nMoveDis = 0
    WidgetUtils.Hidden(self)
    self:ClearTimer()
end

function tbClass:ClearTimer()
    if self.nTimer then UE4.Timer.Cancel(self.nTimer) self.nTimer = nil end
end


---试图下一轮
function tbClass:TryNext()
    self:Stop()
    local fEnd = function() 
        CacheBroadcast.Stop()
        UI.Close(self) 
    end
    ---事件结束
    if self.tbInfo.nEnd < GetTime() then fEnd()  return end
    ---事件间隔
    self.nTimer = UE4.Timer.Add(self.tbInfo.nInterval, function()
        self.nTimer = nil
        if self.tbInfo.nEnd < GetTime() then fEnd() return end
        self:Play()
    end)
end


---Tick
---@param MyGeometry FGeometry
---@param InDeltaTime number
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.bPlay then return end
    self.nMoveDis = self.nMoveDis + InDeltaTime * MOVE_SPEED
    if self.nMoveDis > self.ContentSizeX + self.TxtSizeX then
        self:TryNext()
        return
    end
    self.Pos.X = self.ContentSizeX - self.nMoveDis
    self.TxtContent:SetRenderTranslation(self.Pos)
end

return tbClass