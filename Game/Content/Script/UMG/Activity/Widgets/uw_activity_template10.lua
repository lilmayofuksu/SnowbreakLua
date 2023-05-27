-- ========================================================
-- @File    : uw_activity_template10.lua
-- @Brief   : 首充活动模板
-- ========================================================

local tbActiveContent10 = Class("UMG.BaseWidget")

function tbActiveContent10:Construct()
    self.Factory = Model.Use(self)

    BtnAddEvent(
        self.BtnGo, 
        function()
            local tbConfig = Activity.GetActivityConfig(self.nActivityId)
            if tbConfig and tbConfig.sGotoUI then
                UI.Open(tbConfig.sGotoUI, table.unpack(tbConfig.tbUIParam))
            end
        end
    )
end

function tbActiveContent10:OnOpen(tbParam)
    self.nActivityId = tbParam.nActivityId
    self:ShowMain()
end

--显示当前界面
function tbActiveContent10:ShowMain()
    local tbConfig = Activity.GetActivityConfig(self.nActivityId)
    if not tbConfig then
        return
    end

    self:ShowAward(tbConfig.tbCustomData)
    self:DoGetAward()
end

function tbActiveContent10:ShowAward(tbRewards)
    local bGet =  (Activity.GetDiyData(self.nActivityId, 1) > 0)
    if bGet then
        WidgetUtils.Collapsed(self.BtnGo)
    end

    self:DoClearListItems(self.ListReward)
    if tbRewards and #tbRewards > 0 then
        for _, item in ipairs(tbRewards) do
            local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5], bGeted = bGet}
            local pObj = self.Factory:Create(cfg)
            self.ListReward:AddItem(pObj)
        end
    end
end

function tbActiveContent10:DoGetAward()
    if me:Charged() <= 0 or Activity.GetDiyData(self.nActivityId, 1) > 0 then
        return
    end

    local cmd = {nId = self.nActivityId, }
    Activity.Quest_GetAward(cmd, true)
end

return tbActiveContent10