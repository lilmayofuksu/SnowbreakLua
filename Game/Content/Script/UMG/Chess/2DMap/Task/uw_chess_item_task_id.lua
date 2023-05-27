-- ========================================================
-- @File    : uw_chess_item_task_id.lua
-- @Brief   : 地图任务 - 任务id
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(0.5, 0.5, 0.5, 1);

function view:Construct()
    BtnAddEvent(self.BtnSelect, function()
        if self.tbData.parent:IsSelectedMode() then return end
        
        if self.cfg.isAdd then 
            self.tbData.parent:AddNewTask();
        else 
            self.tbData.parent:SetSelectedTaskId(self.tbData.id, true);
        end

        -- local isChange = ChessEditor.CurrentSettingType ~= self.tbData.id
        -- ChessEditor:SetCurrentSettingType(self.tbData.id)
        -- if isChange then 
        --     ChessEditor:Snapshoot()
        -- end
    end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.tbData.ui = self
    self.cfg = self.tbData.cfg
    self.tbData.refresh = function(tb)
        if tb ~= self.tbData then return end
        if self.cfg.isAdd then 
            self.TxtName:SetText("               +")
        else 
            self.TxtName:SetText(Text(self.cfg.tbArg.name))
        end
    end
    self.tbData.refresh(self.tbData)
    self:UpdateSelected()
end

function view:UpdateSelected()
    if self.cfg.tbArg.select then 
        self.BtnSelect:SetBackgroundColor(ColorGreen)
    else
        self.BtnSelect:SetBackgroundColor(ColorWhite)
    end
end

------------------------------------------------------------
--- 当鼠标按下时
function view:OnMouseButtonDown(MyGeometry, MouseEvent)
    if self.cfg.isAdd then return end
    self.tbData.parent:SetSelectedTaskId(self.tbData.id, true);

    local key = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
    if key == ChessEditor.KeyRightMouseButton then 
        local tbParam = {
            {"克隆", self.Menu_Clone, self},
            {"向上插入", self.Menu_InsertUp, self},
            {"向下插入", self.Menu_InsertDown, self},
            {"上移", self.Menu_MoveUp, self},
            {"下移", self.Menu_MoveDown, self},
            {"移动最后", self.Menu_MoveToLast, self},
            {"删除", self.Menu_Delete, self}
        }
        EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
    end
    return UE4.UWidgetBlueprintLibrary.UnHandled()
end

function view:Menu_MoveToLast()
    local tbDef = ChessConfigHandler:GetTaskDef()
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg then 
            table.remove(tbDef, i)
            break
        end
    end
    table.insert(tbDef, self.cfg)
    self.tbData.parent:UpdateTaskList()
end

function view:Menu_Clone()
    local tbDef = ChessConfigHandler:GetTaskDef()
    self.cfg.select = false
    local newCfg = Copy(self.cfg)
    newCfg.tbArg.id = #tbDef + 1 
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg then 
            table.insert(tbDef, i + 1, newCfg)
            break
        end
    end
    self.tbData.parent:UpdateTaskList()
    self.tbData.parent:SetSelectedTaskId(newCfg.tbArg.id, true);
end

function view:Menu_InsertUp()
    local tbDef = ChessConfigHandler:GetTaskDef()
    self.cfg.select = false
    local newCfg = ChessConfigHandler:CreateTask(#tbDef + 1 )
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg then 
            table.insert(tbDef, i, newCfg)
            break
        end
    end
    self.tbData.parent:UpdateTaskList()
    self.tbData.parent:SetSelectedTaskId(newCfg.tbArg.id, true);
end

function view:Menu_InsertDown()
    local tbDef = ChessConfigHandler:GetTaskDef()
    self.cfg.select = false
    local newCfg = ChessConfigHandler:CreateTask(#tbDef + 1 )
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg then 
            table.insert(tbDef, i + 1, newCfg)
            break
        end
    end
    self.tbData.parent:UpdateTaskList()
    self.tbData.parent:SetSelectedTaskId(newCfg.tbArg.id, true);
end

function view:Menu_MoveUp()
    local tbDef = ChessConfigHandler:GetTaskDef()
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg and i > 1 then 
            table.remove(tbDef, i)
            table.insert(tbDef, i - 1, self.cfg)
            break
        end
    end
    self.tbData.parent:UpdateTaskList()
end

function view:Menu_MoveDown()
    local tbDef = ChessConfigHandler:GetTaskDef()
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg and i < #tbDef then 
            table.remove(tbDef, i)
            table.insert(tbDef, i + 1, self.cfg)
            break
        end
    end
    self.tbData.parent:UpdateTaskList()
end

function view:Menu_Delete()
    local tbDef = ChessConfigHandler:GetTaskDef()
    for i, tb in ipairs(tbDef) do 
        if tb == self.cfg and i > 1 then 
            table.remove(tbDef, i)
            break
        end
    end
    self.tbData.parent:UpdateTaskList()
end

------------------------------------------------------------
return view
------------------------------------------------------------