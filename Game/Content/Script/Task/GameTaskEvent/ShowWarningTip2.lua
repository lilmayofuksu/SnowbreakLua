local tbClass = Class()

function tbClass:OnTrigger()
	local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelWarn then
        local LevelWarn = FightUMG.LevelWarn
        if self.ShowTip then
        	WidgetUtils.SelfHitTestInvisible(LevelWarn)
        	LevelWarn:PlayAnimation(LevelWarn.Loop)
        else
        	WidgetUtils.Collapsed(LevelWarn)
        end
    end
end

return tbClass;