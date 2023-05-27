-- ========================================================
-- @File    : S2CCall.lua
-- @Brief   : 服务器远程调用客户端脚本接口处理
-- @Author  : Leo Zhao
-- @Date    : 2020-01-13
-- ========================================================

---开放API给服务器的接口工具
---@class s2c
---@field tbCmds table 已注册的API接口
s2c = s2c or { tbCmds = {} };

---注册客户端API
---@param sCmd string 接口名
---@param fProc function 接口实现
function s2c.Register(sCmd, fProc)
    if type(fProc) ~= 'function' then
        error('s2c.Register #2 must be function! Command: ' .. sCmd)
    elseif s2c.tbCmds[sCmd] then
        error('s2c.Register command[' .. sCmd .. '] already registered.')
    else
        s2c.tbCmds[sCmd] = fProc;
    end    
end

---分发指令
---@param sCmd string API接口名
---@param sParam string JSON格式的参数
function s2c.Dispatch(sCmd, sParam)
    local f = s2c.tbCmds[sCmd];
    if not f then
        error('s2c.Dispatch error. No command named: ' .. sCmd);
    else
        f(json.decode(sParam));
    end
end