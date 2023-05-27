DropWay = {};

require 'Item.DropWay.DropWayRegister'


----------------------------------------------- 公有接口 ----------------------------------------------
---得到道具的掉落途径
---@param gdpl 道具gdpl, 格式为lua table，如{1,1,1,1}
---@param needCount 需要的道具数量
---@return table 返回具体的掉落途径信息，如果table长度为0 表示没有任何地方有掉落
function DropWay.GetWays(gdpl, needCount)
	--gdpl = {5, 4, 8, 1}
	local tbWays = {};
	local g, d, p, l = table.unpack(gdpl);
	needCount = needCount or 1

	for type, tbClass in pairs(DropWay.tbClasses) do 
		local tbInfo = tbClass:GetDropInfo(g, d, p, l, needCount) or {};
		if tbInfo and #tbInfo > 0 then 
			for idx, data in ipairs(tbInfo) do 
				tbWays[#tbWays + 1] = {
					['order'] 		= tbClass:GetOrder();
					['index']		= idx;
					['prefix']		= tbClass:GetPrefix();
					['name']		= data.name or "";
					['isUnlock']	= tbClass:IsUnlock(data.tbArgs);								-- 活动是否解锁
					['isOpen']		= tbClass:CheckOpen(data.tbArgs);								-- 活动是否开启
					['isComplete']	= data.isComplete or tbClass:IsComplete();			-- 活动是否完成
					['openUI']		= function() 										-- 点击开启
						local unlock, msg = tbClass:IsUnlock(data.tbArgs);
						if not unlock then 
							return UI.ShowTip(msg);
						end
						tbClass:OpenUI(data.tbArgs) 
					end;	
					['RikiTip'] = data.RikiTip or nil;
					['canJumpTo'] = tbClass:CanJumpTo(data);
					['format'] = tbClass:GetFormat(data.tbArgs);
					['preFormat'] = tbClass:GetPreFormat(data.tbArgs) or ''
				};
			end
		end
	end
	table.sort(tbWays, function(a, b)
		if a.isOpen == b.isOpen then
			if a.isComplete == b.isComplete then 
				if a.isUnlock == b.isUnlock then 
					if a.order == b.order then 
						return a.index < b.index;
					else 
						return a.order < b.order 
					end
				else 
					return a.isUnlock; 
				end
			else
				return not a.isComplete;
			end
		else 
			return a.isOpen;
		end
	end);

	return tbWays;
end


---打开目标UI
---@param target 目标名，可能是某个UI名，也可能是一个特殊的字符串，具体看DropWayTargetUI.lua
---@param tbParam 打开目标UI需要的参数
---@return bool 返回是否需要切换场景
function DropWay.OpenTargetUI(target, tbParam)
	if not target then return end;

	local handler = DropWay.tbTargetUIHandler[target];
	assert(handler, string.format("没有在DropWayTargetUI.lua中注册目标UI类型: %s", target));
	return handler(tbParam);
end

--在一个Scroll中生成掉落条目
--@param scroll:Scroll控件
--@param factory:生成掉落cfg对应的UObject的工具类
--@param gdpl:道具GDPL
--@param uiClass:原UI的UObject*
function DropWay.ShowWaysOnUI(tbClass, scroll, factory, gdpl, uiClass, needCount)
	local self = DropWay;
	if not scroll or not gdpl or not factory then return end;
	needCount = needCount or 1
	uiClass = uiClass or scroll
	local tbWays = self.GetWays(gdpl,needCount)
	if not tbWays or #tbWays == 0 then
		--print tip
		return false
	end
	tbClass:DoClearListItems(scroll)
	for i,way in ipairs(tbWays) do
		local obj = factory:Create(way)
		scroll:AddItem(obj)
	end
	--[[scroll.BP_OnItemClicked:Add(uiClass, function(pList, pItem) 
		if pItem.pItem and pItem.pItem.openUI then
			pItem.pItem.openUI()
		end
	end)]]
	return true;
	--self.PanelItem:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

----------------------------------------------- 配置加载 ----------------------------------------------
function DropWay:Init() 
	self.tbSetting = {};
	local tbFile = LoadCsv("item/dropway/dropway.txt", 1);
	for i, info in ipairs(tbFile) do
		local type = info.Type;
		if type and type ~= "" then 

			assert(not self.tbSetting[type], string.format("重复的掉落类型: %s, 文件 item/dropway/dropway.txt", type));

			self.tbSetting[type] = 
			{	
				order 	= i;
				prefix 	= info.Prefix;
				format 	= info.Format;
				canJumpTo = tonumber(info.CanJumpTo or 1) == 1
			};		
		end
	end
end

DropWay:Init();

------------------------------------------------- end -------------------------------------------------