local tbClass = Class("UMG.SubWidget")


function tbClass:OnDropOver(InItem)
    if InItem.Type == 0 then
        if not InItem.Data.GirlId or not InItem.Data.RoomId then
            return
        end
        HouseBedroom.GirlLeaveRoom(InItem.Data.GirlId, InItem.Data.RoomId, function()
            EventSystem.TriggerTarget(HouseBedroom, "UpdateAll")
        end)
    end
end


return tbClass