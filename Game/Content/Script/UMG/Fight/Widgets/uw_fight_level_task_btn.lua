-- ========================================================
-- @File    : uw_fight_level_task_btn.lua
-- @Brief   : 战斗界面 任务显示按钮
-- @Author  : 
-- @Date    : 
-- ========================================================
local uw_fight_level_task_btn = Class("UMG.SubWidget")

local LevelBtn = uw_fight_level_task_btn

function LevelBtn:Construct()
    print("LevelBtn:Construct")
    WidgetUtils.Hidden(self.BtnUnfold)
    WidgetUtils.Hidden(self.BtnCollapse)
    self.bShowLevel = true

    BtnAddEvent(self.BtnUnfold, function() self:PlayAnim(true, false) end)
    BtnAddEvent(self.BtnCollapse, function() self:PlayAnim(false, false) end)

    local FightUMG = UI.GetUI("Fight")
    if FightUMG then
        if Launch.GetType() ~= LaunchType.TOWER then return end
        if FightUMG.Sudden then
            FightUMG.Sudden.OnVisibilityChanged:Add(self, function(InVisibility)
                self:VisibilityChanged(InVisibility)
            end)
        end
        if FightUMG.Star then
            FightUMG.Star.OnVisibilityChanged:Add(self, function(InVisibility)
                self:VisibilityChanged(InVisibility)
            end)
        end
        if FightUMG.LevelBar then
            FightUMG.LevelBar.OnVisibilityChanged:Add(self, function(InVisibility)
                self:VisibilityChanged(InVisibility)
            end)
        end
        -- if FightUMG.SkillIntro then
        --     FightUMG.SkillIntro.OnVisibilityChanged:Add(self, function(InVisibility)
        --         self:VisibilityChanged(InVisibility)
        --     end)
        -- end

    end
end

function LevelBtn:PostTaskOffFinish()
    --self.BtnUnfold:SetIsEnabled(true)
    WidgetUtils.Visible(self.BtnUnfold)
    print("LevelBtn:PostTaskOffFinish")
end

function LevelBtn:PostTaskOnFinish()
    --self.BtnCollapse:SetIsEnabled(true)
    WidgetUtils.Visible(self.BtnCollapse)
    print("LevelBtn:PostTaskOnFinish")
end

function LevelBtn:VisibilityChanged(InVisibility)
    print("LevelBtn:VisibilityChanged ", InVisibility)
    if InVisibility ~= UE4.ESlateVisibility.Collapsed and InVisibility ~= UE4.ESlateVisibility.Hidden then
        WidgetUtils.SelfHitTestInvisible(self)
        WidgetUtils.Visible(self.BtnCollapse)
        WidgetUtils.Hidden(self.BtnUnfold)
        self.bShowLevel = true
        print("LevelBtn:VisibilityChanged show")
    else
        WidgetUtils.Collapsed(self)
        print("LevelBtn:VisibilityChanged Hide")
    end
end

function LevelBtn:PlayAnim(bShow, bSkipFirst)
    print("LevelBtn:PlayAnim ", bShow, bSkipFirst)
     if self.bShowLevel ~= bShow or bSkipFirst then
        self.bShowLevel = bShow
        local FightUMG = UI.GetUI("Fight")
        if FightUMG then
            FightUMG:UnbindFromAnimationFinished(
                FightUMG.TaskOff,
                { self, self.PostTaskOffFinish }
            )
            FightUMG:UnbindFromAnimationFinished(
                FightUMG.TaskOn,
                { self, self.PostTaskOnFinish }
            )
            FightUMG:BindToAnimationEvent(
                FightUMG.TaskOff,
                { self, self.PostTaskOffFinish },
                UE4.EWidgetAnimationEvent.Finished
            )
            FightUMG:BindToAnimationEvent(
                FightUMG.TaskOn,
                { self, self.PostTaskOnFinish },
                UE4.EWidgetAnimationEvent.Finished
            )
            
            if bShow then
                WidgetUtils.Hidden(self.BtnUnfold)
                --WidgetUtils.Visible(self.BtnCollapse)
                WidgetUtils.HitTestInvisible(self.BtnCollapse)
                --self.BtnCollapse:SetIsEnabled(false)
                FightUMG:PlayAnimation(FightUMG.TaskOn)
                print("LevelBtn:PlayAnim show")
            else
                --WidgetUtils.Visible(self.BtnUnfold)
                WidgetUtils.HitTestInvisible(self.BtnUnfold)
                WidgetUtils.Hidden(self.BtnCollapse)
                FightUMG:PlayAnimation(FightUMG.TaskOff)
                --self.BtnUnfold:SetIsEnabled(false)
                print("LevelBtn:PlayAnim hide")
            end
        end
     end
end


function LevelBtn:OnDestruct()
    BtnRemoveEvent(self.BtnUnfold)
    BtnRemoveEvent(self.BtnCollapse)
end

return LevelBtn
