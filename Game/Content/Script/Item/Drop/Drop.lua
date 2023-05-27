-------------------------------------------------------------------------
--
-- 掉落
--
-------------------------------------------------------------------------
Drop = {};


--- 得到掉落预览
function Drop.GetPreview(dropId)
	local tbItems = {}
	local tbDrop = Drop.tbDrop[dropId]
	if not tbDrop then return tbItems end

	for _, tb in ipairs(tbDrop) do 
		local groupId = tb[1]
		local tbGroup = Drop.tbDropGrop[groupId]
		if tbGroup then 
			for _, group in ipairs(tbGroup) do 
				local gdpl, weight, num, effectId = table.unpack(group);
				if gdpl and num then 
					table.insert(tbItems, {gdpl[1], gdpl[2], gdpl[3], gdpl[4], num})
				end
			end
		end
	end
	return tbItems;
end


--- 加载掉落配置
function Drop.LoadCfg()
	Drop.tbDrop = {}
	Drop.tbDropGrop = {}

    ---加载掉落表
    local tbFile = LoadCsv('drop/drop.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0;
        if nId > 0 then
        	Drop.tbDrop[nId] = Eval(tbLine.Drop) or {}
        end
    end
    
    ---加载掉落组合表
    local tbFile = LoadCsv('drop/drop_grop.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0;
        if nId > 0 then
        	Drop.tbDropGrop[nId] = Eval(tbLine.Grop) or {}
        end
    end
end

--- 奖励显示
s2c.Register("drop.do.rsp", function (tbParam)
	if tbParam and tbParam.tbItem then 
    	Item.Gain(tbParam.tbItem)
    end
end)

---掉落调试使用
s2c.Register('TestDrop_Gm', function(tbData)
    local allNum = tbData.nSumRandTime
    local nSumPickTimes = 0
    local sShowTxt = string.format('DropGroupID: %s , 总随机次数: %s',tbData.nDropID,tbData.nSumRandTime).. '\n'
    for sGDPL,v in pairs(tbData.tbItems or {}) do
    	sShowTxt = sShowTxt .. string.format('GDPL: %s  数量：%s 掉落次数:%s 概率为: %s', sGDPL, v.nNum, v.nPickTimes,v.nPickTimes / allNum) .. '\n'
    	nSumPickTimes = nSumPickTimes + v.nPickTimes
	end
	sShowTxt = sShowTxt .. string.format('总掉落次数：%s',nSumPickTimes) .. '\n'
    UE4.UGameLibrary.SaveFile('DropTest.txt', sShowTxt)
    print("已保存到 /Content/DropTest.txt")
end)

Drop.LoadCfg()