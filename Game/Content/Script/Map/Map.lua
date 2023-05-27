-- ========================================================
-- @File    : Chapter/MapID.lua
-- @Brief   : 地图数据
-- ========================================================
Map = Map or { tbClasses = {}}

-- 棋盘地图id
Map.ChessMapId = 15

---逻辑模板
local tbTemplateLogic = {
    OnEnter     = function(self, nMapID)  end,
    OnLeave     = function(self, nMapID)  end,
    OnLoading   = function(self, nMapID)  end,
}

---进入地图
---@param nMapID number 地图ID
---@param sOption string 附加选项
---@param pCall function 进入回调
---@param bSkipCheck bool 是否跳过检查地图
function Map.Open(nMapID, sOption, pCall, bSkipCheck)
    if bSkipCheck or Map.IsCanOpen(nMapID) then
        UE4.UCrashEyeHelper.CrashEyeLeaveBreadcrumb("open map:" .. nMapID);
        UE4.UMapManager.Open(nMapID, sOption or '')
        Map.pCallEnter = pCall
    end
end

---注册Lua逻辑
---@param sType string 脚本逻辑
function Map.Class(sType)
    if sType == nil or sType == '' then return tbTemplateLogic end
    if Map.tbClasses[sType] then return Map.tbClasses[sType] end;
    local tbLogic = Inherit(tbTemplateLogic);
    tbLogic.sType = sType;
    Map.tbClasses[sType] = tbLogic;
    return tbLogic;
end

---检查是否可以打开
function Map.IsCanOpen(nMapID)
    if nMapID == Map.GetCurrentID() then
       return false
    end
    return true
end

---获取当前地图ID
function Map.GetCurrentID()
   return UE4.UMapManager.GetCurrentID()
end

---获取当前关卡id
function Map.GetCurrentLevelId()
    return UE4.UMapManager.GetCurrentLevelId()
end

function Map.GetGameMode()
    local bFind, mapInfo = UE4.UMapManager.Find(UE4.UMapManager.GetCurrentID())
    if bFind then
        local bSuc, sLeft, sRight  =  UE4.UKismetStringLibrary.Split(mapInfo.GameMode, '.')
        if bSuc then
            return string.sub(sRight, 1, #sRight - 2)
        end
    end
    return ''
end

---获取当前地图的LuaClass
local function GetLuaClass()
    local bFind, mapInfo = UE4.UMapManager.Find(UE4.UMapManager.GetCurrentID())
    if bFind then
        return mapInfo.LuaClass
    end
end

function Map.OnMapChange(nMapID)
    CacheBroadcast.TryPlay()
end

--[[
    响应地图进入 退出 加载 回调
]]
function Map.Enter(nMapID)
    print('Map.Enter:', nMapID)
    if Map.IsFightMap(nMapID) then Map.OnEnterFight() end
    GuideLogic.AddNotifyEvent()
    GM.TryOpenAdin();
    Map.Class(GetLuaClass()):OnEnter(nMapID)
    GM.TryOpenAdin();

    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self,"ShowFlag.Decals 1")
    if Map.pCallEnter then
        Map.pCallEnter()
        Map.pCallEnter = nil
    end

    if WaterMarkLogic.IsShowWaterMark() then
        ---显示水印
        UI.Open("WaterMark")
    end

    HealthTip.TryTip()
end

function Map.Leave(nMapID)
    print('Map.Leave:', nMapID)
    if Map.IsFightMap(nMapID) then Map.OnLevelFight() end
    Map.Class(GetLuaClass()):OnLeave(nMapID)
    if UI.IsOpen("WaterMark") then
        ---关闭水印
        UI.Close("WaterMark")
    end
end

function Map.Loading(nMapID)
    print('Map.Loading:', nMapID)
    Map.Class(GetLuaClass()):OnLoading(nMapID)
end

-- 是不是战斗地图
function Map.IsFightMap(nMapID)
    return nMapID > 10;
end

-- 是不是战斗地图
function Map.InFight()
    return Map.GetCurrentID() > 10 or Map.GetCurrentID() < 0;
end

-- 加载逻辑代码
function Map.LoadLogic()
    local allFiles = UE4.UUMGLibrary.FindFilesInFolder("Script/Map/Classes", ".lua");
    for i = 1, allFiles:Length() do
        local sFile = allFiles:Get(i);
        local pFile = string.gsub(sFile,".lua","")
        require(string.format('Map.Classes.%s', pFile))
    end
end

-- 当进入战斗场景时
function Map.OnEnterFight()
    LaunchLog.SetGamepadUsed(false) -- 重置lua层全局变量
    FragmentStory.ClearRepeat()
end

-- 当离开战斗场景时
function Map.OnLevelFight()
    
end

-- 是不是棋盘地图
function Map.IsChessMap()
    local id = Map.GetCurrentID()
    return (id ==  Map.ChessMapId) or (id >= 801 and id < 900)
end

function Map.IsPlot()
    return Map.GetCurrentID() > 50000
end

Map.LoadLogic()