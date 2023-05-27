-- ========================================================
-- @File    : uw_main_up_btn.lua
-- @Brief   : 主界面侧边按钮
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function() FunctionRouter.GoTo(self.nFunID) end)
end

---设置
---@param fOnClick function 点击回调
function tbClass:Set(nFunID)
    self.nFunID = nFunID
    local tbCfg = FunctionRouter.Get(nFunID)
    if not tbCfg then return end

    SetTexture(self.ImgIcon, tbCfg.nIcon)
   
    self:UpdateState()
end

---更新数据显示
function tbClass:UpdateState()
    if not self.nFunID then return end
    local tbRuntimeInfo = FunctionRouter.GetRuntimeInfo(self.nFunID)

    if not tbRuntimeInfo then return end

    if tbRuntimeInfo.bUnlock then
        WidgetUtils.Collapsed(self.BtnLock)

        if tbRuntimeInfo.nReddotNum and  tbRuntimeInfo.nReddotNum > 0 then
            WidgetUtils.HitTestInvisible(self.New)
        else
            WidgetUtils.Collapsed(self.New)
        end
    else
        WidgetUtils.HitTestInvisible(self.BtnLock)
    end
end

return tbClass;