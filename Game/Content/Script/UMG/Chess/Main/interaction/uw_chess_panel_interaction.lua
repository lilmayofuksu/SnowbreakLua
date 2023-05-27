-- ========================================================
-- @File    : uw_chess_panel_interaction.lua
-- @Brief   : 交互界面
-- ========================================================

local view = Class("UMG.SubWidget")
local tbAroundGridOffset = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}

function view:Construct()
    self.tbPool = {}
    self.tbUsed = {}
    self:RegisterEvent(Event.NotifyShowChessInteraction, function(actor) self:ShowActor(actor) end)
    self:RegisterEvent(Event.NotifyHideChessInteraction, function(actor) self:HideActor(actor) end)
    self:RegisterEvent(Event.NotifyChessMapChanged, function(actor) self:FreeAll() end)
    self:RegisterEvent(Event.NotifyBeginLoad3DChess, function() self:FreeAll() end)
    self:RegisterEvent(Event.NotifyRefreshChessInteraction, function(tbParam)
        if tbParam then self.tbRefreshParam = tbParam end
        self:NotifyRefreshChessInteraction()
    end)
    self:RegisterEvent(Event.NotifyHideChessObject, function(tbTargetData) 
        if tbTargetData.actor then 
            self:HideActor(tbTargetData.actor) 
        end
    end)
    self:RegisterEvent(Event.NotifyShowChessObject, function(tbTargetData) 
        if tbTargetData.actor and tbTargetData.actor:CanInteraction() then 
            self:NotifyRefreshChessInteraction()
        end
    end)
end

function view:ShowActor(actor)
    local widget = self:Alloc(actor)
    widget.widget:SetContent(actor)
end

function view:HideActor(actor)
    if actor then 
        self:FreeByActor(actor)
    else 
        self:FreeAll()
    end
end

function view:Update(deltaSecond)
    for key, tb in pairs(self.tbUsed) do 
        tb.widget:Update(deltaSecond) 
    end
end


function view:NotifyRefreshChessInteraction()
    if not self.tbRefreshParam then return end

    self:HideActor()
    local x, y = self.tbRefreshParam.x, self.tbRefreshParam.y
    for _, tb in ipairs(tbAroundGridOffset) do 
        local ground = self.tbRefreshParam.regionActor:FindGroundActor(x + tb[1], y + tb[2]);
        if ground and ground.InteractionActor and ground.InteractionActor:HasTag("box") and ChessData:GetObjectIsUsed(ground.InteractionActor:GetObjectId()) ~= 1 then 
            self:ShowActor(ground.InteractionActor) 
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
        local widget = LoadWidget("/Game/UI/UMG/Chess/Main/interaction/uw_chess_tpl_interaction.uw_chess_tpl_interaction_C")
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