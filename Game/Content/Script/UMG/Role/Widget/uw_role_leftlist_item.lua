-- ========================================================
-- @File    : uw_role_leftlist_item.lua
-- @Brief   : 角色属性
-- @Author  :
-- @Date    :
-- ========================================================

local ListItem = Class("UMG.SubWidget")
ListItem.Obj = nil

function ListItem:Construct()
    self.BtnSeclet.OnClicked:Add(self, function()
        self.Obj:Click(self.Obj.Index)
    end)

    ---红点检测类型
    self.tbRedDotType = {}
    self.tbRedDotType[2] = {6}
    self.tbRedDotType[3] = {5}
    self.tbRedDotType[4] = {2}
    self.tbRedDotType[5] = {4,7}
end

function ListItem:OnMouseButtonDown(MyGeometry, InTouchEvent)
    if not IsMobile() then
        if self.Obj.Click then
            self.Obj:Click(self.Obj.Index)
        end
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function ListItem:OnTouchEnded(MyGeometry, InTouchEvent)
    if self.Obj.Click then
        self.Obj:Click(self.Obj.Index)
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function ListItem:SetLock(bLock)
    if bLock then
        WidgetUtils.Visible(self.Lock)
    else
        WidgetUtils.Collapsed(self.Lock)
    end
end

function ListItem:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end
    self.Obj = InObj
    self.OnText:SetText(self.Obj:GetPageName(self.Obj.nSys))
    self.OffText:SetText(self.Obj:GetPageName(self.Obj.nSys))

    self:OnSelectChange(self.Obj.bSelect)
    self:UpdateRedDot()

    EventSystem.Remove(self.nSelectHandle)
    self.nSelectHandle = EventSystem.OnTarget(InObj, InObj.SelectChange, function()
        self:OnSelectChange(self.Obj.bSelect)
    end)
    if self.Obj.Index == 4 then
        EventSystem.Remove(self.BreakHandle)
        self.BreakHandle = EventSystem.OnTarget(RBreak, RBreak.RoleBreakHandle, function()
            self:UpdateRedDot()
        end)
    end
    if self.Obj.Index == 5 then
        EventSystem.Remove(self.SpineHandle)
        self.SpineHandle = EventSystem.OnTarget(Spine, Spine.UpDataNode, function()
            self:UpdateRedDot()
        end)
        EventSystem.Remove(self.ProLevelHandle)
        self.ProLevelHandle = EventSystem.OnTarget(RoleCard, RoleCard.ProLevelPromoteHandle, function()
            self:UpdateRedDot()
        end)
    end
    self.Obj.UpdateRedDot = function()
        self:UpdateRedDot()
    end
end

function ListItem:UpdateRedDot()
    if not self.Obj.pCard or self.Obj.pCard:IsTrial() then
        WidgetUtils.Collapsed(self.New)
        return
    end
    if self.Obj.nSys == 1 then
        if self.tbRedDotType[self.Obj.Index] and RoleCard.CheckCardRedDot(self.Obj.pCard, self.tbRedDotType[self.Obj.Index]) then
            WidgetUtils.HitTestInvisible(self.New)
        else
            WidgetUtils.Collapsed(self.New)
        end
    else
        WidgetUtils.Collapsed(self.New)
    end
end

function ListItem:OnDestruct()
    EventSystem.Remove(self.nSelectHandle)
    self.nSelectHandle = nil
    if self.BreakHandle then
        EventSystem.Remove(self.BreakHandle)
        self.BreakHandle = nil
    end
    if self.SpineHandle then
        EventSystem.Remove(self.SpineHandle)
        self.SpineHandle = nil
    end
    if self.ProLevelHandle then
        EventSystem.Remove(self.ProLevelHandle)
        self.ProLevelHandle = nil
    end
end

function ListItem:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.Collapsed(self.Group_off)
        WidgetUtils.HitTestInvisible(self.Group_on)
        self.p1:ActivateSystem()
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
        WidgetUtils.Collapsed(self.Group_on)
        WidgetUtils.HitTestInvisible(self.Group_off)
        self.p1:DeactivateSystem()
        self:PlayAnimation(self.Select, 1, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
    end
end

function ListItem:Init(InObj)
    if InObj == nil then
        return
    end
    self.Obj = InObj
    self.OnText:SetText(self.Obj.sName)
    self.OffText:SetText(self.Obj.sName)
    EventSystem.Remove(self.nSelectHandle)
    self.nSelectHandle = EventSystem.OnTarget(InObj, InObj.SelectChange, function()
        self:OnSelectChange(self.Obj.bSelect)
    end)
    self:OnSelectChange(self.Obj.bSelect)
    self:SetLock(InObj.bLock)
end

return ListItem
