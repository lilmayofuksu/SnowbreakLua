----------------------------------------------------------------------------------
-- @File    : ChessEditor.lua
-- @Brief   : 棋盘编辑器 【客户端用】
----------------------------------------------------------------------------------

---@class ChessEditor 棋盘编辑器
ChessEditor = ChessEditor or {
    tbMapList = nil;            -- 当前模块所有地图列表
    tbGridDef = nil;            -- 当前模块格子定义
    tbItemDef = nil;            -- 当前模块物件定义
    tbMapData = nil;            -- 当前地图数据
    ModuleName = nil;           -- 当前模块名
    tbRewardDef = nil;          -- 奖励定义
    CurrentMapId = 0;           -- 当前地图id
    IsTopUIMode = nil;          -- 是不是在操作top ui
    
    EditorType = "";            -- 当前编辑类型
    tbSnapshoot = {};           -- 快照列表 (用于撤销回退)
    snapIndex = 0;              -- 快照索引
    RegionOffset = nil;         -- 区域坐标偏移
    CurrentGridId = 1;
    CurrentSettingType = 0;     -- 当前配置类型
    SettingUIIsOpen = false;    -- 配置界面是否打开
    tbCurrentInspectorData = nil; -- 当前正在编辑的事件信息
    IsGridHintMode = false;         -- 是不是格子提示模式
    IsOpenSpecialUI = false;        -- 是不是打开了特殊UI
    EnterMenuOrInspector = false;   -- 当前鼠标位置是不是在Inspector或者Menu里面
    tbLayerFlag = {[0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true}; -- layer层默认显示
}

--- 编辑类型 
ChessEditor.EditorTypeRegion = "Region"
ChessEditor.EditorTypeEvent = "Event"
ChessEditor.EditorTypeObject = "Object"
ChessEditor.EditorTypeGround = "Ground"
ChessEditor.EditorTypeHeight = "Height"
ChessEditor.EditorTypeNone = "None"

ChessEditor.KeyRightMouseButton = UE4.UUMGLibrary.GetFKey("RightMouseButton")

----------------------------------------------------------------------------------
--- 设置当前模块
function ChessEditor:SetCurrentModule(moduleName)
    if moduleName ~= UE4.UUserSetting.GetString('ChessEdtorModuleName', "") then 
        UE4.UUserSetting.SetString('ChessEdtorModuleName', moduleName)
        UE4.UUserSetting.Save()    
    end

    self.tbMapList = ChessConfig:GetMapListByModuleName(moduleName) 
    self.tbGridDef = ChessConfig:GetGridDefineByModuleName(moduleName) 
    self.tbItemDef = ChessConfig:GetItemDefineByModuleName(moduleName) 
    self.tbRewardDef = ChessReward:GetRewardsByModuleName(moduleName) 

    self:SetCurrentModelName(moduleName)
end

--- 设置当前地图
function ChessEditor:SetCurrentMap(mapId)
    if mapId ~= UE4.UUserSetting.GetInt('ChessEdtorModuleMapId', 0) then 
        UE4.UUserSetting.SetInt("ChessEdtorModuleMapId", mapId)
        UE4.UUserSetting.Save()    
    end

    for _, tb in ipairs(self.tbMapList) do 
        if tb.Id == mapId then
            -- 删除UI临时数据 
            if tb.tbData then 
                tb.tbData.tbUICfg = {}
            end
            self:SetCurrentMapData(mapId, tb)
            return
        end
    end
    self:SetCurrentMapData(0, {})
    self:SetCurrentRegionId(0)
end

--- 设置当前地图数据 (撤销/回退时需要)
function ChessEditor:ResetCurrentMapData(mapId, tbMapData)
    for idx, tb in ipairs(self.tbMapList) do 
        if tb.Id == mapId then 
            self.tbMapList[idx] = tbMapData
            self:SetCurrentMapData(mapId, tbMapData)
            return
        end
    end
    self:SetCurrentMapData(0, {})
    self:SetCurrentRegionId(0)
end

--- 得到当前模块下所有地图数据
function ChessEditor:GetMapList() return self.tbMapList end

--- 得到当前模块下所有格子定义
function ChessEditor:GetGridDef() return self.tbGridDef end

--- 得到当前模块下所有道具
function ChessEditor:GetItemDef() return self.tbItemDef end

--- 得到当前模块下奖励配置
function ChessEditor:GetRewardDef() return self.tbRewardDef end;

--- 得到一个有效的格子(针对配置发生变化的情况)
function ChessEditor:GetValidObjectId()
    for i, tb in ipairs(self.tbGridDef.tbList) do 
        if tb.Layer >= 2 then 
            return tb.Id;
        end
    end
end

--- 通过格子类型得到格子定义
function ChessEditor:GetGridDefByTypeId(gridTypeId)
    return self.tbGridDef.tbId2Data[gridTypeId]
end

--- 得到区域信息 
function ChessEditor:GetRegionDataById(regionId)
    if self.tbMapData and self.tbMapData.tbData then 
        return self.tbMapData.tbData.tbRegions[regionId]
    end
end

--- 得到物件Id定义
function ChessEditor:GetObjectIdDef() return self.tbMapData.tbData.tbObjectIdDef end

--- 得到物件Tag定义
function ChessEditor:GetTagDef() return self.tbMapData.tbData.tbTagDef end

--- 得到 Event Id 定义
function ChessEditor:GetEventDef() return self.tbMapData.tbData.tbEventDef end

--- 得到 task 定义
function ChessEditor:GetTaskDef() return self.tbMapData.tbData.tbTaskDef end

--- 得到战斗定义
function ChessEditor:GetFightDef() return ChessConfig:GetFightDefineByMoudleName(self.ModuleName) end

--- 得到剧情定义
function ChessEditor:GetPlotDef() return ChessConfig:GetPlotDefineByModuleName(self.ModuleName) end

--- 得到Sequence定义
function ChessEditor:GetSequenceDef() return ChessConfig:GetSequenceDefineByModuleName(self.ModuleName) end

--- 得到特效定义
function ChessEditor:GetParticleDef() return ChessConfig:GetParticleDefineByModuleName(self.ModuleName) end

--- 得到npc定义
function ChessEditor:GetNpcDef() return ChessConfig:GetNpcDefineByModuleName(self.ModuleName) end

----------------------------------------------------------------------------------
--- 得到当前区域信息 
function ChessEditor:GetCurrentRegionData()
    return self:GetRegionDataById(self.CurrentRegionId)
end

--- 是否有数据
function ChessEditor:CheckHasData()
    return self.tbMapData and self.tbMapData.tbData
end

--- 注册hover提示
function ChessEditor:RegisterBtnHoverTip(btn, param, needClear)
    local pOuter = UE4.UUMGLibrary.GetWidgetOuter(btn)
    if btn and pOuter then
        if needClear then 
            btn.OnHovered:Clear()    
            btn.OnUnhovered:Clear()    
        end

        btn.OnHovered:Add(pOuter, function() 
            if type(param) == "string" then 
                EventSystem.Trigger(Event.NotifyChessTipMsg, param) 
            else
                param() 
            end
        end)
        btn.OnUnhovered:Add(pOuter, function() EventSystem.Trigger(Event.NotifyChessTipMsg, "") end)
    end
end

--- 从当前区域开始运行
function ChessEditor:RunFromCurrentRegion()
    ChessClient:LoadMapByMapData(ChessEditor.ModuleName, ChessEditor.tbMapData, self.CurrentMapId, self.CurrentRegionId)
end

--- 从上次区域运行
function ChessEditor:RunFromLastRegion()
    ChessClient:LoadMapByMapData(ChessEditor.ModuleName, ChessEditor.tbMapData, self.CurrentMapId)
end

----------------------------------------------------------------------------------
--- 设置当前选中的格子类型
function ChessEditor:SetCurrentGridId(gridTypeId)
    self.CurrentGridId = gridTypeId;
    EventSystem.Trigger(Event.NotifyChessGridTypeSelected, gridTypeId)
end

--- 设置当前选中的Object
function ChessEditor:SetSelectedObject(type, id)
    local tbRegion = self:GetCurrentRegionData();
    local tb = tbRegion.SelectedObject
    tbRegion.SelectedObject = {}
    EventSystem.Trigger(Event.NotifyChessSelectedObject, tb, false)

    tbRegion.SelectedObject = {type = type, id = id}
    EventSystem.Trigger(Event.NotifyChessSelectedObject, tbRegion.SelectedObject, true)

    if tb and (tb.type ~= type or tb.id ~= id) then 
        self:Snapshoot()
    end
end

--- 更新选中物件显示信息
function ChessEditor:UpdateSelectedObject()
    local tbRegion = self:GetCurrentRegionData();
    if tbRegion.SelectedObject and tbRegion.SelectedObject.type then 
        EventSystem.Trigger(Event.NotifyUpdateChessObject, tbRegion.SelectedObject)
    end
end

--- 清空选择
function ChessEditor:ClearSelectedObject()
    local tbRegion = self:GetCurrentRegionData();
    if tbRegion and tbRegion.SelectedObject and tbRegion.SelectedObject.type then 
        local tb = tbRegion.SelectedObject
        tbRegion.SelectedObject = {}
        EventSystem.Trigger(Event.NotifyChessSelectedObject, tb, false)
        EventSystem.Trigger(Event.NotifyChessSelectedObject, tbRegion.SelectedObject, true)
    end
end

--- 是否选中
function ChessEditor:IsObjectSelected(type, id)
    local tbRegion = self:GetCurrentRegionData()
    return tbRegion.SelectedObject.type == type and tbRegion.SelectedObject.id == id
end

--- 得到事件
function ChessEditor:GetObjectDatas(type, id)
    local tbRegion = self:GetCurrentRegionData()
    local tbData;
    if type == "grid" and tbRegion.tbGround[id] then 
        tbData = tbRegion.tbGround[id].tbData or {}
        tbRegion.tbGround[id].tbData = tbData
    elseif type == "object" and tbRegion.tbObjects[id] then 
        tbData = tbRegion.tbObjects[id].tbData or {}
        tbRegion.tbObjects[id].tbData = tbData
    end
    return tbData;
end

-- 得到模板id
function ChessEditor:GetTplId(type, id)
    local tbRegion = self:GetCurrentRegionData()
    if type == "grid" and tbRegion.tbGround[id] then 
        return tbRegion.tbGround[id].objectId
    elseif type == "object" and tbRegion.tbObjects[id] then 
        return tbRegion.tbObjects[id].tpl
    end
end

--- 删除选中的物件
function ChessEditor:DeleteSelectedObject()
    local tbRegion = self:GetCurrentRegionData();
    local tb = tbRegion.SelectedObject

    local ok = false;
    if tb.type == "grid" and tbRegion.tbGround[tb.id] then 
        if self.EditorType ~= self.EditorTypeNone then 
            tbRegion.tbGround[tb.id] = nil
            ok = true
        else 
            EventSystem.Trigger(Event.NotifyChessErrorMsg, "只读模式不允许删除物件")
        end
    elseif tb.type == "object" and tbRegion.tbObjects[tb.id] then 
        if self.EditorType ~= self.EditorTypeNone then 
            tbRegion.tbObjects[tb.id] = nil
            ok = true
        else 
            EventSystem.Trigger(Event.NotifyChessErrorMsg, "只读模式不允许删除物件")
        end
    end
    if ok then 
        tb.type = nil
        EventSystem.Trigger(Event.NotifyChessUpdateInspector)
        self:Snapshoot()
        EventSystem.Trigger(Event.NotifyChessHintMsg, "删除成功")
        EventSystem.Trigger(Event.NotifyChessRegionRefresh, self.CurrentRegionId)
        EventSystem.Trigger(Event.NotifyChessObjectCountChanged)
    end
end

--- 设置当前正在编辑的模块
function ChessEditor:SetCurrentModelName(moduleName)
    self.ModuleName = moduleName
    EventSystem.Trigger(Event.NotifyChessMoudleChanged, moduleName)
end

--- 设置当前正在编辑的region
function ChessEditor:SetCurrentRegionId(regionId)
    self.CurrentRegionId = regionId
    EventSystem.Trigger(Event.NotifyChessSelectRegion, regionId)

    local tbRegion = self:GetCurrentRegionData();
    if tbRegion and not self.IsGridHintMode then 
        EventSystem.Trigger(Event.NotifyChessSelectedObject, tbRegion.SelectedObject, false)
    end
end

--- 设置编辑类型
function ChessEditor:SetEditorType(type)
    if self.EditorType == type then return end
    self.EditorType = type
    EventSystem.Trigger(Event.NotifyChessEditorTypeChanged, type)
end

--- 创建一个默认区域
function ChessEditor:CreateDefaultRegion(Id, tbList)
    local tbRegion = {
        RangeX = {min = -2, max = 2}, 
        RangeY = {min = -2, max = 2}, 
        Position = {0, 0},
        tbGround = {},
        tbObjects = {},
        SelectedObject = {},
    }
    tbList[Id] = tbRegion

    -- 填充默认地形
    local groundId = self.tbMapData.tbData.DefaultGroundId
    if groundId > 0 then 
        for x = tbRegion.RangeX.min, tbRegion.RangeX.max do 
            for y = tbRegion.RangeY.min, tbRegion.RangeY.max do 
                local gridId = ChessTools:GridXYToId(x, y);
                ChessEditor:SetGroundObjectId(tbRegion, gridId, groundId);
            end
        end
    end
end

--- 设置当前正在编辑的事件信息
function ChessEditor:SetCurrentInspectorData(tbData)
    self.tbCurrentInspectorData = tbData
    EventSystem.Trigger(Event.NotifyChessInspectorUpdate)
end

--- 设置当前配置类型
function ChessEditor:SetCurrentSettingType(type)
    self.CurrentSettingType = type
    EventSystem.Trigger(Event.NotifyChessSettingTypeChanged)
end

--- 设置配置界面是否打开
function ChessEditor:SetSettingUIIsOpen(value)
    self.SettingUIIsOpen = value
    self.IsTopUIMode = value
end

----------------------------------------------------------------------------------
--- load && save
--- 保存
function ChessEditor:Save()
    if not self:CheckHasData() then return end
    if self.IsOpenSpecialUI then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "请关闭当前界面再Save")
    end

    self:SetEditorData(self.tbMapData)
    ChessConfig:SaveMap(self.ModuleName, self.MapId, self.tbMapData)
    EventSystem.Trigger(Event.NotifyChessHintMsg, "保存成功");
end

function ChessEditor:TryAutoSave()
    local tb = self.tbMapData.tbData
    if tb and tb.bAutoSave then
        self:Save()
    end
end

--- 设置编辑器数据
function ChessEditor:SetEditorData(tbMapData)
    local tbData = tbMapData.tbData
    if not tbData then return end

    tbData.CurrentRegionId = self.CurrentRegionId
    tbData.CurrentSettingType = self.CurrentSettingType
    tbData.SettingUIIsOpen = self.SettingUIIsOpen
end

--- 设置当前正在编辑的地图
function ChessEditor:SetCurrentMapData(mapId, tbMapData)
    self.tbMapData = tbMapData;
    ChessConfigHandler:InitData(tbMapData)
    EventSystem.Trigger(Event.NotifyChessExitGridHintMode)
    
    self.MapId = mapId 
    if tbMapData and tbMapData.tbData then 
        local tbData = tbMapData.tbData
        self.CurrentRegionId = tbData.CurrentRegionId
        self.CurrentSettingType = tbData.CurrentSettingType
        self.SettingUIIsOpen = tbData.SettingUIIsOpen
    else
        self.CurrentRegionId = 0;
        self.CurrentSettingType = 0
        self.SettingUIIsOpen = false
    end
    EventSystem.Trigger(Event.NotifyChessMapChanged, mapId) 

    local tbRegion = self:GetCurrentRegionData();
    if tbRegion then 
        EventSystem.Trigger(Event.NotifyChessSelectedObject, tbRegion.SelectedObject)
    end

    EventSystem.Trigger(Event.NotifySetChessMapDataComplete)
end

--- 重新加载地图
function ChessEditor:Reload()
    if not self:CheckHasData() then return end

    if self.IsOpenSpecialUI then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "该界面暂不支持 Reload")
    end

    ChessConfig:ReloadMap(self.ModuleName, self.MapId)
    self:SetCurrentMap(self.MapId)
    EventSystem.Trigger(Event.NotifyChessHintMsg, "重新加载地图");
end

----------------------------------------------------------------------------------
--- redo && undo
--- 撤销 
function ChessEditor:Undo()
    if self.IsGridHintMode then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "该模式暂不支持 撤销/回退")
    end
    if self.IsOpenSpecialUI then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "该界面暂不支持 撤销/回退")
    end
    local tb = self.tbSnapshoot[self.snapIndex - 1]
    if tb then 
        self.snapIndex = self.snapIndex - 1;
        self:ResetCurrentMapData(tb.Id, Copy(tb))
        print("undo ok", self.CurrentRegionId, self.snapIndex, #self.tbSnapshoot);
    end
end

--- 回退
function ChessEditor:Redo()
    if self.IsGridHintMode then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "该模式暂不支持 撤销/回退")
    end
    if self.IsOpenSpecialUI then 
        return EventSystem.Trigger(Event.NotifyChessHintMsg, "该界面暂不支持 撤销/回退")
    end
    local tb = self.tbSnapshoot[self.snapIndex + 1]
    if tb then 
        self.snapIndex = self.snapIndex + 1;
        self:ResetCurrentMapData(tb.Id, Copy(tb))
        print("redo ok", self.CurrentRegionId, self.snapIndex, #self.tbSnapshoot);
    end
end

--- 快照
function ChessEditor:Snapshoot()
    if self.IsGridHintMode then return end
    if not self:CheckHasData() then return end 

    local tbMapData = Copy(self.tbMapData)
    self:SetEditorData(tbMapData)

    for i = #self.tbSnapshoot, self.snapIndex + 1, -1 do 
        table.remove(self.tbSnapshoot, i)
    end
    table.insert(self.tbSnapshoot, tbMapData)
    self.snapIndex = #self.tbSnapshoot

    print("-------------------------------------- Snapshoot", tbMapData.tbData.CurrentRegionId, self.snapIndex)
end

--- 清空快照
function ChessEditor:ResetSnapshoot()
    self.tbSnapshoot = {}
    self.snapIndex = 0
end

----------------------------------------------------------------------------------
--- tool
--- 地图类型转换为可阅读文字
function ChessEditor:MapTypeToTypeName(type)
    if type == "normal" then return "默认" end
    return "默认"
end

--- 地图名字转换为名字 
function ChessEditor:MapTypeNameToType(name)
    if name == "默认" then return "normal" end
    return "normal"
end

--- 得到物件ID描述
function ChessEditor:GetObjectIdDesc(objectId)
    if not objectId or type(objectId) ~= "table" then return "" end
    local tbIdDef = self:GetObjectIdDef()
    local tbName = {}
    for _, id in ipairs(objectId) do 
        local cfg = tbIdDef[id]
        if cfg then table.insert(tbName, cfg.name) end
    end
    return table.concat(tbName, ",")
end 

--- 得到物件tag描述
function ChessEditor:GetObjectTagDesc(tag)
    if not tag or type(tag) ~= "table" then return "" end
    local tbTagDef = self:GetTagDef()
    local tbName = {}
    for _, id in ipairs(tag) do 
        local cfg = tbTagDef[id]
        if cfg then table.insert(tbName, cfg.name) end
    end
    return table.concat(tbName, ",")
end

--- 得到道具名字描述
function ChessEditor:GetItemNameDesc(itemId)
    if not itemId or type(itemId) ~= "table" then return "" end
    local tbDef = self:GetItemDef()
    local tbName = {}
    for _, id in ipairs(itemId) do 
        local cfg = tbDef.tbId2Data[id]
        if cfg then table.insert(tbName, cfg.Name) end
    end
    return table.concat(tbName, ",")
end

--- 得到奖励描述
function ChessEditor:GetRewardNameDesc(rewardId)
    if not rewardId or type(rewardId) ~= "table" then return "" end
    local tbDef = self:GetRewardDef()
    local tbName = {}
    for _, id in ipairs(rewardId) do 
        local cfg = tbDef.tbList[id]
        if cfg then table.insert(tbName, string.format("%d-%s", cfg.Id, cfg.Name)) end
    end
    return table.concat(tbName, ",")
end

--- 得到战斗id描述
function ChessEditor:GetFightIdDesc(fightId)
    if not fightId or type(fightId) ~= "table" then return "" end
    local tbDef = self:GetFightDef()
    local tbName = {}
    for _, id in ipairs(fightId) do 
        local cfg = tbDef.tbId2Data[id]
        if cfg then table.insert(tbName, string.format("%d-%s", cfg.Id, cfg.Name)) end
    end
    return table.concat(tbName, ",")
end

--- 得到剧情id描述
function ChessEditor:GetPlotIdDesc(plotId)
    if not plotId or type(plotId) ~= "table" then return "" end
    local tbDef = self:GetPlotDef()
    local tbName = {}
    for _, id in ipairs(plotId) do 
        local cfg = tbDef.tbId2Data[id]
        if cfg then table.insert(tbName, string.format("%d-%s", cfg.Id, cfg.Name)) end
    end
    return table.concat(tbName, ",")
end

--- 得到特效id描述
function ChessEditor:GetParticleIdDesc(_Id)
    if not _Id or type(_Id) ~= "table" then return "" end
    local tbDef = self:GetParticleDef()
    local tbName = {}
    for _, id in ipairs(_Id) do 
        local cfg = tbDef.tbId2Data[id]
        if cfg then table.insert(tbName, string.format("%d-%s", cfg.Id, cfg.Name)) end
    end
    return table.concat(tbName, ",")
end

--- 得到sequence id描述
function ChessEditor:GetSequenceIdDesc(_Id)
    if not _Id or type(_Id) ~= "table" then return "" end
    local tbDef = self:GetSequenceDef()
    local tbName = {}
    for _, id in ipairs(_Id) do 
        local cfg = tbDef.tbId2Data[id]
        if cfg then table.insert(tbName, string.format("%d-%s", cfg.Id, cfg.Name)) end
    end
    return table.concat(tbName, ",")
end

--- 得到npc id描述
function ChessEditor:GetNpcIdDesc(_Id)
    if not _Id or type(_Id) ~= "table" then return "" end
    local tbDef = self:GetNpcDef()
    local tbName = {}
    for _, id in ipairs(_Id) do 
        local cfg = tbDef.tbId2Data[id]
        if cfg then table.insert(tbName, string.format("%d-%s", cfg.Id, cfg.Name)) end
    end
    return table.concat(tbName, ",")
end

--- 得到格子描述
function ChessEditor:GetGridDesc(value)
    if not value or type(value) ~= "table" then return "" end
    local tbName = {}
    for _, tb in ipairs(value) do 
        local x, y = ChessTools:GridIdToXY(tb[2])
        table.insert(tbName, string.format("(%d,%d,%d)", tb[1], x, y))
    end
    if #tbName > 0 then 
        return table.concat(tbName, ";")
    else 
        return ""
    end
end

--- 得到任务描述
function ChessEditor:GetTaskDesc(id)
    if id then 
        if type(id) == "number" then id = {id} end
        local tbName = {}
        for _, _id in ipairs(id) do 
            local cfg = ChessConfigHandler:GetTaskById(_id)
            if cfg then table.insert(tbName, string.format("(%d - %s)", cfg.tbArg.id, Text(cfg.tbArg.name))) end
        end
        if #tbName > 0 then return table.concat(tbName, ",") end
    end
    return ""
end

--- 得到任务变量描述
function ChessEditor:GetTaskVarDesc(id)
    if id then 
        if type(id) == "number" then id = {id} end
        local tbName = {}
        for _, _id in ipairs(id) do 
            local cfg = ChessConfigHandler:GetTaskVarById(_id)
            if cfg then table.insert(tbName, string.format("(%d - %s)", cfg.id, Text(cfg.name))) end
        end
        if #tbName > 0 then return table.concat(tbName, ",") end
    end
    return ""
end

-- 得到物件Id名
function ChessEditor:GetObjectEventIdName(id)
    if id then 
        if type(id) == "number" then id = {id} end
        local tbEventDef = self:GetEventDef()
        local tbName = {}
        for _, _id in ipairs(id) do 
            local cfg = tbEventDef[_id]
            if cfg then table.insert(tbName, cfg.name) end
        end
        if #tbName > 0 then return table.concat(tbName, ",") end
    end
    return ""
end

-- 得到指定物件id被哪些物件包含
function ChessEditor:GetObjectIdUsed(objectId)
    local tbRet = {}
    ChessTools:ForeachGroundAndObjectDo(self.tbMapData, function(regionId, id, tb)
        if tb.tbData and tb.tbData.id and ChessTools:Contain(tb.tbData.id, objectId) then 
            table.insert(tbRet, {type = "grid", regionId = regionId, id = id})
        end
    end, function(regionId, id, tb)
        if tb.tbData and tb.tbData.id and ChessTools:Contain(tb.tbData.id, objectId) then 
            table.insert(tbRet, {type = "object", regionId = regionId, id = id})
        end
    end)
    return tbRet
end

-- 得到指定tag被哪些物件引用
function ChessEditor:GetObjectIdRefrence(objectId)
    return ChessTools:GetEventArgValueRefrence(self.tbMapData, ChessEvent.InputTypeObjectId, objectId)
end

-- 得到指定物件tag被哪些物件包含
function ChessEditor:GetTagUsed(tagId)
    local tbRet = {}
    ChessTools:ForeachGroundAndObjectDo(self.tbMapData, function(regionId, id, tb)
        if tb.tbData and tb.tbData.tag and ChessTools:Contain(tb.tbData.tag, tagId) then 
            table.insert(tbRet, {type = "grid", regionId = regionId, id = id})
        end
    end, function(regionId, id, tb)
        if tb.tbData and tb.tbData.tag and ChessTools:Contain(tb.tbData.tag, tagId) then 
            table.insert(tbRet, {type = "object", regionId = regionId, id = id})
        end
    end)
    return tbRet
end

-- 得到指定tag被哪些物件引用
function ChessEditor:GetTagRefrence(tagId)
    return ChessTools:GetEventArgValueRefrence(self.tbMapData, ChessEvent.InputTypeTag, tagId)
end

--- 得到指定eventId被哪些事件使用 
function ChessEditor:GetEventUsed(eventId)
    local tbRet = {}
    ChessTools:ForeachEventDo(self.tbMapData, function(regionId, type, id, tbEventData, groupIdx, eventIdx)
        if ChessTools:Contain(tbEventData.id, eventId) then 
            table.insert(tbRet, {type = type, regionId = regionId, id = id, groupIdx = groupIdx, eventIdx = eventIdx})
        end
    end)
    return tbRet
end

--- 得到指定event被哪些事件引用
function ChessEditor:GetEventRefrence(eventId)
    return ChessTools:GetEventArgValueRefrence(self.tbMapData, ChessEvent.InputTypeEvent, eventId)
end

--- 移除所有无效的ground
function ChessEditor:RemoveAllInvalidGround()
    local tbRegion = self:GetCurrentRegionData()
    local minX = tbRegion.RangeX.min; 
    local maxX = tbRegion.RangeX.max;
    local minY = tbRegion.RangeY.min;
    local maxY = tbRegion.RangeY.max;
    for id, _ in pairs(tbRegion.tbGround) do 
        local x, y = ChessTools:GridIdToXY(id)
        if x < minX or x > maxX or y < minY or y > maxY then 
            tbRegion.tbGround[id] = nil
        end
    end
end

----------------------------------------------------------------------------------
--- 接口封装
--- 设置地形数据
function ChessEditor:SetGroundObjectId(tbRegion, gridId, objectId)
    if objectId == nil then 
        tbRegion.tbGround[gridId] = nil
    else
        -- 默认没有tbEvents字段，因为只有地形格子有事件
        tbRegion.tbGround[gridId] = tbRegion.tbGround[gridId] or {}
        tbRegion.tbGround[gridId].objectId = objectId
    end
end

--- 得到地形数据
function ChessEditor:GetGroundObjectId(tbRegion, gridId)
    local tb = tbRegion.tbGround[gridId]
    if tb then 
        return tb.objectId
    end
    return 0
end

-- 得到地块数据
function ChessEditor:GetGroundByGridId(gridId)
    local tbRegion = self:GetCurrentRegionData()
    return tbRegion.tbGround[gridId]
end

--- 创建一个物件信息
function ChessEditor:NewObjectData(typeId, x, y)
    -- 默认没有tbEvents字段，因为只有部分物件有事件
    return {tpl = typeId, pos = {x, y}};
end
----------------------------------------------------------------------------------