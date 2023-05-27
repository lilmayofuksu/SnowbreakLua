-- ========================================================
-- @File    : Notice.lua
-- @Brief   : 公告
-- ========================================================

---@class Notice 公告
---@field tbCacheNotice table 缓存公告信息
Notice = Notice or {tbCacheNotice = {}}

require('Notice.NOTICE_TTF')
require('Notice.CacheBroadcast')
require('Notice.HealthTip')

---@class NOTICE_TYPE 公告类型定义
NOTICE_TYPE = {}
NOTICE_TYPE.ACTIVE = 1 ---活动公告
NOTICE_TYPE.SYSTEM = 0 ---系统公告

local SAVE_HEAD = 'NOTICE_SAVE_HEAD_'


---是否弹出公告
---@return boolean
function Notice.CheckOpen()
    if not FunctionRouter.IsOpenById(FunctionType.Notice) then return false end

    if Notice.Opened then return false end

    local bMustNewNotice = PlayerSetting.GetOne(PlayerSetting.SSID_OTHER, OtherType.NOTICE_DISTURB) == 1
    if bMustNewNotice then return Notice.HaveNew() end

    ---功能开发判断
    local bUnLock, _ = FunctionRouter.IsOpenById(FunctionType.Notice)
    if not bUnLock then return false end

    ---今日是否弹出判断
    local nPopFlag = me:GetAttribute(PlayerSetting.GID, PlayerSetting.SID_NOTICE) or 0
    return nPopFlag == 0
end

---打开公告UI
function Notice.OpenUI()
    FunctionRouter.GoTo(FunctionType.Notice)
end

---清除保存的数据
function Notice.ClearSaveData()
    me:SetAttribute(PlayerSetting.GID, PlayerSetting.SID_NOTICE, 0)
end

-----------------------
 
---获取保存Key
local GetSaveKey = function(tbInfo)
    return SAVE_HEAD .. UE4.UUMGLibrary.GetStringHash(tbInfo.title or '') --Md5.sumhexa(tbInfo.title)
end

local GetContentServer = function()
    return Login.GetContent()
end


---是否有新公告
function Notice.HaveNew()
    for _, tbInfo in ipairs(Notice.tbCacheNotice) do
        local bRead = Notice.IsRead(tbInfo)
        if not bRead then return true end
    end
    return false
end

---是否已读
---@param tbInfo table
function Notice.IsRead(tbInfo)
    return UE4.UUserSetting.GetBool(GetSaveKey(tbInfo), false)
end

---阅读公告信息
---@param tbInfo table 公告信息
function Notice.ReadNotice(tbInfo)
    local sSaveKey = GetSaveKey(tbInfo)
    print('ReadNotice:', sSaveKey)
    UE4.UUserSetting.SetBool(sSaveKey, true)
    ---更新红点信息
    Notice.UpadteNewInfo()
end

function Notice.Refresh()
    Notice.PullNotice(true)
end

---拉取公告信息
---@param funBack function 拉取后的回调
function Notice.RefreshCallBack(funBack)
    local sContentServer = GetContentServer()
    if #sContentServer == 0 then
        if funBack then funBack() end
    end
    Download(string.format('%snotice?pid=%s&channel=%s&subchannel=%s', sContentServer, me:Id(), me:Channel(), me:SubChannel()), function(_, sData)
        Notice.tbCacheNotice = json.decode(sData) or {};
        if funBack then funBack() end
    end);
end

---拉取公告信息
---@param bCheck boolean 拉取后是否打开
function Notice.PullNotice(bCheck)
    if not (DSAutoTestAgent.bOpenAutoAgent and DSAutoTestAgent.bRunNullRhi) then
        local sContentServer = GetContentServer()
        if #sContentServer == 0 then return end
        Download(string.format('%snotice?pid=%s&channel=%s&subchannel=%s', sContentServer, me:Id(), me:Channel(), me:SubChannel()), function(_, sData)
            Notice.tbCacheNotice = json.decode(sData) or {};
            if not bCheck and Notice.Opened then
                Notice.Recive()
            elseif bCheck and Notice.CheckOpen() then
                Notice.OpenUI()
            end
        end);
    end
end

function Notice.Recive()
    Notice.UpadteNewInfo()
    UI.Call2('Notice', 'Refresh', Notice.tbCacheNotice)
end

function Notice.Test()
    Notice.tbCacheNotice = {
        { left_title = "测试2", title = "测试title", type = 1, content = "http://www.baidu.com", start_time = GetTime(), weight = 1},
        { left_title = "测试22", title = "测试title2", type = 0, content = "http://www.baidu.com", start_time = GetTime(), weight = 1},
        { left_title = "测试32", title = "测试title3", type = 1, content = "http://www.baidu.com", start_time = GetTime(), weight = 1},
    }
    Notice.Recive()
end

function Notice.Print()
    print('==============================')
    Dump(Notice.tbCacheNotice or {})
end


---清除读取标记
function Notice.ClearRead()
    for _, tbInfo in ipairs(Notice.tbCacheNotice) do
        UE4.UUserSetting.SetBool(GetSaveKey(tbInfo), false)
    end
    Notice.UpadteNewInfo()
end

function Notice.UpadteNewInfo()
    UI.Call2('Main', 'RefreshRedInfo', FunctionType.Notice)
    UI.Call2('Notice', 'UpdateRedInfo')
end

