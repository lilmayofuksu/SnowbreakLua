-- ========================================================
-- @File    : umg_setting.lua
-- @Brief   : 设置界面
-- @Author  :
-- @Date    :
-- ========================================================

local umg_setting = Class("UMG.SubWidget")

local Setting = umg_setting

Setting.ItemPath = "/Game/UI/UMG/Setting/Widgets/uw_setting_item.uw_setting_item_C"
Setting.Items = {}

function Setting:Construct()
    self.SaveBtn.OnClicked:Add(
        self,
        function()
            for _, Item in ipairs(self.Items) do
                Item:Save()
            end
            self:Save()
        end
    )
    
end
return Setting
