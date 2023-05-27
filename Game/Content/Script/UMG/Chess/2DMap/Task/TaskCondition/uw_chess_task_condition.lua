-- ========================================================
-- @File    : uw_chess_task_condition.lua
-- @Brief   : 地图任务 - 任务id
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbPool = {}
    self.tbCurrent = {}
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnOK() end)

    local all = ChessTaskCondition:GetAllConditionNames()
    for _, name in ipairs(all) do 
        self.ParamTypeSelect:AddOption(name)
    end

    self.ParamTypeSelect.OnSelectionChanged:Add(self, function(_, type, c) 
        local cfg = ChessTaskCondition:FindClassByName(type)
        if cfg then 
            self.tbParam.cfg.id = cfg.Id
            self:OnConditionTypeChanged()
        end
    end)
end

--[[
tbParam = 
{
    title = "标题",
    cfg = {      -- 参数列表
    },
    okHandler = function() end, -- 确认回调
}
--]]
function view:OnOpen(tbParam)
    WidgetUtils.SelfHitTestInvisible(self)
    self.tbParam = tbParam;
    self.tbData = {}
    self.TxtTitle:SetText(tbParam.title or "")

    local cfg = ChessTaskCondition:FindClassById(tbParam.cfg.id)
    if cfg then 
        self.ParamTypeSelect:SetSelectedOption(cfg.Name)
    else 
        self.ParamTypeSelect:SetSelectedOption("")
    end
    self:OnConditionTypeChanged()
end

function view:OnConditionTypeChanged()
    self:FreeAll()
    local cfg = ChessTaskCondition:FindClassById(self.tbParam.cfg.id)
    if not cfg then return end 

    self.tbData = {}
    for _, tb in ipairs(cfg.tbParam) do 
        local tbData = self:AllocItem()
        local data = {id = tb.id, type = tb.type, name = tb.desc, value = self.tbParam.cfg.tbParam[tb.id]}
        data.widget = tbData.widget
        tbData.widget:SetData(data)
        table.insert(self.tbData, data)
    end
end

function view:Refresh()
    for _, tb in ipairs(self.tbData) do 
        self.tbParam.cfg.tbParam[tb.id] = tb.value
    end

    self:OnConditionTypeChanged()
end

function view:OnOK()
    for _, tb in ipairs(self.tbData) do 
        tb.widget:TrySave()
        self.tbParam.cfg.tbParam[tb.id] = tb.value
    end

    if self.tbParam.okHandler then 
        self.tbParam.okHandler(self.tbParam.cfg)
    end
    self:OnClose()
end

function view:OnClose()
    WidgetUtils.Collapsed(self)
end



---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:AllocItem()
    for _, tbData in ipairs(self.tbPool) do 
        if tbData.isHidden then 
            WidgetUtils.Visible(tbData.widget)
            tbData.isHidden = false;
            return tbData
        end
    end

    local tbData = {}
    local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Task/Widgets/uw_chess_task_arg.uw_chess_task_arg_C")
    widget.parent = self
    tbData.widget = widget
    self.Scroll:AddChild(widget)
    table.insert(self.tbPool, tbData)
    return tbData;
end

function view:FreeAll()
    for _, tbData in ipairs(self.tbPool) do 
        tbData.isHidden = true
        WidgetUtils.Collapsed(tbData.widget)
    end
end

------------------------------------------------------------
return view
------------------------------------------------------------