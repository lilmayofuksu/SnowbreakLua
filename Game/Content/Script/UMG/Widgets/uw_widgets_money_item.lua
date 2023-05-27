-- ========================================================
-- @File    : uw_widgets_money_item.lua
-- @Brief   : 货币
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function ()
        if type(self.nType) == 'table' then
            local g, d, p , l = table.unpack(self.nType)
            local nCount = me:GetItemCount(g, d, p, l)
            UI.Open("ItemInfo", g, d, p, l, nCount)
        else
            if self.nType == Cash.MoneyType_Vigour then
                UI.Open("PurchaseEnergy", "Energy")
            elseif self.BtnBtnState == 1 then
                CashExchange.ShowUIExchange(self.nType)
            elseif self.BtnBtnState == 2 then
                UI.Open("ItemInfo", self.nType)
            end
        end
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nChangeEvent)
end

function tbClass:OnListItemObjectSet(pObj)
    if pObj == nil or pObj.Data == nil then
        return
    end
    self.nType = pObj.Data.nType
    if type(self.nType) == 'table' then
        EventSystem.Remove(self.nChangeEvent)
        local g, d, p , l = table.unpack(self.nType)
        local nCount = me:GetItemCount(g, d, p, l)
        local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
        SetTexture(self.ImgIcon, pTemplate.Icon)
        self.TxtName:SetText(Text(pTemplate.I18N))
        self.TxtNum:SetText(NumberToString(nCount))

        self:SetBtnState(2)

        ---TODO 监听道具数量变化
        self.nChangeEvent =
            EventSystem.On(
            Event.ItemChanged,
            function()
                self:Update()
            end
        )
    else
        EventSystem.Remove(self.nChangeEvent)
        if self.nType == Cash.MoneyType_Money then
            self.nChangeEvent =
                EventSystem.On(
                Event.MoneyChanged,
                function()
                    self:Update()
                end
            )
        elseif self.nType == Cash.MoneyType_Vigour then
            self.nChangeEvent =
                EventSystem.On(
                Event.VigorChanged,
                function()
                    self:Update()
                end
            )
        else
            self.nChangeEvent =
                EventSystem.On(
                Event.CustomAttr,
                function()
                    self:Update()
                end
            )
        end

        local icon, name, num = Cash.GetMoneyInfo(self.nType)
        SetTexture(self.ImgIcon, icon)
        self.TxtName:SetText(Text(name))

        num = NumberToString(num)
        if self.nType == Cash.MoneyType_Vigour then
            local lv = me:Level()
            if Player.tbLevelCfg and Player.tbLevelCfg[lv] then
                num = num .. "/" .. NumberToString((Player.tbLevelCfg[lv].nMaxVigor or 0))
            end
        end
        if self.nType == Role.MoneyID then
            num = num .. "/" .. NumberToString(Role.LimitNum)
        end
        self.TxtNum:SetText(num)

        if pObj.Data.bShowAdd and CashExchange.CanExchange(self.nType) then
            self:SetBtnState(1)
        else
            self:SetBtnState(2)
        end
    end
end

---更新数量
function tbClass:Update()
    local sNum = 0
    if type(self.nType) == 'table' then
        local g, d, p , l = table.unpack(self.nType)
        sNum = NumberToString(me:GetItemCount(g, d, p, l))
    elseif self.nType == Cash.MoneyType_Vigour then
        sNum = NumberToString(Cash.GetMoneyCount(self.nType)) .. "/" .. NumberToString(Player.tbLevelCfg[me:Level()].nMaxVigor)
    elseif self.nType == Role.MoneyID then
        sNum = NumberToString(Cash.GetMoneyCount(self.nType)) .. "/" .. NumberToString(Role.LimitNum)
    else
        sNum = NumberToString(Cash.GetMoneyCount(self.nType))
    end
    self.TxtNum:SetText(sNum)
end

---开启/关闭添加按钮
---@param bOn boolean 开启/关闭
function tbClass:Addable(bOn)
    if bOn then
        WidgetUtils.SelfHitTestInvisible(self.ImageAdd)
        WidgetUtils.SelfHitTestInvisible(self.ImageAdd_2)
        WidgetUtils.Visible(self.BtnClick)
    else
        WidgetUtils.Collapsed(self.ImageAdd)
        WidgetUtils.Collapsed(self.ImageAdd_2)
        WidgetUtils.Collapsed(self.BtnClick)
    end
end

--设置按钮状态
---@param nState integer 0关闭 1显示+ 2可查看详情
function tbClass:SetBtnState(nState)
    --按钮状态 0关闭 1显示+ 2可查看详情
    self.BtnBtnState = nState
    if nState == 0 then
        WidgetUtils.Collapsed(self.ImageAdd_2)
        WidgetUtils.Collapsed(self.ImageAdd)
        WidgetUtils.Collapsed(self.ImageInfo)
        WidgetUtils.Collapsed(self.BtnClick)
    elseif nState == 1 then
        WidgetUtils.Collapsed(self.ImageInfo)
        WidgetUtils.HitTestInvisible(self.ImageAdd_2)
        WidgetUtils.HitTestInvisible(self.ImageAdd)
        WidgetUtils.Visible(self.BtnClick)
    elseif nState == 2 then
        WidgetUtils.Collapsed(self.ImageAdd)
        WidgetUtils.HitTestInvisible(self.ImageAdd_2)
        WidgetUtils.HitTestInvisible(self.ImageInfo)
        WidgetUtils.Visible(self.BtnClick)
    end
end

return tbClass
