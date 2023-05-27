-- ========================================================
-- @File    : uw_shop_main.lua
-- @Brief   : 商城推荐界面
-- ========================================================
local tbClass = Class("UMG.SubWidget")

tbClass.tbSpineAnimName = {"sp_npc002_stand", "sp_npc002_huanying", "sp_npc002_rentong"}

function tbClass:Construct()
    BtnAddEvent(self.BtnBuy, function()
        self:DoGoto()
    end)

    BtnAddEvent(self.BtnBuy2, function()
        self:DoGoto()
    end)
end

--判断推荐页是什么?  根据跳转参数
function tbClass:CheckRecommend(tbParam)
    if type(tbParam) ~= "table" then return end
    if #tbParam < 2 then return end

    local nShopType = nil
    if tonumber(tbParam[1]) == 1 then --商店
        local tbShop = IBLogic.GetShopConfig(tonumber(tbParam[2]))
        if not tbShop then return end

        nShopType = tbShop.nWidgetType
    elseif tonumber(tbParam[1]) == 2 then --商品
        local tbGoods = IBLogic.GetIBGoods(tonumber(tbParam[2]))
        if not tbGoods then return end

        if tbGoods.nType  == IBLogic.Type_IBGift then
            nShopType = IBLogic.Tab_IBGift
        elseif tbGoods.nType  == IBLogic.Type_IBSkin then
            nShopType = IBLogic.Tab_IBSkin
        end
    end

     return nShopType
end

--显示
function tbClass:ShowMallInfo(tbData)
    self.tbData = tbData
    local tbConfig = tbData and tbData.tbConfig
    if not tbConfig then return end

    local nShopType = self:CheckRecommend(tbConfig.tbUIParam)

    self:ShowMain(nShopType, tbConfig)

    --self:PlayAnimation(self.AllEnter)
end

function tbClass:ShowMain(nShopType, tbConfig)
    if not tbConfig then return end

    if nShopType == IBLogic.Tab_IBSkin then
        WidgetUtils.Collapsed(self.Box)
        WidgetUtils.Collapsed(self.Spine)
        WidgetUtils.SelfHitTestInvisible(self.Skin)
        if tbConfig.nBG then
            SetTexture(self.PicSkin, tbConfig.nBG)
        end
        return
    end

    WidgetUtils.Collapsed(self.Skin)
    WidgetUtils.SelfHitTestInvisible(self.Box)
    if tbConfig.nBG then
        SetTexture(self.PicBox, tbConfig.nBG)
    end

    if nShopType == IBLogic.Tab_IBGift then
        WidgetUtils.SelfHitTestInvisible(self.Spine)
        self.SpineWidget:SetScaleX(-1)
        self:PlaySpineAnimation(2)
    else
        WidgetUtils.Collapsed(self.Spine)
    end
end

--跳转
function tbClass:DoGoto()
    local tbConfig = self.tbData and self.tbData.tbConfig or {}
    local tbParam = tbConfig and tbConfig.tbUIParam or {}
    if not tbConfig.sGotoUI or #tbParam < 2 then return end

    if tbParam[1] == 1 then
        UI.Open(tbConfig.sGotoUI, tbParam[2])
    else
        local tbGoods = IBLogic.GetIBGoods(tbParam[2])
        if not tbGoods or tbGoods.nShopId == 0 then
            return
        end

        local sUI = UI.GetUI(tbConfig.sGotoUI)
        if sUI and sUI:IsOpen() and sUI.GotoMall then
            sUI:GotoMall(tbGoods.nShopId, tbParam[2])
        else
            UI.Open(tbConfig.sGotoUI, tbGoods.nShopId, tbParam[2])
        end
     end
end

---播放Spine动画
function tbClass:PlaySpineAnimation(index)
    if not index then
        self.nSpineTime = self.nSpineTime or GetTime()
        if GetTime() - self.nSpineTime >= 10 then
            index = (math.random(2)+1)
            self.nSpineTime = GetTime()
        end
    end

    index = index or 1
    self.SpineWidget.AnimationComplete:Clear()
    if index >= 1 and index <= 3 then
        self.SpineWidget.AnimationComplete:Add(self, function()
            self:PlaySpineAnimation()
        end)
        self.SpineWidget:SetAnimation(0, self.tbSpineAnimName[index], false)
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    self.SpineWidget:Tick(InDeltaTime)
end

return tbClass
