local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    --获取Unix时间戳
    --self.UnixTime = GetTime()
    self.TimeZones_1:SetText(ZoneTime.Server_Zone or os.date("%z", GetTime()))
    local tbServerInfo = Login.GetServer()
    if tbServerInfo then
        local sAddr, nPort = tbServerInfo.sAddr, tbServerInfo.nPort
        self.TextServerIP:SetText(sAddr .. ":" .. nPort)
   end
end

function tbClass:Tick(MyGeometry, InDelayTime)
    --self.UnixTime = self.UnixTime + InDelayTime
    self.TextServerTime_1:SetText(os.date("%Y-%m-%d %H:%M:%S", math.floor(GetTime())))
end

function tbClass:RefreshResolution()
    local FBL = UE4.UGameUserSettings.GetGameUserSettings():GetScreenResolution()
    local X = FBL.X
    local Y = FBL.Y
    local ScreenPercentage = UE4.UGraphicsSettingManager.GetIntConsoleVariable("r.ScreenPercentage")
    if ScreenPercentage > 0 then
        X = math.floor(X * ScreenPercentage / 100)
        Y = math.floor(Y * ScreenPercentage / 100)
    end
    self.TextScreenResolution:SetText(X .. "*" .. Y)
end

return tbClass
