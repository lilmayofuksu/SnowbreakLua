-- ========================================================
-- @File    : RedPoint.lua
-- @Brief   : 红点处理
-- ========================================================
---@class RedPoint 红点管理
---@field rootNode table 根节点
---@field tbCacheNode table 缓存的节点
RedPoint = RedPoint or {rootNode = nil, tbCacheNode = {}}

local ROOT_NODE = "Main" ---根节点

---@class RedPointType
RedPointType = {}
---邮件
RedPointType.Mail               = 1     ---主界面邮件

---商店
RedPointType.Shop               = 10    ---主界面商店

---出击
RedPointType.Launch             = 20    ---主界面出击
RedPointType.Chapter            = 21    ---出击章节
RedPointType.ChapterItem        = 22    ---章节条目
RedPointType.StarAward          = 23    ---章节星级奖励
RedPointType.PlotLevel          = 24    ---剧情关卡奖励


RedPointType.Role               = 30    ---角色
RedPointType.RoleItem           = 31    ---角色条目
RedPointType.WeaponPage         = 32    ---武器页签
RedPointType.ChangeWeaponBtn    = 33    ---更换武器按钮
RedPointType.NewWeapon          = 34    ---新武器提示
RedPointType.RoleItemBtn        = 35    ---角色养成Btn
RedPointType.RoleItemPage       = 36    ---角色系统养成页签



RedPointType.Question           = 50    ---问卷
RedPointType.Notice             = 51    ---公告
RedPointType.NoticeActive       = 52    ---活动公告
RedPointType.NoticeSystem       = 53    ---系统公告

---红点配置信息
local RedPointCfg = {
    ---邮件
    -- [RedPointType.Mail]             = "Main-Mail",
    
    -- ---商店
    -- [RedPointType.Shop]             = "Main-Shop", 

    ---出击
    [RedPointType.Launch]           = "Main-Launch",
    [RedPointType.Chapter]          = "Main-Launch-Chapter",
    [RedPointType.ChapterItem]      = "Main-Launch-Chapter-Item_M",
    [RedPointType.StarAward]        = "Main-Launch-Chapter-Item_M-StarAward",
    [RedPointType.PlotLevel]        = "Main-Launch-Chapter-Item_M-PlotLevel_M",

    ---角色
    [RedPointType.Role]             = "Main-Role",
    [RedPointType.RoleItem]         = "Main-Role-RoleItem_M",
    [RedPointType.RoleItemBtn]      = "Main-Role-RoleItem_M-RoleSysBtn_M",
    [RedPointType.RoleItemPage]     = "Main-Role-RoleItem_M-RoleSysBtn-RolePage_M",
    [RedPointType.WeaponPage]       = "Main-Role-RoleItem_M-WeaponPage",
    [RedPointType.ChangeWeaponBtn]  = "Main-Role-RoleItem_M-WeaponPage-ChangeWeaponBtn",
    [RedPointType.NewWeapon]        = "Main-Role-RoleItem_M-WeaponPage-ChangeWeaponBtn-NewWeapon_M",
    
    ---问卷
    [RedPointType.Question]         = "Main-Question",
    ---公告
    [RedPointType.Notice]           = "Main-Notice",
    [RedPointType.NoticeActive]     = "Main-Notice-Active",
    [RedPointType.NoticeSystem]     = "Main-Notice-System",
}

---设置红点数量
---@param nType RedPointType 红点类型
---@param nNum integer 数量
---@param sTag string 标记 （有多个条目时进行条目标记，无多个时可以不传）
function RedPoint.SetRedNum(nType, nNum, sTag)
    if sTag ~= nil then sTag = tostring(sTag) end
    local node = RedPoint.GetLeafNode(nType)
    if node then node:SetNum(nNum, sTag) end
end

---获取红点节点
---@param nType RedPointType
---@return RedNodeTemplate
 function RedPoint.GetLeafNode(nType)
    if RedPoint.tbCacheNode[nType] then return RedPoint.tbCacheNode[nType] end
end

local function CheckTag(sTag)
    sTag = (sTag == nil) and 'default' or sTag
    sTag = type(sTag) == 'string' and sTag or tostring(sTag)
    return sTag
end

local function TrimLastTag(str, chr)
    local tb = Split(str, chr)
    local rstr = ''
    for i = 1, #tb - 1 do
        rstr = tb[i] .. chr
    end
    return string.sub(rstr, 1, -2)
end

---@class RedNodeTemplate 红点节点模板
---@field sName string 节点名称
---@field parent table 父节点
---@field tbChild table 子节点
---@field tbInfo table 红点数据
---@field bMultiTag boolean 是否是多标记节点
local RedNodeTemplate = {
    ---设置红点变化事件
    SetChangeEvent = function(self, sTag, fEvent)
        local tag = CheckTag(sTag)
        self.tbInfo[tag] =  self.tbInfo[tag] or {}
        self.tbInfo[tag].fChangeEvent = fEvent
    end,

    ---设置红点数量
    SetNum = function(self, nNum, sTag)
        local tag = CheckTag(sTag)
        self.tbInfo[tag] =  self.tbInfo[tag] or {}
        local nOld = self.tbInfo[tag].nNum or 0
        if nOld ~= nNum then
            self.tbInfo[tag].nNum = nNum
            self:__Change(tag)
            if self.parent then
                self.parent:Update(tag, nNum - nOld, self.bMultiTag)
            end
        end 
    end,

    ---获取红点数量
    GetTagNum = function(self, sTag)
        if self.tbInfo[sTag] then return self.tbInfo[sTag].nNum or 0 end
        return 0
    end,

    ---获取节点的红点数量
    GetTotalNum = function(self)
        local nNum = 0
        for _, value in pairs(self.tbInfo or {}) do
            nNum = nNum + (value.nNum or 0)
        end
        return nNum
    end,

    ---更新红点数量
    Update = function(self, sTag, nAddNum, bMulti)
        local tag = 'default'
        if bMulti then
            tag = TrimLastTag(sTag, '-')
            if tag == '' then tag = 'default' end
        else
            tag = sTag
        end
        local nNewNum = self:GetTagNum(tag) + nAddNum
        self:SetNum(nNewNum, tag)
    end,

    ---红点变化通知
    __Change = function(self, sTag)
        if self.tbInfo[sTag] and self.tbInfo[sTag].fChangeEvent then
            --print('Notify Num Change :', self.sName, sTag, self:GetTagNum(sTag))
            self.tbInfo[sTag].fChangeEvent(self:GetTagNum(sTag))
        end
    end,
}

---构建红点节点模板
local function NewRedNodeTemplate(sName, parent)
    local tbNode = {Logic = RedNodeTemplate, sName = sName, parent = parent, tbChild = nil, tbInfo = {}, bMultiTag = false}
    setmetatable(tbNode, {
        __index = function(tb, key)
            local v = rawget(tb, key);
            return v or tb.Logic[key];
        end
    });
    return tbNode
end

---初始化红点配置
function RedPoint.Init()
    RedPoint.rootNode = NewRedNodeTemplate(ROOT_NODE, nil)
    for nType, sValue in pairs(RedPointCfg) do
        local redNode = RedPoint.rootNode
        local tbTreeNode = Split(sValue, "-")
        if tbTreeNode[1] == ROOT_NODE then
            local nLength = #tbTreeNode
            if nLength > 1 then
                for i = 2, nLength do
                    local sNodeName = tbTreeNode[i]
                    redNode.tbChild = redNode.tbChild or {}
                    if not redNode.tbChild[sNodeName] then
                        redNode.tbChild[sNodeName] = NewRedNodeTemplate(sNodeName, redNode)
                    end
                    redNode = redNode.tbChild[sNodeName]
                end
                local sName = redNode.sName
                local sEnd = '_M'
                if string.sub(sName , -string.len(sEnd)) == sEnd then
                    redNode.bMultiTag = true
                else
                    redNode.bMultiTag = false
                end
                RedPoint.tbCacheNode[nType] = redNode
            end
        end
    end
end

-- 清空红点数据缓存
function RedPoint.Clear()
    RedPoint.rootNode = nil
    RedPoint.tbCacheNode = {}
    RedPoint.Init()
end

---输出节点信息
function RedPoint.Dump(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    elseif type(val) == "function" then
                        
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

---输出红点信息
---@param nType RedPointType 类型
function RedPoint.Print(nType)
    ---@type RedNodeTemplate
    local dumpTb = RedPoint.tbCacheNode[nType]
    if not dumpTb then return end
    local fPrint = nil
    ---@param node RedNodeTemplate
    fPrint = function(node)
        print('节点信息:' , node.sName, node:GetTotalNum())
        for tag, value in pairs(node.tbInfo or {}) do
            print('\t\t\t\tTag:', tag, value.nNum)
        end
        for _, value in pairs(node.tbChild or {}) do
            fPrint(value)
        end
    end
    fPrint(dumpTb)
end

RedPoint.Init()
