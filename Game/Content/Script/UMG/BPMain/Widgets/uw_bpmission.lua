-- ========================================================
-- @File    : uw_bpmission.lua
-- @Brief   : bp通行证任务界面
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
	self.Factory = Model.Use(self)
    self.ListMission:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnActive(ShowType, tbConfig)
	self.nShowType = ShowType
    self.tbConfig = tbConfig
	self:ShowMain()
	self:ShowMissionList(true)
end

function tbClass:OnClose()
    self.tbConfig = nil
    self.nShowType = nil
end

--显示主界面
function tbClass:ShowMain()
	WidgetUtils.Collapsed(self.Active)
    WidgetUtils.Collapsed(self.Npc)

    if not self.tbConfig then 
        return 
    end

    if self.tbConfig.tbNpcImgItem and #self.tbConfig.tbNpcImgItem >= 4 then
        WidgetUtils.SelfHitTestInvisible(self.Npc)

        local temp = UE4.UItem.FindTemplate(self.tbConfig.tbNpcImgItem[1], self.tbConfig.tbNpcImgItem[2], self.tbConfig.tbNpcImgItem[3], self.tbConfig.tbNpcImgItem[4])
        print("======", temp.Icon)
        AsynSetTexture(self.Npc, temp.Icon)
    end
end

--显示任务
function tbClass:ShowMissionList(bReset)
    self:DoClearListItems(self.ListMission)

    if (self.nShowType == BattlePass.SHOW_DAILY or self.nShowType == BattlePass.SHOW_WEEKLY) and BattlePass.CheckWeeklyExp() then return end

    local tbShowList = BattlePass.GetMissionList(self.nShowType)
    if not tbShowList or #tbShowList == 0 then return end

    local tbfinished = {}      --已完成未领取
    local tbnotFinished = {}   --进行中
    local tbreceived = {}      --已领取
    for _, nMissionId in ipairs(tbShowList) do
    	local tbMission = Achievement.GetQuestConfig(nMissionId)
        if tbMission and Achievement.IsPreFinished(tbMission) then
            local situation = Achievement.CheckAchievementReward(tbMission)
            if situation == Achievement.STATUS_GOT then
               if tbMission.nReceivedShow > 0 then table.insert(tbreceived, tbMission) end
            elseif situation == Achievement.STATUS_CAN then
                local tbNew = Copy(tbMission)
                tbNew.tbGotFunc = function()  self:DoGotAward(nMissionId) end
                table.insert(tbfinished, tbNew)
            else
                table.insert(tbnotFinished, tbMission)
            end
        end
    end
    for i, v in ipairs(tbfinished) do
        local pObj = self.Factory:Create(v)
        self.ListMission:AddItem(pObj)
    end
    for i, v in ipairs(tbnotFinished) do
        local pObj = self.Factory:Create(v)
        self.ListMission:AddItem(pObj)
    end
    for i, v in ipairs(tbreceived) do
        local pObj = self.Factory:Create(v)
        self.ListMission:AddItem(pObj)
    end

    if bReset then
        self.ListMission:ScrollIndexIntoView(0)
    end
end

function tbClass:DoGotAward(nId)
    if not nId then 
        return
    end

    BattlePass.DoGetMission(self.nShowType - 1, {nId})
end

return tbClass