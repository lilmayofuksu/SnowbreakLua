----------------------------------------------------------------------------------
-- @File    : ChessConfigHandler.lua
-- @Brief   : 棋盘配置数据管理接口（编辑器配置数据）
-- 由于lua数据结构非常复杂，所以统一对数据的操作（包括读取和设置），方面维护和阅读
----------------------------------------------------------------------------------

---@class ChessConfigHandler 棋盘配置数据管理接口
ChessConfigHandler = ChessConfigHandler or {}

-- 私有变量
local tbMapConfigData = {}      -- 地图配置数据

----------------------------------------------------------------------------------
--[[
地图配置数据格式 = 
{
    Name = "map001",            -- 地图名
    Width = 100,                -- 地图总宽度
    Height = 100,               -- 地图总高度
    Type = "normal",            -- 地图类型
    Scale = 1,                  -- 地图编辑器缩放
    CurrentRegionId = 1,        -- 当前正在编辑的区域ID
    CurrentSettingType = 1,     -- 当前配置类型
    SettingUIIsOpen = false,    -- 配置界面是否打开
    MaxObjectId = 0,            -- 最大ObjectId
    DefaultGroundId = 0,        -- 默认地形
    bAutoSave = false,          -- 是否运行时自动保存
    tbUICfg = {                 -- ui临时数据相关
    },
    tbObjectIdDef = {           -- 地图物件id定义，顺序列表 (object id增加后就不允许删除，不然顺序就错了)
        {name = name, desc = desc}  -- id名，id描述
    },
    tbTagDef = {                -- 地图物件tag定义，顺序列表 (tag增加后就不允许删除，不然顺序就错了)
        {name = name, desc = desc}  -- tag名，tag描述
    },                            
    tbEventDef = {                -- 地图事件id定义，顺序列表 (event id增加后就不允许删除，不然顺序就错了)
        {name = "12", desc = desc, max = 1} -- 事件名，事件描述，事件最大触发次数
    },    
    tbTaskDef = {                   -- 地图任务定义
        {                           -- 第一个任务
            tbArg = {               -- 任务参数
                id = 1,             -- 任务id
                name = "任务名",
                select = true,      -- 是否选中
                trace = true,       -- 是否追踪
                main = true,        -- 是否主线
                time = 30,          -- 时间限制30秒
                rewardId = 1,       -- 奖励id 1
            },
            tbContent = {
                desc = "",          -- 任务描述
            },
            tbCondition = {         -- 任务触发条件，可以有多个
                {
                    id = ChessEvent.DefaultCondition,   -- 条件类型
                    tbParam = {},                       -- 条件参数
                },
            },
            tbTaskComplete = {          -- 任务完成条件
                {
                    taskId = 0,         -- 任务变量id
                    type = 0,           -- 变量比较类型：等于固定值，大于固定值，小于固定值，等于最大值，等于最小值，等于变量值，大于变量值，小于变量值
                    destValue = 0;      -- 参数，如果是（等于变量值，大于变量值，小于变量值，则这里填写变量id）
                },
            },
            tbTaskBegin = {        -- 任务开始事件，可以有多个行为，程序依次执行（支持各种wait）（有一个专门的类来执行这一系列Action，方面后面扩展，比如添加跳转逻辑）
                {
                    id = 1,                             -- 行为类型
                    tbParam = {}                        -- 行为参数
                },                                            
            },
            tbTaskEnd = {          -- 任务成功事件，可以有多个行为，程序依次执行（支持wait）
                {
                    id = 1,                             -- 行为类型
                    tbParam = {}                        -- 行为参数
                },                                            
            },
            tbTaskFail = {         -- 任务失败事件，可以有多个行为，程序依次执行（支持wait）
                {
                    id = 1,                             -- 行为类型
                    tbParam = {}                        -- 行为参数
                },                                            
            },
        },                       
    },
    tbTaskVarDef = {                    -- 任务变量定义，类型数组
        {       
            id = 1,                     -- id，名字，初始值，最大值，最小值 
            name = "",
            init = 0,
            max = 0,
            min = 0,
        }
    },
    tbArtDef = {                -- 美术物件定义
        art_ids = {"资源路径1", "资源路径2"}, -- 美术资源id
        art_list = {                     -- 美术资源列表
            {
                id = 1,                  -- 资源id，见art_ids中的索引
                pos = {x, y, z},         -- 位置
                rotate = {x, y, z},      -- 旋转
                scale = {x, y, z},       -- 缩放
            },
        },
        logic = {                        -- 对逻辑物件的修改
            [1] = {                      -- 区域1
                tbGround = {[1] = {height = 0.5, rotate = 10}}      -- 设置地表的高度和旋转
                tbObjects = {[1] = {height = 0.5, rotate = 10}}     -- 设置物件的高度和旋转
            }
        },
    },
    tbRegions = {               -- 区域列表（区域Id最多不超过9）
        [1] = {
            RangeX = {min = -5, max = 5},               -- 区域范围X
            RangeY = {min = -5, max = 5},               -- 区域范围Y
            Position = {x,y,z},                         -- 区域世界坐标
            CanvasPosition = {x,y},                     -- 编辑器中坐标     
            CanvasScale = 1,                            -- 编辑中区域缩放 
            Rotation = 90,                              -- 区域旋转
            SelectedObject = {type = type, id = id}    -- 设置当前选中的object类型，以及id（type为ground或者object）

            -- 地面
            tbGround = {              
                [id1] = {objectId = 1, tbData = {}},         -- 格子编号1 -> {objectId = 地面Id1, tbData = {tbGroups={事件列表}}}
                [id2] = {objectId = 2, tbData = {}},         -- 格子编号2 -> {objectId = 地面Id2, tbData = {tbGroups={事件列表}}}
            },

            -- 物件Id，Id不重复(Id -> 数据)
            tbObjects = {
                [1] = { 
                    index = 1,      -- 存档索引（从1递增，最多不超过100，只有动态物件才有存档索引）
                    tpl = 1000,     -- 模板id
                    pos = {1,2},    -- 位置
                    tbData = {
                        tag = {1,2},        -- 物件tag列表
                        id = {1},           -- 物件唯一id
                        height = 0,         -- 额外偏移
                        hide = false,       -- 是否默认隐藏
                        classArg = {},      -- classArg 类型参数
                        angle = 90,
                        tbGroups = {                -- 事件组
                            {
                                expand = false,     -- 是否展开
                                tbEvents = {        -- 事件列表
                                    {
                                        expand = false,     -- 是否展开
                                        id = 1,             -- 事件Id
                                        tbCondition = {     -- 事件条件，可以有多个
                                            {
                                                id = ChessEvent.DefaultCondition,   -- 条件类型
                                                tbParam = {},                       -- 条件参数
                                            },
                                        },
                                        tbTiming = {
                                            id = ChessEvent.DefaultTiming,      -- 时机类型    
                                            tbParam = {}                        -- 时机参数
                                        },
                                        tbAction = {        -- 事件行为，可以有多个
                                            {
                                                id = 1,                             -- 行为类型
                                                tbParam = {}                        -- 行为参数
                                            },                                            
                                        }
                                    },
                                    {
                                        -- 其他事件
                                    }
                                }
                            },
                            {
                                -- 其他group
                            }
                        }
                    },   -- 事件列表
                }       
            },
        }
    }
}    
--]]

----------------------------------------------------------------------------------

---初始化数据
---@param tbMapConfigData 地图配置数据
function ChessConfigHandler:InitData(_tbMapConfigData)
    tbMapConfigData = _tbMapConfigData
end

---清空数据
function ChessConfigHandler:ClearAllData()
    tbMapConfigData = nil
end

--- 校正地图数据
function ChessConfigHandler:FixMapData(tbData)
    tbData.PathType = tbData.PathType or 1
    tbData.Scale = tbData.Scale or 1
    tbData.CharacterScale = tbData.CharacterScale or 1
    tbData.MaxObjectId = tbData.MaxObjectId or 0
    tbData.Type = tbData.Type or "normal"
    tbData.tbRegions = tbData.tbRegions or {}
    tbData.tbTagDef = tbData.tbTagDef or {}
    tbData.tbEventDef = tbData.tbEventDef or {}
    tbData.tbObjectIdDef = tbData.tbObjectIdDef or {}
    tbData.tbTaskDef = tbData.tbTaskDef or {}
    tbData.tbTaskVarDef = tbData.tbTaskVarDef or {}
    tbData.DefaultGroundId = tbData.DefaultGroundId or 0
    tbData.bAutoSave = tbData.bAutoSave or false
    tbData.tbUICfg = tbData.tbUICfg or {}
end

--- 得到临时UI保存数据
function ChessConfigHandler:GetTempUICfg()
    return tbMapConfigData.tbData.tbUICfg
end

--- 得到物件Tag定义
function ChessConfigHandler:GetTagDef() 
    return tbMapConfigData.tbData.tbTagDef 
end

--- 得到任务定义
function ChessConfigHandler:GetTaskDef()
    return tbMapConfigData.tbData.tbTaskDef 
end

--- 得到任务定义
function ChessConfigHandler:GetTaskById(id)
    local tbList = self:GetTaskDef()
    for _, tb in ipairs(tbList) do 
        if tb.tbArg.id == id then 
            return tb
        end
    end
end

--- 得到任务变量定义列表
function ChessConfigHandler:GetTaskVarDef()
    return tbMapConfigData.tbData.tbTaskVarDef;
end

--- 得到任务变量定义
function ChessConfigHandler:GetTaskVarById(id)
    local tbList = self:GetTaskVarDef()
    for _, tb in ipairs(tbList) do 
        if tb.id == id then 
            return tb
        end
    end
end

--- 创建新的task
function ChessConfigHandler:CreateTask(id)
    return {
        tbArg = { id = id, name = "任务名", trace = true },
        tbContent = {},
        tbTaskComplete = {},
        tbCondition = {},
        tbTaskBegin = {},
        tbTaskEnd = {},
        tbTaskFail = {},
    }
end

--- 创建新的任务变量
function ChessConfigHandler:CreateTaskVar(id)
    return {
        id = id,
        name = "",
        init = 0,
        max = 99,
        min = 0,
    }
end

--- 得到任务的前置任务id
function ChessConfigHandler:GetTaskPreTaskId(tbTask)
    for _, tbCondition in ipairs(tbTask.tbCondition) do 
        if tbCondition.id == "OnPreTaskId" then 
            return tbCondition.tbParam.preTaskId;
        end
    end
end

-- 得到所有主线任务
function ChessConfigHandler:GetAllMainTask()
    local tbList = {}
    for _, tb in ipairs(self:GetTaskDef()) do 
        if tb.tbArg.main and tb.tbArg.trace then 
            table.insert(tbList, tb)
        end
    end 
    return tbList
end

-- 得到所有支线任务
function ChessConfigHandler:GetAllSubTask()
    local tbList = {}
    for _, tb in ipairs(self:GetTaskDef()) do 
        if not tb.tbArg.main and tb.tbArg.trace then 
            table.insert(tbList, tb)
        end
    end 
    return tbList
end

--------------------------------------------------------------------------
--- 保存棋盘美术场景
function ChessConfigHandler:SaveChessArt(gameMode)
    ChessTools:ShowTip("暂时禁用运行时 场景保存 功能，请在编辑器下编辑场景。", true)
    do return end

    local AllActor = gameMode:GetAllChessActor();
    local tbArtDef = {art_ids = {}, art_list = {}, logic = {}}
    local getResId = function(path)
        for id, name in ipairs(tbArtDef.art_ids) do 
            if name == path then 
                return id
            end
        end
        table.insert(tbArtDef.art_ids, path)
        return #tbArtDef.art_ids
    end
    local to_number_table = function(value1, value2, value3)
        value1 = value1 * 10000;
        value2 = value2 * 10000;
        value3 = value3 * 10000;

        value1 = math.floor(value1 + 0.1);
        value2 = math.floor(value2 + 0.1);
        value3 = math.floor(value3 + 0.1);
        return {value1 * 0.0001, value2 * 0.0001, value3 * 0.0001}
    end

    for i = 1, AllActor:Length() do 
        local actor = AllActor:Get(i);
        if actor:IsArtActor() and actor.IsPlacementByArt then 
            actor = actor:Cast(UE4.AChessArtActor)
            local data = {}
            local location = actor:K2_GetActorLocation()
            local rotation = actor:K2_GetActorRotation();
            local scale = actor:GetActorScale3D()
            data.id = getResId(actor:GetResPath());
            data.pos = to_number_table(location.X, location.Y, location.Z)
            data.rotate = to_number_table(rotation.Pitch, rotation.Yaw, rotation.Roll)
            data.scale = to_number_table(scale.X, scale.Y, scale.Z)
            table.insert(tbArtDef.art_list, data)
        else 
           --  
        end
    end

    --Dump(tbArtDef)
    ChessConfig:SaveArtMap(ChessEditor.ModuleName, ChessEditor.MapId, tbArtDef)
    EventSystem.Trigger(Event.NotifyChessHintMsg, "保存成功");
end
--------------------------------------------------------------------------