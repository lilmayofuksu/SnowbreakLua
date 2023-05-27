-- ========================================================
-- @File    : Magic.lua
-- @Brief   : 魔法属性列表
-- @Author  : Leo Zhao
-- @Date    : 2019-08-26
-- ========================================================

---@class Magic 定义类
local Magic = {};

---生成时回调
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier
---@param Parameter FParamInfo
function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect) end;

---Tick回调
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier
---@param Parameter FParamInfo
---@param CurOverlaid int32
function Magic:OnExec(AbilityTarget,Modifier, Parameter , CurOverlaid) end;

---增加技能和攻击
---@param Skill UAbilityComponent 目标
---@param Modifier UModifier 
---@param Parameter FMagicParameter
---@param bFire bool 是否为射击
---@param CurOverlaid int32 叠加层数
function Magic:Intensify(Skill , Modifier ,  Parameter ,CurOverlaid, bFire) 
    return 1.0;
end

---实现对受到伤害的缩放
---@param Modifier UModifier
---@param DamageCasuer UAbilityComponentBase
---@param DamageType EModifyHPType
---@param Damage float
---@param Parameter FMagicParameter
---@return float
function Magic:OnTargetDamage(Modifier,OriginLocation , ApplyLocation ,DamageCasuer, DamageType, Damage, Parameter)
    return Damage;
end

---实现对造成伤害的缩放
---@param Modifier UModifier
---@param TargetAbility UAbilityComponentBase
---@param DamageType EModifyHPType
---@param Damage float
---@param Parameter FMagicParameter
---@return float
function Magic:ApplyDamageToOthers(Modifier,OriginLocation , ApplyLocation ,TargetAbility, DamageType, Damage, Parameter)
    return Damage;
end

---当对任意单位造成伤害
---@param Target UAbilityComponent 受到伤害的目标
---@param Modifier UModifier 效果所属Modifier
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Magic:DamageApplyEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    return 0, 0;
end

---当受到任意来源的伤害
---@param Launcher UAbilityComponent 造成伤害的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Magic:DamageReceiveEffect(Launcher, Modifier, MagicParam, Overlaid, ChangeValueData)
    return 0, 0;
end

---治疗效果
---@param Target UAbilityComponent 受到治疗的目标
---@param Modifier UModifier 效果所属Modifier
---@param MagicParam FMagicParameter  效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中的参数
function Magic:HealEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    return 0, 0;
end

---所属附属单位的造成/受到伤害变化
---@param Target UAbilityComponent 受到治疗的目标
---@param Modifier UModifier 效果所属Modifier
---@param MagicParam FMagicParameter  效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中的参数
function Magic:MinionDamageEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    return 0, 0;
end

function Magic:ApplyHitApplyEffect(Target, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)
    return bCrit;
end

function Magic:ApplyHitReceiveEffect(Target, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)
    return bCrit;
end

function Magic:ApplyAttributeChangeDamage(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    return 0, 0
end

function Magic:HitDistanceChangeDamage(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    return 0, 0
end

function Magic:OnModifierDeadCheck(DamageCauser, Modifier, MagicParam, HealthCHangeData)
    return true
end

function Magic:OnModifierHitCheck(DamageCauser, Modifier, MagicParam, HitType, OriginID)
    return true
end

---删除时回调
---@param AbilityTarget UAbilityComponent 目标
---@param Modifier UModifier
---@param Parameter FMagicParameter
function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
end

---获取资源路径
---@param Param Magic执行所需的参数
function Magic:GetAssetPath(Parameter)
    return ""
end

---获取使用到ModifierID
---@param Param Magic执行所需的参数
function Magic:GetUsedModifierID(Parameter)
    local OutModifierID = UE4.TArray(UE4.int32);
    return OutModifierID
end


function Magic:OnNotifySummon(AbilityTarget,Modifier, Param, InSummon)
    return 
end
function Magic:OnBulletHit(AbilityTarget,Modifier, Param, InBullet, InHitTarget)
    return 
end


return Magic;