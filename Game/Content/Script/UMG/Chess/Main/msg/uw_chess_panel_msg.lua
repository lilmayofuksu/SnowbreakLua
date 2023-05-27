-- ========================================================
-- @File    : uw_chess_panel_msg.lua
-- @Brief   : 场景消息提示界面
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbPool = {}
    self.tbUsed = {}
    self:RegisterEvent(Event.NotifyChessTalkMsg, function(tbParam) self:ShowMsg(tbParam) end)
    self:RegisterEvent(Event.NotifyChessMapChanged, function() self:FreeAll() end)
    self:RegisterEvent(Event.NotifyBeginLoad3DChess, function() self:FreeAll() end)
end

function view:ShowMsg(tbParam)
    local actor = tbParam.actor;                -- 说话人
    local widget = self:Alloc(actor)
    widget.widget:SetContent(actor, tbParam)
end

function view:Update(deltaSecond)
    for key, tb in pairs(self.tbUsed) do 
        if not tb.widget:Update(deltaSecond) then 
            self:FreeByActor(key)
        end
    end
end

----------------------------------------------------------------------------
function view:Alloc(actor)
    if self.tbUsed[actor] then 
        return self.tbUsed[actor]
    end

    local tbData;
    if #self.tbPool > 0 then 
        tbData = self.tbPool[#self.tbPool]
        WidgetUtils.Visible(tbData.widget)
        table.remove(self.tbPool, #self.tbPool)
    else 
        tbData = {}
        local widget = LoadWidget("/Game/UI/UMG/Chess/Main/msg/uw_chess_tpl_msg.uw_chess_tpl_msg_C")
        self.Root:AddChild(widget)
        widget.wSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
        tbData.widget = widget
    end
    self.tbUsed[actor] = tbData
    return tbData;
end

function view:FreeByActor(actor)
    local tb = self.tbUsed[actor]
    if tb then 
        self.tbUsed[actor] = nil
        WidgetUtils.Collapsed(tb.widget)
        table.insert(self.tbPool, tb)
    end
end

function view:FreeAll()
    for actor, tb in pairs(self.tbUsed) do 
        self:FreeByActor(actor)
    end
end
----------------------------------------------------------------------------

return view