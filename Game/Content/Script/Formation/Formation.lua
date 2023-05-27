-- ========================================================
-- @File    : Formation.lua
-- @Brief   : 编队管理器
-- ========================================================

---@class Formation 编队逻辑管理器
---@field Formation table 编队数据
---@field Actor AActor 编队模型管理
Formation = Formation or { Formation = nil, Actor = nil }

Formation.TRIAL_INDEX = 9

---是否试玩
Formation.bTrial = false
Formation.CacheParam = {}

local var = {nTeamID = 1, nMemberPos = 0}

local LineupLogic = require('Formation.Lineup')
require('Formation.TeamRule')

---是否有新卡
function Formation.HasNewCardTip(nIndex)
    local member = Formation.GetMember(nIndex)
    if not member:IsNone() then return false end
    local allCard = me:GetCharacterCards()
    for i = 1, allCard:Length() do
        local pCard = allCard:Get(i)
        if pCard and not Formation.IsInFormation(Formation.GetCurLineupIndex(), pCard) then
            return true
        end
    end
    return false
end


function Formation.GetMemberPos()
    return var.nMemberPos
end

function Formation.SetMemberPos(nPos)
    var.nMemberPos = nPos
end

-------------------外部调用接口-------------------------------
---获取编队逻辑
function Formation.GetLineupLogic()
    return LineupLogic
end

---初始化编队信息
function Formation.InitLineup()
    Formation.Formation = {}

    if me then
        ---客户端读取保存的队伍ID
        var.nTeamID = 1
        ---获取队伍信息 & 构建队伍
        local lineupsData = me:GetLineups()
        for i = 1, lineupsData:Length() do
            local pLineup = lineupsData:Get(i)
            Formation.Formation[pLineup.Index] = LineupLogic.New(pLineup)
        end
        print('init lineup...')
    end
end

---更新编队信息
---@param nTeamID Integer 队伍ID
---@param InRemove boolean 是否移除
function Formation.UpdateLineup(nTeamID, InRemove)
    if Formation.Formation == nil then return end
    if InRemove then
        Formation.Formation[nTeamID] = nil
    else
        local Lineup = Formation.GetLineup(nTeamID)
        if Lineup then
            Lineup:SynData(me:GetLineup(nTeamID))
        end
    end
end

---更新当前队伍的数据
---@param InCard UCharacterCard
---@param InCard function
function Formation.UpdateCurrentFormation(InCard, InCallBack)
    local nIndex = Formation.GetCurLineupIndex()
    local nPos = var.nMemberPos
    local pCard = Formation.GetCardByIndex(nIndex, nPos)
    local nState = Formation.GetRoleState(nIndex, pCard, InCard)
    if nState == 0 then
        Formation.SetLineupMember(nIndex, nPos, InCard)
    elseif nState == 1 then
        Formation.SetLineupMember(nIndex, nPos, nil)
    elseif nState == 2 then
        local Pos = Formation.GetRoleIndex(nIndex, InCard)
        if Pos then
            Formation.ChangePos(nIndex, nPos, Pos)
        end
    end
    Formation.Req_UpdateLineup(nIndex, InCallBack)
end


---设置队伍成员
---@param InTeamID Integer 队伍ID
---@param InPos Integer 队员位置
---@param InCard UCharacterCard
function Formation.SetLineupMember(InTeamID, InPos, InCard)
    local Lineup = Formation.GetLineup(InTeamID)
    if Lineup then
        local member = Lineup:GetMember(InPos)
        member:SynData(InCard)
    end
end

---获取阵型中的角色UID,武器UID
---@param InTeamID Integer 队伍ID
function Formation.GetCardByIndex(InTeamID, InPos)
    local Lineup = Formation.GetLineup(InTeamID)
    if Lineup then
        local mem = Lineup:GetMember(InPos)
        return mem:GetCard()
    end
    return nil
end

---设置当前队伍ID
---@param InTeamID Integer 队伍ID
function Formation.SetCurLineupIndex(InTeamID)
    if Formation.Formation == nil then
        Formation.InitLineup()
    end
    local Lineup = Formation.GetLineup(InTeamID)
    if Lineup == nil then
        Formation.Formation[InTeamID] = LineupLogic.New(me:GetLineup(InTeamID))
        if InTeamID == RogueLogic.TeamId then
            local tbCard = RogueLogic.GetRogueLineup(true)
            for i = 1, 3 do
                if tbCard[i] then
                    Formation.SetLineupMember(InTeamID, i-1, tbCard[i])
                end
            end
        end
    end
    var.nTeamID = InTeamID
end

---获取当前队伍ID
function Formation.GetCurLineupIndex()
    return var.nTeamID or 1
end

---获取队伍数据
---@param InTeamID integer 队伍ID
function Formation.GetLineup(InTeamID)
    if Formation.Formation then
        return Formation.Formation[InTeamID]
    end
end

---获取队员
---@param InPos integer 位置
function Formation.GetMember(InPos)
    local Lineup = Formation.GetCurrentLineup()
    if Lineup then return Lineup:GetMember(InPos) end
end

---获取当前队伍
function Formation.GetCurrentLineup()
   return Formation.GetLineup(Formation.GetCurLineupIndex())
end

---获取当前角色在队伍中的位置
---@param InTeamID integer 队伍ID
---@param InCard UCharacterCard 角色
function Formation.GetRoleIndex(InTeamID, InCard)
    local Lineup = Formation.GetLineup(InTeamID)
    if Lineup then
        return Lineup:GetCardPos(InCard)
    end
end

---角色是否在队伍
---@param InTeamID number 小队
---@param InCard UCharacterCard
function Formation.IsInFormation(InTeamID, InCard)
    if not InCard then return false end
    local Lineup = Formation.GetLineup(InTeamID)
    if Lineup then
        return Lineup:IsExist(InCard)
    end
    return false
end

---角色是否在队伍(增加爬塔队伍判断)
---@param InTeamID number 小队
---@param InCard UCharacterCard
function Formation.IsInTowerFormation(InTeamID, InCard)
    if not InCard then return false end
    if InTeamID == 7 or InTeamID == 8 then
        return Formation.IsInFormation(7, InCard) or Formation.IsInFormation(8, InCard)
    else
        return Formation.IsInFormation(InTeamID, InCard)
    end
end

---获取当前角色的状态 0 不在队伍中，1 与参考角色一致 2 在队伍中
---@param InReferRole 参考角色
---@param InSelectRole 选择的角色
function Formation.GetRoleState(InIndex, InReferRole, InSelectRole)
    if InReferRole == InSelectRole then
        return 1
    elseif Formation.IsInFormation(InIndex, InSelectRole) then
        return 2
    else
        return 0
    end
end

---队伍是否满足出战规则
function Formation.CanFight()
    if Launch.GetType() == LaunchType.TOWER then
        local nowindex = Formation.GetCurLineupIndex()
        if nowindex == 7 or nowindex == 8 then  --爬塔活动基座编队必须两个队伍都有队长
            local Lineup7 = Formation.GetLineup(7)
            if not Lineup7 or not Lineup7:GetCaptain() then
                return false, "tip.not_captain_activity"
            end
            local Lineup8 = Formation.GetLineup(8)
            if not Lineup8 or not Lineup8:GetCaptain() then
                return false, "tip.not_captain_activity"
            end
        end
    elseif Launch.GetType() == LaunchType.BOSS then ---boss挑战编队检查
        local canFight, msg = BossLogic.CanFight()
        if not canFight then
            return false, msg
        end
    end

    local isCaptain = Formation.GetCaptain() ~= nil
    if not isCaptain then
        return false, "tip.not_captain"
    end
    return true
end

---新账户设置一个指定角色在编队1的队长位置
---@return boolean 是否设置成功
function Formation.SetMemberByLineup1(InCallBack)
    local NewCallBack = function() 
        Reconnect.ClearSettleInfo()
        InCallBack()
    end
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:Genre() == 1 and card:Detail() == 2 and card:Particular() == 1 and card:Level() == 1 then
            Formation.SetMemberPos(0); 
            local nIndex = Formation.GetCurLineupIndex()
            local nPos = var.nMemberPos
            local pCard = Formation.GetCardByIndex(nIndex, nPos)
            local nState = Formation.GetRoleState(nIndex, pCard, card)
            if nState == 0 then
                Formation.SetLineupMember(nIndex, nPos, card)
            elseif nState == 1 then
                Formation.SetLineupMember(nIndex, nPos, nil)
            elseif nState == 2 then
                local Pos = Formation.GetRoleIndex(nIndex, card)
                if Pos then
                    Formation.ChangePos(nIndex, nPos, Pos)
                end
            end
            Reconnect.SetMemberByLineup1(function() Formation.Req_UpdateLineup(nIndex, NewCallBack) end)            
            return true
        end
    end
    return false
end

---获取队长
function Formation.GetCaptain()
    local Lineup = Formation.GetCurrentLineup()
    if Lineup then
        return Lineup:GetCaptain()
    end
end

---获取角色的位置
---@param InIndex Integer 队伍位置Index
function Formation.GetPos(InIndex)
    if Formation.Actor then
        return Formation.Actor:GetPos(InIndex)
    end
end


---加载队伍数据 创建队伍模型
---@param InContext UObject
function Formation.SpawnActor(InContext)
    if not Formation.Actor then
        local World = InContext:GetWorld()
        local FormationActorClass = UE4.UClass.Load("/Game/UI/Config/FormationActor.FormationActor")
        Formation.Actor = World:SpawnActor(FormationActorClass)
    end
end

---更新模型显示
function Formation.UpdateModel(InPos, InID)
    if Formation.Actor == nil then return end
    Formation.Actor:Update(InPos, InID)
end

---清除队伍模型信息
function Formation.Clear()
    if Formation.Actor and IsValid(Formation.Actor) then
        Formation.Actor:K2_DestroyActor()
    end
    Formation.Actor = nil
end

---交换队伍成员位置
---@param InTeamID Integer 队伍ID
---@param InP1 Integer 位置1
---@param InP2 Integer 位置2
function Formation.ChangePos(InTeamID, InP1, InP2)
    if InP1 == InP2 then return end
    local Lineup = Formation.GetLineup(InTeamID)
    if Lineup then 
        Lineup:ChangePos(InP1, InP2) 
        Audio.PlaySounds(3022)
    end
end

---创建训练队伍
---@param InTeamID Integer 队伍ID
function Formation.CreateTrainLineup(InTeamID)
    local Mems = UE4.TArray(UE4.int64);
    Mems:Add(UE4.UItemLibrary.GetTemplateId(1,2,1,1));
    Mems:Add(UE4.UItemLibrary.GetTemplateId(1,5,1,1));
    me:CreateTrainLineup(InTeamID, Mems);
end

---复制其他编队信息(新编队要不存在)
---@param preTeamId Integer 被拷贝编队id
---@param nTeamId Integer 生成的编队id
function Formation.CopyLineup(preTeamId, nTeamId)
    local Lineup = Formation.GetLineup(preTeamId)
    if not Lineup then
        return
    end

    local newLineup = Formation.GetLineup(nTeamId)
    if newLineup then 
        return 
    end

    Formation.Formation[nTeamId] = LineupLogic.New(me:GetLineup(preTeamId))
end

function Formation.Print()
    print('Formation Info')
    print('current index', Formation.GetCurLineupIndex())
    
    for i = 0, 2 do
        local pCard = Formation.GetCardByIndex(Formation.GetCurLineupIndex(), i)
        print('index ', i, 'card :', pCard and Text(pCard:I18N()) or 'nil')
    end
end

-- 检测关卡编队相关条件
function Formation.CheckStarCondition(tbLevel)
    local formation = Formation.GetCurrentLineup()
    if not formation or not tbLevel or not tbLevel.tbStarCondition or not tbLevel.DidGotStar then
        return
    end
    local TaskInfo = UE4.ULevelStarTaskManager.GetInfoByCondition(tbLevel.sStarCondition)
    for i = 1, #tbLevel.tbStarCondition do
        if not tbLevel:DidGotStar(i - 1) then
            local info = TaskInfo:Get(i)
            if info then
                if info.TypeID == 4 and info.Params:Length() >= 2 then
                    local str = string.gsub(info.Params:Get(2), 'sp_weapontype', '')
                    local weaponType = tonumber(str)
                    local conditionVal = tonumber(info.Params:Get(1))
                    if weaponType and conditionVal then
                        local val = 0
                        for _, member in pairs(formation.tbMember) do
                            local pCard = member:GetCard()
                            if pCard and Item.GetCardWeaponType(pCard) == weaponType then
                                val = val + 1
                            end
                        end
                        if val < conditionVal then
                            return Text('star.starfalse1', conditionVal, Text('weapon.type_'..weaponType))
                        end
                    end
                elseif info.TypeID == 5 and info.Params:Length() >= 1 then
                    local bVal = false
                    local conditionVal = tonumber(info.Params:Get(1))
                    if conditionVal then
                        for _, member in pairs(formation.tbMember) do
                            local pCard = member:GetCard()
                            if pCard and pCard:Detail() == conditionVal then
                                bVal = true
                                break
                            end
                        end
                        if not bVal then
                            return Text('star.starfalse2', Text(Item.GetI18nByDetail(conditionVal)))
                        end
                    end
                elseif info.TypeID == 8 and info.Params:Length() >= 1 then
                    local bVal = true
                    local str = string.gsub(info.Params:Get(1), 'sp_weapontype', '')
                    local weaponType = tonumber(str)
                    if weaponType then
                        for _, member in pairs(formation.tbMember) do
                            local pCard = member:GetCard()
                            if pCard and Item.GetCardWeaponType(pCard) == weaponType then
                                bVal = false
                                break
                            end
                        end
                    end
                    if not bVal then
                        return Text('star.starfalse3', Text('weapon.type_'..weaponType))
                    end
                elseif info.TypeID == 3 or info.TypeID == 11 then
                    local num = 0
                    for _, member in pairs(formation.tbMember) do
                        if not member:IsNone() then num = num + 1 end
                    end
                    if num < 2 then
                        return Text('star.starfalse4')
                    end
                end
            end
        end
    end
end

-- 检测关卡编队相关条件
function Formation.CheckStarConditionResult(tbLevel)
    local ret = {}
    local formation = Formation.GetCurrentLineup()
    if not formation or not tbLevel or not tbLevel.tbStarCondition or not tbLevel.DidGotStar then
        return ret
    end
    local TaskInfo = UE4.ULevelStarTaskManager.GetInfoByCondition(tbLevel.sStarCondition)
    for i = 1, #tbLevel.tbStarCondition do
        ret[i] = false;
        if not tbLevel:DidGotStar(i - 1) then
            local info = TaskInfo:Get(i)
            if info then
                if info.TypeID == 4 and info.Params:Length() >= 2 then
                    local str = string.gsub(info.Params:Get(2), 'sp_weapontype', '')
                    local weaponType = tonumber(str)
                    local conditionVal = tonumber(info.Params:Get(1))
                    if weaponType and conditionVal then
                        local val = 0
                        for _, member in pairs(formation.tbMember) do
                            local pCard = member:GetCard()
                            if pCard and Item.GetCardWeaponType(pCard) == weaponType then
                                val = val + 1
                            end
                        end
                        if val >= conditionVal then
                            ret[i] = true 
                        end
                    end
                elseif info.TypeID == 5 and info.Params:Length() >= 1 then
                    local bVal = false
                    local conditionVal = tonumber(info.Params:Get(1))
                    if conditionVal then
                        for _, member in pairs(formation.tbMember) do
                            local pCard = member:GetCard()
                            if pCard and pCard:Detail() == conditionVal then
                                bVal = true
                                break
                            end
                        end
                        if bVal then
                            ret[i] = true
                        end
                    end
                elseif info.TypeID == 8 and info.Params:Length() >= 1 then
                    local bVal = true
                    local str = string.gsub(info.Params:Get(1), 'sp_weapontype', '')
                    local weaponType = tonumber(str)
                    if weaponType then
                        for _, member in pairs(formation.tbMember) do
                            local pCard = member:GetCard()
                            if pCard and Item.GetCardWeaponType(pCard) == weaponType then
                                bVal = false
                                break
                            end
                        end
                    end
                    if bVal then
                        ret[i] = true
                    end
                end
            end
        end
    end
    return ret
end

-----------------------请求---------------------------------
---通知服务器更新队伍
function Formation.Req_UpdateLineup(InLineupIndex, InCallback)
    if Formation.bReq_UpdateLineup then return end
    local fRes = function()
        Formation.bReq_UpdateLineup = false
        InCallback()

        if Online.GetPreId() > 0 and Online.GetOnlineState() ~= Online.STATUS_INVALID then
            Online.UpdateLineup(InLineupIndex)
        end
    end

    Formation.bReq_UpdateLineup = true
    if Login.bOffLine then fRes() return end

    local curTbLineup = Formation.GetLineup(InLineupIndex)
    if curTbLineup == nil then InCallback() return end

    ---肉鸽活动编队
    if InLineupIndex == RogueLogic.TeamId then
        local tbCard = {}
        tbCard[1] = curTbLineup:GetMember(0):GetCard()
        tbCard[2] = curTbLineup:GetMember(1):GetCard()
        tbCard[3] = curTbLineup:GetMember(2):GetCard()
        if RogueLogic.IsLineupChange(tbCard) then
            RogueLogic.SetRogueLineup(tbCard, fRes)
        else
            fRes()
        end
        return
    end

    local oldLineupData = me:GetLineup(InLineupIndex)
    local oldTbLineup = LineupLogic.New(oldLineupData)

    if oldTbLineup:IsEqual(curTbLineup) then
        fRes()
    else
        local fGetID = function(member)
            local pCard = member:GetCard()
            if pCard and not pCard:IsTrial() then
                return pCard:Id()
            end
            return 0
        end

        local tbData = {
            index = InLineupIndex,
            name = curTbLineup.sName,
            member1 = fGetID(curTbLineup:GetMember(0)),
            member2 = fGetID(curTbLineup:GetMember(1)),
            member3 = fGetID(curTbLineup:GetMember(2)),
        }
        print("===================Req_UpdateLineup==================>",  json.encode(tbData))
        UI.ShowConnection()
        me:CallGS("Lineup_Update", json.encode(tbData))
        Formation.SaveLineup_Handle = fRes
    end
end

function Formation.Rsp_UpdateLineup()
    UI.CloseConnection()
    PreviewScene.UpdateCharacterCache()
    if Formation.SaveLineup_Handle then
        Formation.SaveLineup_Handle()
        Formation.SaveLineup_Handle = nil
    end
end


-----------------------请求---------------------------------

------------------------注册消息------------------------
s2c.Register("UpdateLineup", Formation.Rsp_UpdateLineup)

---登录初始化
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    Formation.bReq_UpdateLineup = false
    if bReconnected then return end
    Formation.InitLineup()
end)
--------------------------------------------------------

return Formation
