


local uw_Panel_Monster_Buff=Class("UMG.SubWidget")

local MonsterBuf=uw_Panel_Monster_Buff

MonsterBuf.NowTime=nil
MonsterBuf.tempPercent=1


-- function MonsterBuf:Tick(MyGeometry, InDeltaTime)
--     self.NowTime = UE4.UGameplayStatics.GetTimeSeconds(self)
--     if self.tempPercent<0 then
--         self.tempPercent=1
--     end
--     self.tempPercent=self.tempPercent-InDeltaTime
--     self.CDBar:SetPercent(self.tempPercent)
-- end



return MonsterBuf