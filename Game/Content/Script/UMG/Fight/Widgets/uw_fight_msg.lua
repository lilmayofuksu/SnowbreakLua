-- ========================================================
-- @File    : uw_fight_msg.lua
-- @Brief   : 战斗消息提示（大世界）
-- @Author  :
-- @Date    :
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    print("uw_fight_msg Construct");
    self.tbUnusedTip = {}
    self.tbUsedTip = {}
     --#ZhangGuangYu- Todo 注意 这个Event里处理多语言，不要在外部处理传进去！FightTip已改，大世界以后改
    self.handlerId = EventSystem.On(Event.ShowFightTip, function(msg)  
        self:ShowMsg(msg)
    end)
    self.freeTip = function(tip)
        self:FreeTip(tip)
    end

    self.totalCount = 0;
end

function tbClass:OnDestruct()
    print("uw_fight_msg Destruct");
    EventSystem.Remove(self.handlerId)
end

function tbClass:ShowMsg(msg)
    self.totalCount = self.totalCount + 1;

    local tip = self:AllocTip();
    tip:SetMsg(msg)
    tip:OnBegin(self.freeTip)

    local count = #self.tbUsedTip
    for i, tip in ipairs(self.tbUsedTip) do 
        local slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(tip)
        local n1 = 0
        local n2 = (count - i - 1) * -35;
        slot:SetPosition(UE4.FVector2D(n1, n2))
        tip:SetCurrentShow(i == count)
    end

end

function tbClass:AllocTip()
    if #self.tbUnusedTip == 0 then 
        local widget = LoadWidget("/Game/UI/UMG/Fight/Widgets/uw_fight_msg_item.uw_fight_msg_item_C")
        self.tbUnusedTip[1] = widget;
        self.Root:AddChild(widget)
    end
    local widget = self.tbUnusedTip[#self.tbUnusedTip]
    table.remove(self.tbUnusedTip, #self.tbUnusedTip)
    table.insert(self.tbUsedTip, widget)
    WidgetUtils.Visible(widget);
    return widget
end

function tbClass:FreeTip(tip)
    print("free tip", tip )
    table.insert(self.tbUnusedTip, tip);
    WidgetUtils.Collapsed(tip)

    for i = #self.tbUsedTip, 1, -1 do 
        local one = self.tbUsedTip[i]
        if one == tip then 
            table.remove(self.tbUsedTip, i)
            return;
        end
    end
end

return tbClass
