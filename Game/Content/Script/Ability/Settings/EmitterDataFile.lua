return {
        -- 定义一个名为AOE_001的发生器
        AOE_001 = 
        {
            ---唯一指定ID
            ID = 1,
            GeneralData = 
            {
                ---对应发生器的蓝图类名字
                Name = "SkillEmitter_AOE",
                ---搜寻对应的目标阵营
                TargetRelation = UE4.ERelationship.Friend;
                ---EEmitterRunType.Block , EEmitterRunType.Synchronization
                TickType = UE4.EEmitterRunType.Block,
                ---发生器执行失败时是否取消技能的释放
                bCancleSkillOnFailed = 1,
                ---发生器是否需要播放动画
                bHasAnimToPlayOnEmit = 1,
                ---所拥有的魔法属性列表
                ModifiersID = {1 , 2 , 3},
            },

           ---对应Emitter的特有参数
           ---请对照相应Emitter的文档进行填写
            SpecificData = 
            {
                Range = 200.0,
            },
        };


        Bullet_Test =
        {
            ---唯一指定ID
            ID = 2,
            GeneralData = 
            {
                ---对应发生器的蓝图类名字
                Name = "SkillEmitter_Bullet",
                ---搜寻对应的目标阵营
                TargetRelation = UE4.ERelationship.Friend;
                ---EEmitterRunType.Block , EEmitterRunType.Synchronization
                TickType = UE4.EEmitterRunType.Block,
                ---发生器执行失败时是否取消技能的释放
                bCancleSkillOnFailed = 1,
                ---	成功执行一次Emit后的返回值
	            ---(Finish:完成并结束当前Emitter  InProgress:继续执行  Faile:失败)
                EmitResult = UE4.EEmitterResult.Finish,
                ---发生器是否需要播放动画
                bHasAnimToPlayOnEmit = 0,
                ---所拥有的魔法属性列表
                ModifiersID = { 2 },
            },

           ---对应Emitter的特有参数
           ---请对照相应Emitter的文档进行填写
            SpecificData = 
            {
                BulletName = "TestBullet",
                MoveType = UE4.EBulletMovementType.Naturally,
                HitEffect = 0,
                SpawnScale = UE4.FVector(1,1,1),
                LifeTime = 5.0,
            },
        };

        ApplyDirectly_001 = 
        {
            ---唯一指定ID
            ID = 3,
            GeneralData = 
            {
                ---对应发生器的蓝图类名字
                Name = "SkillEmitter_ApplyDirectly",
                ---搜寻对应的目标阵营
                TargetRelation = UE4.ERelationship.Friend;
                ---EEmitterRunType.Block , EEmitterRunType.Synchronization
                TickType = UE4.EEmitterRunType.Synchronization,
                ---发生器执行失败时是否取消技能的释放
                bCancleSkillOnFailed = 1,
                ---发生器是否需要播放动画
                bHasAnimToPlayOnEmit = 0,
                ---所拥有的魔法属性列表
                ModifiersID = { 4 },
            },

           ---对应Emitter的特有参数
           ---请对照相应Emitter的文档进行填写
            SpecificData = 
            {
                
            },
        };

        Aura_001 = 
        {
            ---唯一指定ID
            ID = 4,
            GeneralData = 
            {
                ---对应发生器的蓝图类名字
                Name = "SkillEmitter_Aura",
                ---搜寻对应的目标阵营
                TargetRelation = UE4.ERelationship.Friend;
                ---EEmitterRunType.Block , EEmitterRunType.Synchronization
                TickType = UE4.EEmitterRunType.Synchronization,
                ---发生器执行失败时是否取消技能的释放
                bCancleSkillOnFailed = 1,
                ---发生器是否需要播放动画
                bHasAnimToPlayOnEmit = 0,
                ---所拥有的魔法属性列表
                ModifiersID = { 5 },
            },

           ---对应Emitter的特有参数
           ---请对照相应Emitter的文档进行填写
            SpecificData = 
            {
                Range = 2000.0,
                LifeTime = 20.0;
            },
        };


        Bullet_Grenade =
        {
            ---唯一指定ID
            ID = 10,
            GeneralData = 
            {
                ---对应发生器的蓝图类名字
                Name = "SkillEmitter_Bullet",
                ---搜寻对应的目标阵营
                TargetRelation = UE4.ERelationship.Friend;
                ---EEmitterRunType.Block , EEmitterRunType.Synchronization
                TickType = UE4.EEmitterRunType.Block,
                ---发生器执行失败时是否取消技能的释放
                bCancleSkillOnFailed = 1,
                ---	成功执行一次Emit后的返回值
	            ---(Finish:完成并结束当前Emitter  InProgress:继续执行  Faile:失败)
                EmitResult = UE4.EEmitterResult.Finish,
                ---发生器是否需要播放动画
                bHasAnimToPlayOnEmit = 1,
                ---发生器对应的蒙太奇表现片段名
                SectionName = "",
                ---	是否使用Notify控制Emitter的释放和结束(只应用了Notify在Montage上对应的时间)
                ---	bUseNotify和EmitDelayTime只有一个可生效,UseNotify优先级大于EmitDelayTime
                bUseNotify = 1,
                EmitNotify = "Fire",
                FinishNotify = "Finish",
                ---所拥有的魔法属性列表
                ModifiersID = {2},
            },

           ---对应Emitter的特有参数
           ---请对照相应Emitter的文档进行填写
            SpecificData = 
            {
                BulletName = "Grenade",
                MoveType = UE4.EBulletMovementType.Naturally,
                HitEffect = 1,
                bUseSocket = 1,
                bUseSocketRotation = 1,
                SocketName = "FireHole",
                SubSkillIDs = {0,1},
                SpawnScale = UE4.FVector(1.0,1.0,1.0),
                LifeTime = 5.0,
            },
        };

        Bullet_WeaponFire =
        {
            ---唯一指定ID
            ID = 5,
            GeneralData = 
            {
                ---对应发生器的蓝图类名字
                Name = "SkillEmitter_CastAccessorySkill",
                ---搜寻对应的目标阵营
                TargetRelation = UE4.ERelationship.Friend;
                ---EEmitterRunType.Block , EEmitterRunType.Synchronization
                TickType = UE4.EEmitterRunType.Synchronization,
                ---发生器执行失败时是否取消技能的释放
                bCancleSkillOnFailed = 0,
                ---	成功执行一次Emit后的返回值
	            ---(Finish:完成并结束当前Emitter  InProgress:继续执行  Faile:失败)
                EmitResult = UE4.EEmitterResult.Finish,
                ---发生器是否需要播放动画
                bHasAnimToPlayOnEmit = 0,
                ---发生器对应的蒙太奇表现片段名
                SectionName = "",
                ---	是否使用Notify控制Emitter的释放和结束(只应用了Notify在Montage上对应的时间)
                ---	bUseNotify和EmitDelayTime只有一个可生效,UseNotify优先级大于EmitDelayTime
                bUseNotify = 0,
                EmitNotify = "Fire",
                FinishNotify = "Finish",
                ---所拥有的魔法属性列表
                ModifiersID = {},
            },

           ---对应Emitter的特有参数
           ---请对照相应Emitter的文档进行填写
            SpecificData = 
            {
                SkillID = 100;
            },
        };
}