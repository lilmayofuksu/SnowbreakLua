-- ========================================================
-- @File    : uw_fight_teammate_item.lua
-- @Brief   : 战斗界面 联机战斗队伍信息
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    if not self.IsOnlineClient then 
        WidgetUtils.Collapsed(self)
        return;
    end

    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible);
    local tbWidget = {self.Member1, self.Member2}  -- 暂定2个队友
    local widgetIndex = 0;
    local maxPlayer = UE4.UAccount.GetOnlineTeamMemberCount();

    -- 把队友与UI绑定起来
    for i = 1, maxPlayer do 
        local account = UE4.UAccount.GetOnlineMember(i - 1)
        if account and account:Id() ~= me:Id() then 
            widgetIndex = widgetIndex + 1
            local widget = tbWidget[widgetIndex]
            if widget then 
                widget:InitPlayer(account:Id())
            end
        end
    end
    
    for i = widgetIndex + 1, #tbWidget do 
        WidgetUtils.Collapsed(tbWidget[i])
    end
end

return tbClass
