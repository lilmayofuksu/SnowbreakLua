-- ========================================================
-- @File    : uw_chess_item_setting_type.lua
-- @Brief   : 地图配置 - 类型
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(0.5, 0.5, 0.5, 1);

function view:Construct()
    BtnAddEvent(self.BtnSelect, function()
        if self.tbData.parent:IsSelectedMode() then return end
        
        local isChange = ChessEditor.CurrentSettingType ~= self.tbData.id
        ChessEditor:SetCurrentSettingType(self.tbData.id)
        if isChange then 
            ChessEditor:Snapshoot()
        end
    end)

    self:RegisterEvent(Event.NotifyChessSettingTypeChanged, function() self:UpdateSelected() end)
end


function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.TxtName:SetText(self.tbData.name)
    self:UpdateSelected()
end

function view:UpdateSelected()
    if self.tbData.id == self.tbData.parent:GetCurrentSettingType() then 
        self.BtnSelect:SetBackgroundColor(ColorGreen)
    else
        self.BtnSelect:SetBackgroundColor(ColorWhite)
    end
end

------------------------------------------------------------
return view
------------------------------------------------------------