-- ========================================================
-- @File    : uw_chess_selector.lua
-- @Brief   : 通用选择界面
-- ========================================================


local view = Class("UMG.SubWidget")

function view:Construct()
    self.Factory = Model.Use(self)
    WidgetUtils.Collapsed(self.Root)
    
    BtnAddEvent(self.BtnClose, function() self:OnButtonClickClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnButtonClickOK() end) 

    self:RegisterEvent(Event.NotifyOpenSelectorUI, function(tbParam)  
        self:OnOpen(tbParam)
    end)
end

--[[
local tbParam = {
    title = "标题"
    type = "taskvar" or "taskid" 
    id = 1,         -- 上次选中的id
    onSelect = function(tbRet)
        self.tbEvent.tag = tbRet
        ChessEditor:Snapshoot()
    end
}
--]]
function view:OnOpen(tbParam)
    self.tbParam = tbParam;
    self.selectedId = tbParam.id
    self.TxtTitle:SetText(tbParam.title)
    WidgetUtils.Visible(self.Root)   
    
    self:DoClearListItems(self.ListView)
    self.tbContent = {}

    if self.tbParam.type == "taskvar" then 
        local tbItems = ChessConfigHandler:GetTaskVarDef()
        for _, cfg in ipairs(tbItems) do 
            local tb = {id = cfg.id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.id}
            tb.desc = string.format("初始值:%d 最大值:%d, 最小值:%d", cfg.init, cfg.max, cfg.min)
            tb.name = cfg.name
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    elseif self.tbParam.type == "taskid" then
        local tbItems = ChessConfigHandler:GetTaskDef()
        for _, cfg in ipairs(tbItems) do 
            local tb = {id = cfg.tbArg.id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.tbArg.id}
            tb.desc = ""
            tb.name = Text(cfg.tbArg.name)
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    elseif self.tbParam.type == "fight" then 
        local tbDef = ChessEditor:GetFightDef()
        for _, cfg in ipairs(tbDef.tbList) do 
            local tb = {id = cfg.Id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.Id}
            tb.desc = cfg.Name
            tb.name = cfg.MapId
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    elseif self.tbParam.type == "plot" then 
        local tbDef = ChessEditor:GetPlotDef()
        for _, cfg in ipairs(tbDef.tbList) do 
            local tb = {id = cfg.Id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.Id}
            tb.desc = cfg.Name
            tb.name = cfg.PlotId
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    elseif self.tbParam.type == "particle" then 
        local tbDef = ChessEditor:GetParticleDef()
        for _, cfg in ipairs(tbDef.tbList) do 
            local tb = {id = cfg.Id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.Id}
            tb.desc = cfg.Desc
            tb.name = cfg.Name
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    elseif self.tbParam.type == "sequence" then 
        local tbDef = ChessEditor:GetSequenceDef()
        for _, cfg in ipairs(tbDef.tbList) do 
            local tb = {id = cfg.Id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.Id}
            tb.desc = cfg.Desc
            tb.name = cfg.Name
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    elseif self.tbParam.type == "npc" then 
        local tbDef = ChessEditor:GetNpcDef()
        for _, cfg in ipairs(tbDef.tbList) do 
            local tb = {id = cfg.Id, cfg = cfg, type = self.tbParam.type, parent = self, isSelected = tbParam.id == cfg.Id}
            tb.desc = cfg.Desc
            tb.name = cfg.Name
            self.ListView:AddItem(self.Factory:Create(tb))
            table.insert(self.tbContent, tb)
        end
    end
end

--- 选中
function view:DoSelect(id)
    self.selectedId = id;
    for _, tb in ipairs(self.tbContent) do 
        if tb.id == id then 
            tb.isSelected = true 
        else 
            tb.isSelected = false 
        end
        if tb.pRefresh then 
            tb.pRefresh(tb)
        end
    end
end 


------------------------------------------------------------
function view:OnButtonClickOK()
    self:OnButtonClickClose()
    if self.selectedId then 
        self.tbParam.onSelect({self.selectedId})
    else 
        self.tbParam.onSelect({})
    end
end

function view:OnButtonClickClose()
    WidgetUtils.Collapsed(self.Root)
end

------------------------------------------------------------
return view
------------------------------------------------------------