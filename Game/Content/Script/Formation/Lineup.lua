-- ========================================================
-- @File    : FormationLineup.lua
-- @Brief   : 编队成员
-- ========================================================
local MemberLogic = require('Formation.Member')

local tbLineupLogic = {
    ---初始化
    Init = function(self, pLineup)
        local memsData = me:GetLineupMembers(pLineup.Index)
        for i = 1, memsData:Length() do
            self.tbMember[i-1] =  MemberLogic.New(i-1, memsData:Get(i))
        end
    end,

    ---获取编队逻辑
    GetMemberLogic = function(self)
        return MemberLogic
    end,

    ---获取编队成员
    GetMembers = function(self)
        return self.tbMember
    end,

     ---获取编队成员根据索引
     GetMember = function(self, nIndex)
        return self.tbMember[nIndex]
    end,

    ---队伍中是否存在某张卡
    IsExist = function(self, pCard)
        for _, member in pairs(self.tbMember or {}) do
            if member:GetCard() == pCard then
                return true
            end
        end
        return false
    end,

    ---获取卡在编队的位置
    GetCardPos = function(self, pCard)
        for _, member in pairs(self.tbMember or {}) do
            if member:GetCard() == pCard then
                return member:GetPosIndex()
            end
        end
        return -1
    end,

    ---获取队长
    GetCaptain = function(self)
        local m = self.tbMember[0]
        return m and m:GetCard() or nil
    end,

    ---深拷贝一个成员
    CloneMember = function(self, nIdx)
        local lookup_table = {}
        local function _copy(object)
            if type(object) ~= "table" then
                return object
            elseif lookup_table[object] then
                return lookup_table[object]
            end
            local new_table = {}
            lookup_table[object] = new_table
            for key, value in pairs(object) do
                new_table[_copy(key)] = _copy(value)
            end
            return setmetatable(new_table, getmetatable(object))
        end
        local object = self:GetMember(nIdx)
        return _copy(object)
    end,

    ---交换位置
    ChangePos = function(self, nIdx1, nIdx2)
        local cacheMember = self:CloneMember(nIdx1)

        self.tbMember[nIdx1]:Copy(self.tbMember[nIdx2])
        self.tbMember[nIdx2]:Copy(cacheMember)

        self.tbMember[nIdx1].nPosIndex = nIdx1
        self.tbMember[nIdx2].nPosIndex = nIdx2

        self.tbMember[nIdx1]:Update()
        self.tbMember[nIdx2]:Update()

        if Formation.Actor then
            Formation.Actor:ChangePos(nIdx1, nIdx2)
        end
    end,

    ---两个编队是否相等
    IsEqual = function(self, tbLineup)
        if not tbLineup then return false end
        if self.Index ~= tbLineup.Index then return false end
        if self.sName ~= tbLineup.sName then return false end
        for nIdx, mem in pairs(self:GetMembers()) do
            if tbLineup:GetMember(nIdx) == nil then return false end
            if not mem:IsEqual(tbLineup:GetMember(nIdx)) then return false end
        end
        return true
    end,

    ---同步编队数据
    SynData = function(self, pLineup)
        self.Index = pLineup.Index
        self.sName = pLineup.Name
        local memsData = me:GetLineupMembers(pLineup.Index)
        for i = 1, memsData:Length() do
            local mem = self:GetMember(i - 1)
            if mem then
                mem:SynData(memsData:Get(i))
            end
        end
    end,

    GetCards = function(self)
        local Cards = UE4.TArray(UE4.UCharacterCard)
        for i = 0, 2 do
            local pCard = self.tbMember[i]:GetCard()
            if pCard then
                Cards:Add(pCard)
            end
        end
       return Cards
    end,

    Clear = function(self)
        for _, v in pairs(self:GetMembers()) do
            
        end
    end,
}

local Lineup = {}

---构建新编队
function Lineup.New(pLineup)
    local tb = Inherit(tbLineupLogic)
    tb.nIndex = 0
    tb.sName = ''
    tb.tbMember = {}
    tb:Init(pLineup)
    return tb
end

return Lineup