-------------------------------------------------------------------------------------------------------
--
-- 道具产出途径注册
--
-------------------------------------------------------------------------------------------------------
DropWay.tbClasses = {};

local tbBase = {};

local RegisterDropWay = function ( szType )
	local tbClass = {};
	tbClass.szType = szType;
	setmetatable(tbClass, { __index = tbBase});
	DropWay.tbClasses[szType] = tbClass;
	return tbClass;
end

------------------------------------------------- 基类 ------------------------------------------------
do
	-- 是否解锁
	function tbBase:IsUnlock( )
		return true;
	end

	-- 检测是否能参加该途径(包括是否解锁、是否未开启、是否已经完成)
	function tbBase:CheckOpen( )
		return true;
	end

	-- 检测该途径是否已经完成 (如果完成了，可能需要隐藏)
	function tbBase:IsComplete( )
		return false;
	end

	-- 检测该途径需打开哪个界面
	function tbBase:OpenUI(tbArg)
	end

	-- 得到title
	function tbBase:GetPrefix()
		return Text(self:GetConfig().prefix);
	end

	-- 得到排序优先级
	function tbBase:GetOrder()
		return self:GetConfig().order;
	end

	-- 得到掉落配置
	function tbBase:GetConfig()
		if not self.cfg then
			self.cfg = DropWay.tbSetting[self.szType]
		end
		return self.cfg;
	end

	-- 得到掉落详情
	function tbBase:GetDropInfo(g, d, p, l, count)
		return nil;
	end

	function tbBase:GetFormat()
		return Text(self:GetConfig().format);
	end

	-- 是否可以跳转过去
	function tbBase:CanJumpTo(tb)
		local cfg = self:GetConfig()
		return cfg.canJumpTo;
	end

	function tbBase:GetPreFormat()
		return ''
	end
end


------------------------------------------ 单机关卡掉落 ------------------------------------------
do
	local tbClass = RegisterDropWay("single_level");
	function tbClass:OpenUI(tbArg)
		print("open ui chapter", tbArg.levelId, tbArg.diff);
		local bMain = true
		local nDifficult = tbArg.diff
		local nChapterID = tbArg.chapterId
		local tbParam = {levelId = tbArg.levelId}
		if UI.IsOpen("level") then
			UI.Close("level")
		end
		UI.Open("level", bMain, nDifficult, nChapterID, tbParam)
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		local tb = ChapterLevel.GetDropWay(g, d, p, l, count)
		table.sort(tb, self.pSort);

		for i, data in ipairs(tb) do
			data.tbArgs = {levelId = data.nID, chapterId = data.chapterId, diff = data.diff }
		end
		return tb;
	end

	function tbClass.pSort(a, b)
		if a.isUnlock == b.isUnlock then
			if a.isComplete == b.isComplete then
				if a.chapterId == b.chapterId then
					if a.isUnlock then
						return a.diff > b.diff;
					else
						return a.diff < b.diff;
					end
				else
					if a.isUnlock then
						return a.chapterId > b.chapterId;
					else
						return a.chapterId < b.chapterId;
					end
				end
			else
				return not a.isComplete;
			end
		else
			return a.isUnlock;
		end
	end

	function tbClass:GetFormat(tbArg)
		if not tbArg or not tbArg.levelId then
			return ''
		end
		return GetLevelName(ChapterLevel.Get(tbArg.levelId))
	end

	function tbClass:GetPreFormat(tbArg)
		if not tbArg or not tbArg.levelId then
			return ''
		end
		if tbArg.diff == 2 then
			return Text('drop.chapterhard')
		else
			return ''
		end
	end

	function tbClass:IsUnlock(tbArg)
		local levelId = tbArg and tbArg.levelId
		local tbCfg = ChapterLevel.Get(levelId)
		if not tbCfg then return false; end
		local bUnLock, tbDes = Condition.Check(tbCfg.tbCondition)
	     return bUnLock;
	end
end


------------------------------------------ 曜日本掉落 ------------------------------------------
do
	local tbClass = RegisterDropWay("daily_level");
	function tbClass:OpenUI(tbArg)
		Launch.SetType(LaunchType.DAILY)
		Daily.SetChapterID(tbArg.chapterId)
		Daily.SetLevelID(tbArg.levelId)
		local TopUI = UI.GetTop()
		if UI.IsOpen("DungeonsSmap") then
			UI.Close("DungeonsSmap")
		end
		UI.Open('DungeonsSmap', tbArg.activityId)
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		local tb = DailyChapter.GetDropWay(g, d, p, l, count)
		for i, data in ipairs(tb) do
			local dailyCfg = Daily.GetCfgByID(data.activityId)
			data.isUnlock = dailyCfg:IsOpen();
			data.tbArgs = {levelId = data.levelId, chapterId = data.chapterId, activityId = data.activityId }
		end
		return tb;
	end

	function tbClass:GetFormat(tbArg)
		if not tbArg or not tbArg.levelId then
			return ''
		end
		return string.format(Text(self:GetConfig().format),tbArg.levelId)
	end

	function tbClass:CheckOpen(tbArg)
		local cfg = Daily.GetCfgByID(tbArg.activityId)
		return cfg.Logic.IsOpen(cfg)
	end

	function tbClass:IsUnlock(tbArg)
		local cfg = Daily.GetCfgByID(tbArg.activityId)
		return Condition.Check(self.tbCondition)
	end
end


------------------------------------------ 碎片本掉落 ------------------------------------------
do
	local tbClass = RegisterDropWay("role_level");
	function tbClass:OpenUI(tbArg)
		local _, _, _, ChapterCfg = table.unpack(tbArg)
		Launch.SetType(LaunchType.ROLE)
		if UI.IsOpen("DungeonsRoleMap") then
			UI.Close("DungeonsRoleMap")
		end
        UI.Open("DungeonsRoleMap", ChapterCfg)
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		return Role.GetDropWay(g, d, p, l, count)
	end

	function tbClass:GetFormat(tbArg)
		local diff, roleId = table.unpack(tbArg)
		local roleName = Role.GetRoleName(roleId)
		return string.format(Text(self:GetConfig().format), roleName)
	end

	function tbClass:CanJumpTo(tb)
		return tb.isUnlock
	end

	function tbClass:IsUnlock(tbArg)
		local _, _, _, ChapterCfg = table.unpack(tbArg)
		local bUnLock = Condition.Check(ChapterCfg.tbCondition) and FunctionRouter.IsOpenById(21)
		return bUnLock;
	end
end

------------------------------------------ boss挑战 ------------------------------------------
do
	local tbClass = RegisterDropWay("boss");
	function tbClass:OpenUI(tbArg)
		print("boss", tbArg.id)
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		for i, tb in ipairs(BossLogic.tbAwardCfg) do
			for _, gdpl in ipairs(tb.tbScoreAward) do
				if gdpl[1] == g and gdpl[2] == d and gdpl[3] == p and gdpl[4] == l then
					return {{tbArgs = {id = i}}}
				end
			end
		end
	end
end

------------------------------------------ climbtower掉落 ------------------------------------------
do
	local tbClass = RegisterDropWay("climbtower");
	function tbClass:OpenUI(tbArg)
		print("climbtower", tbArg.id)
	--	UI.Open('DungeonsSmap', tbArg.activityId)
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		local diff = ClimbTowerLogic.GetLevelDiff()
		local num1 = #ClimbTowerLogic.GetAllLayerTbLevel(1)
		for i, tb in ipairs(ClimbTowerLogic.tbAwardConf) do
			local tbAward = nil
			if i > num1 then
				tbAward = tb[diff]
			else
				tbAward = tb[1]
			end
			if tbAward then
				for _, gdpls in ipairs(tbAward.tbStarAward) do
					for _, gdpl in ipairs(gdpls) do
						if gdpl[1] == g and gdpl[2] == d and gdpl[3] == p and gdpl[4] == l then
							return {{tbArgs = {id = i}}}
						end
					end
				end
			end
		end
	end
end

-------------------------------------------- 抽奖Gacha --------------------------------------------
do
	local tbClass = RegisterDropWay("gacha");
	function tbClass:OpenUI(tbArg)
		if UI.GetUI('Gacha') then
			UI.Close('Gacha')
		end
		UI.Open('Gacha', tbArg.id)
	end

	function tbClass:CheckPool(cfg, g, d, p, l)
		for _, sName in ipairs(cfg.tbPool or {}) do
            local tbPoolCfg = Gacha.GetPoolCfg(sName)
            if tbPoolCfg then
                for _, tbPoolItem in pairs(tbPoolCfg) do
                	local gdpl = tbPoolItem.tbGDPL
                    if gdpl[1] == g and gdpl[2] == d and gdpl[3] == p and gdpl[4] == l then
                        return true
                    end
                end
            end
        end
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		local tb = {}
		for i, cfg in ipairs(Gacha.tbGacha) do
			if cfg:IsInTime() and self:CheckPool(cfg, g, d, p, l) then
				table.insert(tb, {tbArgs = {id = i, name = Text(string.format("gacha.%s_name", cfg.sDes))}})
			end
		end
		return tb
	end

	function tbClass:GetFormat(tbArg)
		if not tbArg or not tbArg.name then
			return ''
		end
		return string.format(Text(self:GetConfig().format),tbArg.name)
	end

	-- 是否解锁
	function tbClass:IsUnlock(tbArg)
		local cfg = Gacha.GetCfg(tbArg and tbArg.id or -1)
		if cfg and cfg:IsOpen() then
			return FunctionRouter.IsOpenById(FunctionType.Welfare)
		end
		return false;
	end
end

--------------------------------------------- 商店掉落 -------------------------------------------
--[[do
	local tbClass = RegisterDropWay("shop");
	-- 是否解锁
	function tbClass:IsUnlock()
		local bOpen, szMsg = SystemUnlock:GetUnlock("UI_UnlockShop");
		return bOpen, szMsg;
	end

	function tbClass:OpenUI(tbArg)
		local ShopId = tbArg[2]
		if ShopId == ShopData.CafeShopId then
			UI.CloseAll();
			UI.Open('UI_Player')
			UI.Open('UI_NCafeShop')
		else
			ShopId = ShopTabLogicC:GetShopId(ShopId);
			local bOpen, szMsg = ShopTabLogicC:CheckShopLock(ShopId);
			if bOpen then
				UI.CloseAll();
				UI.Open('UI_Player')
				UI.Open('UI_ShopNew', ShopId);
			else
				Game.MessageBox.Simple(szMsg);
			end
		end
	end

	function tbClass:GetDropInfo(g, d, p, l, count)
		-- local tb = GoodsLogicC:GetDropInfo(g, d, p, l, count);
		local tbRet = {};
		-- for i = 1, #tb do
		-- 	local one = tb[i]
		-- 	if ShopTabLogicC:GetShopTabCfg(one.tbArg[2]) and ShopTabLogicC:CheckShopOpen(one.tbArg[2]) then
		-- 		table.insert(tbRet ,{
		-- 			name = string.format(self:GetConfig().format, ShopTabLogicC:GetShopTabCfg(one.tbArg[2]).Name);
		-- 			desc = string.format("商店类型:%d id:%d", one.tbArg[1], one.tbArg[2]);
		-- 			isFixed = false;
		-- 			tbArgs = one.tbArg;
		-- 			isUnlock = true;
		-- 			isComplete = false;
		-- 		});
		-- 	end
		-- end
		return tbRet;
	end
end]]