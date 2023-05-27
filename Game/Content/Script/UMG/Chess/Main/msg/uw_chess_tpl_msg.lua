-- ========================================================
-- @File    : uw_chess_tpl_msg.lua
-- @Brief   : 场景消息提示内容
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)   
    self.canvasRoot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Root)
end

function view:SetContent(actor, tbParam)
    self.targetActor = actor
    local msg = tbParam.msg;                                    -- 说话内容
    self.tbMsg = Split(msg, ",");
    self.offsetHeight = tonumber(tbParam.offset) or 0;          -- 位置高度偏移
    self.offsetHeight = self.offsetHeight * 100
    self.duration = tbParam.duration or 3;                      -- 内容持续时间
    self.time = 0;
    self:GotoIndex(1)
    self:Update(0)
    WidgetUtils.Collapsed(self.Root)
    UE4.Timer.Add(0.01, function() 
        WidgetUtils.Visible(self.Root)
    end)
end

function view:Update(deltaSecond)
    self.parentGeometry = self.Root:GetParent():GetCachedGeometry()
    local location = self.targetActor:K2_GetActorLocation();
    location.Z = location.Z + self.offsetHeight;
    local ret, screenPos = self.playerController:ProjectWorldLocationToScreen(location)
    local localPos
    if ret then 
        localPos = UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, self.parentGeometry, screenPos)
        self.canvasRoot:SetPosition(localPos)
    end

    self.time = self.time + deltaSecond
    if self.time >= self.duration then 
        self:GotoIndex(self.index + 1)
    end
    return self.duration < 0 or self.time < self.duration
end

function view:GotoIndex(index)
    self.index = index
    local msgKey = self.tbMsg[index];
    if msgKey then 
        msgKey = Text(msgKey)
        self.TxtContent:SetText(msgKey)
        self.time = 0;
    end
end


return view