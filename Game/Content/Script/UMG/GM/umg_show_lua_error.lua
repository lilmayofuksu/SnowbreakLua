-- ========================================================
-- @File    : umg_show_lua_error.lua
-- @Author  : leiyong
-- @Date    : 2022.02.16
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function()  
        UE4.UGMLibrary.ClearAllLuaError()
        UI.Close(self) 
    end)
    
    BtnAddEvent(self.BtnCloseEx, function() 
        DontShowLuaErrorUI = true;
        UE4.UGMLibrary.ClearAllLuaError()
        UI.Close(self) 
    end)

    BtnAddEvent(self.BtnCopy, function() self:OnBtnClickCopy() end)
end

function tbClass:OnOpen(tbRets)
    self.Title:SetText(string.format("发现 %d 条脚本报错，请复制至项目大群，让程序同学看看是什么情况", UE4.UGMLibrary.GetLuaErrorCount()))
    self.Env:SetText(self:GetEnvDesc());
    self.Value:SetText(UE4.UGMLibrary.GetAllLuaError());
end

function tbClass:OnBtnClickCopy()
    local luaError = UE4.UGMLibrary.GetAllLuaError();
    local envDesc = self:GetEnvDesc();
    local count = UE4.UGMLibrary.GetLuaErrorCount()
    local msg = string.format("客户端发现 %d 条报错，还请程序同学看看是什么情况:\n运行环境:\n%s\n\n报错情况:\n%s", count, envDesc, luaError);
    UE4.UGMLibrary.ClipboardCopy(msg)
end

function tbClass:GetEnvDesc()
    local tbServer = Login.GetServer() or {}
    local addr = string.format("%s(%s)", tbServer.sAddr or "", tbServer.sName or "")
    local roleName = me:Nick()
    local roleId = me:Id()
    local openUI = self:GetOpenUIList()
    local plat = self:GetPlatformName()
    local time = os.date("%Y-%m-%d %H:%M:%S", math.floor(GetTime()))
    local version = UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "0");
    return string.format("服务器: %s 时间: %s\n角色名: %s 角色id: %s 打开的UI列表: %s 平台: %s 版本号: %s", addr, time, roleName, roleId, openUI, plat, version)
end

function tbClass:GetOpenUIList()
    local tbList = {}
    for _, w in pairs(UI.tbWidget) do
        if w.sName ~= "showluaerror" and w.sName ~= "adingm" then 
            table.insert(tbList, w.sName);
        end
    end
    return table.concat(tbList, ",")
end

function tbClass:GetPlatformName()
    if UE4.UGameLibrary.IsEditorMobile() then 
        return "EditorMobile";
    end
    local name = UE4.UGameplayStatics.GetPlatformName()
    if UE4.UGMLibrary.IsEditor() then 
        name = name .. "-Editor"
    end
    return name;
end

return tbClass
