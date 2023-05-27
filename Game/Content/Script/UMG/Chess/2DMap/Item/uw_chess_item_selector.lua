-- ========================================================
-- @File    : uw_chess_item_selector.lua
-- @Brief   : 地图物件选择界面
-- ========================================================


local view = Class("UMG.SubWidget")

function view:Construct()
    self.Factory = Model.Use(self)
    WidgetUtils.Collapsed(self.Root)
    
    BtnAddEvent(self.BtnClose, function() self:OnButtonClickClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnButtonClickOK() end) 

    self:RegisterEvent(Event.NotifyOpenSelectItemUI, function(tbParam)  
        self:OnOpen(tbParam)
    end)
end

--[[
local tbParam = {
    id = 1,         -- 道具id
    onSelect = function(tbRet)
        self.tbEvent.tag = tbRet
        ChessEditor:Snapshoot()
    end
}
--]]
function view:OnOpen(tbParam)
    self.tbParam = tbParam;
    self.selectedId = tbParam.id
    WidgetUtils.Visible(self.Root)   
    
    local tbItems = ChessEditor:GetItemDef()
    self:DoClearListItems(self.ListView)
    self.tbContent = {}
    for _, cfg in ipairs(tbItems.tbList) do 
        local tb = {id = cfg.Id, cfg = cfg, parent = self, isSelected = tbParam.id == cfg.Id}
        self.ListView:AddItem(self.Factory:Create(tb))
        table.insert(self.tbContent, tb)
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