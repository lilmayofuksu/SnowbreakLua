-- ========================================================
-- @File    : uw_widgets_weapon_story.lua
-- @Brief   : 武器或后勤的技能展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Set(pItem, nForm)
    if not pItem or not pItem:IsWeapon() then 
        return
    end

    if not nForm or nForm == RikiLogic.tbState.Lock then
        self.TxtStory:SetContent(Text('ui.TxtHandbook20'))
    else
        self.TxtStory:SetContent(Item.GetDes(pItem))
    end
    
end

return tbClass
