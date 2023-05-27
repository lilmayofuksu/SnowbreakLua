-- ========================================================
-- @File    : uw_activitydate_list_empty.lua
-- @Brief   : 签到界面空白格
-- ========================================================
local tbClass = Class("UMG.SubWidget")

--构造
function tbClass:Construct()
end

--- 界面入口
function tbClass:OnListItemObjectSet(pObj)
    if pObj.Data.bHide then
        WidgetUtils.Collapsed(self.ImgNotSell)
    else
        WidgetUtils.SelfHitTestInvisible(self.ImgNotSell)
    end
end

return tbClass
