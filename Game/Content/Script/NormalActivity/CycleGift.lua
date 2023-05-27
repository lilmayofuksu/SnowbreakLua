--周期 付费礼包 (十日自动发放礼包)
CycleGiftLogic = {}

function CycleGiftLogic:LoadConfig()
	self.tbConfig = {};
	local tbPreCfg = nil
	local tbFile = LoadCsv('normalactivity/cyclegiftlist.txt', 1);
	for _, tbLine in ipairs( tbFile ) do
		local nId = tonumber( tbLine["Id"] ) or -1;
		if nId >= 0 then
			local tb = {};
			tb.Id = nId;
			tb.Day = tonumber( tbLine["Day"] )
			tb.MailSender = tbLine["MailSender"] or "System"
			tb.MailTitle = tbLine["MailTitle"] or "System"
			tb.MailContent = tbLine["MailContent"] or "Content"
			tb.LimitDay = tonumber( tbLine["LimitDay"] ) or 0

			tb.tbAward = Eval(tbLine.AwardList) or {}

			local bAdd = false
			if not tb.Day then
				print_err("CycleGiftLogic Load Error", nId)
			else
				if tb.Day == 0 and tb.LimitDay > 0 then
					bAdd = true
				elseif tb.Day > 0 and tbPreCfg and tbPreCfg.Id == tb.Id and tbPreCfg.LimitDay > 0 then
					bAdd = true
				end
			end

			if bAdd then
				if tb.Day == 0 then
					tbPreCfg = tb
				elseif tbPreCfg.Id == tb.Id then
					if not tbPreCfg.MaxDay or tbPreCfg.MaxDay < tb.Day then
						tbPreCfg.MaxDay = tb.Day
					end
				end

				local tbDayList = self.tbConfig[nId]
				if not tbDayList then
					self.tbConfig[nId] = {}
					tbDayList = self.tbConfig[nId]
				end

				tbDayList[tb.Day or 999] = tb
			end
		end
	end
end

function CycleGiftLogic:GetConfig(nId)
	if not nId then return end

	return self.tbConfig[nId]
end

--返回 立即获得 和 每日获得的物品列表
function CycleGiftLogic:GetCycleItemList(tbItemInfo)
	if not tbItemInfo then return end
	
    local tbConfig = CycleGiftLogic:GetConfig(tbItemInfo.Param1)
    if not tbConfig then 
        return
    end

    local  tbNowList  = nil
    local tbDailyList = nil
    if tbConfig[0] and tbConfig[0].tbAward then
        tbNowList = tbConfig[0].tbAward
    end

    if tbConfig[1] and tbConfig[1].tbAward then --默认每天一样
        tbDailyList = tbConfig[1].tbAward
    end

    return tbNowList,tbDailyList    
end

------------------------------------- 初始化 -------------------------------------

CycleGiftLogic:LoadConfig()