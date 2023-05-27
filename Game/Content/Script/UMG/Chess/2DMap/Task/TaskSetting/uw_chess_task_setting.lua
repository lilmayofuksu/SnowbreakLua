-- ========================================================
-- @File    : uw_chess_task_setting.lua
-- @Brief   : 地图任务 - 任务id
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbPool = {}
    self.tbCurrent = {}
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnOK() end)
end

--[[
tbParam = 
{
    title = "标题",
    tbArg = {      -- 参数列表
        {
            id = "",        -- 参数id
            type = "",      -- 参数类型
            name = "",      -- 参数名
            flag = "",      -- 标记  （是条件还是事件）
            value = "",     -- 参数值
        }
    },
    okHandler = function() end, -- 确认回调
}
--]]
function view:OnOpen(tbParam)
    WidgetUtils.SelfHitTestInvisible(self)
    self.tbParam = tbParam;
    self.TxtTitle:SetText(tbParam.title or "")
    self:Refresh()
end

function view:OnOK()
    if self.tbParam.okHandler then 
        self.tbParam.okHandler(self.tbParam.tbArg)
    end
    self:OnClose()
end

function view:OnClose()
    WidgetUtils.Collapsed(self)
end

function view:Refresh()
    self:FreeAll()
    for _, cfg in ipairs(self.tbParam.tbArg) do 
        local tbData = self:AllocItem()
        tbData.widget:SetData(cfg)
    end
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