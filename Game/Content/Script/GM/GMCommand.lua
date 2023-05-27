-- ========================================================
-- @File    : GMCommand.lua
-- @Brief   : 新GM类
-- ========================================================

GMCommand = GMCommand or {}
local tbClass = GMCommand

function tbClass:Init()
	self.tbTypes = {}
	require 'GM.GMCommandRegister'
end

--注册指令类别
function tbClass:AddCommand(category,name,tb)
	if not self.tbCommands[category] then
		self.tbCommands[category] = {}
		self.tbCategory[#self.tbCategory + 1] = category;
	end
	self.tbCommands[category][#self.tbCommands[category] + 1] = {name = name,tb = tb}
	--[[if not self.tbCommands_sort[category] then
		self.tbCommands_sort[category] = {}
	end
	self.tbCommands_sort[category][#self.tbCommands_sort[category] + 1] = {name = name,tb = tb}]]
end

--取得所有指令
--return: tb = {key:category,value:{name,tbCommands}}
function tbClass:GetAllCommand()
	return self.tbCommands;
end

--取得所有分类
function tbClass:GetAllCategory()
	return self.tbCategory;
end

---设置当前指令类型
function tbClass:SetType(typeName)
	self.typeName = typeName
	local tb = self.tbTypes[typeName] or {tbCommands = {}, tbCategory = {}}
	self.tbTypes[typeName] = tb

	self.tbCommands = tb.tbCommands
	self.tbCategory = tb.tbCategory
end

---得到当前指令类型
function tbClass:GetType() 
	return self.typeName
end

function tbClass:AddEventHandle(EventId,Func)
	if not self.EventHandle then
		self.EventHandle = {}
	end
	self:RemoveEventHandle(EventId)
	self.EventHandle[EventId] = EventSystem.On(EventId,Func)
end

function tbClass:RemoveEventHandle(EventId)
	if self.EventHandle[EventId] then
		EventSystem.Remove(self.EventHandle[EventId]);
		self.EventHandle[EventId] = nil
	end
end

tbClass:Init()
return tbClass;