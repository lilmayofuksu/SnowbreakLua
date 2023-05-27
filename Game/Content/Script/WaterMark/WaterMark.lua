-- ========================================================
-- @File    : WaterMark.lua
-- @Brief   : 水印显示
-- ========================================================

WaterMarkLogic = WaterMarkLogic or {}

--- 加载配置
function WaterMarkLogic.LoadCfg()
    --水印配置
    WaterMarkLogic.tbCfg = {}
    local tbFile = LoadCsv("watermark/watermark.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID         = nID,
                sName       = tbLine.Name or "",
            };

            tbInfo.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nStartTime")
            tbInfo.nEndTime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEndTime")

            WaterMarkLogic.tbCfg[nID] = tbInfo
        end
    end
    print("watermark/watermark.txt")
end

--是否显示水印
function WaterMarkLogic.IsShowWaterMark()
    if me and me:Id() ~= 0 then
        return UE4.UGameLibrary.GetGameIni_Bool("Distribution", "WaterMark", false);
    end
    return false
end

function WaterMarkLogic.GetServrName()
    local time = GetTime()
    for _, info in pairs(WaterMarkLogic.tbCfg) do
        if IsInTime(info.nStartTime, info.nEndTime, time) then
            return Text(info.sName)
        end
    end
    return ""
end

WaterMarkLogic.LoadCfg()
return WaterMarkLogic