-- ========================================================
-- @File    : umg_fightonline_shop.lua
-- @Brief   : 战斗内购买Buffer
-- ========================================================

--- @class umg_fight : UI_Template
local umg_fightonline_shop = Class("UMG.BaseWidget");

function umg_fightonline_shop:PreOpen(...)
    return true
end

function umg_fightonline_shop:Construct( ... )
end

function umg_fightonline_shop:OnInit()
    self.Back:Set(function()
        UI.Close(self)
    end)

    --self:GetPlayerController():ExhaleMouse(true);

    self.BufferButtons = {self.Buff0, self.Buff1, self.Buff2,self.Buff3,self.Buff4,self.Buff5,self.Buff6,self.Buff7};
    self.RarityColor = {UE4.FLinearColor(0.015686, 0.188235, 0.760784, 1), UE4.FLinearColor(0.333333, 0.05098,0.815686, 1),
        UE4.FLinearColor(0.890196, 0.384314, 0.043137, 1)};
    self.CurrentBufferIdx = -1;
    self.Factory = Model.Use(self)
    self:InitShopBufferCountOnOpen()
    self:InitShopBuffer();
    self:OnSelectBuffer(1);
    self:InitActivedBufferes();

    -- 购买操作
    self.BuffDetail.BtnOk.BtnOk.OnClicked:Add(self, function()
        self.LastBuyBuffName = self.LastSelectedBuffName
        if (self:BuyShopBuffer(self.CurrentBufferIdx - 1) ~= false) then
            --[[self:InitShopBuffer();
            self:UpdateShop()]]
        end
    end);

    self:RegisterEvent(
        Event.RefreshRandomBufferes,
        function()
            self:InitShopBuffer();
            self:UpdateShop()
            if self.LastBuyBuffName then
                UI.ShowTip(Text('ui.TxtOnlineEvent13')..self.LastBuyBuffName)
                self.LastBuyBuffName = nil
            end
        end
    )

    self:RegisterEvent(
        Event.OnMultiLevelMoneyChange,
        function(num)
            self:InitShopBuffer();
            self:UpdateShop()
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

function umg_fightonline_shop:UpdateShop()
    local BufferIdx = self.CurrentBufferIdx;
    self.CurrentBufferIdx = -1;
    self:OnSelectBuffer(BufferIdx);
    self:InitActivedBufferes();
end

function umg_fightonline_shop:OnOpen()
    self:ExhaleMouse(true)
    local pawn = self:GetOwningPlayerPawn();
    if pawn and pawn.PlayerState then
        pawn.PlayerState:OnOpenBufferShop();
    end

    local uiFight = UI.GetUI('Fight')
    if uiFight then
        local pGameTaskActor = uiFight:GetTaskActor()
        if pGameTaskActor ~= nil then
            self.CurTime = pGameTaskActor:GetLevelCountDownTime()
            local curTime = math.max(0,self.CurTime)
            self.Time.TxtTime:SetText(os.date("%M:%S",curTime))
        end

        if self.TimerHandle then
            UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
        end
        self.TimerHandle =
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        self.CurTime = (self.CurTime or 1) - 1
                        if self.CurTime >= 0 then
                            self.Time.TxtTime:SetText(os.date("%M:%S",self.CurTime))
                        end
                    end
                },
                1,
                true
            )
    end
    self:CheckGC()
end

function umg_fightonline_shop:OnClose()
    self:ExhaleMouse(false)
    --self:GetPlayerController():ExhaleMouse(false);

    self:RemoveRegisterEvent()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
end

--因为同步多次导致buff等级会闪，现打开时就记录buff当前等级和购买后等级
function umg_fightonline_shop:InitShopBufferCountOnOpen()
    self.buffLevel = {}
    for i, btn in ipairs(self.BufferButtons) do
        local info = self:GetShopBufferInfo(i - 1);
        if (info.ID ~= -1) then
            local nowCount = self:GetPlayerBuffCount(info.ID);
            local hasBuy = not info.bIsAllowToBuy and (info.ID ~= -1)
            self.buffLevel[info.ID] = {nowCount = nowCount,countOver = hasBuy and nowCount or nowCount + 1,hasBuyOnOpen = hasBuy}
        end
    end
end

function umg_fightonline_shop:InitShopBuffer()
    local pawn = self:GetOwningPlayerPawn();
    local nowMoney = pawn and pawn.PlayerState:GetMultiLevelMoney(false) or 0

    for i, btn in ipairs(self.BufferButtons) do
        local info = self:GetShopBufferInfo(i - 1);
        -- Buffer信息显示与控制
        btn.PanelSelected:SetVisibility(UE4.ESlateVisibility.Collapsed);
        btn.PanelUnSelected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);

        local hasBuy = (not info.bIsAllowToBuy) and info.ID ~= -1
         -- 绑定选择消息
        local buffer = self:GetAbilityBuffer(info.ID);

        BtnClearEvent(btn.BtnSl)
        BtnAddEvent(btn.BtnSl,function()
                        self:OnSelectBuffer(i);
        end)
        -- btn.BtnSl.OnClicked:Clear()
        -- btn.BtnSl.OnClicked.Add(self, function()
            
        -- end)
        btn:SetVisibility(UE4.ESlateVisibility.Visible);
        btn.BtnSl:SetVisibility(UE4.ESlateVisibility.Visible);

        --未解锁状态处理
        btn.PanelLock:SetVisibility(info.ID == -1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelSlLock:SetVisibility(info.ID == -1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelUnSl:SetVisibility(info.ID ~= -1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelName1:SetVisibility(info.ID ~= -1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelLvUp1:SetVisibility(info.ID ~= -1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)

        --已购买状态处理
        btn.PanelOver:SetVisibility(hasBuy and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelBuy:SetVisibility((not hasBuy) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelSlBuffover:SetVisibility(hasBuy and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        btn.PanelSlBuff:SetVisibility((info.ID ~= -1 and not hasBuy) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)

        if (info.ID ~= -1) then
            local nowCount = self:GetPlayerBuffCount(info.ID)
            if self.buffLevel then
                nowCount = self.buffLevel[info.ID] and self.buffLevel[info.ID].countOver or 0
            end
            -- 设置图标
            SetTexture(btn.ImgBuff, buffer.Icon, false);
            SetTexture(btn.ImgBuff1, buffer.Icon, false);
            SetTexture(btn.ImgBuff2, buffer.Icon, false);
            SetTexture(btn.ImgBuff3, buffer.Icon, false);
            --[[if (info.bIsAllowToBuy == false) then
                btn.ImgBuff:SetDesaturate(true);
                btn.ImgBuff1:SetDesaturate(true);
            end]]

            self:SetGoodsColor(btn,buffer.Rarity)
            -- 设置价格
            local price = string.format('%d', buffer.Price);
            btn.TxtMoney:SetText(price);
            btn.TxtMoney1:SetText(price);

            -- 设置名称
            btn.TxtName:SetText(Text(buffer.Name));
            btn.TxtName1:SetText(Text(buffer.Name));
            btn.TxtName_1:SetText(Text(buffer.Name));
            btn.TxtName2:SetText(Text(buffer.Name));

            -- 设置等级
            btn.lvUnsl.TxtLv:SetText(nowCount);
            btn.Lv.TxtLv:SetText(nowCount);
            btn.Lv2.TxtLv:SetText(nowCount);
            btn.lvUnsl1.TxtLv:SetText(nowCount)
            -- 是否允许升级
            if (self:CanUpgradeAbilityBufferLevel(info.ID)) then
                btn.PanelLvUp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
                btn.PanelLvUp1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
            else
                btn.PanelLvUp:SetVisibility(UE4.ESlateVisibility.Collapsed);
                btn.PanelLvUp1:SetVisibility(UE4.ESlateVisibility.Collapsed);
            end

            local isMoneyEnough = nowMoney >= buffer.Price;
            btn.ImgRed:SetVisibility(isMoneyEnough and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
            btn.ImgRed1:SetVisibility(isMoneyEnough and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
        else
            --未解锁的槽位，也要显示
            --btn:SetVisibility(UE4.ESlateVisibility.Collapsed);
        end
    end 
end

function umg_fightonline_shop:OnSelectBuffer(BufferIdx)
    if (self.CurrentBufferIdx ~= BufferIdx) then
        if (self.CurrentBufferIdx ~= -1) then
            local btn = self.BufferButtons[self.CurrentBufferIdx];
            btn.PanelSelected:SetVisibility(UE4.ESlateVisibility.Collapsed);
            btn.PanelUnSelected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);

            --[[local info = self:GetShopBufferInfo(self.CurrentBufferIdx - 1);
            local buffer = self:GetAbilityBuffer(info.ID);
            if buffer then
                self:SetGoodsColor(btn,buffer.Rarity)
            end]]
        end
        self.CurrentBufferIdx = BufferIdx;
        local btn = self.BufferButtons[self.CurrentBufferIdx];

        local info = self:GetShopBufferInfo(BufferIdx - 1);
        local hasBuy = not info.bIsAllowToBuy and (info.ID ~= -1)

        btn.PanelSelected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible);
        btn.PanelUnSelected:SetVisibility(UE4.ESlateVisibility.Collapsed);

        if info.ID ~= -1 then
            local buffer = self:GetAbilityBuffer(info.ID);
            local Color = self.RarityColor[buffer.Rarity];

            --self:SetGoodsColor(btn,buffer.Rarity)
            local nowCount = self:GetPlayerBuffCount(info.ID)
            if self.buffLevel then
                nowCount = self.buffLevel[info.ID] and self.buffLevel[info.ID].countOver or 0
            end
            -- 刷新详细信息
            self.BuffDetail.Frame:SetColorAndOpacity(Color);
            self.BuffDetail.SmallFrame:SetColorAndOpacity(Color);
            self.BuffDetail.SmallLight:SetColorAndOpacity(Color);
            SetTexture(self.BuffDetail.ImgBuff, buffer.Icon, false);
            self.BuffDetail.TxtBuffDetail:SetContent(self:GetBuffDesc(buffer,nowCount));
            --self.BuffDetail.TxtBuffDetail:SetContent(buffer.Desc);
            self.BuffDetail.TxtName:SetText(Text(buffer.Name));
            self.BuffDetail.TxtName1:SetText(Text(buffer.Name));
            self.BuffDetail.TxtNumber:SetText(nowCount);
            --self.BuffDetail.TxtNumber:SetVisibility(hasBuy and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
            --self.BuffDetail.TxtNumber_Over:SetText(nowCount);
            --self.BuffDetail.TxtNumber_Over:SetVisibility(not hasBuy and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
            WidgetUtils.SelfHitTestInvisible(self.BuffDetail.TxtBuffDetail)

            local pawn = self:GetOwningPlayerPawn();
            local nowMoney = pawn and pawn.PlayerState:GetMultiLevelMoney(false) or 0
            local isMoneyEnough = nowMoney >= buffer.Price;
            self.BuffDetail.ImgRed:SetVisibility(isMoneyEnough and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
            self.LastSelectedBuffName = Text(buffer.Name)
        else
            WidgetUtils.Collapsed(self.BuffDetail.TxtBuffDetail)
        end

        -- 刷新Buffer按钮
        --[[if (info.bIsAllowToBuy == false) then
            btn:SetDesaturate(true);
        end]]

        --刷新详细信息解锁条件
        --TxtCondition需要一个key

        -- 是否允许购买
        if (self:CanBuyShopBuffer(info.ID)) then
            self.BuffDetail.BtnOk.BtnOk:SetVisibility(UE4.ESlateVisibility.Visible);
            self.BuffDetail.BtnOk.BtnNot:SetVisibility(UE4.ESlateVisibility.Collapsed);
        else
            self.BuffDetail.BtnOk.BtnOk:SetVisibility(UE4.ESlateVisibility.Collapsed);
            self.BuffDetail.BtnOk.BtnNot:SetVisibility(UE4.ESlateVisibility.Visible);
        end

        -- 价格
        self.BuffDetail.TxtMoney:SetText(btn.TxtMoney:GetText());

        --设置解锁相关信息
        local isLock = (info.ID == -1)
        self.BuffDetail.TxtLock:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.BuffDetail.TxtDetail:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.BuffDetail.PanelBuff:SetVisibility(not isLock and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
        self.BuffDetail.PanelName:SetVisibility(not isLock and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
        self.BuffDetail.PanelLock:SetVisibility(isLock and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
        self.BuffDetail.PanelMoney:SetVisibility((not isLock and not hasBuy) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
        self.BuffDetail.BtnOk:SetVisibility((not isLock and not hasBuy) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    self:ResetSmallBuffDesc()
end

function umg_fightonline_shop:InitActivedBufferes()
    self:DoClearListItems(self.AllBuff.ListBuff)
    local ActivedBuffers = self:GetActivedBuffers();
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
            local buffer = self:GetAbilityBuffer(BufferId);
            local nowCount = self:GetPlayerBuffCount(BufferId)
            local Color = self.RarityColor[buffer.Rarity];
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
        end
    end
    local pawn = self:GetOwningPlayerPawn();
    if (pawn ~= nil) then
        -- 当前金币数量
        self.Money:ShowMoney(pawn.PlayerState:GetMultiLevelMoney(false),true);
    end
end

function umg_fightonline_shop:ResetSmallBuffDesc()
    if self.slSmallBuff then
        self.slSmallBuff:ShowSl(false)
    end
    self.slSmallBuff = nil
    self.SlBuffId = nil
end

function umg_fightonline_shop:UpdateMultiLevelMoney(num)
    -- 当前金币数量
    self.Money:ShowMoney(num,true);
end

function umg_fightonline_shop:GetBuffDesc(buff,nowGotNum)
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
        -- print("umg_fightonline_shop GetBuffDesc 1:", desc)
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

function umg_fightonline_shop:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function umg_fightonline_shop:SetGoodsColor(btn,rarity)
    -- 设置品质
    local Color = self.RarityColor[rarity];
    btn.Frame:SetColorAndOpacity(Color);
    btn.SmallFrame:SetColorAndOpacity(Color);
    btn.ColorLight:SetColorAndOpacity(Color);
    btn.SmallLight:SetColorAndOpacity(Color);
    local smallColor = Color
    smallColor.A = 0.4
    btn.Frame1:SetColorAndOpacity(smallColor);
    btn.SmallFrame1:SetColorAndOpacity(smallColor);
    btn.SmallLight1:SetColorAndOpacity(smallColor);
    btn.ImgFrameSmallSl2:SetColorAndOpacity(smallColor);
    btn.ImgFrameSl2:SetColorAndOpacity(smallColor);
    --btn.ImgLigh3:SetColorAndOpacity(smallColor);
    --btn.ImgLight3:SetColorAndOpacity(smallColor);
    btn.ColorLight3:SetColorAndOpacity(smallColor);
    smallColor.A = 1
end

function umg_fightonline_shop:CheckGC()
    if not UE4.UGameLibrary.GetMaxObjectsCount or not UE4.UGameLibrary.GetObjectArrayNumMinusAvailable then
        return
    end
    local NeedGCNum = UE4.UGameLibrary.GetMaxObjectsCount() * 0.7
    local NowObjNum = UE4.UGameLibrary.GetObjectArrayNumMinusAvailable()
    if NowObjNum >= NeedGCNum then
        UI.GC();
    end
end

return umg_fightonline_shop;
