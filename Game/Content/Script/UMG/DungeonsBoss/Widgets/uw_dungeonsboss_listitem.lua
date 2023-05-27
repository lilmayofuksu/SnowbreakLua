-- ========================================================
-- @File    : uw_dungeonsboss_listitem.lua
-- @Brief   : boss挑战阵容成绩记录条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    if not self.tbParam then return end

    if self.tbParam.nRole and self.tbParam.nRole > 0 then
        local card = me:GetItem(self.tbParam.nRole)
        if card then
            local ID = card:Id()
            local TemplateId = card:TemplateId()
            local pCardItem = LoadClass("/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data")
            local obj = NewObject(pCardItem, self, nil)
            local template = UE4.UItem.FindTemplateForID(TemplateId)
            obj:Init(ID, false, template)
            obj.bUIBoss = true
            self.Role:Display(obj)
        end
    end

    self.Weapon:DisplayByGDPL(self.tbParam.WG, self.tbParam.WD, self.tbParam.WP, self.tbParam.WL, self.tbParam.WLevel, self.tbParam.tbPart)

    if self.tbParam.sInfo then
        for i = 1, 3 do
            local widget = self["Logis"..i]
            if widget then
                local info = self.tbParam.sInfo[i]
                if info then
                    WidgetUtils.HitTestInvisible(widget)
                    widget:DisplayByGDPL(info.SG, info.SD, info.SP, info.SL, info.SLevel, info.BreakNum)
                else
                    WidgetUtils.Collapsed(widget)
                end
            end
        end
    end
end

return tbClass