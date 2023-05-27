return {
    -- 定义一个技能
    Skill_MonsterFire = 
    {
        Info = 
        {
          ID = 100001,
          ---技能名,用于备注
          Name = Skill_MonsterFire,
          ---技能权重
          Priority = 1,
          ---最大技能等级
          MaxLevel = 3,
          ---技能类型
          Type = UE4.ESkillType.Active,
          CD = 0,
          MaxChargeTimes = 1,
          Enmity = 10,
          bFireSkill = 1,
          bCanMove = true,
          bMoveWillInterruptSkill = false,
          
          Icon = "",
        },

        
        Caster = 
        {
            ID = 4,
        },

        Checkers = 
        {
            BulletChecker = 
            {
                Name = "SkillChecker_Bullet",
                ---检查器数据
                Info = 
                {
                    BulletCost = 1;
                },
            },
        },

        Emitters = 
        {
            Emitters_Bullet = {
                --发生器对应ID
                ID = 100001,
                --发生器序号,用于此技能(从0开始)
                Index = 0,
                --所继承Emitter数据的序号,<0时不继承数据
                InheritIndex = -1,
                --发生器的执行延时
                EmitDelayTime = 0.2,
            },
        },
    },

        -- 定义一个技能
        Skill_Test = 
        {
            Info = 
            {
              ID = 100011,
              ---技能名,用于备注
              Name = Skill_Test,
              ---技能权重
              Priority = 1,
              ---最大技能等级
              MaxLevel = 3,
              ---技能类型
              Type = UE4.ESkillType.Active,
              CD = 1,
              MaxChargeTimes = 1,
              Enmity = 10,
              bFireSkill = 1,
              bCanMove = true,
              bMoveWillInterruptSkill = false,
              
              Icon = "",
            },
    
            
            Caster = 
            {
                ID = 4,
            },
    
            Checkers = 
            {
                BulletChecker = 
                {
                    Name = "SkillChecker_Bullet",
                    ---检查器数据
                    Info = 
                    {
                        BulletCost = 1;
                    },
                },
            },
    
            Emitters = 
            {
                Emitters_Bullet = {
                    --发生器对应ID
                    ID = 100001,
                    --发生器序号,用于此技能(从0开始)
                    Index = 0,
                    --所继承Emitter数据的序号,<0时不继承数据
                    InheritIndex = -1,
                    --发生器的执行延时
                    EmitDelayTime = 0.2,
                },
            },
        },
};