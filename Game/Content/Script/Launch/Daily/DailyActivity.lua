-- ========================================================
-- @File    : Launch/Daily/DailyActivity.lua
-- @Brief   : 日常副本活动信息
-- ========================================================
DailyActivity = DailyActivity or {}

local Type2WidgetPath = {
    [1] = "/Game/UI/UMG/DungeonsResourse/Widgets/uw_dungeons_resourse_tag_drop.uw_dungeons_resourse_tag_drop_C",
    [2] = "/Game/UI/UMG/DungeonsResourse/Widgets/uw_dungeons_resourse_tag_cost.uw_dungeons_resourse_tag_cost_C",
    [3] = "/Game/UI/UMG/DungeonsResourse/Widgets/uw_dungeons_resourse_tag_limit.uw_dungeons_resourse_tag_limit_C"
}

---获取开放的活动
---@param nID Integer 配置ID
function DailyActivity.GetOpenActivity(nID)
    local cfg = Daily.GetCfgByID(nID)
    if not cfg or not cfg.tbActivity then return end
    local tbRet = {}
    -- Dump(cfg.tbActivity)
    -- for k,tbActivity in pairs(cfg.tbActivity) do
        for _, tbInfo in pairs(cfg.tbActivity) do
            if IsInTime(ParseTime(tbInfo[1]), ParseTime(tbInfo[2]), GetTime()) then
                table.insert(tbRet, tbInfo[3])
            end
        end
    -- end
    --Dump(tbRet)
    return tbRet
end


---显示活动标签
---@param pContent UWrapBox
---@param nID Integer
function DailyActivity.ShowTag(pContent, nID)
    if not pContent then return end
    pContent:ClearChildren()
    local tbActivity = DailyActivity.GetOpenActivity(nID)
    if not tbActivity or #tbActivity == 0 then return end
    local bHasActivity = false
    for _, id in ipairs(tbActivity) do
        -- print("ShowTag,nID:",nID," id:",id)
        local pWidget = LoadWidget(Type2WidgetPath[id])
        if pWidget then
            pContent:AddChild(pWidget)
            bHasActivity = true
        end
        
    end
    -- if bHasActivity == true then
    --     local pWidget = LoadWidget(Type2WidgetPath[3])
    --     if pWidget then
    --         pContent:AddChild(pWidget)
    --     end
    -- end
end

