-- ========================================================
-- @File    : uw_new_role_item.lua
-- @Brief   : 测试UI
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.SelClick, function()
        self.tbData.fClick(self.tbData)
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
end


function tbClass:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end
    self.tbData  = InObj.Data

    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent =
        EventSystem.OnTarget(
            InObj.Data,
        "SET_SELECTED",
        function(_, bSelect)
            self:OnSelect(bSelect)
        end
    )


    local nIcon = self.tbData.pCard:Icon()
    SetTexture(self.ImgRole, nIcon)

    self:OnSelect(self.tbData.bSelect)
end


function tbClass:OnSelect(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.PanelSelect)
    else
        WidgetUtils.Collapsed(self.PanelSelect)
    end
end

return tbClass