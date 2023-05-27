return
{
    Monster_Bullet =
    {
        ---唯一指定ID
        ID = 100001,
        GeneralData = 
        {
            ---对应发生器的蓝图类名字
            Name = "SkillEmitter_Bullet",
            ---搜寻对应的目标阵营
            TargetRelation = UE4.ERelationship.Enermy;
            ---EEmitterRunType.Block , EEmitterRunType.Synchronization
            TickType = UE4.EEmitterRunType.Block,
            ---发生器执行失败时是否取消技能的释放
            bCancleSkillOnFailed = 1,
            ---	成功执行一次Emit后的返回值
	        ---(Finish:完成并结束当前Emitter  InProgress:继续执行  Faile:失败)
            EmitResult = UE4.EEmitterResult.InProgress,
            ---发生器是否需要播放动画
            bHasAnimToPlayOnEmit = 0,
            ---所拥有的魔法属性列表
            ModifiersID = { 2 },
        },

       ---对应Emitter的特有参数
       ---请对照相应Emitter的文档进行填写
        SpecificData = 
        {
            BulletName = "FireBullet",
            MoveType = UE4.EBulletMovementType.Naturally,
            HitEffect = 2,
            bUseSocket = 1,
            bUseSocketRotation = 1,
            SocketName = "FX_weapon01",
            SubSkillIDs = {},
            SpawnScale = UE4.FVector(0.1,0.1,0.1),
            LifeTime = 5.0,
        },
    };
};