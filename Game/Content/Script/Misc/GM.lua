-- ========================================================
-- @File    : GM.lua
-- @Brief   : GM功能对接
-- ========================================================
GM = GM or {}

GM.__IsOpen = UE4.UGMLibrary.GetGMDefaultOpenState()

s2c.Register('GM', function(tbParam)
    if not string.find(tbParam.code, "--TDebug Callback:") then
        assert(load(tbParam.code))()
    else
        _G.oldPrint = _G.print
        xpcall(GM.DoScript, GM.ErrorTraceback, tbParam)
        _G.print = _G.oldPrint
    end    
end)

s2c.Register('gm.notifylogin', function(tbParam)
    if tbParam and tbParam.IsDebug then 
        GM.OpenGMByServer()
    else 
        GM.__IsOpen = false
        UI.Close("AdinGM")
    end
end)

function GM.DoScript(tbParam)
    local callback = nil
    local sStart, sEnd = "--TDebug Callback:", "result"
    local nStart = string.find(tbParam.code, sStart)
    local nEnd = string.find(tbParam.code, sEnd)
    if nStart and nEnd then
        callback = string.sub(tbParam.code, nStart+string.len(sStart), nEnd+string.len(sEnd)-1)
    end
    
    if callback then
        _G.print = function (...)
            oldPrint(...)
            local sRet = ""
            local arg = {...}

            if #arg > 0 then
                for i, val in ipairs(arg) do
                    if i ~= #arg then
                        sRet = sRet .. tostring(val) .. ' '
                    else
                        sRet = sRet .. tostring(val)
                    end
                end
                
                local data = UE4.TMap(UE4.FString, UE4.FString)
                data:Add('ret', sRet)
                UE4.UBiDataRecord.PostFromParam(callback, data)
            end
        end
    end

    assert(load(tbParam.code))()
end

function GM.ErrorTraceback(err)
    print("Lua Error:".. tostring(err))
    _G.print = _G.oldPrint
end

function GM.TryOpenAdin()
    if GM.__IsOpen then
        if not UI.IsOpen("AdinGM") then
            UI.Open('AdinGM')
        end
        return true;
    end
    return false;
end

function GM.TryClose()
    UI.Close("AdinGM")
end

function GM.OpenGMByServer()
    GM.__IsOpen = true;
    UE4.UGameLibrary.InitLogDevice(true);
    GM.TryOpenAdin()
end

function GM.IsOpenUI()
    return UI.IsOpen('AdinGM')
end

function GM.IsOpen()
    return GM.__IsOpen
end

--开启无敌效果
function GM.StateGod(PlayerController)
    if PlayerController then
        if PlayerController:GetPlayerCharacters() then
            local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
            for index, value in ipairs(GMPlayerCharacters) do
                local Location = UE4.FVector(0,0,0)
                if not value.Ability:IsModifierExist(1000912) then
                    UE4.UModifier.MakeModifier(1000912,value.Ability,value.Ability,value.Ability,nil,Location,Location)
                end
            end
        end
        UI.ShowTip("无敌 已开启，啦啦啦啦！！！")
    end   
end

-- 关闭无敌
function GM.EndGod(PlayerController)
    if PlayerController then
        if PlayerController:GetPlayerCharacters() then
            local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
            for index, value in ipairs(GMPlayerCharacters) do
                if value.Ability:IsModifierExist(1000912) then
                    value.Ability:RemoveModifierFormModifierID(1000912)
                end
            end
        end
        UI.ShowTip("无敌效果已移除，噢噢噢噢！！！");
    end   
end

-- 开启忽略伤害
function GM.StateIgnoreDamage(PlayerController)
    if not GM.bEnableIgnoreDamage then
        GM.bEnableIgnoreDamage = true;
        if PlayerController then
            if PlayerController:GetPlayerCharacters() then
                local GMPlayerCharacters = PlayerController:GetPlayerCharacters():ToTable();
                for i, v in ipairs(GMPlayerCharacters) do
                    local Location = UE4.FVector(0, 0, 0);
                    if not v.Ability:IsModifierExist(3301005) then
                        UE4.UModifier.MakeModifier(3301005, v.Ability, v.Ability, v.Ability, nil, Location, Location);
                    end
                end
                UI.ShowTip("开启忽略伤害，啦啦啦啦！！！")
            end
        end
    else
        GM.bEnableIgnoreDamage = false;
        if PlayerController then
            if PlayerController:GetPlayerCharacters() then
                local GMPlayerCharacters = PlayerController:GetPlayerCharacters():ToTable();
                for i, v in ipairs(GMPlayerCharacters) do
                    local Location = UE4.FVector(0, 0, 0);
                    if v.Ability:IsModifierExist(3301005) then
                        v.Ability:RemoveModifierFormModifierID(3301005);
                    end
                end
                UI.ShowTip("移除忽略伤害，噢噢噢噢！！！")
            end
        end
    end
end


--一枪999
function GM.OneShot999(PlayerController, InParam)
    if PlayerController then
        if PlayerController:GetPlayerCharacters() then
            local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
            for index, value in ipairs(GMPlayerCharacters) do
                --local Location=UE4.FVector(0,0,0)
                if InParam == ""  then
                    if value.Ability:IsModifierExist(3002001) then
                        value.Ability:RemoveModifierFormModifierID(3002001)
                        UI.ShowTip("成功移除一枪999,终于知道心疼Bot了")
                    else
                        UI.ShowTip("移除失败,一枪999已经无效,你是不是傻")
                    end
                else
                    if value.Ability:IsModifierExist(3002001) then
                        UI.ShowTip("添加失败,一枪999已经开启,别老整没用滴")
                    else
                        local RuntimeID = UE4.UModifier.MakeModifier(3002001,value.Ability,value.Ability,value.Ability,nil,value.CapsuleComponent:K2_GetComponentLocation(),value.CapsuleComponent:K2_GetComponentLocation())
                        local lpModifier = value.Ability:FindModifierByRunTimeID(RuntimeID)
                        if lpModifier then
                            local AttributeChangeValue = UE4.FAttributeChangeValue()                       
                            AttributeChangeValue.AttributeClass = value.Ability:GetAbilityAttributeFromString("FinalDealDamageRate")
                            AttributeChangeValue.Value = InParam and tonumber(InParam) or 999
                            AttributeChangeValue.ChangeType = UE4.EAttributeChangeType.Multiply
                            lpModifier:ApplyAttributeChange(value.Ability, AttributeChangeValue, UE4.EModifierEffectType.KeepEffect)              
                        end
                        UI.ShowTip("添加一枪999，啦啦啦啦！！！")
                    end
                end
            end
        end
    end
end

function GM.SuspendAllMonster(PlayerController)
    local AICharacters = UE4.UGameplayStatics.GetAllActorsOfClass(PlayerController, UE4.AGameAICharacter)
    for i = 1, AICharacters:Length() do
        local AICharacter = AICharacters:Get(i);
        AICharacter.AIPerformanceComp.bForceSuspendAITick = not AICharacter.AIPerformanceComp.bForceSuspendAITick;
        print("GM.SuspendAllMonster:", AICharacter, AICharacter.AIPerformanceComp, AICharacter.AIPerformanceComp.bForceSuspendAITick)
        if not AICharacter.AIPerformanceComp.bForceSuspendAITick then
            UI.ShowTip("解除怪物暂停")
        else
            UI.ShowTip("砸瓦鲁多！")
        end
    end
end


--清屏
function GM.ClearAllMonster(PlayerController)
    UE4.UGameplayStatics.GetPlayerCharacter(PlayerController,0).Ability:K2_FindOrAddSkill(9000001,0,false)
    UE4.UGameplayStatics.GetPlayerCharacter(PlayerController,0).Ability:CastSkill(9000001)
    print("清除区域敌人")
end

--充能  +100蓝量
function GM.AplliyEnergy(PlayerController)
    if PlayerController then       
        if PlayerController:GetPlayerCharacters() then
            local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
            for index, value in ipairs(GMPlayerCharacters) do
                local Location=UE4.FVector(0,0,0)
                UE4.UModifier.MakeModifier(3205002,value.Ability,value.Ability,value.Ability,nil,Location,Location)
            end
            print("蓝+100")
        end
    end
end


--刷新技能CD
function GM.FreshCD(PlayerController)
    if GM.AutoCount==true then
        GM.AutoCount=false
        if PlayerController then
            if PlayerController:GetPlayerCharacters() then
                local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
                for index, value in ipairs(GMPlayerCharacters) do
                    local Location=UE4.FVector(0,0,0)
                    UE4.UModifier.MakeModifier(3008001,value.Ability,value.Ability,value.Ability,nil,Location,Location)
                end
                UI.ShowTip("开启CD为0，啦啦啦啦！！！")
            end
        end
    else
        GM.AutoCount=true
        if PlayerController then
            if PlayerController:GetPlayerCharacters() then
                local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
                for index, value in ipairs(GMPlayerCharacters) do
                    value.Ability:RemoveModifierFormModifierID(3008001)
                end
                UI.ShowTip("关闭CD为0")
            end
        end
    end
end

--直接关卡胜利
function GM.LevelVictory(PlayerController)
    local Actor= UE4.AGameTaskActor.GetGameTaskActor(PlayerController):GM_LevelFinishSuccess()
 end
--直接关卡失败
function GM.LevelFailed(PlayerController)
    local Actors= UE4.UGameplayStatics.GetAllActorsOfClass(PlayerController,UE4.AGameTaskActor):Get(1)
    Actors:LevelFinishBroadCast(UE4.ELevelFinishResult.Failed)
end

--测试QTE
function GM.StartTestQTE(PlayerController)
   if PlayerController then
        PlayerController:StartTestSwitch()
   end
end

---血量回满
function GM.HealSelf(PlayerController)
    if PlayerController then
        if PlayerController:GetPlayerCharacters() then
            local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
            for index, value in ipairs(GMPlayerCharacters) do
                local Location=UE4.FVector(0,0,0)
                UE4.UModifier.MakeModifier(3201003,value.Ability,value.Ability,value.Ability,nil,Location,Location)
            end
        end
    end
end

--显示关卡名称
function GM.ShowLevel(PlayerController)
    local map = UE4.UKismetSystemLibrary.GetOuterObject(PlayerController)
    if map then
       local MapName = UE4.UKismetSystemLibrary.GetPathName(map)
       print(MapName)
    end
end

---重置关卡锁
function GM.TaskUnlock(PlayerController)
    for i = 1001, 1999 do
        local Account = UE4.UAccount.Get(0)
        Account:SetAttribute(40,i,0)
    end
end

---扣除自己血量
function GM.DecPlayerHealth(PlayerController, PlayerHealth)
    local GamePlayer = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController,0)
    local GamePlayerAbility = GamePlayer and GamePlayer.Ability
    if (not GamePlayer) or (not GamePlayerAbility) then
        return
    end
    -- 扣除自己
    local MaxHealth = GamePlayerAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
    local SubHealth = math.ceil((PlayerHealth / 100) * MaxHealth)
    GamePlayerAbility:AppendHealthValue(GamePlayerAbility, -SubHealth, nil)
end

---扣除怪物血量
function GM.DecMonsterHealth(PlayerController, InParam)
    local tbParams = json.decode(InParam) or {}
    local MonsterHealth = tbParams["MonsterHealth"] or 0
    local MonsterSheild = tbParams["MonsterSheild"] or 0
    if MonsterHealth == 0 or MonsterSheild == 0 then
        return
    end
    local GamePlayer = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController,0)
    local GamePlayerAbility = GamePlayer and GamePlayer.Ability
    if (not GamePlayer) or (not GamePlayerAbility) then
        return
    end
    -- 扣除怪物
    local TargetArray = UE4.UAbilityFunctionLibrary.QueryTargetsWithEmitterInfo(GamePlayerAbility, GamePlayer, GamePlayer, 900000001)
    for i = 1, TargetArray:Length() do
        local Target = TargetArray:Get(i).QueryTarget
        local MonsterAbility = Target and Target.Ability
        if Target and MonsterAbility then
            -- 怪物血量
            local MaxHealth = MonsterAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
            local NowHealth = MonsterAbility:GetRolePropertieValue(UE4.EAttributeType.Health)

            -- 怪物护盾
            local MaxSheild = MonsterAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Shield)
            local NowSheild = MonsterAbility:GetRolePropertieValue(UE4.EAttributeType.Shield)

            local TargetHealth = math.ceil(NowHealth - (MonsterHealth / 100) * MaxHealth)
            -- 直接设置血量时不能设置0 所以直接杀死
            if TargetHealth <= 0 then
                local HealthChangeValue = UE4.FHealthChangeValue()
                HealthChangeValue.Value = MaxHealth + MaxSheild
                HealthChangeValue.HealthChangeType = UE4.EModifyHPType.Pure
                MonsterAbility:ModifyHealth(GamePlayerAbility, HealthChangeValue)
            else
                MonsterAbility:SetPropertieValueFromString("Health", TargetHealth)
            
                if NowSheild > 0 then
                    local SubSheild = math.ceil((MonsterSheild / 100) * MaxSheild)
                    local HealthChangeValue = UE4.FHealthChangeValue()
                    HealthChangeValue.Value = math.min(SubSheild, NowSheild)
                    HealthChangeValue.HealthChangeType = UE4.EModifyHPType.Pure
                    MonsterAbility:ModifyHealth(GamePlayerAbility, HealthChangeValue)
                end
            end
        end
    end
end


---显示lua报错
function GM.OpenLuaErrorUI()
    if DontShowLuaErrorUI then return end

    if not UI.IsOpen("ShowLuaError") then 
        UI.Open("ShowLuaError")
    end
end

---------------------------------------

EventSystem.On(Event.GMCallServer, function(InFunName, InPlayer, InParam) 
    if GM[InFunName] then
        GM[InFunName](InPlayer, InParam) 
    else
        assert(load(InFunName))()
    end
end)