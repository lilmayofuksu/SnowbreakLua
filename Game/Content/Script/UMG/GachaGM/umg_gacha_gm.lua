-- ========================================================
-- @File    : umg_gacha_gm.lua
-- @Brief   : 扭蛋调试界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field TxtContent UTextBlock
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()

    BtnAddEvent(self.BtnClose, function()
        
       UI.Close(self) 
    end)

    BtnAddEvent(self.BtnSave, function()
        UE4.UGameLibrary.SaveFile('GachaTest.txt', self.TxtContent:GetText())
        print('保存成功。。。  ', UE4.UBlueprintPathsLibrary.ProjectContentDir() .. 'GachaTest.txt')
    end)
end

function tbClass:OnOpen()
    self.TxtContent:SetText('        抽奖中...         ')
end


function tbClass:SetData(tbInfo)
    local tbRarity = tbInfo.tbRarity
    local tbItem = tbInfo.tbItem

    local allNum = tbInfo.allNum

    local sShowTxt = ''

    ---稀有度数据
    sShowTxt = sShowTxt .. '         稀有度数据          \n'
    for n, num in pairs(tbRarity) do
       sShowTxt = sShowTxt .. string.format('稀有度: %s  数量：%s  概率为: %s', n, num, num / allNum) .. '\n'
    end
     sShowTxt = sShowTxt .. '         GDPL          ' .. '\n'
    for gdpl, num in pairs(tbItem) do
        sShowTxt = sShowTxt .. string.format('GDPL: %s  数量：%s  概率为: %s', gdpl, num, num / allNum) .. '\n'
    end

    self.TxtContent:SetText(sShowTxt)
end

return tbClass