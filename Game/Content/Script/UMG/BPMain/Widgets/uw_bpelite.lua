-- ========================================================
-- @File    : uw_bpelite.lua
-- @Brief   : bp通行证购买界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
	self.Factory = Model.Use(self)

    BtnAddEvent(self.BtnBuy1, function() self:DoBuyNormal() end)
    BtnAddEvent(self.BtnBuy2, function() self:DoBuyAdvance() end)
    BtnAddEvent(self.Check, function() self:GotoFashion() end)

    self.List1:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self.List2:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnOpen()
    self.tbConfig = BattlePass.GetMeConfig()

    self:ShowADInfo()
    self:ShowLeftGift()
    self:ShowRightGift()
    self:ShowBanner()
    self:ShowInfo()
end

--关闭
function tbClass:OnClose()
    self.tbConfig = nil
    self.NormalItem = nil
    self.AdvanceItem = nil
end

--默认隐藏
function tbClass:ShowEmptyAD()
    WidgetUtils.Collapsed(self.Img)
    WidgetUtils.Collapsed(self.TxtTip)
end

--显示AD 说明
function tbClass:ShowADInfo()
    self:ShowEmptyAD()
    if not self.tbConfig then
        return
    end
end

--显示左边礼包
function tbClass:ShowLeftGift()
    self:DoClearListItems(self.List1)

    local tbList = BattlePass.GetCurBPItemList()
    if not tbList or not tbList[1] then return end

    local BPItem = tbList[1]
    self.NormalItem = BPItem
    if BPItem.sItemName then
        self.TxtTitle1:SetText(Text(BPItem.sItemName))
    end

    local showItem = BPItem.tbItem
    if not showItem then return end
    local iteminfo = UE4.UItem.FindTemplate(showItem[1], showItem[2], showItem[3], showItem[4])
    if iteminfo then
        if iteminfo.LuaType ~= "itembox" then
            local tbParam = {G = showItem[1],D = showItem[2],P = showItem[3],L = showItem[4],N =showItem[5] or 1}
            local obj = self.Factory:Create(tbParam)
            self.List1:AddItem(obj)
        else
            local tbItemList = ShopLogic.GetActualItems(showItem)
            for i,v in ipairs(tbItemList) do
                local tbParam = nil
                if #v == 2 then
                    tbParam = {nCashType = v[1], nNum = v[2]}
                else
                    local info = UE4.UItem.FindTemplate(v[1], v[2], v[3], v[4])
                    if info and info.LuaType ~= "battlepass_box" then
                        tbParam = {G = v[1],D = v[2],P = v[3],L = v[4],N =v[5] or 1}
                    end
                end
                if tbParam then
                    local obj = self.Factory:Create(tbParam)
                    self.List1:AddItem(obj)
                end
            end
        end

        if not BPItem.sItemName then
            self.TxtTitle1:SetText(Text(iteminfo.I18N))
        end
    end

    local tbAwardConfig = BattlePass.GetLevelAward()
    if tbAwardConfig then 
        for i,v in ipairs(tbAwardConfig) do
            if v.nAdvanceSp > 0 then
                local tbAward = v.tbAdvanceAward
                local tbParam = {G = tbAward[1],D = tbAward[2],P = tbAward[3],L = tbAward[4],N =tbAward[5] or 1}
                local obj = self.Factory:Create(tbParam)
                self.List1:AddItem(obj)
            end
        end
    end

    local nFlag = BattlePass.GetPassFlag()
    if nFlag > 0 then
        WidgetUtils.Collapsed(self.MoneyIcon)
        self.Num:SetText(Text("ui.TxtBPBuy"))
    else --价格
        WidgetUtils.SelfHitTestInvisible(self.MoneyIcon)
        local _,sIcon, nMoney = IBLogic.GetMoneyFormat(BPItem.tbCost[2], 2)
        self.Num:SetText(nMoney)--充值接入后修改
        self.MoneyIcon:SetText(sIcon)
    end
end

--显示右边礼包
function tbClass:ShowRightGift()
    self:DoClearListItems(self.List2)

    local nShowIdx = 3
    if BattlePass.GetPassFlag() == 1 then
        nShowIdx = 2
    end
    local tbList = BattlePass.GetCurBPItemList()
    if not tbList or not tbList[nShowIdx] then return end

    local BPItem = tbList[nShowIdx]
    self.AdvanceItem = BPItem
    if BPItem.sItemName then
        self.TxtTitle2:SetText(Text(BPItem.sItemName))
    end

    local showItem = BPItem.tbItem
    if not showItem then return end

    local iteminfo = UE4.UItem.FindTemplate(showItem[1], showItem[2], showItem[3], showItem[4])
    if iteminfo then
        if iteminfo.LuaType ~= "itembox" then
                local tbParam = {G = showItem[1],D = showItem[2],P = showItem[3],L = showItem[4],N =showItem[5] or 1}
                local obj = self.Factory:Create(tbParam)
                self.List2:AddItem(obj)
        else
            local tbItemList = ShopLogic.GetActualItems(showItem)
            for i,v in ipairs(tbItemList) do
                local tbParam = nil
                if #v == 2 then
                    tbParam = {nCashType = v[1], nNum = v[2]}
                else
                    local info = UE4.UItem.FindTemplate(v[1], v[2], v[3], v[4])
                    if info and info.LuaType ~= "battlepass_box" then
                        tbParam = {G = v[1],D = v[2],P = v[3],L = v[4],N =v[5] or 1}
                    end
                end
                if tbParam then
                    local obj = self.Factory:Create(tbParam)
                    self.List2:AddItem(obj)
                end
            end
        end

        if not BPItem.sItemName  then
            self.TxtTitle2:SetText(Text(iteminfo.I18N))
        end
    end
    
    if nFlag == 2 then
        WidgetUtils.Collapsed(self.MoneyIcon2)
        self.num2:SetText(Text("ui.TxtBPBuy"))
    else --价格
        WidgetUtils.SelfHitTestInvisible(self.MoneyIcon2)
        local _,sIcon, nMoney = IBLogic.GetMoneyFormat(BPItem.tbCost[2], 2)
        self.num2:SetText(nMoney)--充值接入后修改
        self.MoneyIcon2:SetText(sIcon)
    end
end

--购买普通
function tbClass:DoBuyNormal()
    local nFlag = BattlePass.GetPassFlag()
    if nFlag > BattlePass.PASS_NONE or not self.NormalItem then
        return
    end

    IBLogic.DoBuyProduct(IBLogic.Type_IBBP, self.NormalItem.nGoodsId)
end

--购买高级
function tbClass:DoBuyAdvance()
    local nFlag = BattlePass.GetPassFlag()
    if nFlag >= BattlePass.PASS_LEVEL2 or not self.AdvanceItem then
        return
    end

    IBLogic.DoBuyProduct(IBLogic.Type_IBBP, self.AdvanceItem.nGoodsId)
end


--显示左边立绘  通行证名字 和 广告短语
function tbClass:ShowBanner()
    WidgetUtils.Collapsed(self.Npc)
    WidgetUtils.Collapsed(self.Banner)
    WidgetUtils.Collapsed(self.Check)
    WidgetUtils.Collapsed(self.Des2_1)

    if not self.tbConfig then 
        return
    end

    if self.tbConfig.tbNpcImgItem and #self.tbConfig.tbNpcImgItem >= 4 then
        WidgetUtils.SelfHitTestInvisible(self.Npc)
        WidgetUtils.Visible(self.Check)

        local temp = UE4.UItem.FindTemplate(self.tbConfig.tbNpcImgItem[1], self.tbConfig.tbNpcImgItem[2], self.tbConfig.tbNpcImgItem[3], self.tbConfig.tbNpcImgItem[4])
        SetTexture(self.Npc, temp.Icon)
    end

    if self.tbConfig.nBannerName then
        WidgetUtils.SelfHitTestInvisible(self.Banner)
        SetTexture(self.Banner, self.tbConfig.nBannerName)
    end

    if self.tbConfig.sBannerInfo then
        WidgetUtils.SelfHitTestInvisible(self.Des2_1)
        self.Des2_1:SetText(Text(self.tbConfig.sBannerInfo))
    end
end

--时装跳转
function tbClass:GotoFashion()
    if not self.tbConfig or not self.tbConfig.tbNpcImgItem then return end
    if #self.tbConfig.tbNpcImgItem < 4 then return end

    local tbParam = {
        CharacterTemplate = {Genre = 1, Detail = self.tbConfig.tbNpcImgItem[2], Particular = self.tbConfig.tbNpcImgItem[3], Level = 1},
        SkinIndex = self.tbConfig.tbNpcImgItem[4],
    }

    UI.Open("RoleFashion", tbParam)
end

--显示信息
function tbClass:ShowInfo()
    self.Info:SetBtnListener(function ()
            if self.tbConfig and self.tbConfig.sIntro then
                UI.Open("Info", self.tbConfig.sIntro)
            end
    end)
end

return tbClass