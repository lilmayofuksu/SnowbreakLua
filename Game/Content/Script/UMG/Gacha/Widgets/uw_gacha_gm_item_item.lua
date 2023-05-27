-- ========================================================
-- @File    : uw_gacha_gm_item_item.lua
-- @Brief   : 扭蛋调试
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.SubWidget")

local tbKeyName = {
    bTrigger = '保底触发',
    tbProtectInfo = '保底信息',
    nTime = '保底计数',
    nTenTime = '概率保底计数',
    tbAwardInfo = '物品信息',
    bSucc = '重置保底计数',
    nType = '保底类型',
    bSuccTen = '重置十连计数',
}

function tbClass:OnListItemObjectSet(pObj)
    local tbData = pObj.Data

    self.Key:SetText(tbKeyName[tbData[1]] or tbData[1])
    if type(tbData[2]) == 'table' then
        self.Value:SetText(json.encode(tbData[2]))
    else
        self.Value:SetText(tostring(tbData[2]))
    end
end

return tbClass