-- ========================================================
-- @File    : uw_shop_monthitem.lua
-- @Brief   : 购买月卡界面获得的道具
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Init(info)
    local iteminfo = UE4.UItem.FindTemplate(info[1], info[2], info[3], info[4])
    if iteminfo then
        local sName = Text(iteminfo.I18N)
        if info[5] and info[5]  > 1 then
            sName = Text(iteminfo.I18N) .. "x" .. (info[5])
        end

        self.Name:SetText(sName)
        local path = nil
        if iteminfo.Genre == 1 or iteminfo.Genre == 2 then
            path = iteminfo.Icon
        else
            path = iteminfo.Icon
        end
        SetTexture(self.Icon, path)
    end

    if info and info[6] then
        self.CustomTextBlock_110:SetText(Text(info[6]))
    end
end

return tbClass
