-- ========================================================
-- @File    : Ability.lua
-- @Brief   : 技能系统外部接口
-- @Author  : XiongHongJi
-- @Date    : 2020-4-16
-- ========================================================

---@class Ability
---@field MagicType Magic[] 存放魔法属性的逻辑定义
---@field Template Magic 默认的魔法属性实现
Ability = Ability or {MagicType = {}, Template = require("Ability.Magic")}

---定义一个魔法属性的实现
---@param Name string 魔法属性的名字
---@param Base string 魔法属性的基类
---@return Magic 返回子类对象
function Ability.DefineMagic(Name, Base)
    local Logic = Inherit(Ability.FindMagic(Base))
    Ability.MagicType[Name] = Logic
    return Logic
end

---查找一个魔法属性的逻辑实现
---@param Name string 魔法属性的名字
---@return Magic 返回魔法属性的逻辑
function Ability.FindMagic(Name)
    if Name == nil then
        return Ability.Template
    end
    local Logic = Ability.MagicType[Name]
    if not Logic then
        Logic = require("Ability.Magics." .. Name)
        Ability.MagicType[Name] = Logic
    end

    return Logic
end

---第一次执行相应Magic
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier Magic所属修改器
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
function Ability.MagicBorn(AbilityTarget,Modifier, Name, Param, bKeepEffect)
    if Modifier == nil then
        return
    end
    local Logic = Ability.FindMagic(Name)
    if Logic then
        Logic:OnBorn(AbilityTarget,Modifier, Param, bKeepEffect)
    else
        error("Missing magic definition", Name)
    end
end

---运行一次相应的Magic
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier Magic所属修改器
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
---@param CurOverlaid Magic当前的叠加层数
function Ability.ExecMagic(AbilityTarget, Modifier, Name, Param, CurOverlaid)
    if Modifier == nil then
        return
    end

    local Logic = Ability.FindMagic(Name)
    if Logic then
        Logic:OnExec(AbilityTarget,Modifier, Param, CurOverlaid)
    else
        error("Missing magic definition", k)
    end
end

---应用Modifier的强化
---@param Skill USkill 目标技能
---@param Modifier UModifier Magic所属修改器
---@param Name FName Magic对应的名字
---@param Param FMagicParameter Magic执行所需的参数
---@param CurOverlaid int32 叠加层数

function Ability.ExecMagicIntensify(Skill , Modifier , Name , Param , CurOverlaid , bFire)
    if Modifier == nil then
        return
    end

    local Logic = Ability.FindMagic(Name)
    if Logic then
        return Logic:Intensify(Skill,Modifier, Param, CurOverlaid, bFire)
    else
        error("Missing magic definition", k)
    end

    return 1.0;
end

---移除相应Magic时的回调
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier Magic所属修改器
---@param Name FName Magic对应的名字
---@param Param FMagicParameter Magic执行所需的参数
---@param CurOverlaid int32 Magic当前的叠加层数
function Ability.RemoveModifier(AbilityTarget,Modifier, Name, Param, CurOverlaid)
    if Modifier == nil then
        return
    end

    local Logic = Ability.FindMagic(Name)
    if Logic then
        Logic:OnRemove(AbilityTarget,Modifier, Param, CurOverlaid)
    else
        error("Missing magic definition", k)
    end
end


---通知生成召唤物
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier Magic所属修改器
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
function Ability.MagicNotifySummon(AbilityTarget,Modifier, Name, Param, InSummon)
    if Modifier == nil then
        return
    end

    local Logic = Ability.FindMagic(Name)
    if Logic then
        Logic:OnNotifySummon(AbilityTarget,Modifier, Param, InSummon)
    else
        error("Missing magic definition", Name)
    end
end

---通知子弹命中目标
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier Magic所属修改器
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
function Ability.MagicOnBulletHit(AbilityTarget,Modifier, Name, Param, InBullet, InHitTarget)
    if Modifier == nil then
        return
    end
    
    local Logic = Ability.FindMagic(Name)
    if Logic then
        Logic:OnBulletHit(AbilityTarget,Modifier, Param, InBullet, InHitTarget)
    else
        error("Missing magic definition", Name)
    end
end

---加载所有的配置
function Ability.LoadAll()
end

---当技能执行状态改变
---@param Skill USkill 状态改变的技能对象
---@param CurrentStage int32 改变后的执行状态
---@param PreStage int32 改变前的执行状态
function Ability.OnSkillExecutionStageChange(Skill, CurrentStage, PreStage)
    ---切换半身动画的开关
    if PreStage == UE4.ESkillExecutionStage.InAnim and CurrentStage ~= UE4.ESkillExecutionStage.InAnim then
        if Skill:GetCharacter() ~= nil then
            local OwnerCharacter = Skill:GetCharacter():Cast(UE4.AGameCharacter)
            if OwnerCharacter ~= nil then
                OwnerCharacter:SetInHalfSkillMontage(false)
            end
        end
        Skill:SkillAnimStateEnd()
    end

    ---切换半身动画的开关
    if CurrentStage == UE4.ESkillExecutionStage.InAnim then
        if Skill.SkillInfo.bHalfSkill then
            if Skill:GetCharacter() ~= nil then
                local OwnerCharacter = Skill:GetCharacter():Cast(UE4.AGameCharacter)
                if OwnerCharacter ~= nil then
                    OwnerCharacter:SetInHalfSkillMontage(true)
                end
            end
        end
    end
end

---当对任意单位造成伤害
---@param Target UAbilityComponent 受到伤害的目标
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Ability.DamageApplyEffect(Target, Modifier, MagicName, MagicParam, Overlaid, ChangeValueData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:DamageApplyEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    end

    return 0, 0;
end

---当受到任意来源的伤害
---@param Launcher UAbilityComponent 造成伤害的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Ability.DamageReceiveEffect(Launcher, Modifier, MagicName, MagicParam, Overlaid, ChangeValueData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:DamageReceiveEffect(Launcher, Modifier, MagicParam, Overlaid, ChangeValueData)
    end

    return 0, 0;
end

---治疗效果
---@param Launcher UAbilityComponent 造成治疗的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter  效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中的参数
function Ability.HealEffect(Target, Modifier, MagicName, MagicParam, Overlaid, ChangeValueData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:HealEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    end

    return 0, 0;
end

---所属附属单位的造成/受到伤害变化
---@param Launcher UAbilityComponent 造成治疗的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter  效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中的参数
function Ability.MinionDamageEffect(Target, Modifier, MagicName, MagicParam, Overlaid, ChangeValueData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:MinionDamageEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    end

    return 0, 0;
end

---当对命中任意单位
---@param Target UAbilityComponent 受到伤害的目标
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Ability.ApplyHitApplyEffect(Target, Modifier, MagicName, MagicParam, Overlaid, OriginID, Outer, bCrit)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:ApplyHitApplyEffect(Target, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)
    end

    return bCrit
end

---当受到任意来源的命中
---@param Launcher UAbilityComponent 造成伤害的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Ability.ApplyHitReceiveEffect(Launcher, Modifier, MagicName, MagicParam, Overlaid, OriginID, Outer, bCrit)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:ApplyHitReceiveEffect(Launcher, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)
    end

    return bCrit
end

---角色属性影响伤害
---@param Launcher UAbilityComponent 造成伤害的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Ability.ApplyAttributeChangeDamage(Launcher, Modifier, MagicName, MagicParam, Overlaid, OriginID, Outer, bCrit)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:ApplyAttributeChangeDamage(Launcher, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)
    end

    return 0, 0
end

---攻击距离影响伤害
---@param Launcher UAbilityComponent 造成伤害的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicName FName Magic对应的名字
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Ability.HitDistanceChangeDamage(Launcher, Modifier, MagicName, MagicParam, Overlaid, ChangeValueData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:HitDistanceChangeDamage(Launcher, Modifier, MagicParam, Overlaid, ChangeValueData)
    end

    return 0, 0
end

---目标死亡前执行特殊效果
function Ability.OnModifierPreDeadExec(DamageCauser,DeadCharAbility, Modifier, MagicName, MagicParam, HealthCHangeData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:OnModifierPreDeadExec(DamageCauser,DeadCharAbility, Modifier, MagicParam, HealthCHangeData);
    end

    return true;
end

---目标的死亡检查
function Ability.OnModifierDeadCheck(DamageCauser, Modifier, MagicName, MagicParam, HealthCHangeData)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:OnModifierDeadCheck(DamageCauser, Modifier, MagicParam, HealthCHangeData);
    end

    return true;
end

---目标的命中检查
function Ability.OnModifierHitCheck(DamageCauser, Modifier, MagicName, MagicParam, HitType, OriginID)
    local Logic = Ability.FindMagic(MagicName)
    if Logic then
        return Logic:OnModifierHitCheck(DamageCauser, Modifier, MagicParam, HitType, OriginID);
    end

    return true;
end

---新版伤害效果特殊处理
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
function Ability.ApplyDamageEffect(Name, MagicParam, PreDamageData, nLevel)
    local Logic = Ability.FindMagic(Name)
    if Logic then
        Logic:ApplyDamageEffect(MagicParam, PreDamageData, nLevel)
    else
        error("Missing magic definition", Name)
    end
end

---获取资源路径
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
function Ability.GetAssetPath(Name, Param)
    local Logic = Ability.FindMagic(Name)
    if Logic then
        return Logic:GetAssetPath(Param)
    else
        error("Missing magic definition", Name)
    end
    return ""
end

---获取使用到ModifierID
---@param Name Magic对应的名字
---@param Param Magic执行所需的参数
function Ability.GetUsedModifierID(Name, Param)
    local Logic = Ability.FindMagic(Name)
    if Logic then
        return Logic:GetUsedModifierID(Param)
    else
        error("Missing magic definition", Name)
    end
    return ""
end

Ability.LoadAll()
