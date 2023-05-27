-- ========================================================
-- @File    : uw_chess_error_msg.lua
-- @Brief   : 显示错误信息
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    WidgetUtils.Collapsed(self.Root)
    self.duration = 0

    self:RegisterEvent(Event.NotifyChessErrorMsg, function(msg) 
        WidgetUtils.HitTestInvisible(self.Root)   
        self.TxtMsg:SetText(msg)
        self.duration = 2
        Color.SetTextColor(self.TxtMsg, 'FF0000FF')
    end)

    self:RegisterEvent(Event.NotifyChessHintMsg, function(msg)
        WidgetUtils.HitTestInvisible(self.Root)   
        self.TxtMsg:SetText(msg)
        self.duration = 1.5
        Color.SetTextColor(self.TxtMsg, '00FF00FF')
    end)
end

function view:Tick(Geometry, DeltaTime)
    if not WidgetUtils.IsVisible(self.Root) then 
        return 
    end

    self.duration = self.duration - DeltaTime;
    if self.duration <= 0 then 
        WidgetUtils.Collapsed(self.Root)
    end
end

return view