-- ========================================================
-- @File    : uw_customize_switchtips.lua
-- @Brief   : 设置
-- ========================================================

---@class tbClass : UUserWidget
---@field List UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnOK, function()
        PlayerSetting.SaveCustomizeSelect(self.Select)
        UI.Close(self)
    end)
    self.Factory = Model.Use(self);
end

function tbClass:OnOpen()
    self.tbItems = {}
    self:DoClearListItems(self.List)
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self.tbCfg, self.Select = PlayerSetting.GetCustomizeCfg()
    for i,v in ipairs(self.tbCfg) do
        local sName = PlayerSetting.GetCustomizeCfgNameByIndex(i)
        local tbParam = {}
        tbParam.nIndex = i
        tbParam.sName = sName ~= "" and sName or (Text('ui.DefaultName' .. i))
        tbParam.bSelect = self.Select == i
        tbParam.pSelect = function ()
            for k,j in ipairs(self.tbItems) do
                if i ~= k then
                    j.Reset()
                end
            end
            self.Select = i
        end
        local pObj = self.Factory:Create(tbParam);
        self.tbItems[i] = pObj.Data
        self.List:AddItem(pObj)
    end
end

return tbClass