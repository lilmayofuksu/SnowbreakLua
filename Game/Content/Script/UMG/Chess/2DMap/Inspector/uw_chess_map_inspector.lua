-- ========================================================
-- @File    : uw_chess_map_inspector.lua
-- @Brief   : 
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(0.484, 0.484, 0.484, 1);

function view:Construct()
    self.Factory = Model.Use(self)
    self:RegisterEvent(Event.NotifyChessMapChanged, function(mapId) self:ReloadRegions() end)
    self:RegisterEvent(Event.NotifyChessPutRegion, function() self:ReloadRegions() end)
    
    BtnAddEvent(self.BtnModifyMap, function() 
        if ChessEditor:CheckHasData() then 
            EventSystem.Trigger(Event.ApplyModifyMapCreateData); 
        else 
            EventSystem.Trigger(Event.NotifyChessHintMsg, "请先新建地图")
        end
    end)
    
    BtnAddEvent(self.BtnSetting, function() 
        if ChessEditor:CheckHasData() then 
            EventSystem.Trigger(Event.ApplyOpenChessSetting) 
            ChessEditor:Snapshoot()
        else 
            EventSystem.Trigger(Event.NotifyChessHintMsg, "请先新建地图")
        end
    end)
    BtnAddEvent(self.BtnTask, function() 
        if ChessEditor:CheckHasData() then 
            EventSystem.Trigger(Event.ApplyOpenChessTask) 
        else 
            EventSystem.Trigger(Event.NotifyChessHintMsg, "请先新建地图")
        end
    end)

    ChessEditor:RegisterBtnHoverTip(self.BtnModifyMap, "修改地图数据，比如名字、玩法类型等等")
    ChessEditor:RegisterBtnHoverTip(self.BtnSetting, "配置区域激活，tag备注信息等")
    ChessEditor:RegisterBtnHoverTip(self.BtnDatabase, "查看地图占用的数据变量，以及当前正在使用的")
end

--- 重新加载区域列表
function view:ReloadRegions()
    self:DoClearListItems(self.ListView_Region)
    if not ChessEditor:CheckHasData() then return end

    local tbRegions = ChessEditor.tbMapData.tbData.tbRegions
    for i, tb in ipairs(tbRegions) do 
        local tbParam = {Id = i}
        self.ListView_Region:AddItem(self.Factory:Create(tbParam))
    end
    if #tbRegions < 8 then 
        self.ListView_Region:AddItem(self.Factory:Create({ isAdd = true, Id = #tbRegions + 1}))
    end
    ChessEditor:SetCurrentRegionId(ChessEditor.CurrentRegionId)
end

function view:OnMouseEnter()
    ChessEditor.EnterMenuOrInspector = true
end

return view