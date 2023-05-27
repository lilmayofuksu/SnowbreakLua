-- ========================================================
-- @File    : uw_shop_monthcard.lua
-- @Brief   : 月卡购买界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnBuy, function()
        if not self.tbGoosInfo then 
            UI.ShowTip("ui.TxtRoleAcquired")
            return 
        end

        local bRet = self:CheckDay()
        if bRet == nil then
            UI.ShowTip("ui.TxtRoleAcquired")
            return
        elseif bRet == false then
            UI.ShowTip("tip.Mall_Limit_MonthCard")
            return
        end

        IBLogic.BuyIbGoods(self.tbGoosInfo.nGoodsId, IBLogic.Type_IBMonth)
    end)

    BtnAddEvent(self.BtnHelp, function()
            if self.tbConfig and self.tbConfig.sInfo then
                UI.Open("Info", self.tbConfig.sInfo)
            end
    end)
end

---检查月卡剩余天数 小于等于goodsInfo.tbParam[2]才可购买
function tbClass:CheckDay()
    local tbConfig = self.tbGoosInfo
    if not tbConfig then 
        return
    end

    local nShowNum, nHaveNum = IBLogic.GetMonthCardData(tbConfig)
    return nHaveNum < nShowNum
end

function tbClass:ShowEmpty()
    WidgetUtils.Collapsed(self.BtnBuy)
    WidgetUtils.Collapsed(self.PanelMoney)
    WidgetUtils.Collapsed(self.PanelBtnTxt)
    WidgetUtils.Collapsed(self.TextBlock_707)
    WidgetUtils.Collapsed(self.TxtLimitNum)
    WidgetUtils.Collapsed(self.PanelNum)

    self.TxtLimit:SetText("TxtNotActive")

    for i = 1, 3 do
        WidgetUtils.Collapsed(self["Item" .. i])
    end
end

function tbClass:ShowMallInfo(tbData)
    self:ShowEmpty()
    local tbConfig = tbData and tbData.tbConfig

    if not tbConfig then return end

    self.tbConfig = tbConfig

    local tbGoosList = IBLogic.GetIBShowGoods(tbConfig.nShopId)
    if not tbGoosList or #tbGoosList == 0 then return end
    self.tbGoosInfo = tbGoosList[1]

    WidgetUtils.Visible(self.BtnBuy)
    WidgetUtils.HitTestInvisible(self.PanelBtnTxt)

    if tbConfig.nBG and self.Bg then
        SetTexture(self.Bg, tbConfig.nBG)
    end

    if tbConfig.sTitle then
        WidgetUtils.HitTestInvisible(self.TextBlock_707)
        self.TextBlock_707:SetText(Text(tbConfig.sTitle))
    else
        WidgetUtils.Collapsed(self.TextBlock_707)
    end

    self:UpdateTime()
    self:UpdateHaveNum()
    self:ShowPrice()
    self:ShowItemList()
    --self:PlayAnimation(self.AllEnter)
end

--每秒刷新
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    self:UpdateTime()
    self:UpdateHaveNum()
end

--刷新显示时间 xx日xx时xx分
function tbClass:UpdateTime()
    self.TxtLimit:SetText("TxtNotActive")
    local nDisTime = IBLogic.GetMonthCardTime()
    if not self.tbGoosInfo or nDisTime < GetTime() then 
        WidgetUtils.Collapsed(self.TxtLimitNum)
        return 
    end

    local nDay, nHour, nMin, nSec = TimeDiff(nDisTime, GetTime())
    if nMin and (nDay + nHour + nMin + nSec) > 0 then
        self.TxtLimit:SetText("TxtSurplus")
        WidgetUtils.SelfHitTestInvisible(self.TxtLimitNum)
        local strTime = ""
        if nDay > 0 then
            strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
        else
            strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
        end

        self.TxtLimitNum:SetText(strTime)
    else
        WidgetUtils.Collapsed(self.TxtLimitNum)
    end
end

--设置可购买数量
function tbClass:UpdateHaveNum()
    local tbConfig = self.tbGoosInfo
    if not tbConfig then 
        self.TxtNum:SetText(0)
        return 
    end

    local nShowNum, nHaveNum = IBLogic.GetMonthCardData(tbConfig)
    --self.TxtNum:SetText(math.max(0, nShowNum - nHaveNum))
end

--显示价格
function tbClass:ShowPrice()
    local tbConfig = self.tbGoosInfo
    if not tbConfig then 
        WidgetUtils.Collapsed(self.PanelMoney)
        return
    end

    local tbCost = IBLogic.GetRealPrice(tbConfig)
    local _,sTxtIcon, nPrice = IBLogic.GetPriceInfo(tbCost)
    if not sTxtIcon or not nPrice then return end

    WidgetUtils.SelfHitTestInvisible(self.PanelMoney)

    self.TXTNote:SetText(sTxtIcon)
    self.TXTMoney:SetText(NumberToString(nPrice))
end

function tbClass:ShowItemList()
    local tbItems = self:MakeShowItems()
    for i=1,2 do
        local sTxt = self["Txt"..i]
        local sNum = self["Num"..i]
        local tbInfo = tbItems and tbItems[i]
        local bHide = true
        if tbInfo then
            local iteminfo = UE4.UItem.FindTemplate(tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4])
            if iteminfo then
                local sName = "1"
                if tbInfo[5] and tbInfo[5]  > 1 then
                    sName = NumberToString(tbInfo[5])
                end

                WidgetUtils.SelfHitTestInvisible(sTxt)
                WidgetUtils.SelfHitTestInvisible(sNum)
                sNum:SetText(sName)
                bHide = false
            end
        end

        if bHide then
            WidgetUtils.Collapsed(sTxt)
            WidgetUtils.Collapsed(sNum)
        end
    end
end

--构建显示物品  ui上反过来了，调换给数据
function tbClass:MakeShowItems()
    local gdpln = self.tbGoosInfo.tbItem
    local template = UE4.UItem.FindTemplate(gdpln[1], gdpln[2], gdpln[3], gdpln[4])
    local tbItem = {}
    local nGetNum = IBLogic.GetMonthSignAward()
    if nGetNum > 0 then
        local temp = Copy(IBLogic.tbMonthGiveItem)
        temp[5] = nGetNum
        temp[6] = "TxtShopPurchaseBuy"
        table.insert(tbItem, temp)
    end

    if template.LuaType == "itembox" and template.Param1 then
        local tbBoxConfig = Item.tbBox[template.Param1]
        if tbBoxConfig then
            for _, tbInfo in pairs(tbBoxConfig) do
                for _, tbcfg in pairs(tbInfo) do
                    for _, item in ipairs(tbcfg) do
                        local info = Copy(item.tbGDPLN)
                        if not IBLogic.CheckMonthItem(info) and UE4.UItem.FindTemplate(info[1], info[2], info[3], info[4]).Genre > 0 then
                            table.insert(tbItem, info)
                        end
                    end
                end
            end
        end
    end

    return tbItem
end

return tbClass
