-----------------------------------------------------------------------------------------------
--  客户端文件CRC检测 (与服务器文件进行比对)
--  2022.02.07
-----------------------------------------------------------------------------------------------

ClientFileCheck = {};

local KEY = "file_crc_next_check_time";

ClientFileCheck.IsOpen = true;

-- 设置是否开启
function ClientFileCheck.SetIsOpen(value)
    ClientFileCheck.IsOpen = value;
end

-- 是否需要检查
function ClientFileCheck:NeedCheck()
    if not self.IsOpen then return end
    local time = UE4.UUserSetting.GetString(KEY, "0") or "0"
    time = tonumber(time) or 0;
    return GetTime() > time;
end

-- 开始检查
function ClientFileCheck:Begin(tbServer)
    if UI.IsOpen("FileCheckRet") then 
        return 
    end

    local sContent = LoadSetting("checks.txt");
    if #sContent == 0 then 
        return self:Diff(tbServer, {}) 
    end

    sContent = string.gsub(sContent, "\r\n", "\n");
    sContent = string.gsub(sContent, "\r", "\n");

    local tbLine = Split(sContent, "\n");
    local tbRets = {};

    table.insert(tbRets, {"checks.txt", UE4.UGameLibrary.GetFileCRC("checks.txt")});

    for i = 1, #tbLine do 
        local path = tbLine[i];
        if not string.find(path, ";") and string.find(path, "%.") then 
            if string.find(path, "->") then
                path = Split(path, "->")[1];
            end
            table.insert(tbRets, {path, UE4.UGameLibrary.GetFileCRC(path)})
        else 
            table.insert(tbRets, {"", 0});
        end
    end

    self:Diff(tbServer, tbRets);
end

-- 检查结果比较
function ClientFileCheck:Diff(tbServer, tbClient)
    local count = math.min(#tbServer, #tbClient);
    local tbRets = {};
    for i = 1, count do 
        if tbServer[i] ~= tbClient[i][2] then 
            table.insert(tbRets, tbClient[i][1]);
        end
    end

    if #tbRets > 0 then
        UI.Open("FileCheckRet", tbRets, count - 3, function(nextDeltaTime) 
            UE4.UUserSetting.SetString(KEY, tostring(GetTime() + nextDeltaTime))
            UE4.UUserSetting.Save();
        end); 
    end
end

-- 尝试打开界面
function ClientFileCheck:TryOpen(tbParam)
    local notice = Notice.CheckOpen() 
    local tbUI = {"Notice", "ActiviyFace", "SignDay", "ShortSign", "WeekSign1", "WeekSign2", "WeekSign3"}
    for _, name in ipairs(tbUI) do 
        if notice or UI.IsOpen(name) then 
            UE4.Timer.Add(0.25, function() 
                ClientFileCheck:TryOpen(tbParam)
            end)
            return 
        end
    end
    ClientFileCheck:Begin(tbParam)
end

s2c.Register("do_server_file_check.rsp", function (tbParam)
    UE4.Timer.Add(1, function()
        ClientFileCheck:TryOpen(tbParam)
    end)
end)

--- 登录时检查配置表是否一致
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if bReconnected then return end

    if GM.IsOpenUI() and ClientFileCheck:NeedCheck() then
        me:CallGS("do_server_file_check")    
    end
end)

