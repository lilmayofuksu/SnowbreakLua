-- ========================================================
-- @File    : TeamRule.lua
-- @Brief   : 队伍规则处理
-- ========================================================

TeamRule = TeamRule or { tbTeamRule = {}}

---缓存当前关卡规则信息
local RunTimeRule = {}

local sVersion = UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", '1.0.0');
local SAVE_HEAD = string.format('TEAM_RULE_%s_', sVersion) ---保存试玩角色标记

---当前队伍ID
local CURRENT_RULE_ID = nil

local function Log(...)
    --print('TEAM RULE ******************:', ...)
end


---GDPL 比较
local function GDPLCompare(c1, c2)
    if not c1 or not c2 then return false end
    return c1:Genre() == c2:Genre() and c1:Detail() == c2:Detail() and
    c1:Particular() == c2:Particular() and c1:Level() == c2:Level()
end

local function GDPLCompare2(c1, g, d, p, l)
    if not c1 or not g or not d or not p or not l then return false end
    return c1:Genre() == g and c1:Detail() == d and c1:Particular() == p and c1:Level() == l
end


local tbCacheCard = {}
function TeamRule.CacheAddCard(pCard)
    if pCard then tbCacheCard[pCard] = 1 end
end


---保存试玩关卡编队信息
function TeamRule.Save(nLevelID)
    if not nLevelID then return end
    local tbSave = {}
    for i = 0, 2 do
        local pCard = Formation.GetCardByIndex(Formation.TRIAL_INDEX, i)
        if pCard then
            if pCard:IsTrial() then
                tbSave[i + 1] = {1, me:GetTrialIDByItem(pCard)}
            else
                tbSave[i + 1] = {0, pCard:Id()}
            end
        end
    end
    local str = json.encode(tbSave)
    Log('TeamRule.Save', nLevelID, str)
    UE4.UUserSetting.SetString(SAVE_HEAD .. nLevelID, str)
    UE4.UUserSetting.Save()
end


---获取保存的角色卡
---@param nLevelID Integer
---@param nPos Integer
function TeamRule.GetSaveCard(nLevelID, nPos)
    if not CURRENT_RULE_ID or not RunTimeRule or not RunTimeRule[CURRENT_RULE_ID] then return end

    local rule = RunTimeRule[CURRENT_RULE_ID][nPos]
    if not rule then return end
    Log('GetSaveCard', nLevelID, nPos)
    if not nLevelID then return end
    local tbSave = json.decode(UE4.UUserSetting.GetString(SAVE_HEAD .. nLevelID))

    local idx = nPos + 1
    if tbSave and tbSave[idx] then
        local info = tbSave[idx]
        return info[1] == 1 and me:GetTrialCard(info[2]) or me:GetCharacterCard(info[2])
    end
end

---解析角色卡
function TeamRule.ParseCard(id)
    if not id then return end
    if type(id) == 'table' then
        local g, d, p, l = table.unpack(id)
        if g and d and p and l then
            local allCard = me:GetCharacterCards()
            for i = 1, allCard:Length() do
                local pCard = allCard:Get(i)
                if pCard and GDPLCompare2(pCard, g, d, p, l) then
                    return pCard
                end
            end
        end
    else
        return me:GetTrialCard(id)
    end
end

---是否与试用角色一致
function TeamRule.CompareCard(a, pCard)
    if not a or not pCard then return false end

    if type(a) == "table" then
        local g, d, p, l = table.unpack(a)
        if GDPLCompare2(pCard, g, d, p, l) then
            return true
        end
    else
        local pTrialCard = me:GetTrialCard(a)
        if pTrialCard then
            if GDPLCompare(pTrialCard, pCard) then
                return true
            end
        end
    end
    return false
end


function TeamRule.Clear()
    Log('TeamRule.Clear()', CURRENT_RULE_ID)
    RunTimeRule = {}
    tbCacheCard = {}
    CURRENT_RULE_ID = nil
end

---角色是否被锁定
---@param pCard UCharacterCard 角色卡
---@param idx Integer 位置
function TeamRule.IsLockCard(pCard, idx)
    if not pCard then return false end
    if not idx then return true end
    for i = 0, 2 do
        local rule = TeamRule.GetPosRule(i)
        local bUseSelf = false
        if rule then
            bUseSelf = rule:IsUseSelfCard()
        end
        if i ~= idx and bUseSelf == false then
            local c = Formation.GetCardByIndex(Formation.TRIAL_INDEX, i)
            if c and GDPLCompare(c, pCard) then
               return true
            end
        end
    end
    return false
end


function TeamRule.IsMaxTrialNum(pCard, idx)
    local rule = RunTimeRule[idx]
    if not rule then return false end
 
    local num = 0
    for i = 0, 2 do
        if i ~= idx then
            local c = Formation.GetCardByIndex(Formation.TRIAL_INDEX, i)
            if c and c:IsTrial() and c ~= pCard then
                num = num + 1
            end
        end
    end
    return rule:GetMaxTrailNum() <= num
end


---缓存队伍规则信息
function TeamRule.CreateRule(nID)
    CURRENT_RULE_ID = nID
    if RunTimeRule and RunTimeRule[nID] then return end

    Log('creat rule :', nID)
    if not nID then return end
    local cfg = TeamRule.Get(nID)
    if not cfg then return end
    RunTimeRule = RunTimeRule or {}

    local tbInfo = {}
    RunTimeRule[nID] = tbInfo

    local fGetIndex = function(nIndex)
        if nIndex == 0 then 
            return 2
        elseif nIndex == 1 then
            return 1
        elseif nIndex == 2 then
            return 3
        end
        return nIndex
    end

    for i = 0, 2 do
        local nCfgPos = fGetIndex(i)
        tbInfo[i]  = {
            nPos = i,
            nCfgPos = nCfgPos,
            cfg = cfg,

            tbWeapon = cfg.tbWeapon and cfg.tbWeapon[nCfgPos] or nil,
            tbBanWeapon = cfg.tbWeaponBanID and cfg.tbWeaponBanID[nCfgPos] or nil,

            bSet = false,

            ---是否开启试玩
            IsOpenTrail = function(self)
                return self.cfg.tbTrailFlag and self.cfg.tbTrailFlag[self.nCfgPos] == 1 or false
            end,

            ---获取角色列表
            GetCardList = function(self)
                local cardList = {}
                local bAdd = false

                for _, id in ipairs(self.cfg.tbTrailRole[self.nCfgPos] or {}) do
                    local card = TeamRule.ParseCard(id)
                    if card then
                        cardList[card] = 1
                        bAdd = true
                    end
                end

                if self:IsUseSelfCard() then
                    ---有指定试用角色时并且可以使用自身角色，则只显示试用角色和与试用角色一致的自身角色
                    if bAdd then
                        local tbSelfCard = me:GetCharacterCards():ToTable()

                        local tbNewAdd = {}
                        for _, card in ipairs(tbSelfCard or {}) do
                            for addCard, _ in pairs(cardList) do
                                if GDPLCompare(card, addCard) then
                                    table.insert(tbNewAdd, card)
                                end
                            end
                        end
                        for _, c in ipairs(tbNewAdd) do
                            cardList[c] = 1
                        end
                    else
                        local tbSelfCard = me:GetCharacterCards():ToTable()
                        for _, c in ipairs(tbSelfCard or {}) do
                            cardList[c] = 1
                        end
                    end
                end
                local tbRet = {}
                for c, _ in pairs(cardList) do
                    if c then
                        table.insert(tbRet, c)
                    end
                end
                return tbRet
            end,

            ---获取自动上阵角色
            GetAutoAddCard = function(self)
                if self.cfg.nAutoAdd ~= 1 then return end
                if self.bSet then return end
                for _, id in pairs(self.cfg.tbTrailRole[self.nCfgPos] or {}) do
                    local card = TeamRule.ParseCard(id)
                    if card then
                       local bAdd = tbCacheCard[card] ~= nil
                        if card:IsTrial() then
                            if not TeamRule.IsMaxTrialNum(self.pCard, self.nPos) and not bAdd then
                               return card
                            end
                        else
                            if not bAdd then
                                return card
                            end
                        end
                    end
                end
            end,

            ---最大试玩角色数量
            GetMaxTrailNum = function(self)
                return self.cfg.nLimit
            end,

            ---是否可以使用自身角色
            IsUseSelfCard = function(self)
                return self.cfg.tbSelfFlag and self.cfg.tbSelfFlag[self.nCfgPos] == 1 or false
            end,

            ---是否被禁用
            IsDisable = function(self)
                Log('IsDisable', self.nPos, self.nCfgPos, self.cfg.tbTrailFlag[self.nCfgPos])
                return self.cfg.tbTrailFlag and self.cfg.tbTrailFlag[self.nCfgPos] ~= 1 or false
            end,

            ---是否包含
            IsContainCard = function(self, pCard)
                for _, id in ipairs(self.cfg.tbTrailRole[self.nCfgPos] or {}) do
                    local card = TeamRule.ParseCard(id)
                    if card and card == pCard then
                        return true
                    end
                end
            end,

            ---是否是指定角色
            IsAssignCard = function(self, pCard)
                if not pCard then return false end
                if not self.cfg.tbTrailRole[self.nCfgPos] then return false end
                local nLen = #self.cfg.tbTrailRole[self.nCfgPos]
                if nLen > 1 then return false end
                return self:IsContainCard(pCard)
            end,

            CanIn = function(self, pCard)
                ---被禁止
                if self:IsDisable() then return false end
                if not pCard then return true end
    
                local bContain = self:IsContainCard(pCard)
                if bContain then return true end

                if not pCard:IsTrial() then
                    if self:IsUseSelfCard() then
                        return true
                    end
                end
                return false
            end,
        }
    end
end

---获取编队位置规则
function TeamRule.GetPosRule(nPos)
    Log('GetPosRule', nPos, CURRENT_RULE_ID)
    if CURRENT_RULE_ID and RunTimeRule and RunTimeRule[CURRENT_RULE_ID] then
        return RunTimeRule[CURRENT_RULE_ID][nPos]
    end
end


----------------------------/////测试/////-------------------
function TeamRule.Print()
    Log('TeamRule.Print')
    Dump(RunTimeRule)
end

function TeamRule.PrintCard(pCard, nIndex)
    Log('PrintCard', pCard. nIndex)
end


function TeamRule.ClearSave(nLevelID)
    UE4.UUserSetting.SetString(SAVE_HEAD .. nLevelID, '')
end

-----------------------------////测试/////--------------------


---获取队伍限制信息
---@param nID Integer
function TeamRule.Get(nID)
    return TeamRule.tbTeamRule[nID]
end

---加载队伍规则配置
function TeamRule.LoadCfg()
    local tbFile = LoadCsv("item/formation/teamrule.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID)
        if nId then
            TeamRule.tbTeamRule[nId] = {
                tbTrailRole = {
                     Eval(tbLine.Trail1),
                     Eval(tbLine.Trail2),
                     Eval(tbLine.Trail3),
                },
                
                tbWeaponID = Eval(tbLine.WeaponID),
                tbWeaponBanID = Eval(tbLine.WeaponBanID),

                tbTrailFlag = Eval(tbLine.TrailFlag),
                tbSelfFlag = Eval(tbLine.SelfFlag),

                nAutoAdd = tonumber(tbLine.AutoAdd) or 0,
                nLimit = tonumber(tbLine.Limit) or 3

                }

        end
    end
end

TeamRule.LoadCfg()
