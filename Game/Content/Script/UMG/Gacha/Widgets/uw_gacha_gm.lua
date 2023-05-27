-- ========================================================
-- @File    : uw_gacha_gm.lua
-- @Brief   : 扭蛋调试
-- ========================================================
---@class tbClass
---@field List UListView
---@field ListInfo UListView
---@field TxtNum UEditableText
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.ListInfo)
    self:DoClearListItems(self.List)
    BtnAddEvent(self.BtnOne, function()
         self:Reset(1)
         self:Do() 
    end)
    BtnAddEvent(self.BtnTen, function()
        self:Reset(10)
        self:Do() 
    end)
    self.nId = 1
    self.nAllCount = 1
    self.TxtCard.OnTextCommitted:Add(self, function(...)
        self.nId = tonumber(self.TxtCard:GetText())
        print('nid ', self.nId)
    end)

    self.GDPL.OnTextCommitted:Add(self, function(...)
        local sGDPL = self.GDPL:GetText()
        self:ShowInfo()
    end)
end

function tbClass:Reset(nTime)
    self.nCount = 0
    self.nTime = nTime
    self.nAllCount = nTime * tonumber(self.TxtNum:GetText())
end

function tbClass:ShowInfo()
    self:DoClearListItems(self.ListInfo)

    ---稀有度显示
    local tbRarity = {}
    for nRarity, nTime in pairs(self.tbInfo.tbRarity) do
        table.insert(tbRarity, {string.format('稀有度为:%s', nRarity), {nTime, string.format('百分比:%s', nTime / self.nAllCount* 100)}})
    end
    for nIdx, value in pairs(tbRarity) do
        local pItem = self.ListFactory:Create(value)
        self.ListInfo:AddItem(pItem)
    end
    ---触发十连保底
    local tbParam = {'触发十连保底次数', self.tbInfo.nTriggerTen}
    local pItem = self.ListFactory:Create(tbParam)
    self.ListInfo:AddItem(pItem)

     ---触发稀有度保底次数
    tbParam = {'触发稀有度保底次数', self.tbInfo.nTrigger}
    pItem = self.ListFactory:Create(tbParam)
    self.ListInfo:AddItem(pItem)

    ---指定卡出现次数
    local sGDPL = self.GDPL:GetText()
    local nCount = 0
    for key, value in pairs(self.tbInfo.tbGDPL) do
        if key == sGDPL then
            nCount = value
        end
    end

    tbParam = {'指定卡出现次数：' .. sGDPL, nCount}
    pItem = self.ListFactory:Create(tbParam)
    self.ListInfo:AddItem(pItem)
end

function tbClass:Do()
    self.tbInfo = Gacha.GM(self.nId, self.nTime, tonumber(self.TxtNum:GetText())).tbDebugInfo
    self:ShowInfo()
    UI.ShowTip('完成')
end

return tbClass