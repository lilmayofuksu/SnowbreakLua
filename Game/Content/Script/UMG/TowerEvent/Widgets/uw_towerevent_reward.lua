-- ========================================================
-- @File    : uw_towerevent_chapter.lua
-- @Brief   : 爬塔-战术考核章节选择界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListScore)

    BtnAddEvent(self.BtnClose, function()
        EventSystem.TriggerTarget(TowerEventChapter, 'CloseAwardList')
    end)
    BtnAddEvent(self.BtnQuick, function()
        TowerEvent.GetReward(self.nChapterID)
    end)
end

function tbClass:UpdateRewards(Chapter)
    self.nChapterID = Chapter.nID
    local nPassLevel = 0
    local nTotalLevel = #Chapter.tbLevel
    local RewardCfg = TowerEvent.tbAwardConf[Chapter.nID]
    if not RewardCfg then
        return
    end

    for _, LevelID in pairs(Chapter.tbLevel) do
        local Level = TowerEventLevel.Get(LevelID)
        if Level and Level:IsPass() then
            nPassLevel = nPassLevel + 1
        end
    end

    local num = 0
    self:DoClearListItems(self.ListScore)
    for i = 1, #RewardCfg.tbLevelCount do
        local LevelCount = RewardCfg.tbLevelCount[i]
        local tbAward = RewardCfg.tbChapterAward[i]
        if LevelCount and tbAward then
            local nType = 0
            local CompletionPer = math.ceil(LevelCount * 100 / nTotalLevel)
            if nPassLevel >= LevelCount then
                if TowerEvent.IsReceive(self.nChapterID, i) then
                    nType = 2
                else
                    num = num + 1
                    nType = 1
                end
            end
            local tbParam = {
                nChapterID = Chapter.nID,
                nGroup = i,
                LevelCount = LevelCount,
                tbAward = tbAward,
                nType = nType,
                CompletionPer = CompletionPer,
            }

            local tbItem = self.Factory:Create(tbParam)
            self.ListScore:AddItem(tbItem)
        end
    end

    self.TxtNum:SetText(math.ceil(nPassLevel * 100 / nTotalLevel))
    if num >= 1 then
        WidgetUtils.Visible(self.BtnQuick)
    else
        WidgetUtils.Collapsed(self.BtnQuick)
    end
end
return tbClass