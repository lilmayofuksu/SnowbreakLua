-- ========================================================
-- @File    : uw_main_left_btn.lua
-- @Brief   : 主界面侧边按钮
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function() FunctionRouter.GoTo(self.nFunID) end)
    BtnAddEvent(self.LockBtn, function() FunctionRouter.GoTo(self.nFunID) end)
end

---设置
---@param fOnClick function 点击回调
function tbClass:Set(nFunID)
    self.nFunID = nFunID
    local tbCfg = FunctionRouter.Get(nFunID)
    if not tbCfg then return end

    self.TxtName:SetText(Text(tbCfg.sName))
    self.TxtLockName:SetText(Text(tbCfg.sName))
    SetTexture(self.ImgIcon, tbCfg.nIcon)
    SetTexture(self.ImgLockIcon, tbCfg.nIcon)

    self:UpdateState()
end


---更新数据显示
function tbClass:UpdateState()
    if not self.nFunID then return end
    local tbRuntimeInfo = FunctionRouter.GetRuntimeInfo(self.nFunID)

    if not tbRuntimeInfo then return end

    if tbRuntimeInfo.bUnlock then
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Visible(self.PanelUnlock)

        if tbRuntimeInfo.nReddotNum and  tbRuntimeInfo.nReddotNum > 0 then
            WidgetUtils.HitTestInvisible(self.ImgNew)
        else
            WidgetUtils.Collapsed(self.ImgNew)
        end

        if self.nFunID == FunctionType.Shop and ShopLogic.IsShowTimeLess() then
            WidgetUtils.HitTestInvisible(self.ImgTime)
        else
            WidgetUtils.Collapsed(self.ImgTime)
        end

    else
        WidgetUtils.Collapsed(self.PanelUnlock)
        WidgetUtils.Visible(self.PanelLock)
        WidgetUtils.Collapsed(self.ImgTime)
    end
end


return tbClass;