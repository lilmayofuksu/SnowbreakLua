-- ========================================================
-- @File    : uw_chess_task_var_def.lua
-- @Brief   : 地图任务 - 变量定义
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnAdd, function() self:OnBtnClickAdd() end)
end


function view:Refresh()
    local tbList = ChessConfigHandler:GetTaskVarDef()
    self:DoClearListItems(self.ListViewType)
    self.tbTasks = {}
    for _, cfg in ipairs(tbList) do 
        local tb = {id = cfg.id, cfg = cfg, parent = self}
        self.ListViewType:AddItem(self.Factory:Create(tb))
        table.insert(self.tbTasks, tb)
    end
end

function view:OnBtnClickAdd()
    local tbList = ChessConfigHandler:GetTaskVarDef()
    table.insert(tbList, ChessConfigHandler:CreateTaskVar(#tbList + 1))
    self:Refresh()
    ChessEditor:Snapshoot()
end


------------------------------------------------------------


------------------------------------------------------------
return view
------------------------------------------------------------