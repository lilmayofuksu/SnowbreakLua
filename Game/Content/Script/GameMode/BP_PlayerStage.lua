
-- ========================================================
-- @File    :
-- @Brief   : 监听相应的网络消息,通知进行角色展示
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================

local BP_PlayerStage = Class()

function BP_PlayerStage:ReceiveBeginPlay()

end

function BP_PlayerStage:ReceiveShowExhibition()
    UI.Open('Exhibition');
end

function BP_PlayerStage:ReceiveSettlement()
    UI.Open('OnlineSettlement');
end

return BP_PlayerStage
