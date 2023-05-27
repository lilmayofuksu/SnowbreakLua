----------------------------------------------------------------------------------
-- @File    : CartoonMgr.lua
-- @Brief   : 剧情管理 
----------------------------------------------------------------------------------

---@class CartoonMgr 剧情管理
CartoonMgr = CartoonMgr or {}
local MapId = 31

function CartoonMgr:InitCmd()
    Designer.Register("run_cartoon", self.cmd_run_cartoon)
    Designer.Register("stop_cartoon", self.cmd_stop_cartoon)
    Designer.Register("apply_cartoon_state", self.cmd_apply_cartoon_state)
    Designer.Register("apply_object_list", self.cmd_apply_object_list)
end

function CartoonMgr.cmd_run_cartoon(tbParam)
    print("cmd_run_cartoon");
    local self = CartoonMgr
    local mapId = Map.GetCurrentID();
    if mapId <= 0 then 
        mapId =  UE4.UMapManager.GetMapIdByGameInstance(GetGameIns());
    end
    self:DebugPlay(tbParam)
    return "run_cartoon_rsp;state:1"
end

function CartoonMgr.cmd_apply_cartoon_state(tbParam)
    local state = UE4.UCartoonLibrary.GetRunningState(GetGameIns())
    local msg = "notify_cartoon_state;state:" .. state
    if state ~= 1 then 
        return msg
    end
    return msg .. ";" .. UE4.UCartoonLibrary.GetRunningNodes(GetGameIns())
end

function CartoonMgr.cmd_stop_cartoon(tbParam)
    print("cmd_stop_cartoon");
    UE4.UCartoonLibrary.Stop(GetGameIns())
    return CartoonMgr.cmd_apply_cartoon_state(tbParam)
end

function CartoonMgr.cmd_apply_object_list(tbParam)
    print("cmd_apply_object_list");
    local str = UE4.UCartoonLibrary.GetObjectsPositionAndRotation(GetGameIns())
    print(str);
    return "apply_object_list_rsp;" .. str;
end

----------------------------------------------------------------------------------
-- play cartoon
function CartoonMgr:DebugPlay(tbParam)
    UE4.UCartoonLibrary.SwitchLanguage(GetGameIns(), Localization.sLanguage)
    
    local ui = UI.GetTop()
    if ui then
        local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
        for i = 1,Widgets:Length() do
            WidgetUtils.Hidden(Widgets:Get(i))
        end
    end

    local system = UE4.UCartoonLibrary.GetCartoonSystem(GetGameIns());
    if not system then return end 
    local runType = tonumber(tbParam.run_type) or 0
    local flagPageId = tonumber(tbParam.flag_page_id) or 0
    local flagLineId = tonumber(tbParam.flag_line_id) or -1
    local pEnd = {GetGameIns(), function(completeType)
        local ui = UI.GetTop()
        if ui then
            local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
            for i = 1,Widgets:Length() do
                WidgetUtils.Visible(Widgets:Get(i))
            end
        end
    end}
    system:DebugPlay(tbParam.data_path, tbParam.file, pEnd, nil, runType, flagPageId, flagLineId);
end

function CartoonMgr:Play(path, endCall)
    local app = GetGameIns()
    endCall = endCall or function() end
    return UE4.UCartoonLibrary.Play(app, path, Localization.sLanguage, {app, endCall})
end

----------------------------------------------------------------------------------
CartoonMgr:InitCmd()
----------------------------------------------------------------------------------