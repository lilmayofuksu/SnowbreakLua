-- ========================================================
-- @File    : uw_widgets_common_btn.lua
-- @Brief   : 通用按钮
-- ========================================================

local tbCommonBtn = Class("UMG.SubWidget")

tbCommonBtn.State = BtnState.Normal

tbCommonBtn.OnClickFun = nil

function tbCommonBtn:OnInit(InTxt)
end
function tbCommonBtn:OnSelect()
end
function tbCommonBtn:OnUnSelect()
end

--------------------------------------
function tbCommonBtn:Init(InClick, InTxt, ...)
    self.OnClickFun = InClick
    self:OnInit(InTxt, ...)
    self:StateChange()
end

function tbCommonBtn:SetState(InState)
    if self.State ~= InState then
        self.State = InState
        self:StateChange()
    end
end

function tbCommonBtn:StateChange()
    if self.State == BtnState.Normal then
        self:OnUnSelect()
    else
        self:OnSelect()
    end
end

return tbCommonBtn
