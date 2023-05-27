----------------------------------------------------------------------------------
-- @File    : CartoonGameMode.lua
-- @Brief   : 剧情测试场景
----------------------------------------------------------------------------------

local tbClass = Class()

function tbClass:ReceiveBeginPlay()
    print("CartoonGameMode ReceiveBeginPlay--------------");
    --WidgetUtils.ShowMouseCursor(self, true)
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, "DisableAllScreenMessages")
end


function tbClass:ReceiveEndPlay()
    print("CartoonGameMode ReceiveEndPlay");
    
end

----------------------------------------------------------------------------------
return tbClass
----------------------------------------------------------------------------------