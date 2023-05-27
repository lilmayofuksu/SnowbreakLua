-- ========================================================
-- @File    : uw_tower_mode.lua
-- @Brief   : 爬塔界面模式选择控件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function()
        if not self.isUnLock then
            return UI.ShowMessage(self.LockDesc)
        end
        if self.UpdateSelect then
            self.UpdateSelect(self.nType)
        end
    end)
end

function tbClass:OnListItemObjectSet(InObj)
    self.tbData = InObj.Data
    self.nType = InObj.Data.nType
    self.UpdateSelect = InObj.Data.UpdateSelect

    self.isUnLock, self.LockDesc = ClimbTowerLogic.CheckUnlock(self.nType, 1)
    if self.nType == 1 then
        SetTexture(self.IconSeleted, 1701076)
        SetTexture(self.IconNormal, 1701076)
        self.TextNameSelected:SetText(Text("ui.TxtDungeonsTowerEasy"))
        self.TextNameNormal:SetText(Text("ui.TxtDungeonsTowerEasy"))
    elseif self.nType == 2 then
        SetTexture(self.IconSeleted, 1701077)
        SetTexture(self.IconNormal, 1701077)
        self.TextNameSelected:SetText(Text("ui.TxtDungeonsTowerHard"))
        self.TextNameNormal:SetText(Text("ui.TxtDungeonsTowerHard"))
        if not self.isUnLock then
            SetTexture(self.IconLock, 1701077)
            self.TextNameLock:SetText(Text("ui.TxtDungeonsTowerHard"))
        end
    end

    self.tbData.SetSelect = function(_, isSelect)
        if not self.isUnLock then
            WidgetUtils.Collapsed(self.Normal)
            WidgetUtils.Collapsed(self.Selected)
            WidgetUtils.HitTestInvisible(self.Lock)
            return
        end
        WidgetUtils.Collapsed(self.Lock)
        if isSelect then
            WidgetUtils.Collapsed(self.Normal)
            WidgetUtils.HitTestInvisible(self.Selected)
        else
            WidgetUtils.Collapsed(self.Selected)
            WidgetUtils.HitTestInvisible(self.Normal)
        end
    end

    self.tbData:SetSelect(self.tbData.isSelect)
    self:UpdateNew()
end

function tbClass:UpdateNew()
    if ClimbTowerLogic.CanReceive(self.nType) then
        WidgetUtils.HitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

return tbClass
