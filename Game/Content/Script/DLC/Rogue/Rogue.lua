-- ========================================================
-- @File    : Rogue.lua
-- @Brief   : dlc1 小肉鸽活动
-- ========================================================

RogueLogic = RogueLogic or {}

RogueLogic.nGID = 25

RogueLogic.nBaseInfoID = 1
RogueLogic.nPathInfoID = 2
RogueLogic.nRoleInfoID = 3
RogueLogic.nBuffInfoID = 4
RogueLogic.nFormationInfoID = 5

RogueLogic.nShopGoodsListID = 10  --当前节点商品列表
RogueLogic.nBuyListID = 11	--已经买过的物品

RogueLogic.TeamId = 11	        --编队编号 肉鸽编队不在服务器存储数据
RogueLogic.MoneyId = 9	        --肉鸽活动代币ID
RogueLogic.MaxPage = 1	        --肉鸽活动地图最大页数

RogueLogic.nRandomDetailFlag = 9996 --随机时间详情设置标志位
RogueLogic.nDailyRefreshFlag = 9997 --每日刷新标志位  1是刚刷新过
RogueLogic.nVisitShopNodeID = 9998 --当前访问的商店ID
RogueLogic.nOpenStoryID = 9999 --活动剧情开启
RogueLogic.nPlotLevelID = 4351 --活动剧情开启

--节点类型
RogueLogic.NodeType = {
    Fight       = 1,    --战斗节点
    Random      = 2,    --事件节点
    Shop        = 3,    --商店节点
    Rest        = 4,    --休息节点
}

---移动到下一个节点触发的事件
RogueLogic.MoveToNext = "OnMoveToNext"

--=======================================配置================================================
---加载配置
function RogueLogic.LoadCfg()
    RogueLogic.LoadActivitiesCfg()
    RogueLogic.LoadBuffCfg()
    RogueLogic.LoadDayupBuffCfg()
    RogueLogic.LoadGoodsCfg()
    RogueLogic.LoadMapCfg()
    RogueLogic.LoadRandomCfg()
    RogueLogic.LoadRoleCfg()
    RogueLogic.LoadShopCfg()
end

--- 加载周期配置
function RogueLogic.LoadActivitiesCfg()
    --周期配置
    RogueLogic.tbActivitiesCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/activities.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID         = nID,
                sDes        = tbLine.Des or "tip.congif_err",
                nMapID      = tonumber(tbLine.MapID) or 0,
                nShopID     = tonumber(tbLine.ShopID) or 0,
                tbPrice     = Eval(tbLine.Price) or {},
                tbRefresh   = Eval(tbLine.Refresh) or {},
                TaskList    = Eval(tbLine.TaskList) or {},
            };

            tbInfo.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nStartTime")
            tbInfo.nEndTime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEndTime")

            RogueLogic.tbActivitiesCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/activities.txt")
end
--- 加载Buff配置
function RogueLogic.LoadBuffCfg()
    --Buff配置
    RogueLogic.tbBuffCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/buff.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID         = nID,
                nGroup      = tonumber(tbLine.Group) or 0,
                nCount      = tonumber(tbLine.Count),
                nType       = tonumber(tbLine.Type),
                tbModifire  = Eval(tbLine.Modifire),
                nPercent    = tonumber(tbLine.Percent),
                nIcon       = tonumber(tbLine.Icon),
                sName       = tbLine.Name or "tip.congif_err",
                sDesc       = tbLine.Desc or "tip.congif_err",
                sSimpleDesc = tbLine.SimpleDesc or "tip.congif_err",
                tbBuffParamPerCount  = Eval(tbLine.BuffParamPerCount) or {},
            };

            RogueLogic.tbBuffCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/buff.txt")
end
--- 加载每日Buff配置
function RogueLogic.LoadDayupBuffCfg()
    --每日Buff配置
    RogueLogic.tbDayupBuffCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/dayupbuff.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.Id);
        if nID then
            local tbInfo = {
                nID         = nID,
                sDescribe   = tbLine.Describe or "tip.congif_err",
                nDynamic    = tonumber(tbLine.Dynamic),
                nLv         = tonumber(tbLine.Lv) or 0,
                nType       = tonumber(tbLine.Type),
                tbModifire  = Eval(tbLine.ModifireID),
                nPercent    = tonumber(tbLine.Percent),
            };

            RogueLogic.tbDayupBuffCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/dayupbuff.txt")
end
--- 加载商品配置
function RogueLogic.LoadGoodsCfg()
    --商品配置
    RogueLogic.tbGoodsCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/goods.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID         = nID,
                nGroup      = tonumber(tbLine.Group) or 0,
                nOnly       = tonumber(tbLine.Only),
                nSets       = tonumber(tbLine.Sets),
                nType       = tonumber(tbLine.Type),
                nTrialID    = tonumber(tbLine.TrialID),
                tbModifire  = Eval(tbLine.Modifire),
                nPercent    = tonumber(tbLine.Percent),
                nPrice      = tonumber(tbLine.Price) or 0,
                nIcon       = tonumber(tbLine.Icon),
                sBuffName   = tbLine.BuffName or "tip.congif_err",
                sDesc       = tbLine.Desc or "tip.congif_err",
                sSimpleDesc = tbLine.SimpleDesc or "tip.congif_err",
                tbBuffParamPerCount  = Eval(tbLine.BuffParamPerCount) or {},
            };

            RogueLogic.tbGoodsCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/goods.txt")
end
--- 加载地图配置
function RogueLogic.LoadMapCfg()
    --地图配置
    RogueLogic.tbMapCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/map1.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nMapID = tonumber(tbLine.MapID);
        local nID = tonumber(tbLine.ID);
        if nMapID and nID then
            local tbInfo = {
                nMapID          = nMapID,
                nID             = nID,
                nConsumeVigor   = tonumber(tbLine.ConsumeVigor) or 0,
                nNode           = tonumber(tbLine.Node),
                nLevelID        = tonumber(tbLine.LevelID),
                nMonsterBuff    = tonumber(tbLine.MonsterBuff),
                nMonsterGrade   = tonumber(tbLine.MonsterGrade),
                nRandomID       = tonumber(tbLine.RandomID),
                sRestDesc       = tbLine.RestDesc,
                tbRestOption    = Eval(tbLine.RestOption),
                tbNext          = Eval(tbLine.Next) or {},
                nIcon           = tonumber(tbLine.Icon),
                nName           = tbLine.Name or "tip.congif_err",
                nPage           = math.floor(nID / 10000),
                nX              = math.floor(nID / 10)%1000,
                nY              = nID % 10
            };
            if tbInfo.nPage > RogueLogic.MaxPage then
                RogueLogic.MaxPage = tbInfo.nPage
            end
            RogueLogic.tbMapCfg[nMapID] = RogueLogic.tbMapCfg[nMapID] or {}
            RogueLogic.tbMapCfg[nMapID][nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/map1.txt")
end
--- 加载随机事件
function RogueLogic.LoadRandomCfg()
    --随机事件配置
    RogueLogic.tbRandomCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/random.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                sTitle          = tbLine.Title,
                tbOptions       = {},
                tbTips          = {},
                tbEffect        = {},
            };
            for i = 1, 3 do
                tbInfo.tbOptions[i] = tbLine["Options"..i]
                tbInfo.tbTips[i] = tbLine["Tips"..i]
                tbInfo.tbEffect[i] = Eval(tbLine["Effect"..i]) or {}
            end

            RogueLogic.tbRandomCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/random.txt")
end
--- 加载每日角色配置
function RogueLogic.LoadRoleCfg()
    --角色配置
    RogueLogic.tbRoleCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/role.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                tbGDPL          = Eval(tbLine.GDPL) or {},
                nDynamic        = tonumber(tbLine.Dynamic),
            };

            RogueLogic.tbRoleCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/role.txt")
end
--- 加载商店配置
function RogueLogic.LoadShopCfg()
    --商店配置
    RogueLogic.tbShopCfg = {}
    local tbFile = LoadCsv("dlc/dlc1/rogue/shop.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                tbGoods         = {},
                tbRepeat        = {},
            };
            for i = 1, 6 do
                tbInfo.tbGoods[i] = Eval(tbLine["Goods"..i])
                tbInfo.tbRepeat[i] = tonumber(tbLine["Repeat"..i])
            end

            RogueLogic.tbShopCfg[nID] = tbInfo
        end
    end
    print("dlc/dlc1/rogue/shop.txt")
end
--============================================================================

---获取当前周期ID 未开放返回0
function RogueLogic.GetActivitieID()
    if RogueLogic.nTimeID then
        local cfg = RogueLogic.tbActivitiesCfg[RogueLogic.nTimeID]
        if cfg and IsInTime(cfg.nStartTime, cfg.nEndTime) then
            return RogueLogic.nTimeID, cfg
        end
    end
    for _, cfg in pairs(RogueLogic.tbActivitiesCfg) do
        if IsInTime(cfg.nStartTime, cfg.nEndTime) then
            RogueLogic.nTimeID = cfg.nID
            return RogueLogic.nTimeID, cfg
        end
    end
    return 0
end

---获取当前周期信息
function RogueLogic.GetBaseInfo()
    if not RogueLogic.BaseData then
        RogueLogic.UpdateBaseData()
    end
    return RogueLogic.BaseData
end

---获取行动力次数
---@return integer 剩余次数
---@return integer 上限次数
function RogueLogic.GetActionNum()
    local info = RogueLogic.GetBaseInfo()
    return info.nAvaActTimes, info.nUpperActTimes
end

---获取怪物等级
function RogueLogic.GetMonsterGrade()
    local cfg = RogueLevel.GetNodeInfo()
    if cfg and cfg.nMonsterGrade then
        return cfg.nMonsterGrade
    end
    return 0
end

---跳转到肉鸽界面
function RogueLogic.GoToRouge()
    if RogueLogic.GetActivitieID()<=0 then
        UI.ShowMessage(Text("tip.not_open"))
        return
    end
    local ntime = tonumber(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nOpenStoryID)) or 0
    local cfg = DLC_Logic.GetCurConf()
    if cfg then
        if IsInTime(cfg.nEnterStartTime, cfg.nCloseEndTime, ntime) then
            UI.Open("DlcRogue")
        else
            Launch.SetType(LaunchType.DLC1_ROGUE)
            RogueLevel.SetLevelID(RogueLogic.nPlotLevelID)
            Launch.Start()
        end
    end
end

--递归刷新函数
function RogueLogic._UpdateCanGoNode(nMapID, tbID)
    if not tbID or #tbID<=0 then
        return
    end
    if not RogueLogic.tbCanGoNode then
        RogueLogic.tbCanGoNode = {}
    end
    for _, ID in ipairs(tbID) do
        RogueLogic.tbCanGoNode[ID] = true
        RogueLogic._UpdateCanGoNode(nMapID, RogueLogic.GetTbNextID(nMapID, ID))
    end
end

---刷新可进入和可前往的节点
function RogueLogic.UpdateActivateNode()
    --路线上可前往的节点
    RogueLogic.tbCanGoNode = {}
    --当前可进入的节点
    RogueLogic.tbActivateNode = {}

    local BaseInfo = RogueLogic.GetBaseInfo()
    if not RogueLogic.tbMapCfg[BaseInfo.nMapID] then
        return
    end

    --所有可前往的点
    RogueLogic._UpdateCanGoNode(BaseInfo.nMapID, RogueLogic.GetTbNextID(BaseInfo.nMapID, BaseInfo.nCurNode))

    --当前可进入的点
    local nState = RogueLogic.GetNodeState(BaseInfo.nMapID, BaseInfo.nCurNode)
    if nState == 1 then
        RogueLogic.tbActivateNode[BaseInfo.nCurNode] = true
    elseif nState > 1 then
        for _, ID in ipairs(RogueLogic.GetTbNextID(BaseInfo.nMapID, BaseInfo.nCurNode)) do
            RogueLogic.tbActivateNode[ID] = true
        end
    end
end

---判断节点当前路线是否可前往
function RogueLogic.CheckNodeCanGo(nID)
    if not RogueLogic.tbCanGoNode then
        RogueLogic.UpdateActivateNode()
    end
    return RogueLogic.tbCanGoNode[nID]
end

---判断节点是否可进入
function RogueLogic.CheckNodeActivate(nID)
    if not RogueLogic.tbActivateNode then
        RogueLogic.UpdateActivateNode()
    end
    return RogueLogic.tbActivateNode[nID]
end

---刷新角色卡信息
function RogueLogic.UpdateCardData()
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nRoleInfoID)) or {}
    --角色卡信息
    RogueLogic.tbCardData = tbData
end

---肉鸽活动获取角色血量
---@param Card UE4.UCharacterCard
---@return number 血量
---@return number 满血血量
function RogueLogic.GetHPByCard(Card)
    if not Card then return 0 end
    if not RogueLogic.tbCardData then
        RogueLogic.UpdateCardData()
    end
    local nFullHP = 0
    local HP = 0
    local key = ""
    if Card:IsTrial() then
        key = tostring(me:GetTrialIDByItem(Card)).."_T"
    else
        key = tostring(Card:Id()).."_P"
    end
    local Data = RogueLogic.tbCardData[key]
    if Data then
        local Health = tonumber(Data.nTotalHP)
        local CardHealth = tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Health", Card))
        if Health ~= CardHealth then
            local GDPL = Card:Genre().."-"..Card:Detail().."-"..Card:Particular().."-"..Card:Level()
            local Name = Item.GetName(Card).."-"..Item.GetTitle(Card)
            printf("RogueLogic_error 肉鸽活动服务器计算的血量和本地不一致 服务器满血量:%f, 本地满血量:%f, 角色卡key:%s, 角色名:%s, GDPL:%s", Health, CardHealth, key, Name, GDPL)
        end
        nFullHP = Health or CardHealth
        HP = Data.nCurHP or nFullHP
    end
    return tonumber(HP), nFullHP
end

---移除编队阵亡的角色
function RogueLogic.RemoveDeathCard()
    local Lineup = Formation.GetLineup(RogueLogic.TeamId)
    if Lineup then
        local Members = Lineup:GetMembers()
        for i = 0, 2 do
            local card = Members[i]:GetCard()
            if card and RogueLogic.GetHPByCard(card) == 0 then
                Formation.SetLineupMember(RogueLogic.TeamId, i, nil)
            end
        end
    end
end

---战斗结束获取剩余血量
function RogueLogic.GetTbHP()
    local tbCard = RogueLogic.GetRogueLineup()
    local tbHP = {}
    local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if Controller then
        local lineup = Controller:GetPlayerCharacters()
        for i = 1, lineup:Length() do
            local Character = lineup:Get(i)
            local PCard = Character:K2_GetPlayerMember()
            for index, card in pairs(tbCard) do
                if card and PCard and card:Genre()==PCard:Genre() and card:Detail()==PCard:Detail() and card:Particular()==PCard:Particular() and card:Level()==PCard:Level() then
                    tbHP[index] = math.ceil(Character.Ability:GetPropertieValueFromString("Health"))
                end
            end
        end
    end
    return tbHP
end

---添加血量恢复事件
function RogueLogic.AddRefreshHPEvent()
    if RogueLogic.CharacterSpawnHandle then
        RogueLogic.RemoveRefreshHPEvent()
    end
    if Launch.GetType() ~= LaunchType.DLC1_ROGUE then
        return
    end
    RogueLogic.CharacterSpawnHandle = EventSystem.On(Event.CharacterSpawned, function(SpawnCharacter)
        if IsValid(SpawnCharacter) and IsPlayer(SpawnCharacter) then
            local Card = SpawnCharacter:K2_GetPlayerMember()
            local hp = RogueLogic.GetHPByCard(Card)
            if hp < tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Health", Card)) then
                SpawnCharacter.Ability:SetPropertieValueFromString("Health", hp)
                if hp <= 0 then
                    local Controller = SpawnCharacter:GetCharacterController()
                    if Controller then
                        Controller:SwitchNextPlayerCharacter(true)
                    end
                end
            end
        end
    end)
end

---删除血量恢复事件
function RogueLogic.RemoveRefreshHPEvent()
    if RogueLogic.CharacterSpawnHandle then
        EventSystem.Remove(RogueLogic.CharacterSpawnHandle)
        RogueLogic.CharacterSpawnHandle = nil
    end
end

---获取当日增益角色和增益buff
---@return table RogueLogic.tbRoleCfg
function RogueLogic.FetchDailyBuff(funBack)
    RogueLogic.FetchDailyBuffCallBack = funBack
    RogueLogic.DayRole = nil
    RogueLogic.DayBuff = nil
    me:CallGS("RogueLogic_FetchDailyBuff")
end
s2c.Register('RogueLogic_FetchDailyBuff', function(tbParam)
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end

    if tbParam.tbDailyBuffRole then
        --每日增益角色
        RogueLogic.DayRole = {}
        for _, info in ipairs(tbParam.tbDailyBuffRole) do
            local cfg = RogueLogic.tbRoleCfg[info.nID]
            if cfg then
                table.insert(RogueLogic.DayRole, cfg)
            end
        end
    end
    if tbParam.tbDailyBuff then
        --每日增益BUFF
        RogueLogic.DayBuff = {}
        for _, info in ipairs(tbParam.tbDailyBuff) do
            local cfg = RogueLogic.tbDayupBuffCfg[info.nID]
            if cfg then
                table.insert(RogueLogic.DayBuff, cfg)
            end
        end
    end

    if RogueLogic.FetchDailyBuffCallBack then
        RogueLogic.FetchDailyBuffCallBack()
        RogueLogic.FetchDailyBuffCallBack = nil
    end
end)


---获取当前所有增益buff
---@return table
function RogueLogic.GetAllBuff()
    local tbBuff = {}
    local tbBuffData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nBuffInfoID)) or {}
    for _, ID in pairs(tbBuffData) do
        local info = RogueLogic.tbBuffCfg[ID]
        if info then
            table.insert(tbBuff, info)
        end
    end
    return tbBuff
end

---获取购买的商品中所有增益buff
---@return table
function RogueLogic.GetGoodsAllBuff()
    local tbGoods = {}
    local tbGoodsData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nBuyListID)) or {}
    for _, goodsID in pairs(tbGoodsData) do
        local info = RogueLogic.tbGoodsCfg[goodsID]
        if info and info.nType==1 and info.tbModifire then
            table.insert(tbGoods, info)
        end
    end
    return tbGoods
end

---获取所有增益buff和购买的商品中所有增益buff
---@return table
function RogueLogic.GetBuffAndGoodsBuff()
    local tbGoods = RogueLogic.GetAllBuff()
    local tbGoodsData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nBuyListID)) or {}
    for _, goodsID in pairs(tbGoodsData) do
        local info = RogueLogic.tbGoodsCfg[goodsID]
        if info and info.nType==1 and info.tbModifire then
            table.insert(tbGoods, info)
        end
    end
    return tbGoods
end

--获取上阵角色中增益角色的数量
function RogueLogic.GetBuffCardNum()
    local tbBuffRole = {}
    if RogueLogic.DayRole then
        for _, Role in ipairs(RogueLogic.DayRole) do
            local key = table.concat(Role.tbGDPL, "-")
            tbBuffRole[key] = true
        end
    end

    local num = 0
    local Lineup = Formation.GetLineup(RogueLogic.TeamId)
    if Lineup then
        local Members = Lineup:GetMembers()
        for i = 0, 2 do
            local card = Members[i]:GetCard()
            if card and tbBuffRole[string.format("%d-%d-%d-%d", card:Genre(), card:Detail(), card:Particular(), card:Level())] then
                num = num + 1
            end
        end
    end
    return num
end

---获取在关卡中玩家的buffID
function RogueLogic.GetTbBuffID()
    local tbID = {}
    for _, info in ipairs(RogueLogic.DayBuff) do
        if info.nType==1 and RogueLogic.GetBuffCardNum() >= info.nLv then
            for _, ID in ipairs(info.tbModifire) do
                table.insert(tbID, ID)
            end
        end
    end
    for _, info in ipairs(RogueLogic.GetAllBuff()) do
        if info.nType==1 and info.tbModifire then
            for _, ID in ipairs(info.tbModifire) do
                table.insert(tbID, ID)
            end
        end
    end
    for _, info in pairs(RogueLogic.GetGoodsAllBuff()) do
        if info.tbModifire then
            for _, ID in ipairs(info.tbModifire) do
                table.insert(tbID, ID)
            end
        end
    end
    return tbID
end

---获取在关卡中怪物的buffID 第二个返回buff配置信息
function RogueLogic.GetTbMonsterBuffID()
    local info = RogueLevel.GetNodeInfo()
    if info and info.nMonsterBuff then
        local buffInfo = RogueLogic.tbBuffCfg[info.nMonsterBuff]
        if buffInfo and buffInfo.tbModifire then
            return buffInfo.tbModifire, buffInfo
        end
    end
    return {}
end

---获取商品列表
---@return table RogueLogic.tbGoodsCfg
function RogueLogic.GettbGoods(nodeID)
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nShopGoodsListID)) or {}
    local tbgoods = {}
    for _, Data in pairs(tbData[tostring(nodeID)] or {}) do
        local cfg = RogueLogic.tbGoodsCfg[Data.nGoodsID]
        if cfg then
            table.insert(tbgoods, {GoodsInfo = cfg, nBuyState = Data.nBuyState})
        end
    end
    return tbgoods
end

---获取商店折扣价
function RogueLogic.GetGoodsPriceBuff()
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nBaseInfoID))
    return tbData.nGoodsPriceBuff
end

---获取可复活的角色列表
function RogueLogic.GettbDeathCard()
    if not RogueLogic.tbCardData then
        RogueLogic.UpdateCardData()
    end

    local tbCard = {}
    for _, Data in pairs(RogueLogic.tbCardData) do
        local card = nil
        if Data.nCurHP and tonumber(Data.nCurHP) <= 0 then
            if Data.nGot and Data.nGot > 0 then
                card = me:GetItem(Data.RoleID)
            else
                card = me:GetTrialCard(Data.RoleID)
            end
        end
        if card then
            table.insert(tbCard, card)
        end
    end
    return tbCard
end

---获取能使用的所有角色Card
function RogueLogic.GetAllCharacter()
    if not RogueLogic.tbCardData then
        RogueLogic.UpdateCardData()
    end

    local tbCard = {}
    for _, Data in pairs(RogueLogic.tbCardData) do
        local card = nil
        if Data.nGot and Data.nGot > 0 then
            card = me:GetItem(Data.RoleID)
        else
            card = me:GetTrialCard(Data.RoleID)
        end
        if card then
            table.insert(tbCard, card)
        end
    end
    return tbCard
end

---刷新数据
function RogueLogic.UpdateData()
    RogueLogic.UpdateBaseData()
    RogueLogic.UpdateNodeState()
    RogueLogic.UpdateCardData()
    RogueLogic.UpdateActivateNode()
end

---刷新周期数据
function RogueLogic.UpdateBaseData()
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nBaseInfoID))
    tbData = tbData or {nMapID = 0, nAvaActTimes = 0, nID = 0, nCurNode = 0, nUpperActTimes = 0, nUsedActTimes = 0, nRefreshTimes = 0, nReviveTimes = 0}
    --周期数据
    RogueLogic.BaseData = tbData
end

---刷新节点状态
function RogueLogic.UpdateNodeState()
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nPathInfoID)) or {}
    --各节点状态
    RogueLogic.tbNodeState = {}
    for key, Data in pairs(tbData) do
        local ID = tonumber(key)
        if ID then
            RogueLogic.tbNodeState[ID] = Data
        end
    end
end
---获取节点状态
---@return integer 0锁定 1可使用节点功能 2已使用节点功能，可前进 3已通过
function RogueLogic.GetNodeState(MapID, ID)
    if RogueLogic.GetBaseInfo().nMapID ~= MapID or not ID then
        return 0
    end
    if not RogueLogic.tbNodeState then
        RogueLogic.UpdateNodeState()
    end
    if not RogueLogic.tbNodeState[ID] then
        return 0
    end
    return RogueLogic.tbNodeState[ID].nState or 0
end

---节点是否完成
function RogueLogic.CheckNodeComplete(MapID, ID)
    if ID==10001 then
        return true
    end
    local cfg = RogueLogic.tbMapCfg[MapID][ID]
    if not cfg then
        return false
    end

    return RogueLogic.GetNodeState(MapID, ID) >= 2
end

---节点是否可打开
function RogueLogic.CheckNodeOpen(MapID, ID)
    local nState = RogueLogic.GetNodeState(MapID, ID)
    if nState == 0 then
        local BaseInfo = RogueLogic.GetBaseInfo()
        local bNext = false
        if RogueLogic.CheckNodeComplete(MapID, BaseInfo.nCurNode) then
            local tbNext = RogueLogic.GetTbNextID(MapID, BaseInfo.nCurNode)
            for _, NextID in ipairs(tbNext) do
                if NextID == ID then
                    bNext = true
                    break
                end
            end
        end
        if bNext then
            return true
        else
            if RogueLogic.CheckNodeCanGo(ID) then
                return false, Text("rogue.TxtNoMove")
            else
                return false, Text("rogue.TxtNodeNoSl")
            end
        end
    elseif nState == 1 then
        return true
    elseif nState >= 2 then
        return false, Text("rogue.TxtNodeOver")
    end
end

---获取节点的下一关
function RogueLogic.GetTbNextID(MapID, ID)
    local cfg = RogueLogic.tbMapCfg[MapID][ID]
    return (cfg and cfg.tbNext) or {}
end

---是否显示红点
function RogueLogic.CheckRedDot()
    local Flag = tonumber(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nDailyRefreshFlag))
    if Flag and Flag > 0 then
        return true
    end

    local _, cfg = RogueLogic.GetActivitieID()
    if cfg then
        for _, ID in ipairs(cfg.TaskList) do
            local taskcfg = Achievement.GetQuestConfig(ID)
            if taskcfg and Achievement.CheckAchievementReward(taskcfg) == Achievement.STATUS_CAN then
                return true
            end
        end
    end
    return false
end

---获取编队信息
---@param bFilterDeath 是否过滤掉死亡角色
---@return table tbCard
function RogueLogic.GetRogueLineup(bFilterDeath)
    local tbCard = {}
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nFormationInfoID)) or {}
    for index, Data in pairs(tbData) do
        local card = nil
        if Data.nGot and Data.nGot > 0 then
            card = me:GetItem(Data.RoleID)
        else
            card = me:GetTrialCard(Data.RoleID)
        end
        if bFilterDeath and card and RogueLogic.GetHPByCard(card)==0 then
            card = nil
        end
        tbCard[index] = card
    end
    return tbCard
end
---编队信息是否改变
function RogueLogic.IsLineupChange(tbLineupCard)
    local tbCard = RogueLogic.GetRogueLineup()
    for i = 1, 3 do
        if tbLineupCard[i] ~= tbCard[i] then
            return true
        end
    end
    return false
end
---获取队员
function RogueLogic.GetLineupRoleByIndex(Index)
    local tbData = json.decode(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nFormationInfoID)) or {}
    local card = nil
    local Data = tbData[Index]
    if Data then
        if Data.nGot and Data.nGot > 0 then
            card = me:GetItem(Data.RoleID)
        else
            card = me:GetTrialCard(Data.RoleID)
        end
    end
    return card
end
---设置队员
function RogueLogic.SetRogueLineup(tbCard, funBack)
    local tbInfo = {}
    for index = 1, 3 do
        local Card = tbCard[index]
        if Card then
            if Card:IsTrial() then
                tbInfo[index] = {me:GetTrialIDByItem(Card), true}
            else
                tbInfo[index] = {Card:Id(), false}
            end
        else
            tbInfo[index] = {0}
        end
    end
    ---设置队员后的回调
    RogueLogic.SetRogueLineupCallBack = funBack
    UI.ShowConnection()
    me:CallGS("RogueLogic_ChangeFormation", json.encode({tbFormation = tbInfo}))
end
s2c.Register('RogueLogic_ChangeFormation', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    if RogueLogic.SetRogueLineupCallBack then
        RogueLogic.SetRogueLineupCallBack()
        RogueLogic.SetRogueLineupCallBack = nil
    end
end)

---进入下一个节点
function RogueLogic.MoveNext(NodeID, funBack)
    ---进入下一个节点后的回调
    RogueLogic.MoveNextCallBack = funBack
    UI.ShowConnection()
    me:CallGS("RogueLogic_ClientMoveNext", json.encode({nID = NodeID}))
end
s2c.Register('RogueLogic_ClientMoveNext', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    RogueLogic.UpdateData()
    EventSystem.TriggerTarget(RogueLogic, RogueLogic.MoveToNext)
    if RogueLogic.MoveNextCallBack then
        RogueLogic.MoveNextCallBack()
        RogueLogic.MoveNextCallBack = nil
    end
end)

---完成节点
function RogueLogic.FinishNode(tbData, funBack)
    if not tbData then return end
    ---完成节点后的回调
    RogueLogic.FinishNodeCallBack = funBack
    UI.ShowConnection()
    me:CallGS("RogueLogic_FinishNode", json.encode(tbData))
end
s2c.Register('RogueLogic_FinishNode', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    if tbParam and type(tbParam[1]) == "table" and tbParam[1].Awards then
        Launch.tbAward = {tbParam[1].Awards}
    end
    RogueLogic.UpdateData()
    if RogueLogic.FinishNodeCallBack then
        RogueLogic.FinishNodeCallBack()
        RogueLogic.FinishNodeCallBack = nil
    end
end)

---复活队员
function RogueLogic.ReviveRole(tbData, funBack)
    if not tbData then return end
    ---复活队员后的回调
    RogueLogic.ReviveRoleCallBack = funBack
    UI.ShowConnection()
    me:CallGS("RogueLogic_ReviveRole", json.encode(tbData))
end
s2c.Register('RogueLogic_ReviveRole', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    RogueLogic.UpdateData()
    if RogueLogic.ReviveRoleCallBack then
        RogueLogic.ReviveRoleCallBack()
        RogueLogic.ReviveRoleCallBack = nil
    end
end)

---刷新商店
function RogueLogic.RefreshShopGoods(NodeID, funBack)
    ---刷新商店后的回调
    RogueLogic.RefreshShopGoodsCallBack = funBack
    UI.ShowConnection()
    me:CallGS("RogueLogic_RefreshShopGoods", json.encode({nNodeID = NodeID}))
end
s2c.Register('RogueLogic_RefreshShopGoods', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    RogueLogic.UpdateData()
    if RogueLogic.RefreshShopGoodsCallBack then
        RogueLogic.RefreshShopGoodsCallBack()
        RogueLogic.RefreshShopGoodsCallBack = nil
    end
end)

---重置
function RogueLogic.ResetRogue()
    UI.ShowConnection()
    me:CallGS("RogueLogic_ResetRogue")
end
s2c.Register('RogueLogic_ResetRogue', function()
    UI.CloseConnection()
    RogueLogic.UpdateData()
    for i = 0, 2 do
        Formation.SetLineupMember(RogueLogic.TeamId, i, nil)
    end
    local uiRogue = UI.GetUI("DlcRogue")
    if uiRogue and uiRogue:IsOpen() then
        uiRogue:UpdatePanel()
    end
end)

--打开商店时记录一下
function RogueLogic.VisitShop(nNodeID, funBack)
	UI.ShowConnection()
    RogueLogic.VisitShopCallBack = funBack
    me:CallGS("RogueLogic_VisitShop", json.encode({nNodeID = nNodeID}))
end
s2c.Register('RogueLogic_VisitShop', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    RogueLogic.UpdateData()
    if RogueLogic.VisitShopCallBack then
        RogueLogic.VisitShopCallBack()
        RogueLogic.VisitShopCallBack = nil
    end
end)

---领取任务奖励
---@param nType integer 1 每日任务；2 每周任务
---@param tbIdList table tbIdList
function RogueLogic.QuickGetReward(tbIdList, funBack)
    if not tbIdList or #tbIdList == 0 then
        UI.ShowMessage("error.BadParam")
        return
    end
	UI.ShowConnection()
    RogueLogic.QuickGetRewardCallBack = funBack
    me:CallGS("RogueLogic_QuickGetReward", json.encode({tbIdList = tbIdList}))
end
s2c.Register('RogueLogic_QuickGetReward', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.sError then
        UI.ShowMessage(tbParam.sError)
        return
    end
    if tbParam and tbParam.tbAwards then
        Item.Gain(tbParam.tbAwards)
    end
    if RogueLogic.QuickGetRewardCallBack then
        RogueLogic.QuickGetRewardCallBack()
        RogueLogic.QuickGetRewardCallBack = nil
    end
end)

---获取当前打开的商店节点ID 没有返回nil 弃用。。。
function RogueLogic.GetVisitShopID()
    local ID = tonumber(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nVisitShopNodeID))
    if ID and ID>0 then
        return ID
    end
    return nil
end

RogueLogic.LoadCfg()
return RogueLogic
