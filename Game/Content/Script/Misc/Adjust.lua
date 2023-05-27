-- ========================================================
-- @File    : Adjust.lua
-- @Brief   : 打点功能
-- ========================================================
Adjust = Adjust or {}
--task group
Adjust.nGroupId = 107
---taskid
Adjust.nGachaWeaponId = 1 --单次武器扭蛋次数
Adjust.nMallBuyId = 2 --首次购买

--普通打点
function Adjust.DoRecord(sId)
    if type(sId) ~= "string" or sId == "" then return end

    --打点
    UE4.UAdjustReporter.TrackEvent(sId);
end

--主界面打点
function Adjust.MainRecord()
    if GuideLogic.nGuideId == 10011 and GuideLogic.nStepId == 1 then
        Adjust.DoRecord("tjdu02")
    end
end

--共鸣界面打点
function Adjust.GachaMainRecord()
    if GuideLogic.nGuideId == 10162 and GuideLogic.nStepId == 1 then
        Adjust.DoRecord("gg7jg8")
    end
end

--共鸣行为打点
function Adjust.GachaRecord(nId, nTime)
    if type(nId) ~= "number" or type(nTime) ~= "number" then return end
    local tbConfig = Gacha.GetCfg(nId)
    if not tbConfig then return end

    if tbConfig.tbTag[1] == 1 then --角色池子
        if nTime == 10 then
            Adjust.DoRecord("ml38rw")
            --新手40次池子
            if tbConfig:IsNewPool() and tbConfig:GetTotalTime() % 40 == 0 then
                Adjust.DoRecord("twmh91")
            end
        end
    elseif tbConfig.tbTag[1] == 2 then --武器池子
        if nTime == 10 then
            Adjust.DoRecord("lj20rx")
        else --单抽10次记录
            local nTime = me:GetAttribute(Adjust.nGroupId, Adjust.nGachaWeaponId)
            if nTime % 10 == 0 then
                Adjust.DoRecord("yjqgqg")
            end
        end
    end
end

--供应站购买成功打点
function Adjust.MallRecord(sProductId)
    if not sProductId then return end

    local tbConfig = IBLogic.GetIBConfig(sProductId)
    if not tbConfig then return end

    if tbConfig.nType == IBLogic.Type_IBMoney then --充值
        Adjust.DoRecord("ef197x")
        local tbPrice = IBLogic.GetRealPrice(tbConfig)
        if tbPrice and tbPrice[1] == Cash.MoneyType_RMB and tbPrice[2] == 648 then
            Adjust.DoRecord("6t4zmu")
        end
    elseif tbConfig.nType == IBLogic.Type_IBMonth then --月卡
        Adjust.DoRecord("8jf1j9")
    elseif tbConfig.nType == IBLogic.Type_IBSkin then --皮肤
        Adjust.DoRecord("hdvhmn")
    elseif tbConfig.nType == IBLogic.Type_IBBP then --bp
        Adjust.DoRecord("mpxjax")
    end
end

--关卡打点
function Adjust.ChapterRecord(tbLevelCfg)
    if type(tbLevelCfg) ~= "table" then return end

    if tbLevelCfg.nID == 10106 and tbLevelCfg:IsPass() then
        Adjust.DoRecord("yfzli0")
    elseif tbLevelCfg.nID == 10108 and tbLevelCfg:IsPass() then
        Adjust.DoRecord("uyyh3f")
    end
end

--天启激活
function Adjust.ChapterBreakRecord(nBreak)
    if type(nBreak) ~= "number" then return end
    if nBreak == RBreak.NBreakLv then 
        Adjust.DoRecord("3ibuge")
    elseif nBreak == RBreak.NBreak * RBreak.NBreakLv then
        Adjust.DoRecord("iym3sk")
    end
end

--武器改造
function Adjust.WeaponBreakRecord(nBreak, bMax)
    if type(nBreak) ~= "number" then return end
    if nBreak == 2 then 
        Adjust.DoRecord("1pmcsb")
    end
    
    if bMax then
        Adjust.DoRecord("xlfav2")
    end
end

-----======================-----
--等级事件
EventSystem.On(Event.LevelUp, function(nNewLevel, nOldLevel)
    if nNewLevel == 3 then
        Adjust.DoRecord("teq3s2")
    elseif nNewLevel == 5 then
        Adjust.DoRecord("bzrpjt")
    end
end)

---获得角色卡时更新缓存的角色卡
EventSystem.On(Event.ItemChanged, function(pItem)
    if pItem and pItem:IsCharacterCard() and pItem:Color() == 5 then
        local nCount = 0
        local pCardList = UE4.TArray(UE4.UItem)
        me:GetItemsByType(UE4.EItemType.CharacterCard, pCardList)
        for i = 1, pCardList:Length() do
            local pGetItem = pCardList:Get(i)
            if pGetItem:Color() == 5 then
                nCount = nCount + 1
            end
        end

        if nCount == 3 then
            Adjust.DoRecord("7oye0a")
        end
    elseif pItem and pItem:IsWeapon() and pItem:Color() == 5 then
        local nCount = 0
        local pWeaponList = UE4.TArray(UE4.UItem)
        me:GetItemsByType(UE4.EItemType.Weapon, pWeaponList)
        for i = 1, pWeaponList:Length() do
            local pGetItem = pWeaponList:Get(i)
            if pGetItem:Color() == 5 then
                nCount = nCount + 1
            end
        end

        if nCount == 3 then
            Adjust.DoRecord("1lno26")
        end
    end
end)