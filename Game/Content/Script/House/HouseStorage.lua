-- ========================================================
-- @File    : Dormitory.lua
-- @Brief   : 宿舍
-- ========================================================
HouseStorage = HouseStorage or {}

HouseStorage.EGirlAttr = {
    Favor   = 0,    --好感度
    RoomNum = 1,     --入住房间号
    LoveStoryReadTask = 2,--信赖度剧情阅读标记
    DailyEvent = 3,       --是否触发每日随机事件

    FurnitureStart = 10,
    FurnitureEnd = 19,
}

HouseStorage.GirlAttrCount = 50
HouseStorage.MaxGirlCount = 50
HouseStorage.BedroomStart = (HouseStorage.MaxGirlCount + 1) * HouseStorage.GirlAttrCount
HouseStorage.BedroomEnd = HouseStorage.BedroomStart + HouseStorage.MaxGirlCount
HouseStorage.DailyTalkGirl = HouseStorage.BedroomEnd + 1
--- 获取角色的属性值
--- @param Detail int 角色detail
--- @param CharacterDoimitoryAttr int 更新角色的属性
--- @return int 指定属性的数值
function HouseStorage.GetCharacterAttr(Detail, CharacterDoimitoryAttr)
    local offset = Detail * HouseStorage.GirlAttrCount + CharacterDoimitoryAttr
    return me:GetAttribute(101, offset)
end

--- 设置角色属性值
--- @param Detail int 角色detail
--- @param CharacterDoimitoryAttr int 更新角色的属性
--- @param Num int 更新数值
function HouseStorage.UpdateCharacterAttr(Detail, CharacterDoimitoryAttr, Num)
    local tbParam = {
        FuncName = "UpdateCharacterAttr",
        Detail = Detail,
        Attr = CharacterDoimitoryAttr,
        Num = Num,
    }
    HouseMessageHandle.HouseMessageSender(tbParam)
end

--- 设置角色属性值
--- @param Detail int 角色detail
--- @param CharacterDoimitoryAttr int 更新角色的属性
--- @param Num int 更新数值
function HouseStorage.SetCharacterAttr(Detail, CharacterDoimitoryAttr, Num)
    local tbParam = {
        FuncName = "SetCharacterAttr",
        Detail = Detail,
        Attr = CharacterDoimitoryAttr,
        Num = Num,
    }
    HouseMessageHandle.HouseMessageSender(tbParam)
end


--- 获取当前家具存在哪一个int的多少位
--- @param InOffset int32 家具偏移
--- @return int32 存在第几位int
--- @return int32 存在该int的第几个
function HouseStorage.GetStoreIndexs(InOffset)
    local MainIndex = math.modf(InOffset / 10 + HouseStorage.EGirlAttr.FurnitureStart)
    local SubIndex = InOffset % 10
    if MainIndex > HouseStorage.EGirlAttr.FurnitureEnd then
        return
    end
    return MainIndex, SubIndex
end

--- 添加家具接口
function HouseStorage.AddFurnitureInternel(AreaID, Index, Count, InCallback)
    local tbParam = {
        FuncName = "AddFurnitureInternel",
        AreaID = AreaID,
        Index = Index,
        Count = Count,
    }
    HouseMessageHandle.HouseMessageSender(tbParam, InCallback)
end

--- 获得家具数量 
--- @param AreaID int32 区域ID
--- @param Index int32 家具偏移ID
--- @return int32 该区域指定偏移ID的家具数量
--- @return int32 该家具所在Index的数值
--- @return int32 该家具所在的Index
--- @return int32 该偏移ID位于该Index的第几个三位
function HouseStorage.GetFurnitureInternel(AreaID, Index)
    local MainIndex, SubIndex = HouseStorage.GetStoreIndexs(Index)
    local AttrIndex = AreaID * HouseStorage.GirlAttrCount + MainIndex
    local FurnitureMain = me:GetAttribute(101, AttrIndex)
    local Count = GetBits(FurnitureMain, SubIndex * 3, SubIndex * 3 + 2)
    return Count, FurnitureMain, AttrIndex, SubIndex
end

--- 检查指定家具数量
--- @param AreaID int32 区域ID
--- @param Index int32 家具偏移ID
--- @param Count int32 传入的比较值
--- @return boolean 该家具拥有数量是否大于某个值
function HouseStorage.CheckHasFurnitureInternel(AreaID, Index, Count)
    local nCount = HouseStorage.GetFurnitureInternel(AreaID, Index)
    return nCount >= Count
end

--- 设置客户端的Attribute
--- @param Offset int32 偏移 代表设置第几个值
--- @param Value int32 设置的值
function HouseStorage.SetAttribute(Offset, Value)
    me:SetAttribute(101, 60000 + Offset, Value)
end

--- 获取客户端的Attribute的值
--- @param Offset int32 偏移 代表获取第几个值
--- @return int32 获取的值
function HouseStorage.GetAttribute(Offset)
    return me:GetAttribute(101, 60000 + Offset)
end