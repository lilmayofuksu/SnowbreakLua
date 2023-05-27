-- ========================================================
-- @File    : uw_fight_msg_item.lua
-- @Brief   : 战斗消息条目
-- @Author  :
-- @Date    :
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    print("uw_fight_msg_item Construct");
    WidgetUtils.Collapsed(self.Back)
end

function tbClass:OnDestruct()
    print("uw_fight_msg_item Destruct");
    UE4.Timer.Cancel(self.timerId or 0)
end

function tbClass:SetMsg(msg)
    self.Msg:SetText(msg)
end

function tbClass:SetCurrentShow(show)
    if show then 
        WidgetUtils.HitTestInvisible(self.Current)
    else 
        WidgetUtils.Collapsed(self.Current)
    end
end

function tbClass:OnBegin(completeHandler)
    self:PlayAnimation(self.Begin)

    self.timerId = UE4.Timer.Add(6, function()
        self:PlayAnimation(self.End)
        self.timerId = UE4.Timer.Add(2, function() 
            completeHandler(self);
        end)
    end)
end

return tbClass
