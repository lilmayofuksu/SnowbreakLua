-- ========================================================
-- @File    : LoginBG.lua
-- @Brief   : 背景
-- ========================================================

---@class LoginBG
LoginBG = LoginBG or {tbCfg = {}}

---获取当前背景信息
function LoginBG.GetBGInfo()
    for nID, info in pairs(LoginBG.tbCfg or {}) do
        if nID ~= 1 then
            return info
        end
    end
   return LoginBG.tbCfg[1]
end

function LoginBG.LoadCfg()
    local tbFile = LoadCsv('function/loginscreen.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local ID = tonumber(tbLine.ID)
        if ID then
            LoginBG.tbCfg[ID] = {
                widget = Eval(tbLine.loginscreen),
                music = tbLine.music
            }
        end
    end
    print('function/loginscreen.txt')
end

LoginBG.LoadCfg()