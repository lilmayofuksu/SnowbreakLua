-- 技能配置示例
return {
    -- 定义一个技能
    Skill_Demo = 
    {
        Info = 
        {
          ID = 0,
          Name = Skill_001,
          ---技能权重
          Priority = 1,
          ---最大技能等级
          MaxLevel = 3,
          ---技能类型
          Type = UE4.ESkillType.Active,
          CD = 1.0,
          MaxChargeTimes = 2,
          Enmity = 10,
          bFireSkill = 0,
          bCanMove = true,
          bMoveWillInterruptSkill = false,
          
          Icon = "",
        },

        
        Caster = 
        {
            ID = 1,
        },

        Checkers = 
        {
            Checkers_1 = {
                Name = "SkillChecker_CD",
                ---检查器数据
                Info = {
                    Test = 1;
                },
            },
        },

        Emitters = 
        {
            Emitters_AOE = {
                --发生器对应ID
                ID = 1,
                --发生器序号,用于此技能(从0开始)
                Index = 0,
                --所继承Emitter数据的序号,<0时不继承数据
                InheritIndex = -1,
                --发生器的执行延时
                EmitDelayTime = 3.0,
            },

            Emitters_2 = {
                --发生器对应ID
                ID = 2,
                --发生器序号,用于此技能(从0开始)
                Index = 2,
                --所继承Emitter数据的序号,<0时不继承数据
                InheritIndex = 0,
                --发生器的执行延时
                EmitDelayTime = 1.0,
            },

            Emitters_3 = {
                --发生器对应ID
                ID = 3,
                --发生器序号,用于此技能(从0开始)
                Index = 1,
                --所继承Emitter数据的序号,<0时不继承数据
                InheritIndex = 0,
                --发生器的执行延时
                EmitDelayTime = 1,
            },
        },
    },

    Skill_Demo11 = 
    {
        Info = 
        {
          ID = 1,
          Name = Skill_002,
          ---技能权重
          Priority = 1,
          ---最大技能等级
          MaxLevel = 3,
          ---技能类型
          Type = UE4.ESkillType.Active,
          CD = 1.0,
          MaxChargeTimes = 1,
          Enmity = 10,
          bFireSkill = 0,
          bCanMove = true,
          bMoveWillInterruptSkill = false,
          
          Icon = "",
        },

        
        Caster = 
        {
            -- Name = "SkillCaster_Anim",
            -- ---
            -- Info = {},
            ID = 1,
        },

        Checkers = 
        {
            Checkers_1 = {
                Name = "SkillChecker_CD",
                ---检查器数据
                Info = {
                    Test = 1;
                },
            },
        },

        Emitters = 
        {
            Emitters_3 = {
                --发生器对应ID
                ID = 4,
                --发生器序号,用于此技能(从0开始)
                Index = 1,
                --所继承Emitter数据的序号,<0时不继承数据
                InheritIndex = 0,
                --发生器的执行延时
                EmitDelayTime = 5,
            },
        },
    },


    Skill_MonsterFireHole = 
    {
        Info = 
        {
          ID = 3,
          Name = MonsterSkill_FireHole,
          ---技能权重
          Priority = 1,
          ---最大技能等级
          MaxLevel = 3,
          ---技能类型
          Type = UE4.ESkillType.Active,
          CD = 1.0,
          MaxChargeTimes = 1,
          Enmity = 10,
          bFireSkill = 0,
          bCanMove = false,
          bMoveWillInterruptSkill = false,
          
          Icon = "",
        },

        
        Caster = 
        {
            ID = 3,
        },

        Checkers = 
        {
        },

        Emitters = 
        {
            Emitters_Grenade = {
                --发生器对应ID
                ID = 10,
                --发生器序号,用于此技能(从0开始)
                Index = 1,
                --所继承Emitter数据的序号,<0时不继承数据
                InheritIndex = 0,
                --发生器的执行延时
                EmitDelayTime = 0.56,
            },
        },
    },
}
