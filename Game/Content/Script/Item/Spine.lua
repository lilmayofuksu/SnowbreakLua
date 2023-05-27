-- ========================================================
-- @File    : Spline.lua
-- @Brief   : 脊柱数据管理层
-- ========================================================

---@class SplineData 角色卡突破管理

Spine = Spine or {
    tbMasterNode = {},
    tbSpineLayout = {}
}

---GId-记录当前正在通导的大节点
Spine.GId = 81

--- 脊椎最大的主节点数量
Spine.MaxMastNum = 6

--- 脊椎最大的子节点数量
Spine.MaxSubNum = 9

--开始通导时显示弹窗提示
Spine.ShowActiveTip = true
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if not bReconnected and not Spine.ShowActiveTip then
        Spine.ShowActiveTip = true
    end
end)

--- 父子脊椎节点状态
Spine.MAndCState = {
    None = 1,
    Master = 2,
    Child = 3
}
--- 子节点数据Type
Spine.DataType=
{
    TypeSkill=1,
    TypeCond=2,
    TypeMat=3
}

Spine.NodeCate = {
    Node_Small = 1,
    Node_Big   = 2,
}

--- 脊椎主节点激活
Spine.ActiveMNode = "ON_ACTIVED_MNODE"

--- 子节点激活，刷新当前主节点，子节点信息
Spine.UpDataNode = "UPDATA_ACTIVED_HANDLE"

--- 拖拽
Spine.OnDrag = "DRAG_HANDLE"
--- 
Spine.UnDrag = "UN_DRAG_HANDLE"

--- 脊椎当前的解锁进度
Spine.ActivedProgress = {MastId= 1,SubId = 0}

--- 当前可激活节点
Spine.ActivedIdx = 1

--- 当前主界面动画状态1:打开，2:复原
Spine.pMasterAnim = 1

--- 播放节点预览动画
Spine.ShowPreviewNote = "SHOW_PREVIEW_NODE_ANIM"

--- 进度重置
Spine.ResetProgressHandle = "RESET_PROGRESS_HANDLE"

--- 场景特效
Spine.WorldNiagaraPlayHandle = "WORLD_NIAGARA_HANDLE"

--- 节点点亮界面特效
Spine.NoteActivedFinishHandle = "NOTE_ACTIVED_FINISH"
--- 节点状态
NodeState = {
    Lock = 1, -- 当前锁定状态
    PreActive = 2, -- 当前预激活状态
    OnActive = 3, -- 当前激活状态
    Actived = 4 -- 当前已激活状态
}

--角色神经专属道具
Spine.tbExItem = {}
Spine.tbExItem["5-9-2-2"] = 1
Spine.tbExItem["5-9-2-3"] = 2

--- 获取正在通导的阶段
function Spine.GetRecordIndx(CardID)
    local v = me:GetAttribute(Spine.GId, CardID)
    return GetBits(v, 0, 8)
end

--- 获取专属道具数量
function Spine.GetItemNum(CardID)
    local v = me:GetAttribute(Spine.GId, CardID)
    return {GetBits(v, 9, 18), GetBits(v, 19, 28)}
end

--- 获取专属道具数量
function Spine.GetItemNumByGDPL(CardID, G, D, P, L)
    local v = me:GetAttribute(Spine.GId, CardID)
    local index = Spine.tbExItem[table.concat({G, D, P, L}, "-")]
    if index == 1 then
        return GetBits(v, 9, 18)
    end
    if index == 2 then
        return GetBits(v, 19, 28)
    end
    return 0
end

--- 主节点是否解锁
---@param InItem UItem 需培养的卡
---@param InIndex integer 主节点的位置
function Spine.MasterUnLock(InItem, InIndex)
    local tbInfo = Spine.tbKeyId[InItem:SpineId()]
    if not tbInfo then
        return false
    end

    local condid = tbInfo[0]
    if not condid then
        return true
    end


    local nLv = InItem:EnhanceLevel()
    local tbReq = Spine.tbSpineCond[condid][InIndex]
    if tbReq and tbReq[1] and tbReq[1][1] == 1 then
        return nLv >= tbReq[1][2]
    end

    return false
end

--- 获取已经激活子节点数
---@param InNode integer 已激活子节点位置
function Spine.CheckChildNode(tbActived, Num)
    table.insert(tbActived, Num)
end

--- 获取子节点进度
function Spine.GetChildNodeBar(InItem, Indx)
    local tbHasActived = {}
    for i = 1, 10 do
        if InItem:GetSpine(Indx, i) then
            table.insert(tbHasActived, i)
        end
    end
    return tbHasActived
end

--- 主节点解锁条件判定
function Spine.CheckPreNode(InItem, tbCond)
   if not tbCond then return true end
    for key, value in pairs(tbCond) do
        if key > 1 and value then
            local tbHasActived = Spine.GetChildNodeBar(InItem, key)
            if value > #tbHasActived then
                -- print('value',value)
                UI.ShowTip("tip.pre_unlocking_condition_is_not...")
                return false
            end
        end
    end
    return true
end

function Spine.GetNoteType(InIdx)
    if InIdx == Spine.MaxSubNum then
        return Spine.NodeCate.Node_Big
    end
    return Spine.NodeCate.Node_Small
end

--- 检查等级
---@param InItem UItem 角色卡
---@param tbCond table 条件列表
---@return boolean 检查结果
function Spine.CheckLv(InItem, tbCond)
    if type(tbCond[1]) == "table" then
        if tbCond[1][2] > InItem:EnhanceLevel() then
            return false
        end
    end
    return true
end
----------------------------------

--- 主节点解锁条件，子节点预览条件
---@param InKeyId integer 主节点Id
---@return table 等级，前置主节点进度
function Spine.GetSpineId(InKeyId)
    local tbSpineCond = Spine.tbSpineCond[InKeyId]
    return tbSpineCond
end

-- 角度
function Spine.SetAngle(InFv2D)
    local fvNormalized = UE4.UKismetMathLibrary.Normal2D(InFv2D)
    local Xaxis = UE4.FVector2D()
    local fDot = 0
    local fAngle = 0
    if InFv2D.X >= 0 then
        Xaxis = UE4.FVector2D(-1, 0)
        fDot = UE4.UKismetMathLibrary.DotProduct2D(fvNormalized, Xaxis)
        if InFv2D.Y >= 0 then
            fAngle = 180 - math.deg(math.acos(fDot))
        else
            fAngle = math.deg(math.acos(fDot))
        end
    else
        Xaxis = UE4.FVector2D(1, 0)
        fDot = UE4.UKismetMathLibrary.DotProduct2D(fvNormalized, Xaxis)
        if InFv2D.Y >= 0 then
            fAngle = math.deg(math.acos(fDot))
        else
            fAngle = 180 - math.deg(math.acos(fDot))
        end
    end
    return fAngle
end

--- 获取主节点进度
function Spine.GetProgresNum(InCard)
    local num = 1
    if not InCard then return num end
    for i = 1, Spine.MaxMastNum do
        if InCard:GetSpine(i, Spine.MaxSubNum) then
            num = num + 1
        end
    end
    return math.min(num, Spine.MaxMastNum)
end

--- 检查神经进化材料
function Spine.CheckMat(InMasterId, InSubId, pItem)
    local tbMaterials = Spine.tbSpineNodeCond[InMasterId][InSubId].NodeCost
    if not tbMaterials then
        print('cfg err')
        return false
    end

    local tbNum = {}
    if pItem then
        tbNum = Spine.GetItemNum(pItem:Id())
    end
    for k, v in pairs(tbMaterials) do
        if v[5] > me:GetItemCount(v[1], v[2], v[3], v[4]) + (tbNum[k] or 0) then
            return false
        end
    end
    return true
end
------------------------------------
--- 主节点解锁请求
Spine.MasterUnLockCallBack = nil
function Spine.Req_MasterNode(tbData, InCallback)
    --- 检查当前角色卡有效
    local pItem = tbData.InItem
    if not pItem then
        return UI.ShowTip("tip.rolecard_error.")
    end
    --- 检查升星(取nSpine)
    local nSpine = 10001
    local SpineFrameId = Spine.tbKeyId[nSpine][Spine.GetProgresNum(pItem)].SpcondId
    local tbSpineCond = Spine.tbSpineNodeCond[SpineFrameId][tbData.NodeId].NodeCondition
    --- 等级检查
    if not Spine.CheckLv(pItem, tbSpineCond) then
        UI.ShowTip('tip.lv_lower')
        return
    end

    --- 前置解锁条件检查
    if not Spine.CheckPreNode(pItem, tbSpineCond) then
        UI.ShowTip('tip.pre_node_condition_fail')
        return
    end

    local cmd = {
        pId = tbData.InItem:Id(),
        NodeId = tbData.NodeId
    }
    Spine.MasterUnLockCallBack = InCallback
    me:CallGS("GirlSpine_MasterUnlock", json.encode(cmd))
end

s2c.Register(
    "GirlSpine_MasterUnlock",
    function()
        if Spine.MasterUnLockCallBack then
            Spine.MasterUnLockCallBack()
            Spine.MasterUnLockCallBack = nil
        end
    end
)
--- 子节点解锁条件判断
function Spine.CheckChildCond(InItem, tbCond, InMastId)
    if tbCond then
        for key, value in pairs(tbCond) do
            if key > 1 then
                local bActived = InItem:GetSpine(InMastId, value[2])
                if not bActived then
                    return false
                end
            end
        end
    end
    return true
end

--- 子节点解锁请求
Spine.ChildUnlockCallBack = nil
---@param InItem UItem 角色卡
---@param NodeInfo table 解锁节点的父子节点信息
function Spine.Req_ChildNode(InData, InCallback)
    local pItem = InData.pItem
    if not pItem then
        return UI.ShowTip('Data_Item_Error')
    end
    -- 检查角色卡是否有效
    if not me:GetItem(pItem:Id()) then
        return UI.ShowTip("tip.RoleSpine_not")
    end

    --- 是否已经解锁
    if pItem:GetSpine(InData.MastIdx, InData.SubIdx) then
        return UI.ShowTip("tip.girlcard_alread_break")
    end

    -- 需解锁的子父节点信息
    local tbNodeInfo = {
        Indx = InData.MastIdx,
        InSubIdx = InData.SubIdx
    }
    local SpineId = pItem:SpineId()
    local SPId = Spine.tbKeyId[SpineId][Spine.GetProgresNum(pItem)].SpcondId
    local tbNodeCond = Spine.tbSpineNodeCond[SPId][InData.SubIdx].NodeCondition

    --- 检查等级
    if not Spine.CheckLv(pItem, tbNodeCond) then
        UI.ShowTip('tip.lv_lower')
        return
    end

    --- 检查该主节点的前置节点（同一条线上的前置）
    if not Spine.CheckChildCond(pItem, tbNodeCond, InData.MastIdx) then
        UI.ShowTip("tip.pre_node_condition_fail")
        return
    end

    --- 检查材料
    if not Spine.CheckMat(SPId, InData.SubIdx, pItem) then
        return UI.ShowTip("tip.not_material")
    end
    local tbMaterials = Spine.tbSpineNodeCond[SPId][InData.SubIdx].NodeCost

    -- if tbMaterials then
    --     for k, v in pairs(tbMaterials) do
    --         local nMat = me:GetItemCount(v[1], v[2], v[3], v[4])
    --         if nMat < v[5] then
    --             return UI.ShowTip("tip.not_material")
    --         end
    --     end
    -- else 
    --     return
    -- end

    local cmd = {
        pId = pItem:Id(),
        tbInfo = tbNodeInfo,
        tbMat = tbMaterials,
        tbMasterList = Spine.FilterUnlockMasterAllCards(),
    }
    Spine.ChildUnlockCallBack = InCallback
    UI.ShowConnection()
    me:CallGS("GirlSpine_ChildUnLock", json.encode(cmd))
end

s2c.Register("GirlSpine_ChildUnLock", function()
    UI.CloseConnection()
    if Spine.ChildUnlockCallBack then
        Spine.ChildUnlockCallBack()
        Spine.ChildUnlockCallBack = nil
    end
end)

---重置子节点解锁
function Spine.Req_ChildNodeReset(pItem, InCallback)
    if not pItem then
        return
    end

    Spine.ChildNodeResetCallBack = InCallback
    me:CallGS("GirlSpine_ChildNodeReset", json.encode({pId = pItem:Id()}))
    UI.ShowConnection()
end
s2c.Register("GirlSpine_ChildNodeReset", function(tbParam)
    UI.CloseConnection()
    if Spine.ChildNodeResetCallBack then
        Spine.ChildNodeResetCallBack()
        Spine.ChildNodeResetCallBack = nil
    end
    if tbParam and tbParam.tbItem then
        Item.Gain(tbParam.tbItem)
    end
end)

---------------LOAD-------------
--- 脊椎及其条件索引Id
function Spine.LoadSplineData()
    ---神经配置
    Spine.tbKeyId = {}
    local tbData = LoadCsv("item/skill/spine.txt", 1)
    for key, tbLine in pairs(tbData) do
        local Id = tonumber(tbLine.ID)
        if Id then
            Spine.tbKeyId[Id] = {}
            Spine.tbKeyId[Id][0] = tonumber(tbLine.SpineReq)
            for i = 1, Spine.MaxMastNum do
                Spine.tbKeyId[Id][i]=
                {
                    SpId = tonumber(tbLine['Spine'..i]) or nil,
                    SpDes = tonumber(tbLine["Spine"..i.."Des"]) or 0,
                    SpcondId = tonumber(tbLine['Node'..i..'Req']) or nil,
                }
            end
        end
    end
end
--- 脊柱养成条件
function Spine.LoadSpineCond()
    ---大节点解锁条件
    Spine.tbSpineCond = {}
    local tbData = LoadCsv("item/skill/spinecondition.txt", 1)
    for key, tbLine in pairs(tbData) do
        local Id = tonumber(tbLine.ID)
        if Id then
            Spine.tbSpineCond[Id] = {}
            for i = 1, Spine.MaxMastNum do
                Spine.tbSpineCond[Id][i] = Eval(tbLine['Req'..i])
            end
        end
    end
end

--- 节点解锁条件和消耗
function Spine.LoadSpineNodeCond()
    ---节点解锁条件和消耗和返还
    Spine.tbSpineNodeCond = {}
    local tbData = LoadCsv("item/skill/nodecondition.txt", 1)
    for key, tbLine in pairs(tbData) do
        local Id = tonumber(tbLine.ID)
        if Id then
            Spine.tbSpineNodeCond[Id] = {}
            for i = 1, Spine.MaxSubNum do
                Spine.tbSpineNodeCond[Id][i] = {
                    --消耗
                    NodeCost = Eval(tbLine['Node'..i..'Cost']),
                    --返还
                    NodeRefund = Eval(tbLine['Node'..i..'Refund']),
                    --要求
                    NodeCondition = Eval(tbLine['Node'..i..'Condition']),
                }
            end
        end
    end
end

--- 脊柱节点配置
function Spine.LoadSpineNode()
    ---脊柱节点配置
    Spine.tbSpineNode = {}
    local tbData = LoadCsv("item/skill/spinenode.txt", 1)
    for key, tbLine in pairs(tbData) do
        local Id = tonumber(tbLine.ID)
        if Id then
            Spine.tbSpineNode[Id] = {}
            for i = 1, 10 do
                local tbSkillId = nil
                if tonumber(tbLine['SkillIDs'..i]) then
                    tbSkillId = {}
                    tbSkillId[1] = tonumber(tbLine['SkillIDs'..i])
                else
                    tbSkillId = Eval(tbLine['SkillIDs'..i])
                end
                Spine.tbSpineNode[Id][i]=
                {
                    Nodedes = tonumber(tbLine['Node'..i..'des']) or nil,
                    tbSkillId = tbSkillId,
                    Skilfix = tonumber(tbLine['Node'..i]),
                    AttributeID = Eval(tbLine['Attribute'..i]),
                }
            end
        end
    end
end

function Spine.LoadMasterLayout()
    local tbData = LoadCsv("item/spine/spinemaster.txt", 1)
    for key, tbLine in pairs(tbData) do
        local Id = tonumber(tbLine.ID)
        Spine.tbMasterNode[Id] ={}
        for i = 1, 5 do
            Spine.tbMasterNode[Id][i]=
            {
                tblayout = Eval(tbLine['Note'..i]) or nil
            }
        end
    end
    -- Dump(Spine.tbMasterNode)
end

function Spine.LoadChildLayout()
    local tbData = LoadCsv("item/spine/spinelayout.txt", 1)
    for key, tbLine in pairs(tbData) do
        local Evol = tonumber(tbLine.Evolution)
        Spine.tbSpineLayout[Evol] = {}
        for i = 1, 10 do
            Spine.tbSpineLayout[Evol][i]=
            {
                tblayout = Eval(tbLine['Spine'..i]) or nil
            }
        end
    end
    -- Dump(Spine.tbSpineLayout)
end
--- 节点分数(暂定记录个数)
function Spine.LoadNodeScore()
    -- body()
end

--筛选所有完成至少1个大节点的角色卡
function Spine.FilterUnlockMasterAllCards()
    local tbList = {}
    local allCard = me:GetCharacterCards()
    for i = 1, allCard:Length() do
        local pCard = allCard:Get(i)
        if pCard and Spine.GetProgresNum(pCard) > 0 then
            table.insert(tbList, pCard:Id())
        end
    end

    return tbList
end

function Spine._OnInit()
    Spine.LoadSplineData()
    Spine.LoadSpineCond()
    Spine.LoadSpineNodeCond()
    Spine.LoadSpineNode()
    Spine.LoadMasterLayout()
    Spine.LoadChildLayout()
end
Spine._OnInit()

return Spine
