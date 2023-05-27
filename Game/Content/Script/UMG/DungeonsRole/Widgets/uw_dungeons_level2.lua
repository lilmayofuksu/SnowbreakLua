-- ========================================================
-- @File    : uw_dungeons_level2.lua
-- @Brief   : 角色碎片本关卡控件（含次数限制）
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.Level.Widgets.uw_level_item")

function tbClass:Construct()
    BtnAddEvent(self.BtnCommon, function() if self.ClickFun then self.ClickFun(self.tbCfg) end end)
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        WidgetUtils.HitTestInvisible(self.CommonSelected)
    else
        self:StopAnimation(self.AllLoop)
        WidgetUtils.Collapsed(self.CommonSelected)
    end
end

function tbClass:OnInit()
    self.TxtLevelName:SetText(Text(self.tbCfg.sName))
    if self.StarNode then
        self.StarNode:Set(self.tbCfg)
    end

    -- if self.tbCfg:IsCompleted() then
    --     WidgetUtils.HitTestInvisible(self.CommonCompleted)
    -- else
        WidgetUtils.Collapsed(self.CommonCompleted)
    --end

    if self.tbCfg.nNum and self.tbCfg.nNum > 0 then
        WidgetUtils.HitTestInvisible(self.Num)
        local passNum = Role.GetLevelPassNum(self.tbCfg.nID)
        self.TxtTime:SetText(self.tbCfg.nNum - passNum)
        self.TxtTotal:SetText(self.tbCfg.nNum)
        if self.tbCfg.nNum - passNum <= 0 then
            self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.5, 0, 0, 1))
        else
            self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        end
    else
        WidgetUtils.Collapsed(self.Num)
    end
end

function tbClass:SetLockState(bLock)
    if bLock then
        WidgetUtils.Collapsed(self.CommonNormal)
        WidgetUtils.HitTestInvisible(self.CommonLock)
        self.TxtLevelName:SetRenderOpacity(0.4)
    else
        WidgetUtils.Collapsed(self.CommonLock)
        WidgetUtils.HitTestInvisible(self.CommonNormal)
        self.TxtLevelName:SetRenderOpacity(1)
    end
end


function tbClass:SetIcon(Icon)
    if Icon and self.Pic then
        SetTexture(self.Pic, Icon)
    end
end

return tbClass