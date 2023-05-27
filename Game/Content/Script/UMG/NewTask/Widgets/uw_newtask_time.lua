-- ========================================================
-- @File    : umg_newtask_time.lua
-- @Brief   : 新手7天乐子时间widget
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
	
end

--param:secs秒数
function tbClass:SetTime(secs)
	if not secs then
		return
	end
	if secs < 0 then
		secs = 0
	end
	local hourNum = math.floor(secs / 3600)
	local minNum = math.floor(math.fmod(secs,3600) / 60)
	if hourNum ~= self.hourNum or minNum ~= self.minNum then
		local str = string.format(Text("ui.TxtDungeonsTowerTime2"),hourNum,minNum)
		self.TxtTime:SetText(str);
		self.hourNum = hourNum;
		self.minNum = minNum;
	end
end


return tbClass;