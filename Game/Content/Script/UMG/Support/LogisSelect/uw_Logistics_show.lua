-- ========================================================
-- @File    : uw_Logistics_show.lua
-- @Brief   : 角色后勤展示
-- @Author  :
-- @Date    :
-- ========================================================

local uw_Logistics_show = Class("UMG.BaseWidget")
local LogiList = uw_Logistics_show
--- 判断是否是滑屏距离
LogiList.StandDis = 20
--- 标记上下滑动的权限
LogiList.nUptag = 1
LogiList.nCurtag = 1
LogiList.nDowntag = 1

--- 后勤动画
LogiList.tbLogistics = {}
--- 后勤列表
LogiList.OnPopupTip = nil
--- 后勤签页显示信息
LogiList.OnUpdate = nil
--- Item Data path
LogiList.LogiCardPath = "UMG/Support/LogisticsShow/Widgets/uw_Logistics_show_item_data"

--- 后勤卡点击选中
LogiList.SelectHandle = "SUPPORT_SELECT_HANDLE"

---初始化后勤卡列表
function LogiList:Construct()
    self:OnInit()
    self:PlayAnimation(self.AnimShow, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self.ShowItem = Model.Use(self, self.LogiCardPath)

    self.tbTips = {
        {Des = Text("tip.support_equip_ok")},
        {Des = Text("tip.support_replace_ok")},
        {Des = Text("tip.support_unload_ok")},
    }

    self.OnEquipReq =
        EventSystem.OnTarget(
        Logistics,
        Logistics.LogiOperation,
        function(Target, InSCard,InMode)
            self:SendEquipReq(InSCard,InMode)
        end
    )

    self.ChangePageHandle = EventSystem.OnTarget(
        Logistics,
        Logistics.ChangePage,
        function(InTarget, InSupportCard)
            Logistics.CurCard = InSupportCard
            self:CheckSlotState(InSupportCard)
            self:SetLive2dTexture(InSupportCard)
        end
    )
end

--- 初始化滑屏动画
function LogiList:OnInit()
    self.tbLogistics = {self.LogiItem1, self.LogiItem2, self.LogiItem3}
    if UI.IsOpen("EquipTip") then
        UI.Close("EquipTip")
    end
end

--- 后勤卡
---@param InCard UE4.UCharacterCard 角色卡 
---@param nSlot interge 插槽位
function LogiList:OnOpen(InCard, nSlot, InFrom)
    --- 当前操作的角色卡
    if InCard and nSlot then
        Logistics.CurCard = nil
    end
    self.pRCard = InCard or Logistics.CurRole
    Logistics.CurRole = self.pRCard
    self.GCIndex = 0
    self:ResetPreviewRole()
    local function GetSlot()
        if nSlot then
            return nSlot
        else
            return Logistics.SelectType or 1
        end
    end
    Logistics.SelectType = GetSlot()
    --- 需要对接数值当前账号没有后勤的情况
    --- 当前操作的后勤卡
    local tbSlot = UE4.TArray(UE4.USupporterCard)
    --- 试玩角色只显示装备后勤卡
    if InCard and InCard:IsTrial() then
        InCard:GetSupporterCards(tbSlot)
    else
        me:GetSupporterCardsForType(GetSlot() or 1,tbSlot)
    end
    local function GetShowSupportCard()
        if self.pRCard:IsTrial() then
            return self.pRCard:GetSupporterCard(GetSlot() or 1)
        end
        if Logistics.CurCard then
            return Logistics.CurCard
        else
            if self.pRCard and self.pRCard:GetSupporterCard(GetSlot() or 1) then
                return self.pRCard:GetSupporterCard(GetSlot() or 1)
            else
                if tbSlot:Length()>=1 then
                    return tbSlot:Get(1)
                end
            end
        end
        -- body
    end
    self.ShowSlot = GetShowSupportCard()
    self:CheckSlotState(self.ShowSlot)
    self:SetLive2dTexture(self.ShowSlot)
    self.ItemList:OnOpen(
        self.pRCard,
        GetSlot(),
        function(InSupportCard)
            Logistics.CurCard = InSupportCard
            self:CheckSlotState(InSupportCard)
            self:SetLive2dTexture(InSupportCard)
        end,
        self.ShowSlot
    )
    if InCard and InCard:IsTrial() then  --试玩角色
        WidgetUtils.Collapsed(self.AttrTip.BtnChange)
        WidgetUtils.Collapsed(self.AttrTip.BtnUp)
    end
end

function LogiList:ResetPreviewRole()
    Preview.Destroy()
end


--[[
    1:装备，2:替换 ，3:卸下
--]]
--- 后勤卡套装以及属性面板
function LogiList:CheckSlotState(InSupportCard)
    if InSupportCard then
        local HasEquip = self.pRCard:GetSupporterCard(InSupportCard:Detail())
        if not HasEquip then
            Logistics.OptionMode = 1
        else
        if (InSupportCard:Id() ~= HasEquip:Id()) then
                Logistics.OptionMode = 2
            else
                Logistics.OptionMode = 3
            end
        end
        WidgetUtils.HitTestInvisible(self.Info)
        self.Info:Display(InSupportCard or Logistics.GetSlotSupportCards(Logistics.SelectType)[1])
    else
        WidgetUtils.Collapsed(self.Info)
    end
    local nEquipSuit = Logistics.GetSuitEquipNum(InSupportCard, self.pRCard)
    self.AttrTip:OnOpen(InSupportCard or Logistics.GetSlotSupportCards(Logistics.SelectType)[1], nEquipSuit, true)
end

--- 装备之后刷新
function LogiList:AfterEquipUpdate(InSCard)
    if not InSCard then return end
    local HasEquip = self.pRCard:GetSupporterCard(InSCard:Detail())
    if not HasEquip then
        Logistics.OptionMode = 1
    else
    if (InSCard:Id() ~= HasEquip:Id()) then
            Logistics.OptionMode = 2
        else
            Logistics.OptionMode = 3
        end
    end
    local nEquipSuit = Logistics.GetSuitEquipNum(InSCard, self.pRCard)
    self.AttrTip:AfterEquipUpdate(InSCard, nEquipSuit)
    self.ItemList:AfterEquipUpdate(InSCard)
    self:UpdatePanelState(InSCard)
end

--- 发送装备请求
function LogiList:SendEquipReq(InSCard,InMode)
    if not InSCard then
        print('Cur Select SupCard err')
        return
    end
    local tbParam = {
        Model   = InMode,
        pRCard  = self.pRCard,
        pSCard  = InSCard,
        pBRCard = nil,
        bForce  = false,
        BEqId   = 0
    }
    Logistics.Req_Equip(
        tbParam,
        function()
            EventSystem.TriggerTarget(Logistics, Logistics.OnUpdataLogisticsSlot)
            UI.ShowTip(self.tbTips[Logistics.OptionMode].Des)
            self:AddEquipFlag(InSCard,Logistics.OptionMode)
            self:AfterEquipUpdate(InSCard)
            self.AttrTip.BtnChange:SetVisibility(UE4.ESlateVisibility.Visible)
        end,
        function ()
            local pCallBack = function()
                UI.ShowTip(self.tbTips[Logistics.OptionMode].Des)
                self:AddEquipFlag(InSCard,Logistics.OptionMode)
                self:AfterEquipUpdate(InSCard)
            end
            self.AttrTip.BtnChange:SetVisibility(UE4.ESlateVisibility.Visible)
            UI.Open("EquipTip", tbParam, pCallBack)
            self.Info:Display(InSCard)
        end
    )
end

--- 添加标记
function LogiList:AddEquipFlag(InSupportCard,InMode)
    if InMode<=2 then
        InSupportCard:AddFlag(Item.FLAG_USE)
    else
        InSupportCard:DelFlag(Item.FLAG_USE)
    end
    
end

function LogiList:Select(InCard)
    if self.SelectNode ~= InCard then
        if self.SelectNode then
            self.SelectNode:SetSelect(false)
        end
        self.SelectNode = InCard
        if self.SelectNode then
            self.SelectNode:SetSelect(true)
        end
    end
end

---
function LogiList:UpdateSlot()
    for index, value in pairs(self.tbLogistics) do
        value:ShowLogiItem(false)
        local pSlot = Logistics.GetLogisticsSlot(index)
        self.tbLogistics[index]:BelongedIcon(self.tbComponyIcon[index])
        if not pSlot then
            self.tbLogistics[index]:ShowLogiItem(false)
        else
            self.tbLogistics[index]:ShowLogiItem(true)
            self.tbLogistics[index]:SetLogiName(pSlot)
            self.tbLogistics[index]:SetLogiQual(pSlot)
            self.tbLogistics[index]:SetDynamicIcon(pSlot)
            self.tbLogistics[index]:SetQuaLv(pSlot)
        end
        value:SetLogiType(Logistics.tbName[index])
        value:ShowTipClick(
            function()
                self.SelectCard = pSlot
                EventSystem.TriggerTarget(Logistics, Logistics.OnLogiPopTipHandle, true, pSlot, LogiType.LogiDisboard)
            end
        )
    end
end

---打开，关闭Tips状态
---@param InHidden  boolean tip状态
function LogiList:SetTipOnHidden(InHidden)
    WidgetUtils.Hidden(self.AttrTip)
    if InHidden then
        WidgetUtils.Visible(self.AttrTip)
    else
        WidgetUtils.Hidden(self.AttrTip)
    end
end
--- Remove事件
function LogiList:OnClose()
    -- self.ShowSlot = nil
    EventSystem.Remove(self.OnPopupTip)
    EventSystem.Remove(self.OnEquipReq)
    EventSystem.Remove(self.OnUpdataShowItem)
    EventSystem.Remove(self.OnUpdate)
    EventSystem.Remove(self.ChangePageHandle)
    EventSystem.Remove(Logistics.ChangePage)
    EventSystem.Remove(Logistics.LogiOperation)
    EventSystem.RemoveAllByTarget(self)
    EventSystem.RemoveAllByTargetName(Logistics,Logistics.LogiOperation)
    Logistics.EquipCallBack = nil
    Logistics.ForceEquipCallBack = nil
end

function LogiList:SetLive2dTexture(InCard)
    if not InCard then
       WidgetUtils.Collapsed(self.ImgSerPoseA)
       WidgetUtils.Collapsed(self.State)
    -- SetTexture(self.bg, Resource.Get(1803018))
       return
    end
    WidgetUtils.SelfHitTestInvisible(self.State)
    WidgetUtils.SelfHitTestInvisible(self.ImgSerPoseA)
    self.ImgSerPoseA:SetBrushFromTexture(nil)
    if Logistics.CheckUnlockBreakImg(InCard) then
        local IconId = InCard:IconBreak()
        AsynSetTexture(self.ImgSerPoseA,IconId,true)
    else
        local IconId = InCard:Icon()
        AsynSetTexture(self.ImgSerPoseA,IconId,true)
    end
    -- SetTexture(self.bg, Logistics.GetBgTexture(InCard))

    self.GCIndex = self.GCIndex + 1
    if self.GCIndex >= 3 then 
        self.GCIndex = 0;
        UE4.UGameLibrary.CollectGarbage()
    end
    self:UpdatePanelState(InCard)
end

function LogiList:UpdatePanelState(InCard)
    if not InCard:IsSupportCard() then
        return
    end

    local EquipInfo = Logistics.GetEquipInfoWithId()
    self.State:UpdateState(EquipInfo[InCard:Id()], InCard)
end

return LogiList
