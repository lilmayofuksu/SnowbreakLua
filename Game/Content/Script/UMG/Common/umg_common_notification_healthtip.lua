-- ========================================================
-- @File    : umg_common_notification_healthtip.lua
-- @Brief   : 健康提示
-- ========================================================

---@class tbClass
local tbClass = Class("UMG.BaseWidget")
local MOVE_SPEED = 150

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() UI.Close(self)  end)
end

function tbClass:OnOpen(cfg)
    self.nStartPlayTime = GetTime()
    print('HealthTip :--------- OnOpen :', cfg)
    if not cfg then return end
    if self.TxtContent == nil then return end
    self.TxtContent:SetText(Text(cfg.txtkey))
    self.cfg = cfg
    self:Stop()
    self:Play()
end

function tbClass:OnClose()
    self:ClearTimer()
end

function tbClass:Play()
    print('HealthTip :--------- Play :', GetTime() - HealthTip.nTriggerTipTime, self.cfg.duration)
    UE4.Timer.NextFrame(function()
        if self:IsOpen() == false then
            return
        end

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
    ---时间结束
    if self:IsTimeEnd() then 
        print('HealthTip :--------- TryNext TimeEnd')
        UI.Close(self)   
        return 
    end
    ---时间间隔

    if self.nTimer then
        UE4.Timer.Cancel(self.nTimer)
        self.nTimer = nil
    end

    self.nTimer = UE4.Timer.Add(2, function()
        self.nTimer = nil
        if self:IsTimeEnd() then
            HealthTip.End() 
            UI.Close(self)     
            return 
        end
        self:Play()
    end)
end

function tbClass:IsTimeEnd()
    local dis = GetTime() - HealthTip.nTriggerTipTime
    return dis > self.cfg.duration
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