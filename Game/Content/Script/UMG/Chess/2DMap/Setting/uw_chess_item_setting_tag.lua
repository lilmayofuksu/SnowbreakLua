-- ========================================================
-- @File    : uw_chess_item_setting_tag.lua
-- @Brief   : 地图配置 - tag内容
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorInvalid = UE.FLinearColor(1, 1, 1, 0);
local ColorValid = UE.FLinearColor(0.5, 0.5, 0.5, 1);
local BGColorNormal = UE4.UUMGLibrary.GetSlateColor(0.15, 0.15, 0.15, 1)
local BGColorSelect = UE4.UUMGLibrary.GetSlateColor(0, 0.48, 0.17, 1)

function view:Construct()
    self.InputName.OnTextCommitted:Add(self, function(_, value) self:OnChangeName(value) end)
    self.InputDesc.OnTextCommitted:Add(self, function(_, value) self:OnChangeDesc(value) end)

    BtnAddEvent(self.BtnCount, function() 
        if self.tbData.parent:IsSelectedMode() then return end
        self:OnBtnClickCount()
    end)

    BtnAddEvent(self.BtnRef, function() 
        if self.tbData.parent:IsSelectedMode() then return end
        self:OnBtnClickRef()
    end)

    BtnAddEvent(self.BtnSelected, function() 
        if not self.tbData.parent:IsSelectedMode() then return end
        self.tbData.parent:DoSelect(self.tbData.id)
    end)
end


function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data 
    self.tbData.refresh = function(id)
        if id ~= self.tbData.id then return end
        self:UpdateSelected()
    end

    self.InputName:SetText(self.tbData.cfg.name)
    self.InputDesc:SetText(self.tbData.cfg.desc)

    self.TxtCount:SetText(#ChessEditor:GetTagUsed(self.tbData.id))
    self.TxtRef:SetText(#ChessEditor:GetTagRefrence(self.tbData.id))

    if self.tbData.parent:IsSelectedMode() then 
        self.BtnSelected:SetBackgroundColor(ColorValid)
        self.TxtIndex:SetText("选择" .. self.tbData.index)
    else
        self.BtnSelected:SetBackgroundColor(ColorInvalid)
        self.TxtIndex:SetText(self.tbData.index)
    end
    self:UpdateSelected()
end


function view:OnChangeName(value)
    if value == self.tbData.cfg.name then 
        return 
    end
    self.tbData.cfg.name = value
    if not self.tbData.parent:IsSelectedMode() then 
        ChessEditor:Snapshoot()
    end
    EventSystem.Trigger(Event.NotifyChessUpdateInspector)
end 

function view:OnChangeDesc(value)
    if value == self.tbData.cfg.desc then 
        return 
    end
    self.tbData.cfg.desc = value
    if not self.tbData.parent:IsSelectedMode() then 
        ChessEditor:Snapshoot()
    end
end

function view:UpdateSelected()
    self.Background:SetColorAndOpacity(self.tbData.select and BGColorSelect or BGColorNormal)
end

function view:OnBtnClickCount()
    self.tbData.parent:OnButtonClickClose()
    local tbParam = {
        find_type = "find_object",
        title = string.format("使用 %s 列表", self.tbData.cfg.name),
        tbList = ChessEditor:GetTagUsed(self.tbData.id)
    }
    EventSystem.Trigger(Event.NotifyChessOpenFastJump, tbParam)
end

function view:OnBtnClickRef()
    self.tbData.parent:OnButtonClickClose()
    local tbParam = {
        find_type = "find_event",
        title = string.format("引用 %s 列表", self.tbData.cfg.name),
        tbList = ChessEditor:GetTagRefrence(self.tbData.id)
    }
    EventSystem.Trigger(Event.NotifyChessOpenFastJump, tbParam)
end

------------------------------------------------------------
return view
------------------------------------------------------------