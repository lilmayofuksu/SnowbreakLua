----------------------------------------------------------------------------------
-- @File    : OpenWorldClient.lua
-- @Brief   : 开放世界数据管理 客户端
----------------------------------------------------------------------------------

---@class OpenWorldClient 开放世界客户端
OpenWorldClient = {}

-- 当前任务列表
-- 主线任务id在数组的前面
OpenWorldClient.tbTaskIds = {}

--- 任务更新回调
OpenWorldClient.onUpdateTaskCallBack = nil;


----------------------------------------------------------------------------------

function OpenWorldClient.RefreshTaskList()
    OpenWorldClient.tbTaskIds = OpenWorldMgr.GetCurrentTaskIds()
end

--- 设置任务完成
function OpenWorldClient.SetTaskComplete(taskId)
    print("call gs OpenWorldClient.SetTaskComplete", taskId);

    if RunFromEntry then
        me:CallGS("open_world.set_task_complete", json.encode({taskId = taskId}))
    else 
        for i = #OpenWorldMgr.tbDebugTaskIds, 1, -1 do 
            if OpenWorldMgr.tbDebugTaskIds[i] == taskId then
                table.remove(OpenWorldMgr.tbDebugTaskIds, i)
            end
        end
    end
end

--- 设置巡逻怪死亡
function OpenWorldClient.SetTaskPatrolOK(npcUId, npcTplId)
    print("SetTaskPatrolOK", npcUId, npcTplId);
    me:CallGS("open_world.set_patrol_complete",json.encode({uid = npcUId, tplid = npcTplId}))    
end

--- 设置物件状态【针对自动生成的配置表，如可破坏物，大门】
function OpenWorldClient.SetObjectState(objectId, state)
    print("SetObjectState", objectId);
    me:CallGS("open_world.set_object_state",json.encode({uid = objectId, state = state}))    
end

--- 设置宝箱状态【针对人工维护的配置表，如宝箱】
function OpenWorldClient.SetItemBoxState(boxId, state)
    print("SetItemBoxState", boxId);
--    me:CallGS("open_world.set_itembox_state",json.encode({uid = boxId, state = state}))    
end

--- 请求领取探索度奖励
function OpenWorldClient.ApplyExploreAward(index)
    if not OpenWorldMgr.CheckExploreAwardState(index) then 
       return UI.ShowTip('探索度不足哟~')
    end 
    me:CallGS("open_world.get_explore_award",json.encode({index = index}))    
end

function OpenWorldClient.NotifyGainAwards(tbReward)
    for _, item in ipairs(tbReward) do 
        local item = UE4.UItemLibrary.GetItemTemplateByGDPL(item[1], item[2], item[3], item[4])
        local name = Text(item.I18N)
        EventSystem.Trigger(Event.ShowFightTip, string.format("获得 %s * %d", name, item[5] or 1))
    end
end


----------------------------------------------------------------------------------
-- 得到小地图Debug数据
function OpenWorldClient.GetMapDebugData()
    local world = GetGameIns():GetWorld()
    local levelName = string.lower(UE4.UGameplayStatics.GetCurrentLevelName(world))
    return OpenWorldMgr.LoadMapDebugData(levelName)
end



----------------------------------------------------------------------------------
--- 通知更新任务
s2c.Register("open_world.set_task_complete.rsp", function (tbParam)
    print(" open_world.notify_update_task ");
    OpenWorldClient.RefreshTaskList()
    
    if OpenWorldClient.onUpdateTaskCallBack then 
        OpenWorldClient.onUpdateTaskCallBack()
    end

    if tbParam.tbAwards then 
        OpenWorldClient.NotifyGainAwards(tbParam.tbAwards);
    end
    UI.ShowTip('任务已完成')
end)

--- 通知巡逻怪领奖成功
s2c.Register("open_world.set_patrol_complete.rsp", function (tbParam)
    print(" open_world.set_patrol_complete.rsp ", tbParam.money);
    if tbParam.money and tbParam.money > 0 then
        EventSystem.Trigger(Event.ShowFightTip, string.format("代币 +%d", tbParam.money))
    end
end)

--- 通知设置物件状态成功
s2c.Register("open_world.set_object_state.rsp", function (tbParam)
    print(" open_world.set_object_state.rsp ", tbParam.uid, tbParam.state);
    local tbReward = OpenWorldMgr.GetObjectReward(tbParam.uid)
    if tbReward then
        OpenWorldClient.NotifyGainAwards(tbReward);
    end
end)

--- 通知探索度奖励领取成功
s2c.Register("open_world.get_explore_award.rsp", function(tbParam)
    print(" open_world.get_explore_award.rsp ", tbParam.index);
    EventSystem.Trigger(Event.OWExploreAwardSync, tbParam)
    if tbParam.ok then 
        local tbAwards = OpenWorldMgr.GetAllExploreAward()
        local tbCfg = tbAwards[tbParam.index]
        Item.Gain(tbCfg.tbItems)
    end
end)

--- 通知刷新任务
s2c.Register("open_world.refresh_task", function (tbParam)
    print("open_world.refresh_task ");
    EventSystem.Trigger(Event.NotifyRefreshOWTask)
end)


--- 通知设置宝箱状态成功
-- s2c.Register("open_world.set_itembox_state.rsp", function (tbParam)
--     print(" open_world.set_itembox_state.rsp ");
-- end)


----------------------------------------------------------------------------------