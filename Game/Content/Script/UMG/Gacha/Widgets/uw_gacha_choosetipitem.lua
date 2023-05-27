-- ========================================================
-- @File    : uw_gacha_choosetipitem.lua
-- @Brief   : 附加赠送
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelected, function() self.tbData.OnClick(self.tbData) end )
    BtnAddEvent(self.BtnCheck, function()
        if not self.tbData then return end 
        local g, d, p, l = table.unpack(self.tbData.gdpl)
        UI.Open("ItemInfo", g, d, p, l, 1)
    end )
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
end

function tbClass:OnListItemObjectSet(pObj)
    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent = EventSystem.OnTarget( pObj.Data, "SET_SELECTED", function()
            self:SetSelect()
        end
    )
    self.tbData = pObj.Data

    local g, d, p, l = table.unpack(self.tbData.gdpl)

    if not g or not d or not p or not l then print('OnListItemObjectSet :', g, d, p, l) return end

    self.Weapon:DisplayByGDPL(g, d, p, l)
    WidgetUtils.Collapsed(self.Weapon.PanelLevel)
    WidgetUtils.HitTestInvisible(self.Weapon)

    local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
    if pTemplate then
        self.TxtName:SetText(Text(pTemplate.I18n))
    end
    self:SetSelect()
end

function tbClass:SetSelect()
    if self.tbData.bSelect then
        WidgetUtils.Visible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
    end
end


return tbClass