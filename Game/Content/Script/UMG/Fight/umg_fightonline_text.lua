-- ========================================================
-- @File    : umg_fightonline_text.lua
-- @Brief   : 战斗内购买Buffer
-- ========================================================

--- @class umg_fightonline_text : UI_Template
local umg_fightonline_text = Class("UMG.BaseWidget");

function umg_fightonline_text:OnInit()
    --self:GetOwningPlayer():ExhaleMouse(true);

    self.Time:SetTaskActor(UE4.UGameplayStatics.GetActorOfClass(GetGameIns(), UE4.AGameTaskActor));

    -- 初始化商城Buffer
    self:InitActivedBufferes();
    self.CurrentBufferIdx = -1;

    -- 关闭商城

    self.Back:Set(function()
        UI.Close(self)
    end)

    -- 购买操作
    self.BtnOk.OnClicked:Add(self, function()
        local pawn = self:GetOwningPlayerPawn();
        if (pawn ~= nil) and (self.CurrentBufferIdx ~= -1) then
            self.LastBuyBuffName = self.LastSelectedBuffName
            if pawn:BuyShopBuffer(self.CurrentBufferIdx - 1) then
                --self:InitActivedBufferes();
            end
        end
    end);

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
end

function umg_fightonline_text:OnOpen()
    self:ExhaleMouse(true)
    local pawn = self:GetOwningPlayerPawn();
    if pawn and pawn.PlayerState then
        pawn.PlayerState:OnOpenBufferShop();
    end
end

function umg_fightonline_text:OnClose()
    self:GetOwningPlayer():ExhaleMouse(false);

    self.Time:SetTaskActor(nil);
    self:ExhaleMouse(false)
end

function umg_fightonline_text:InitActivedBufferes()
    local BufferOptions = {self.Options1, self.Options2, self.Options3};
    local pawn = self:GetOwningPlayerPawn();
    if (pawn ~= nil) then
        for i, opt in ipairs(BufferOptions) do
            local info = pawn:GetShopBufferInfo(i - 1);
            if (info.ID ~= -1) then
                local buffer = pawn:GetAbilityBuffer(info.ID);
                local nowCount = self:GetPlayerBuffCount(info.ID);
                opt.TxtContent:SetContent(self:GetBuffDesc(buffer,nowCount + 1));
                if pawn:CanBuyShopBuffer(info.ID) then
                    opt.ClickBtn.OnClicked:Add(self, function()
                        if self.optSelected then
                            WidgetUtils.Collapsed(self.optSelected)
                        end
                        self.optSelected = opt.Selected
                        WidgetUtils.SelfHitTestInvisible(self.optSelected)
                        self:OnSelectBuffer(i);
                        self.LastSelectedBuffName = Text(buffer.Name);
                    end);
                end
            end
        end
    end

    self.Money:ShowMoney(pawn.PlayerState:GetMultiLevelMoney(false),true);
end

function umg_fightonline_text:GetBuffDesc(buff,nowGotNum)
    if not buff or not buff.BufferCount then
        return ''
    end
    --{{10,20,40},{20,30,60}}
    local tbStr = buff.BuffParamPerCount
    if tbStr == '' then
        tbStr = '{}'
    end
    local desc = Text(buff.Desc)
    local tbParam = Eval(tbStr)
    if #tbParam == 0 or not string.find(desc,'%%s') then
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
    return string.format(desc,table.unpack(res));
end

function umg_fightonline_text:OnSelectBuffer(BufferIdx)
    self.CurrentBufferIdx = BufferIdx;
end

function umg_fightonline_text:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function umg_fightonline_text:UpdateMultiLevelMoney(num)
    -- 当前金币数量
    self.Money:ShowMoney(num,true);
end

return umg_fightonline_text;
