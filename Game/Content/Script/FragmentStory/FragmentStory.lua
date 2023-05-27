-- ========================================================
-- @File    : FragmentStory/FragmentStory.lua
-- @Brief   : 碎片化叙事
-- ========================================================

FragmentStory = FragmentStory or {}

FragmentStory.GID = 11
FragmentStory.tbTempTriggered = {}
FragmentStory.tbRepeat = {}
FragmentStory.RoleId = 0

FragmentStory.Type = {
    ['Area'] = 1,
    ['Special'] = 2,
    ['Info'] = 3,
    ['Log'] = 4,
    ['Record'] = 5,
    ['Report'] = 6,
}

function FragmentStory.LoadConfig()
    FragmentStory.tbConfig = {}
    FragmentStory.tbGroup = {}
    local tbFile = LoadCsv('fragmentstory/fragment_story.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine.ID) or 0
        if Id > 0 then
            local tb = {}
            tb.nId = Id
            tb.sTitle = tbLine.Title and 'fragment_story.' .. tbLine.Title or nil
            tb.sDesc = tbLine.Desc and 'fragment_story.' .. tbLine.Desc or nil
            tb.sContent = tbLine.Content and 'fragment_story.' .. tbLine.Content or nil
            tb.nIcon = tonumber(tbLine.Icon) or 0
            tb.nType = tonumber(tbLine.Type)
            tb.sSimpleDialogue = tbLine.SimpleDialogue
            tb.nGroup = tonumber(tbLine.Group) or 0
            tb.bIgnoreDiff = tonumber(tbLine.IgnoreDiff or '0') == 1
            tb.bCanRepeat = tonumber(tbLine.CanRepeat or '0') == 1
            tb.sWwise_event = tbLine.Wwise_event or nil
            tb.sChapter = tonumber(tbLine.Chapter) or 0
            tb.nLevel = tonumber(tbLine.Level) or 0
            -- tb.VoiceID = tbLine.VoiceID
            -- tb.CharacterID = tonumber(tbLine.CharacterID) or 0
            if tb.nGroup > 0 then
               FragmentStory.tbGroup[tb.nGroup] = FragmentStory.tbGroup[tb.nGroup] or {}
               table.insert(FragmentStory.tbGroup[tb.nGroup], tb)
            end
            FragmentStory.tbConfig[Id] = tb
        end
    end
end

-- 清空所有碎片化叙事任务变量 - GM指令
function FragmentStory.ClearAllTaskValue()
    for _, tb in pairs(FragmentStory.tbConfig) do
        if me:GetAttribute(FragmentStory.GID, tb.nId) ~= 0 then
            me:SetAttribute(FragmentStory.GID, 0)
        end    
        tb.bCanRepeat = true
    end
end

function FragmentStory.Show(ID, IsGroup)
    local FragmentId = 0
    if IsGroup then
        if not FragmentStory.tbGroup[ID] then return end
        local tbCanShow = {}
        for _, v in ipairs(FragmentStory.tbGroup[ID]) do
            if me:GetAttribute(FragmentStory.GID, v.nId) == 0 then
                table.insert(tbCanShow, v)
            end
        end
        if #tbCanShow == 0 then return end
        FragmentId = tbCanShow[math.random(#tbCanShow)].nId
    else
        FragmentId = ID
    end

    local conf = FragmentStory.tbConfig[FragmentId]
    if not conf and not FragmentStory.IsIgnore(FragmentId) then return end
    if FragmentStory.CheckTriggered(FragmentId, true) and not conf.bCanRepeat then return end

    if me:GetAttribute(FragmentStory.GID, FragmentId) == 0 then
        me:SetAttribute(FragmentStory.GID, FragmentId, 1)
        me:CallGS("RikiLogic_AddExploreRiki",FragmentId)
    end

    UI.SafeOpen('DialoguePieces', conf)

    if conf.sSimpleDialogue and conf.sSimpleDialogue ~= '' and not FragmentStory.IsRepeat(FragmentId) then
        UE4.Timer.NextFrame(function()
            local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
            subsytem:ApplyOpen(UE4.EUIDialogueType.SimplePlot, conf.sSimpleDialogue);
        end)
    end
end

function FragmentStory.GetGroupProgress(GroupID)
    if not FragmentStory.tbGroup[GroupID] then return 0, 1 end
    local GotNum = 0
    for _, v in ipairs(FragmentStory.tbGroup[GroupID]) do
        if FragmentStory.CheckTriggered(v.nId) then
            GotNum = GotNum + 1
        end
    end
    return GotNum, CountTB(FragmentStory.tbGroup[GroupID])
end

function FragmentStory.IsGot(Id)
    local conf = FragmentStory.tbConfig[Id]
    if not conf then return true end
    if FragmentStory.IsIgnore(Id) then return true end
    if conf.bCanRepeat then return false end
    return FragmentStory.CheckTriggered(Id)
end

-- 返回INT 蓝图用
function FragmentStory.Check(Id, IsGroup)
    Id = tonumber(Id) or 0
    if IsGroup == 'true' then
        if not FragmentStory.tbGroup[Id] then return 0 end
        for _, v in ipairs(FragmentStory.tbGroup[Id]) do
            if me:GetAttribute(FragmentStory.GID, v.nId) == 0 then return 1 end
        end
        return 0
    else
        local conf = FragmentStory.tbConfig[Id]
        if not conf then return 0 end
        if FragmentStory.IsIgnore(Id) then return 0 end
        if conf.bCanRepeat then return 1 end
        return FragmentStory.CheckTriggered(Id) and 0 or 1
    end
end

function FragmentStory.AddDropHandle()
    local handle = EventSystem.On(Event.OnPickupDrop, function(InPlayerController, InDrop)
        if InDrop.FragmentStoryInfo.IsFragmentDrop then
            local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
            local info = InDrop.FragmentStoryInfo
            local param = info.IsGroupFragment and "1" or "0"
            subsytem:ApplyOpen(UE4.EUIDialogueType.FragmentStory, info.FragmentId, param);
        end
    end)
    TaskCommon.AddHandle(handle)
end

function FragmentStory.CheckTriggered(checkId, bTrigger)
    if FragmentStory.RoleId == 0 or FragmentStory.RoleId ~= me:Id() then
        FragmentStory.tbTempTriggered = {}
        FragmentStory.RoleId = me:Id()
    end
    if me:GetAttribute(FragmentStory.GID, checkId) == 1 then return true end
    for _, id in pairs(FragmentStory.tbTempTriggered) do
        if checkId == id then
            return true
        end
    end
    if bTrigger then
        table.insert(FragmentStory.tbTempTriggered, checkId)
    end
    return false
end

function FragmentStory.IsIgnore(nId)
    local conf = FragmentStory.tbConfig[nId]
    if not conf then return true end
    if conf.bIgnoreDiff and Launch.GetType() == LaunchType.CHAPTER and Chapter.GetChapterDifficult() ~= CHAPTER_LEVEL.EASY then
        return true
    end
end

function FragmentStory.ClearRepeat()
    FragmentStory.tbRepeat = {}
end

function FragmentStory.IsRepeat(nId)
    local conf = FragmentStory.tbConfig[nId]
    if not conf or not conf.bCanRepeat then return false end
    if not FragmentStory.tbRepeat[nId] then
        FragmentStory.tbRepeat[nId] = true
        return false
    else
        return true
    end
end

EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if not me then return end
    if FragmentStory.RoleId ~= me:Id() then
        FragmentStory.tbTempTriggered = {}
        return
    end
    for _, id in pairs(FragmentStory.tbTempTriggered) do
        if me:GetAttribute(FragmentStory.GID, id) == 0 then
            me:SetAttribute(FragmentStory.GID, id, 1)
            me:CallGS("RikiLogic_AddExploreRiki",id)
        end
    end
    FragmentStory.tbTempTriggered = {}
end)

FragmentStory.LoadConfig()