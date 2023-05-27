-- ========================================================
-- @File    : ChallengeMgr.lua
-- @Brief   : 挑战管理
-- @Author  :
-- @Date    :
-- ========================================================

ChallengeMgr = ChallengeMgr or {}
ChallengeMgr.tbChallenge = {}
ChallengeMgr.tbBarricade = {}

function ChallengeMgr.AddChallenge(nId, tbOne)
    ChallengeMgr.RemoveChallenge(nId)
    ChallengeMgr.tbChallenge[nId] = tbOne
end

function ChallengeMgr.RemoveChallenge(nId)
	local challenge = ChallengeMgr.tbChallenge[nId]
    if challenge then
    	if challenge.self then
    		if challenge.TimerHandle then
	    		UE4.UKismetSystemLibrary.K2_ClearTimerHandle(challenge.self, challenge.TimerHandle)
	    	end

            if challenge.DeathHook then
                EventSystem.Remove(challenge.DeathHook)
            end

            if challenge.DamageReceiveHandle then
                EventSystem.Remove(challenge.DamageReceiveHandle)
            end

            if challenge.PartBreakHook then
                EventSystem.Remove(challenge.PartBreakHook)
            end
    	end
    end
end

function ChallengeMgr.ClearAll()
	for k,_ in pairs(tbChallenge) do
		ChallengeMgr.RemoveChallenge(k)
	end
    ChallengeMgr.tbBarricade = {}
end

function ChallengeMgr.AddBarricade(AreaId, one)
    if not ChallengeMgr.tbBarricade[AreaId] then
        ChallengeMgr.tbBarricade[AreaId] = {}
    end
    table.insert(ChallengeMgr.tbBarricade[AreaId], one)
end