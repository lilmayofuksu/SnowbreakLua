HouseBedroom = HouseBedroom or {}

HouseBedroom.GirlConfig = {}
HouseBedroom.OpenGirlCount = 0

function HouseBedroom.LoadCfg()
    local tbFile = LoadCsv("house/open_girl.txt", 1)
    for _, tbLine in pairs(tbFile) do
        local tbParam = {
            GirlId = tonumber(tbLine.GirlId),
        }
        if tbParam.GirlId and tbParam.GirlId > 0 then
            HouseBedroom.GirlConfig[tbParam.GirlId] = tbParam
            HouseBedroom.OpenGirlCount = HouseBedroom.OpenGirlCount + 1
        end
    end
end

--- 获得当前开放了卧室的妹子数量
function HouseBedroom.GetOpenCount()
    return HouseBedroom.OpenGirlCount
end

--- 检查少女是否开放
function HouseBedroom.CheckGirlAviliable(InGirlId)
    return HouseBedroom.GirlConfig[InGirlId] ~= nil
end

--- 检查房间是否解锁
function HouseBedroom.CheckRoomAviliable(BedRoomId)
    local num = me:GetAttribute(101, HouseStorage.BedroomStart + BedRoomId)
    return num > 0
end

--- 获取入住少女Id
function HouseBedroom.GetBedroomGirlId(BedRoomId)
    local num = me:GetAttribute(101, HouseStorage.BedroomStart + BedRoomId)
    return num
end

--- 少女入住的房间号
function HouseBedroom.GetGirlBedroomId(InGirlId)
    local num = HouseStorage.GetCharacterAttr(InGirlId, HouseStorage.EGirlAttr.RoomNum)
    return num
end

--- 少女入住
--- @param InGirlId UCharacter 入住妹子
--- @param InRoomId int 入住房间
--- @param InCallback function 回调
function HouseBedroom.GirlLiveIn(InGirl, InRoomId, InCallback)
    if not InGirl or not InRoomId then
        UI.ShowMessage(Text('error.BadParam'))
        return
    end

    local tbParam = {
        FuncName = "SetBedroomGirlId",
        BedroomId = InRoomId,
        GirlId = InGirl:Detail(),
    }

    HouseMessageHandle.HouseMessageSender(tbParam, InCallback)
end

--- 登记入住
function HouseBedroom.GirlRegister(InGirlId, InCallback)
    local tbParam = {
        FuncName = "GirlRegister",
        GirlId = InGirlId,
    }

    HouseMessageHandle.HouseMessageSender(tbParam, function()
        if InCallback then
            InCallback()
        end
        local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
        local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
        if HouseMode then
            HouseMode:LetGirlToBedRoom(InGirlId);
            HouseMode:UpdateDoors();
        end
    end)
end

function HouseBedroom.GirlLeaveRoom(InGirlId, InRoomId, InCallback)
    if not InGirlId or not InRoomId then
        UI.ShowMessage(Text('error.BadParam'))
        return
    end

    local tbParam = {
        FuncName = "GirlLeaveRoom",
        BedroomId = InRoomId,
        GirlId = InGirlId,
    }

    HouseMessageHandle.HouseMessageSender(tbParam, InCallback)
end

function HouseBedroom.ExchangeRoomGirl(RoomId1, RoomId2, InCallback)
    if not RoomId1 or not RoomId2 then
        UI.ShowMessage(Text('error.BadParam'))
        return
    end

    local tbParam = {
        FuncName = "ExchangeRoomGirl",
        RoomId1 = RoomId1,
        RoomId2 = RoomId2,
    }

    HouseMessageHandle.HouseMessageSender(tbParam, InCallback)
end

HouseBedroom.LoadCfg()

