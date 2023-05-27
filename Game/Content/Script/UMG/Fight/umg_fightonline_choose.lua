-- ========================================================
-- @File    : umg_fightonline_choose.lua
-- @Brief   : 战斗内购买Buffer
-- ========================================================

--- @class umg_fightonline_choose : UI_Template
local umg_fightonline_choose = Class("UMG.BaseWidget");

function umg_fightonline_choose:OnInit()
    self.Time:SetTaskActor(UE4.UGameplayStatics.GetActorOfClass(GetGameIns(), UE4.AGameTaskActor));

    -- 设置关闭按钮

    self.Back:Set(function()
        UI.Close(self)
    end)

    self.BufferButtons = {self.Buff1, self.Buff2,self.Buff3};
    self.RarityColor = {UE4.FLinearColor(0.015686, 0.188235, 0.760784, 1), UE4.FLinearColor(0.333333, 0.05098,0.815686, 1),
        UE4.FLinearColor(0.890196, 0.384314, 0.043137, 1)};
    self.Factory = Model.Use(self)
    self:InitShopBuffer();
    self:InitActivedBufferes();

    self:RegisterEvent(
        Event.RefreshRandomBufferes,
        function()
            local shop = self:GetBufferShop()
            if shop then
                shop:SetShopState(UE4.EBufferShopStateEnum.Complete)
            end
            if self.LastBuyBuffName then
                UI.ShowTip(Text('ui.TxtOnlineEvent13')..self.LastBuyBuffName)
                self.LastBuyBuffName = nil
            end
            UI.Close(self)
            --[[self:InitShopBuffer();
            self:InitActivedBufferes();]]
        end
    )
    self:RegisterEvent(
        Event.OnMultiLevelMoneyChange,
        function(num)
            self:UpdateMultiLevelMoney(num)
        end
    )

    -- self:RegisterEvent( Event.PauseGame, function(bDownESC)
    --     if bDownESC then
    --         UI.Close(self)
    --     end  
    -- end)

    self:RegisterEvent(
        Event.OpenOrCloseBuffDesc,
        function(tbParam)
            if tbParam[1] then
                WidgetUtils.Visible(self.BtnClose)
            else
                WidgetUtils.Collapsed(self.BtnClose)
            end
        end
    )

    BtnAddEvent(self.BtnClose,function ()
        EventSystem.Trigger(Event.OpenOrCloseBuffDesc, {false})
    end)
end

function umg_fightonline_choose:OnOpen()
    self:ExhaleMouse(true)
    local pawn = self:GetOwningPlayerPawn();
    if pawn and pawn.PlayerState then
        pawn.PlayerState:OnOpenBufferShop();
    end
end

function umg_fightonline_choose:OnClose()
    self:ExhaleMouse(false)
    --self:GetOwningPlayer():ExhaleMouse(false);

    self.Time:SetTaskActor(nil);
end

function umg_fightonline_choose:InitShopBuffer()
    local pawn = self:GetOwningPlayerPawn();
    if (pawn ~= nil) then
        for BufferIdx, btn in ipairs(self.BufferButtons) do
            btn.PanelMoney:SetVisibility(UE4.ESlateVisibility.Collapsed)
            
            local info = pawn:GetShopBufferInfo(BufferIdx - 1);
            if (info.ID ~= -1) then
                -- 绑定购买消息
                local buffer = pawn:GetAbilityBuffer(info.ID);
                local nowCount = self:GetPlayerBuffCount(info.ID);
                if pawn:CanBuyShopBuffer(info.ID) and pawn:CanUpgradeAbilityBufferLevel(info.ID) then
                    btn.BtnOk.BtnOk.OnClicked:Add(self, function ()
                        self.LastBuyBuff = info.ID;
                        self.LastBuyBuffName = Text(buffer.Name);
                        if pawn:BuyShopBuffer(BufferIdx - 1) then
                            self:InitShopBuffer();
                            self:InitActivedBufferes();
                        end
                    end);
                    btn.BtnOk.BtnOk:SetVisibility(UE4.ESlateVisibility.Visible);
                    btn.BtnOk.BtnNot:SetVisibility(UE4.ESlateVisibility.Collapsed);
                    btn.BtnOk.TxtOk:SetVisibility(UE4.ESlateVisibility.Collapsed);
                    btn.BtnOk.TxtRoleGet1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
                else
                    btn.BtnOk.BtnOk:SetVisibility(UE4.ESlateVisibility.Collapsed);
                    btn.BtnOk.BtnNot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
                    btn.BtnOk.TxtOk1:SetVisibility(UE4.ESlateVisibility.Collapsed);
                    btn.BtnOk.TxtRoleGet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
                end

                --btn.BtnOk.TxtOk:SetText(Text('ui.TxtChoose'))
                --btn.BtnOk.TxtOk1:SetText(Text('ui.TxtChoose'))

                btn:SetVisibility(UE4.ESlateVisibility.Visible);
                -- 设置图标
                SetTexture(btn.ImgBuff, buffer.Icon, false);
                if (info.bIsAllowToBuy == false) then
                    btn.ImgBuff:SetDesaturate(true);
                end

                -- 设置品质
                local Color = self.RarityColor[buffer.Rarity];
                btn.Frame:SetColorAndOpacity(Color);
                btn.SmallFrame:SetColorAndOpacity(Color);
                btn.SmallLight:SetColorAndOpacity(Color);

                -- 设置价格
                local price = string.format('%d', buffer.Price);
                btn.TxtMoney:SetText(price);

                -- 设置名称
                btn.TxtName:SetText(Text(buffer.Name));
                btn.TxtName1:SetText(Text(buffer.Name));

                local hasBuy = not info.bIsAllowToBuy and (info.ID ~= -1)
                -- 设置等级
                local level = string.format('%d', self:GetPlayerBuffCount(info.ID));
                btn.TxtNumber:SetText(hasBuy and level or level + 1);

                -- 是否允许升级
                if (pawn:CanBuyShopBuffer(info.ID)) then
                    btn.PanelLvUp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
                else
                    btn.PanelLvUp:SetVisibility(UE4.ESlateVisibility.Collapsed);
                end
                WidgetUtils.Collapsed(btn.PanelLock)
                -- 设置描述信息
                btn.TxtBuffDetail:SetContent(self:GetBuffDesc(buffer, nowCount + 1))
            else
                btn:SetVisibility(UE4.ESlateVisibility.Collapsed);
            end
        end
    end
end

function umg_fightonline_choose:InitActivedBufferes()
    local pawn = self:GetOwningPlayerPawn();
    if (pawn ~= nil) then
        self:DoClearListItems(self.AllBuff.ListBuff)
        local ActivedBuffers = pawn:GetActivedBuffers();
        local NoRepeatedBuffList = UE4.TArray(UE4.int32)
        for i = 1, ActivedBuffers:Length() do
            local BufferId = ActivedBuffers:Get(i)
            if not NoRepeatedBuffList:Contains(BufferId) then
                NoRepeatedBuffList:Add(BufferId)
            end
        end
        for i = 1, NoRepeatedBuffList:Length() do
            local BufferId = NoRepeatedBuffList:Get(i);
            if (BufferId ~= -1) then
                local buffer = pawn:GetAbilityBuffer(BufferId);
                local Color = self.RarityColor[buffer.Rarity];
                local nowCount = self:GetPlayerBuffCount(BufferId)

                local tbParam = {nIcon = buffer.Icon, nColor = Color, desc = self:GetBuffDesc(buffer,nowCount),name = Text(buffer.Name), root = self.AllBuff, onClick = function (isSl,widget)
                if isSl then
                    if self.slSmallBuff then
                        self.slSmallBuff:ShowSl(false)
                    end
                    self.slSmallBuff = widget;
                    self.SlBuffId = buffId
                else
                    if self.slSmallBuff then
                        self.slSmallBuff:ShowSl(false)
                    end
                    self.slSmallBuff = nil
                    self.SlBuffId = nil
                end
            end}
                local pObject = self.Factory:Create(tbParam)
                self.AllBuff.ListBuff:AddItem(pObject);
                --Text('ui.character')
            end
        end
        -- 当前金币数量
        self.Money:ShowMoney(pawn.PlayerState:GetMultiLevelMoney(false),true);
    end
end

function umg_fightonline_choose:GetBuffDesc(buff,nowGotNum)
    if not buff or not buff.BufferCount then
        return ''
    end
    --{{10,20,40},{20,30,60}}
    local tbStr = buff.BuffParamPerCount
    if tbStr == '' then
        tbStr = '{}'
    end
    local tbParam = Eval(tbStr)
    local desc = Text(buff.Desc)
    if #tbParam == 0 or not string.find(desc,'{') then
        -- print("GetBuffDesc 1:", desc)
        return desc
    end
    local getStrNeed = function (tbNum)
        if type(tbNum) ~= 'table' then
            tbNum = {10}
        end
        local resStr = ''
        for i=1,buff.BufferCount do
            local thisLevelNum = tbNum[i] or (tbNum[1] * i)
            resStr = resStr..((nowGotNum == i) and ('<span color="#f88d0f">'..string.format('%s',thisLevelNum)..'</>') or string.format('%s',thisLevelNum))
            resStr = resStr..(i == buff.BufferCount and '' or '/')
        end
        return resStr
    end
    local res = {}
    for i=1,#tbParam do
        res[i] = getStrNeed((tbParam[i]))
    end
    for i=1,4 do
        res[#res + 1] = 0
    end
    local ParamArray = UE4.TArray(UE4.FString)
    for i = 1, #res do
        ParamArray:Add(res[i])
    end

    return UE4.UAbilityLibrary.FormatDescribe(desc, ParamArray)
    -- return string.format(desc,table.unpack(res))
end

function umg_fightonline_choose:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function umg_fightonline_choose:UpdateMultiLevelMoney(num)
    -- 当前金币数量
    self.Money:ShowMoney(num,true);
end

return umg_fightonline_choose;
