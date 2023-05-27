-- ========================================================
-- @File    : uw_setup_language_manage.lua
-- @Brief   : 语音包设置
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.tbLanguage = {'zh_CN', 'en_US', 'ja_JP'} 
    BtnAddEvent(self.BtnNo, function ()
      UI.Close(self)
    end)
    self.ListFactory = Model.Use(self)
    self.DefaultSelected = 1;
end

function tbClass:OnOpen()
    self:DoClearListItems(self.List)
    self.tbItem = {}
    for i,v in ipairs(self.tbLanguage) do
      local tbParam = {Index = i, Label = v, Size = '2.7GB', pSelect = function() self:OnSelect(i) end }
      local pObj = self.ListFactory:Create(tbParam)
      self.List:AddItem(pObj)
      table.insert(self.tbItem, pObj);
    end
end

function tbClass:OnSelect(Index)
    if not Index then Index = self.DefaultSelected end
    for i,v in ipairs(self.tbItem) do
      v.OnRadio(Index == i)
    end
end

function tbClass:OnClose()
    
end

return tbClass