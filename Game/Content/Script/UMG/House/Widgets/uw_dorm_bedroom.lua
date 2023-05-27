-- ========================================================
-- @File    : uw_dorm_bedroom.lua
-- @Brief   : 角色卧室
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

----------------------------------------------------------------------------------
--- 门卡界面相关功能
----------------------------------------------------------------------------------
function tbClass:RoomDisplay(tbParam)
    self.tbParam = tbParam
    --- 预留楼层
    local floor = 2
    local RoomStart = (floor - 2) * 8 + 1
    local RoomEnd = RoomStart + 7
    for i = RoomStart, RoomEnd do
        if self["Location"..i] then
            WidgetUtils.Collapsed(self["Location"..i])
            local tbRoom = tbParam[i]
            if not tbRoom or not tbRoom.IsUnlock then
                self:SetRoomState(i, 0)
            else
                self:SetRoomState(i, 1, tbRoom)
            end
        end
    end
end

function tbClass:SetRoomState(RoomId, InState, tbRoom)
    WidgetUtils.Collapsed(self["Lived"..RoomId])
    if InState == 0 then
        WidgetUtils.SelfHitTestInvisible(self["Lock"..RoomId])
        WidgetUtils.Collapsed(self["Item"..RoomId])
    else
        WidgetUtils.Collapsed(self["Lock"..RoomId])
        WidgetUtils.SelfHitTestInvisible(self["Item"..RoomId])
        self["Item"..RoomId]:RoomDisplay(tbRoom)
    end
end

function tbClass:OnSelect(GirlId)
    for _, tbRoom in pairs(self.tbParam) do
        if tbRoom.GirlId == GirlId then
            WidgetUtils.SelfHitTestInvisible(self["Lived".._])
        else
            WidgetUtils.Collapsed(self["Lived".._])
        end
    end
end

return tbClass