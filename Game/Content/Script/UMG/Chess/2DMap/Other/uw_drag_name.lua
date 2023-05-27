-- ========================================================
-- @File    : uw_drag_name.lua
-- @Brief   : 拖动名字
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
   
end

function view:SetData(dragWidget)
    WidgetUtils.Collapsed(self.TxtName)
    self.TxtName:SetText(dragWidget:GetDragNameShow())

    UE4.Timer.Add(0.15, function() 
        WidgetUtils.Visible(self.TxtName)
    end)
end

------------------------------------------------------------
return view
------------------------------------------------------------