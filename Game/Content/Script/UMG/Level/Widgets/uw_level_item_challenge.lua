-- ========================================================
-- @File    : uw_level_item_challenge.lua
-- @Brief   : 关卡历史挑战记录控件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListItem)
end

function tbClass:Init(info)
    if self.TextTime then
        local str = ""
        if info.time then
            local min = math.floor(info.time / 60)
            local sec = math.ceil(info.time % 3600 % 60)
            str = string.format("%02d:%02d", min, sec)
        elseif info.integral then
            str = info.integral
        end
        self.TextTime:SetText(str)
    end

    self:DoClearListItems(self.ListItem)
    local members = {info.member1, info.member2, info.member3}
    for i = 1, 3 do
        local member = members[i]
        if member and #member >= 4 then
            local tbParam = {G = member[1], D = member[2], P = member[3], L = member[4], fCustomEvent = function() end}
            local pObj = self.Factory:Create(tbParam)
            self.ListItem:AddItem(pObj)
        end
    end
    WidgetUtils.Collapsed(self.New)
end

function tbClass:ShowPoit()
    WidgetUtils.Visible(self.New)
end

return tbClass
