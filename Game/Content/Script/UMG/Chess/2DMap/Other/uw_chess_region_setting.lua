-- ========================================================
-- @File    : uw_chess_region_setting.lua
-- @Brief   : 区域设置
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbValue = {}
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnBttonClickOK() end) 

    self:RegisterEvent(Event.NotifyChessModifyRegionSetting, function(tbParam) self:OnOpen(tbParam) end) 

    self.InputPosX.OnTextCommitted:Add(self, function(_, value) self.tbValue.X = tonumber(value) end)
    self.InputPosY.OnTextCommitted:Add(self, function(_, value) self.tbValue.Y = tonumber(value) end)
    self.InputPosZ.OnTextCommitted:Add(self, function(_, value) self.tbValue.Z = tonumber(value)  end)
    self.InputRotate.OnTextCommitted:Add(self, function(_, value) self.tbValue.Rotation = tonumber(value) end)

    self:OnClose()
end

function view:OnBttonClickOK()
    local tbData = ChessEditor:GetRegionDataById(self.Id)
    tbData.Position = {self.tbValue.X, self.tbValue.Y, self.tbValue.Z}
    tbData.Rotation = self.tbValue.Rotation
    self:OnClose()
end

function view:OnOpen(tbParam)
    WidgetUtils.Visible(self.Root)   

    self.Id = tbParam.Id
    self.TxtTitle:SetText(string.format("%d 号区域", tbParam.Id))

    local tbData = ChessEditor:GetRegionDataById(self.Id)
    self.tbValue.X, self.tbValue.Y, self.tbValue.Z = table.unpack(tbData.Position)
    self.tbValue.Rotation = tbData.Rotation

    self.InputPosX:SetText(self.tbValue.X or 0)
    self.InputPosY:SetText(self.tbValue.Y or 0)
    self.InputPosZ:SetText(self.tbValue.Z or 0)
    self.InputRotate:SetText(self.tbValue.Rotation or 0)

    ChessEditor.IsOpenSpecialUI = true
end

function view:OnClose()
    ChessEditor.IsOpenSpecialUI = false
    WidgetUtils.Collapsed(self.Root)
end

return view