-- ========================================================
-- @File    : riki.lua
-- @Brief   : 图鉴
-- @Author  :
-- @Date    :  每个组别(type)可以记录900条数据
-- ========================================================

RikiLogic = RikiLogic or {}

RikiLogic.nTaskGroup = 103
-- 按位存 每个task存30位 每个type留30个变量  900个位置
-- 红点状态单独保存 客户端可以修改 从501开始  位置与图鉴状态对应
RikiLogic.nTaskCount = 30

RikiLogic.tbType = {
    ['Role'] = 1,
    ['Weapon'] = 2,
    ['Support'] = 3,
    ['Monster'] = 4,
    ['Fashion'] = 5,
    ['Plot'] = 6,
    ['Explore'] = 7,
    ['Parts'] = 8,
}

RikiLogic.tbState = {
    ['Lock'] = 10,
    ['New'] = 11,
    ['Read'] = 12,
}

RikiLogic.tbTypeIcon = {
    {1701113,1701115,1701114},
    {1701117,1701117,1701118}
}

RikiLogic.TxtNameType = {
    [FragmentStory.Type.Area] = 'RikiExplore00',
    [FragmentStory.Type.Special] = 'RikiExplore01',
    [FragmentStory.Type.Info] = 'RikiExplore02',
    [FragmentStory.Type.Log] = 'RikiExplore03',
    [FragmentStory.Type.Record] = 'RikiExplore04',
    [FragmentStory.Type.Report] = 'RikiExplore05'
}

RikiLogic.FrontPageImg = {
    [FragmentStory.Type.Area] = 2100220,
    [FragmentStory.Type.Special] = 2100221,
    [FragmentStory.Type.Info] = 2100222,
    [FragmentStory.Type.Log] = 2100223,
    [FragmentStory.Type.Record] = 2100224,
    [FragmentStory.Type.Report] = 2100225,
}

RikiLogic.FrontPageSmallImg = {
    [FragmentStory.Type.Area] = 2100240,
    [FragmentStory.Type.Special] = 2100241,
    [FragmentStory.Type.Info] = 2100242,
    [FragmentStory.Type.Log] = 2100243,
    [FragmentStory.Type.Record] = 2100244,
    [FragmentStory.Type.Report] = 2100245,
}


--返回图鉴状态  红点状态
function RikiLogic:GetRiki(nId)
    local nTaskId, nBit = self:GetTask(nId)
    local nVal1 = me:GetAttribute(self.nTaskGroup, nTaskId)
    local nVal2 = me:GetAttribute(self.nTaskGroup, nTaskId+500)
    return GetBits(nVal1, nBit, nBit), GetBits(nVal2, nBit, nBit)
end

-- 清除红点状态
function RikiLogic:CleanDot(nId)
    local nTaskId, nBit = self:GetTask(nId)
    local nVal = me:GetAttribute(self.nTaskGroup, nTaskId+500)
    nVal = SetBits(nVal, nBit, nBit, 0)
    me:SetAttribute(self.nTaskGroup, nTaskId+500, nVal)
end

--获取某个类型的激活数量、红点数量、总数
function RikiLogic:GetTypeRikiNum(nType)
    local nActivity,nRed,nSum = 0,0,0
    local cfgs = RikiLogic.tbTypeCfg[nType]
    if cfgs then
        for _, tb in ipairs(cfgs) do
            if self:IsUnlock(tb) and not Item.IsBanItem(tb.tbItem) then
                local nStatus, nRedStatus = RikiLogic:GetRiki(tb.Id)
                if nStatus == 1 then
                    nActivity = nActivity + 1
                end
                if nRedStatus == 1 then
                    nRed = nRed + 1
                end
                nSum = nSum + 1
            end
        end
    end

    return nActivity,nRed,nSum
end

function RikiLogic:IsUnlock(cfg)
    if Player.IsOversea() and cfg.UnLockTimeOversea < GetTime() then
        return true
    end

    if not Player.IsOversea() and cfg.UnLockTime < GetTime() then
        return true
    end

    return false
end

-- 按类型获取图鉴列表状态
-- 0 未解锁 1解锁显示红点 2解锁不显示红点
function RikiLogic:GetTypeRikiList(nType, nChildType, isGet)
    local tbRet = {}
    if not self.tbTypeCfg[nType] then
        return tbRet
    end

    local function CheckChildType(nType, nChildType, cfg)
        if not nChildType then
            return true
        end

        if nType ~= self.tbType.Monster and nType ~= self.tbType.Explore then
            return nChildType == cfg.tbItem[2]
        end

        return true
    end

    for _, tb in ipairs(self.tbTypeCfg[nType]) do
        if self:IsUnlock(tb) and not Item.IsBanItem(tb.tbItem) and CheckChildType(nType, nChildType, tb) then
            local info = Copy(tb)
            info.state = self.tbState.Lock
            local bGet, bRed = self:GetRiki(info.Id)
            if bGet == 1 then
                if bRed == 1 then
                    info.state = self.tbState.New
                else
                    info.state = self.tbState.Read
                end
            end

            if not isGet or (isGet and info.state ~= self.tbState.Lock) then
                table.insert(tbRet, info)
            end
        end
    end

    return tbRet
end

function RikiLogic:GetMonsterTypeIcon(nMonsterId)
    if not nMonsterId then
        return self.tbTypeIcon[1][1], self.tbTypeIcon[2][1]
    end

    local nType1, nType2 = self.tbTypeIcon[1][1], self.tbTypeIcon[2][1]
    
    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(nMonsterId)
    if MonsterInfo and MonsterInfo.TriangleType and RikiLogic.tbTypeIcon[1][MonsterInfo.TriangleType+1] then
        nType1 = RikiLogic.tbTypeIcon[1][MonsterInfo.TriangleType+1]
    end

    local nId = math.floor(nMonsterId/1000000) - 3
    if self.tbTypeIcon[2][nId] then
        nType2 =  self.tbTypeIcon[2][nId]
    end

    return nType1, nType2
end

function RikiLogic:GetExploreList(nExploreType)
    local tbExploreItemList = {}
    for _,config in pairs(self.tbTypeCfg[RikiLogic.tbType.Explore]) do
        if config.ExploreType == nExploreType then
            table.insert(tbExploreItemList,config)
        end
    end
    return tbExploreItemList

end

-- 匹配相同gdpl的道具中最大值
-- 第二个参数是当前最大等级
function RikiLogic:IsRikiBreakMax(pDefault)
	local all = me:GetItemsByGDPL(pDefault:Genre(), pDefault:Detail(), pDefault:Particular(), pDefault:Level())
    local nMax = 0
	for i=1, all:Length() do
		local pItem = all:Get(i)
        if nMax < pItem:Break() then
            nMax = pItem:Break()
        end
		if Item.IsBreakMax(pItem) then
			return true, nMax
		end
	end

	return false, nMax
end



-------------------------------------------------------------------------------------------------------------------
--内部调用接口

function RikiLogic:GetMonsterData(TaskSubActor)
    local tbMonster = {}
    if TaskSubActor and TaskSubActor.GetMonsterData then
        local tbMonsterSet = TaskSubActor:GetMonsterData()
        local tbArray = tbMonsterSet:ToArray()
        for i = 1, tbArray:Length() do
            table.insert(tbMonster, tbArray:Get(i))
        end
    end

    return tbMonster
end

function RikiLogic:GetTask(nId)
    local nIndex = math.floor(nId/1000)
    local nVal = nId%1000

    local nTaskId = (nIndex-1)*30 + math.ceil(nVal/30)
    local nBit = nVal%30

    return nTaskId, nBit
end

function RikiLogic:LoadRikiCfg()
    local tbFile = LoadCsv('riki/Riki.txt', 1)
    self.tbCfg = {} -- 总配置表 key 图鉴id
    self.tbTypeCfg = {} --道具类型  图鉴信息数组 
    for _, tbLine in ipairs(tbFile) do
        local Type = tonumber(tbLine.Type) or 0
        local Id = tonumber(tbLine.Id) or 0
        local TitleImg = tbLine.TitleImg
        local Condition = tbLine.Condition
        local tbInfo = {Id = Id, Type = Type, TitleImg = TitleImg}
        if Type == self.tbType.Monster then
            tbInfo.tbMonster = Eval(Condition)
        elseif Type == self.tbType.Explore then
            local ExploreList = Eval(Condition)
            tbInfo.ExploreType = ExploreList[1] or 0
            tbInfo.ExploreID   = ExploreList[2] or 0
        else
            tbInfo.tbItem = Eval(Condition)
        end

        tbInfo.UnLockTime = ParseTime(string.sub(tbLine.UnLockTime or '', 2, -2), tbInfo, "UnLockTime")
        tbInfo.UnLockTimeOversea = ParseTime(string.sub(tbLine.UnLockTimeOversea or '', 2, -2), tbInfo, "UnLockTimeOversea")

        for i=1, 4 do
            tbInfo['Extension'..i] = tbLine['Extension'..i]
        end
        
        self.tbTypeCfg[Type] = self.tbTypeCfg[Type] or {}
        table.insert(self.tbTypeCfg[Type], tbInfo)

        self.tbCfg[Id] = tbInfo
    end

    print('Load settings/riki/Riki.txt')
end

function RikiLogic:LoadRikiVoiceCfg()
    local tbFile = LoadCsv('riki/voice_riki.txt', 1)
    self.tbVoiceCfg = {}
    for _,tbLine in pairs(tbFile) do
        local cfg = {}
        cfg.RikiId = tonumber(tbLine.rikiID) or 0
        cfg.Index = tonumber(tbLine.index) or 0
        cfg.VoiceID = tbLine.VoiceID
        cfg.CharacterID = tonumber(tbLine.CharacterID) or 0
        cfg.TxtKey = tbLine.UIkey

        local voiceList = self.tbVoiceCfg[cfg.RikiId]
        if voiceList == nil then
            self.tbVoiceCfg[cfg.RikiId] = {}
            voiceList = self.tbVoiceCfg[cfg.RikiId]
        end
        voiceList[cfg.Index] = cfg
    end

    print('Load settings/riki/voice_riki.txt')
end

---设置当前选择的角色配置
function RikiLogic:SetNowRoleData(tbData)
    self.tbNowRoleData = tbData
end

---获取当前选择的角色配置
function RikiLogic:GetNowRoleData()
    return self.tbNowRoleData
end

function RikiLogic:SetRoleList(tbRoleList)
    self.tbRoleList = tbRoleList
end

function RikiLogic:GetLeftRole(nId)
    if not self.tbRoleList then
        return
    end
    for index, pObj in ipairs(self.tbRoleList) do
        if nId == pObj.Data.Id then
            local nNext = pObj
            if index == 1 then
                nNext = self.tbRoleList[#self.tbRoleList]
            else
                nNext = self.tbRoleList[index-1]
            end

            return nNext.Data
        end
    end
end

function RikiLogic:GetRightRole(nId)
    if not self.tbRoleList then
        return
    end

    for index, pObj in ipairs(self.tbRoleList) do
        if nId == pObj.Data.Id then
            local nNext = pObj
            if index == #self.tbRoleList then
                nNext = self.tbRoleList[1]
            else
                nNext = self.tbRoleList[index+1]
            end

            return nNext.Data
        end
    end
end


RikiLogic:LoadRikiCfg()
RikiLogic:LoadRikiVoiceCfg()