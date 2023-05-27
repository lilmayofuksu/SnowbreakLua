-- ========================================================
-- @File    : Model.lua
-- @Brief   : Lua数据层
-- @Usage   : 用于ListView等需要传UObject，同时又只有Lua逻辑时
--            不需要建uasset，只需要写相应逻辑
-- ========================================================

---数据模型基类
---@class ModelLogic
ModelLogic = ModelLogic or {};

---实例化时调用
---@param vParam any 初始化参数，多个时使用table
function ModelLogic:OnInit(vParam) end

---Factory生成的实例
---@class ModelInstance
---@field Data any 简单数据模型中直接数据
---@field Logic ModelLogic 文件定义的数据模型存放
local ModelInstance = nil;

---实体对象生成器
---@class ModelFactory
---@field pOuter UE4.UObject 用于实例所有对象的Outer属性
---@field Template table Lua逻辑模板
ModelFactory = ModelFactory or {};

---实例化一个对象
---@param vParam any 实例化需要的参数，多个参数需要以Table打包
---@return ModelInstance 实例化的/Game/Blueprints/LuaModel
function ModelFactory:Create(vParam)
    local pClass    = LoadClass('/Game/Blueprints/LuaModel.LuaModel_C');
    local pObject   = NewObject(pClass, self.pOuter);

    if self.Template then
        pObject.Logic = Inherit(self.Template);
        pObject.Logic:OnInit(vParam);
    else
        pObject.Data = vParam or {};
    end

    return pObject;
end

---数据层接口
---@class Model
Model = Model or {};

---声明一个模型
---@return ModelLogic 返回一个默认的实现，可以复写
function Model.Class()
    return Inherit(ModelLogic);
end

---取得数据对象生成器，通常在OnInit中执行一次
---@param pOuter UE4.UObject 实例的Outer属性
---@param vModule string|table Lua对象定义文件或Table，不传时直接使用传入值
---@return ModelFactory 返回一个用于创建实体对象的Factory
function Model.Use(pOuter, vModule)
    local tbFactory = Inherit(ModelFactory);
    tbFactory.pOuter = pOuter;

    if not vModule then return tbFactory end;

    if type(vModule) == 'string' then
        tbFactory.Template = require(vModule);
    elseif type(vModule) == 'table' then
        tbFactory.Template = vModule;
    end

    return tbFactory;
end

