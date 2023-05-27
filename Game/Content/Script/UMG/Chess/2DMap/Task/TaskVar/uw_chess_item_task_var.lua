-- ========================================================
-- @File    : uw_chess_item_task_var.lua
-- @Brief   : 地图任务 - 任务变量条目
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.InputName.OnTextCommitted:Add(self, function(_, value) 
        if value ~= self.cfg.name then 
            self.cfg.name = value
            ChessEditor:Snapshoot()
        end
    end)

    self.InputInit.OnTextCommitted:Add(self, function(_, value) 
        value = math.max(0, tonumber(value) or 0)
        if value ~= self.cfg.init then 
            self.cfg.init = value
            ChessEditor:Snapshoot()
        end
        self.InputInit:SetText(value)
    end)

    self.InputMax.OnTextCommitted:Add(self, function(_, value) 
        value = math.max(0, tonumber(value) or 0)
        if value ~= self.cfg.max then 
            self.cfg.max = value
            ChessEditor:Snapshoot()
        end
        self.InputMax:SetText(value)
    end)

    self.InputMin.OnTextCommitted:Add(self, function(_, value) 
        value = math.max(0, tonumber(value) or 0)
        if value ~= self.cfg.min then 
            self.cfg.min = value
            ChessEditor:Snapshoot()
        end
        self.InputMin:SetText(value)
    end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    local cfg = self.tbData.cfg;
    self.cfg = cfg
    self.TxtId:SetText(cfg.id)
    self.InputName:SetText(cfg.name)
    self.InputInit:SetText(cfg.init)
    self.InputMax:SetText(cfg.max)
    self.InputMin:SetText(cfg.min)

    self.TxtTaskRef:SetText("")
    self.TxtEventRef:SetText("")
end

------------------------------------------------------------

------------------------------------------------------------
return view
------------------------------------------------------------