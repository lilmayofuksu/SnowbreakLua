-- ========================================================
-- @File    : uw_dungeonsonline_reward.lua
-- @Brief   : 联机周积分奖励界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListScore)
    BtnAddEvent(self.BtnClose, function()
        if self.tbFunc then
            self.tbFunc()
        end
        
        UI.Close(self)
    end)

    BtnAddEvent(self.BtnQuick, function()
            self:DoGetAll()
    end)

    self.ListScore:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

--打开界面
function tbClass:OnOpen(funcOnline)
    local tbReward = Online.GetAwardConfig()
    if not tbReward then return end

    self.tbFunc = funcOnline
    self:ShowMain(tbReward)
    self:PlayAnimation(self.AllEnter)
end

--显示主要界面
function tbClass:ShowMain(tbList)
    if not tbList then return end

    self:DoClearListItems(self.ListScore)
    local nScrolIdx = nil
    self.tbAwardList = {}
    for key, tbConfig in ipairs(tbList) do
        local  tbParam = {
            tbConfig  = tbConfig,
            tbGetAllFunc = function() self:DoItemClick()  end,
        }

        if not Online.GetWeeklyAward(tbConfig.nId) then
            if not nScrolIdx then
                nScrolIdx = key
            end
            if Online.GetWeeklyPoint() >= tbConfig.nPoint  then
                table.insert(self.tbAwardList, tbConfig.nId)
            end
        end

        local pObj = self.Factory:Create(tbParam)
        self.ListScore:AddItem(pObj)
    end

    if #self.tbAwardList == 0 then
        WidgetUtils.Collapsed(self.BtnQuick)
    end

    if nScrolIdx  and nScrolIdx > 2 then
        if nScrolIdx == #tbList then
            nScrolIdx = #tbList - 1
        end
        self.ListScore:ScrollIndexIntoView(nScrolIdx)
    end
    self.ListScore:PlayAnimation(-1)
end

function tbClass:DoGetAll()
    if not self.tbAwardList or #self.tbAwardList == 0 then
        UI.ShowTip('tip.reward_not_exist')
        return
    end

    Online.GetAllWeeklyAward(self.tbAwardList)
end

function tbClass:DoItemClick()
    if not self.tbAwardList or #self.tbAwardList == 0 then
        return
    end

    self:DoGetAll()
end

return tbClass
