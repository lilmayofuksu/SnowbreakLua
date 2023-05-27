-- ========================================================
-- @File    : uw_Logistics_item.lua
-- @Brief   : 角色后勤条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_Logistics_item = Class("UMG.SubWidget")
local LogiItem = uw_Logistics_item

LogiItem.InObj = nil
LogiItem.OnSelectTypeHandle = "ON_SELECTTYPE_HANDLE"
LogiItem.QualPath = "UMG.Support.LogisticsShow.Widgets.uw_Logistics_star_data"

function LogiItem:Construct()
    self:SetLogiType("technology")
    self:ShowLogiItem(true, self.bEdit)
    WidgetUtils.Collapsed(self.PanelSelect)
    self.QualItem = Model.Use(self, self.QualPath)
    WidgetUtils.Collapsed(self.PanelUse)
    self.bSelect = false
    self.BtnSelect.OnClicked:Add(self, function()
        if not self.Data.SupportCard then
            return
        end
        --- 点击插槽监听
        EventSystem.TriggerTarget(self, self.OnSelectTypeHandle)
        --- 后勤卡点击监听
        if self.OnClick then
            self.Data.ClickFun(self.Data.SupportCard)
            self:GetSelect(true)
        end
        if self.goClick then
            self.goClick(self.SlotIdx)
            self.goClick = nil 
        end
    end)

    self:RegisterEventOnTarget(Logistics, Logistics.ShowHead, function(InTarget)
        self:SetMark(self.Data.RoleCard)
    end)

    self:RegisterEventOnTarget(Logistics, "OnListItemSelect", function(InTarget, InItem)
        if self.pCard and self.pCard ~= InItem then
            WidgetUtils.Collapsed(self.PanelSelect)
        end
    end)
    self.tbItemColor = {"#93939333", "#211b4433", "#4460ec33", "#a15ce533", "#f2a73d33", "#ee2b4c33"}

    self.tbQualityImg = {
        1700001,
        1700002,
        1700003,
        1700004,
        1700005,
    }
    
end

function LogiItem:Display(InParam)
    self.goClick = InParam.Click
    self.SlotIdx = InParam.Slot
    if not InParam.SupportCard then
        self:ShowLogiItem()
        return
    end
    self.Data = InParam.SupportCard
    self.OnClick = nil
    self:SetIcon(InParam.SupportCard)
    self:SetLogiName(InParam)
    self:SetColor(InParam.SupportCard)
end

function LogiItem:DisplayByGDPL(G, D, P, L, Level, BreakNum)
    local logiInfo = UE4.UItem.FindTemplate(G, D, P, L)
    if not logiInfo then return end

    self.OnClick = nil

    WidgetUtils.Collapsed(self.NumDes)
    WidgetUtils.Collapsed(self.CanvasSlot)
    WidgetUtils.Collapsed(self.ImgEmpty)
    WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
    WidgetUtils.SelfHitTestInvisible(self.CanvasDes)
    SetTexture(self.ImgType, Item.SupportTypeIcon[D])
    SetTexture(self.ImgQuality, self.tbQualityImg[logiInfo.Color])
    if self.ImgQuality2 then
        local hexColor = UE4.UUMGLibrary.GetSlateColorFromHex(self.tbItemColor[logiInfo.Color])
        self.ImgQuality2:SetColorAndOpacity(hexColor)
    end
    if BreakNum >= 4 then
        SetTexture(self.ImgIcon, logiInfo.IconBreak, false)
    else
        SetTexture(self.ImgIcon, logiInfo.Icon, false)
    end
    self.TextCurrLv:SetText(Level)
end

function LogiItem:OnListItemObjectSet(InParam)
    self.Data = InParam.Logic
    self.OnClick = InParam.Logic.ClickFun
    self.pCard = self.Data.SupportCard
    if not self.pCard then
        WidgetUtils.Collapsed(self.PanelTeam)
        WidgetUtils.Collapsed(self.PanelSlot)
        WidgetUtils.Collapsed(self.PanelUse)
        WidgetUtils.Collapsed(self.PanelSelect)
        WidgetUtils.SelfHitTestInvisible(self.ImgEmpty)
        return
    end
    self:SetIcon(self.Data.SupportCard)
    self:SetLogiName(self.Data)
    self:SetColor(self.Data.SupportCard)
    self:SetDynamicIcon(self.Data.SupportCard)
    self:SetMark(self.Data.RoleCard)
    if self.Data.ShowPanelteam then
        WidgetUtils.SelfHitTestInvisible(self.PanelTeam)
        -- 目前装备了几个和当前后勤成套装的卡
        local SuitNum = 0
        for i = 1, 3 do
            local SkillTemplateId = self.Data.tbSkillTemplateId[i]
            local CurSuitId =  Logistics.GetSkillSuitId(self.pCard)
            if SkillTemplateId and CurSuitId and SkillTemplateId == CurSuitId then
                SuitNum = SuitNum + 1
                self["Log"..i]:SetState(true)
            else
                self["Log"..i]:SetState(false)
            end
        end

        if SuitNum == 0 then
            WidgetUtils.Collapsed(self.PanelTeam)
        end
    else
        WidgetUtils.Collapsed(self.PanelTeam)
    end

    WidgetUtils.Collapsed(self.NumDes)

    if self.Data.SelectItem == self.pCard then
        self:GetSelect(true)
    end
end

function LogiItem:UpdatSlot()
    EventSystem.TriggerTarget(Logistics, Logistics.OnUpdataLogisticsSlot)
end

-- ---播放切换后勤角色动画
-- ---@param InType boolean  动画类型
-- function LogiItem:OnPlayAnim(InType)
--     if InType == true then
--         self:PlayAnimation(self.Up, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
--     elseif InType == false then
--         self:PlayAnimation(self.Down, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
--     else
--         print("chang logistics role anim error")
--     end
-- end

function LogiItem:SetSelectType()
    EventSystem.TriggerTarget(self, self.OnSelectTypeHandle)
end

function LogiItem:SetLogiType(InText)
    --self.TxtName:SetText(Text("ui." .. InText))
    -- self.txtEName:SetText(InText)
end

function LogiItem:SetTypeIcon()
    --- self.ImgIcon
end

function LogiItem:InitClick(ClickFun)
    self.ClickFun = ClickFun
end

function LogiItem:ShowTipClick(InCallFun)
    self.OnTipClickFun = InCallFun
end

function LogiItem:ShowLogiItem(InShow, bEdit)
    if InShow then
        WidgetUtils.Collapsed(self.ImgAdd)
        WidgetUtils.Collapsed(self.ImgEmpty)
        WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
    else
        WidgetUtils.Collapsed(self.PanelSlot)
        if bEdit then
            WidgetUtils.Collapsed(self.ImgEmpty)
            WidgetUtils.HitTestInvisible(self.ImgAdd)
        else
            WidgetUtils.Collapsed(self.ImgAdd)
            WidgetUtils.HitTestInvisible(self.ImgEmpty)
        end
    end
end

function LogiItem:SetLogiName(InParam)
    local pItem = InParam.SupportCard
    if not pItem then return end
    if InParam.ShowNum then
        WidgetUtils.SelfHitTestInvisible(self.NumDes)
        WidgetUtils.Collapsed(self.CanvasDes)
        self.NumDes:SetText(string.format("%d/%d", InParam.nNum, pItem:Count()))
    else
        WidgetUtils.SelfHitTestInvisible(self.CanvasDes)
        WidgetUtils.Collapsed(self.NumDes)
    end

    if pItem and pItem:CanStack() then
        WidgetUtils.SelfHitTestInvisible(self.CanvasSlot)
        WidgetUtils.Collapsed(self.CanvasDes)
    elseif pItem and not pItem:CanStack() then
        self.TextCurrLv:SetText(pItem:EnhanceLevel())
        WidgetUtils.Collapsed(self.CanvasSlot)
    end
end

function LogiItem:SetLogiQual(InItem)
    --self.ImgQualBg:
    self:DoClearListItems(self.ListQual)
    for i = 1, InItem:Break() + 1 do
        local tbParam = {}
        local NewQual = self.QualItem:Create(tbParam)
        self.ListQual:AddItem(NewQual)
    end
end

function LogiItem:SetDynamicIcon(InItem)
    --- Icon 设置
    if not InItem then return end
    local ResourceId= InItem:Icon()
    local BreakResourceId = InItem:IconBreak()
    local IconId= function(Item)
        if Item:IsSupportCard() then
            if Item:Break()>=Logistics.GetBreakMax(Item) - 1 then
                return BreakResourceId
            else
                return ResourceId
            end
        else
            return Item:Icon()
        end
    end
    SetTexture(self.ImgIcon,IconId(InItem))
    -- SetTexture(self.img_icon_have,InItem:CompanyID())
end

--- 标记被装备角色头像
function LogiItem:SetMark(InCard)
    if InCard and InCard:IsCharacterCard() then
        WidgetUtils.SelfHitTestInvisible(self.PanelUse)
        local HeadId = InCard:Icon()
        SetTexture(self.ImgHead,HeadId)
    else
        WidgetUtils.Collapsed(self.PanelUse)
    end
end

function LogiItem:SetColor(InCard)
    if InCard then
        SetTexture(self.ImgQuality, self.tbQualityImg[InCard:Color()])
        if self.ImgQuality2 then
            local hexColor = UE4.UUMGLibrary.GetSlateColorFromHex(self.tbItemColor[InCard:Color()])
            self.ImgQuality2:SetColorAndOpacity(hexColor)
        end
    end
end

-- 公司LogoIcon
function LogiItem:SetLogo(InLogo,InLogoDes)
    self.img_icon_have:SetBrushFromAtlasInterface(InLogo,true)
end


function LogiItem:SetIcon(InItem)
    WidgetUtils.Collapsed(self.ImgEmpty)
    WidgetUtils.Collapsed(self.PanelSlot)
    if InItem then
        WidgetUtils.SelfHitTestInvisible(self.PanelSlot)
        SetTexture(self.ImgType,Item.SupportTypeIcon[InItem:Detail()])
        local ResId = InItem:Icon()
        local ResBreakId = InItem:IconBreak()
        if InItem:IsSupportCard() then
            if Logistics.CheckUnlockBreakImg(InItem) then
                local IconId = ResBreakId
                SetTexture(self.ImgIcon,IconId,false)
            else
                local IconId = ResId
                SetTexture(self.ImgIcon,IconId,false)
            end
        else
            SetTexture(self.ImgIcon, ResId,false)
        end
    else
        WidgetUtils.SelfHitTestInvisible(self.ImgEmpty)
    end
end

function LogiItem:BelongedIcon(Id)
    if not Id or Id == 0 then
        print('IconId err')
        return
    end
    SetTexture(self.ImgType,Id,false)
end

--- 选中效果
function LogiItem:GetSelect(InShow)
    if InShow then
        WidgetUtils.SelfHitTestInvisible(self.PanelSelect)
        self:OnFinish()
	    self:PlayAnimation(self.Select, 0, 999, UE4.EUMGSequencePlayMode.Forward, 1, true)
        EventSystem.TriggerTarget(Logistics, "OnListItemSelect", self.pCard)
    end
end

return LogiItem
