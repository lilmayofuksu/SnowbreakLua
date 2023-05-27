-- ========================================================
-- @File    : uw_rolestar_new.lua
-- @Brief   :星级列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnOpen(InParam)
    self:ShowStar(InParam.nStar)
end

---显示星级
---@param nStar number 数量
function tbClass:ShowStar(nStar,InChange)
    for i = 1, 6 do
        local pw = self["s_" .. i]
        if pw then
            WidgetUtils.Collapsed(pw.ImgStarOff)
            WidgetUtils.Collapsed(pw.ImgStar)
            WidgetUtils.Collapsed(pw.ImgStarNext)
            if i <= nStar then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStar)
            elseif i == nStar + 1 then
                if InChange then
                    WidgetUtils.SelfHitTestInvisible(pw.ImgStarNext)
                else
                    WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
                end
            else
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
            end
        end
    end
end

return tbClass