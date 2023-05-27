-- ========================================================
-- @File    : umg_common_bg.lua
-- @Brief   : 通用背景
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function()
        if self.funClose then
            self.funClose()
        else
            UI.CloseTopChild()
        end
    end)

    self:BindToAnimationEvent(
        self.AllEnter,
        {
            self,
            function()
                self:UnbindAllFromAnimationFinished(self.AllEnter)
                --- 临时处理挂同一个.lua脚本的情况
                if UI.IsOpen("RoleLvTip") 
                or UI.IsOpen("SupportLvTip") 
                or UI.IsOpen("ArmsUnlockTip")
                or UI.IsOpen("WeaponLvUp")    
                then
                    if self.funClose then
                        self.funClose()
                    else
                        UI.CloseTopChild()
                    end
                end
            end
        },
    UE4.EWidgetAnimationEvent.Finished)
end

function tbClass:Init(funClose)
    self.funClose = funClose
end

function tbClass:SetText(sTxt)
    if self.TxtPopupTips then
        self.TxtPopupTips:SetText(sTxt or "")
    end
end

return tbClass