-- ========================================================
-- @File    : uw_main_player_info.lua
-- @Brief   : 玩家信息显示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function() FunctionRouter.GoTo(self.nFunID) end)
end

function tbClass:Set(nFunID)
    self.nFunID = nFunID
    WidgetUtils.SelfHitTestInvisible(self)
    local tbCfg = FunctionRouter.Get(nFunID)
    self.TxtName:SetText(Text(tbCfg.sName))
    SetTexture(self.ImgIcon, tbCfg.nIcon)
    self:UpdateState()
end

---更新数据显示
function tbClass:UpdateState()
    if not self.nFunID then return end
    local tbRuntimeInfo = FunctionRouter.GetRuntimeInfo(self.nFunID)

    if not tbRuntimeInfo then return end

    if tbRuntimeInfo.bUnlock then
        WidgetUtils.Collapsed(self.Lock)
        WidgetUtils.HitTestInvisible(self.ImgIcon)

        if tbRuntimeInfo.nReddotNum and  tbRuntimeInfo.nReddotNum > 0 then
            WidgetUtils.HitTestInvisible(self.Red)
        else
            WidgetUtils.Collapsed(self.Red)
        end
    else
        WidgetUtils.Collapsed(self.ImgIcon)
        WidgetUtils.HitTestInvisible(self.Lock)
        WidgetUtils.Collapsed(self.Red)
    end
end

return tbClass
