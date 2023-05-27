-- ========================================================
-- @File    : umg_fashion_preview.lua
-- @Brief   : 商城预览界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()

    BtnAddEvent(
        self.BtnSize,
        function()
            if self.CurMode then
                self:RefreshCameraType(PreviewType.role_fashion_preview1)
            else
                self:RefreshCameraType(PreviewType.role_fashion_preview)
            end
            self.CurMode = not self.CurMode
        end
    )

    BtnAddEvent(self.BuyBtn, function() self:DoPurchase() end)

    self.CurMode = true
end

function tbClass:OnOpen(InParam)
    if not InParam or not InParam.CharacterTemplate or not InParam.SkinIndex then
        return
    end
    PreviewScene.Enter(PreviewType.role_lvup)

    if InParam.tbMallConfig then
        self.tbMallConfig = InParam.tbMallConfig
        WidgetUtils.Visible(self.BuyBtn)
    else
        WidgetUtils.Collapsed(self.BuyBtn)
    end

    -- 获取角色皮肤的模板 并创建preview actor
    local Template = InParam.CharacterTemplate
    local pCardTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(Template.Genre, Template.Detail, Template.Particular, Template.Level)
    local pSkinTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(7, Template.Detail, Template.Particular, InParam.SkinIndex)
    Preview.PreviewByGDPL(UE4.EItemType.CharacterCard , Template.Genre, Template.Detail, Template.Particular, Template.Level, PreviewType.role_fashion_preview)
    Preview.UpdateCharacterSkin(pSkinTemplate.AppearID)

    -- 创建特效
    local effectPath = "/Game/Effects/UI/e_ui_mall_fashion/e_ui_mall_fashion_bp.e_ui_mall_fashion_bp_C"
    local softPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(effectPath)

    local pClass = UE4.UGameAssetManager.GameLoadAsset(softPath)
    if pClass then
        self.Effect = GetGameIns():GetWorld():SpawnActor(pClass)
        if self.Effect then
            local location = Preview.GetModel():K2_GetActorLocation()
            location.Z = location.Z + 80
            self.Effect:K2_SetActorLocation(location)
        end
    end

    -- 记录初始Rotation
    self.Actor = Preview.GetModel()
    self.Interaction:Init(self, self.Actor)

    self:UpdateSkinInfo(pCardTemplate, pSkinTemplate)
end

function tbClass:UpdateSkinInfo(InCardTemplate, InSkinTemplate)
    self.GirlName:SetText(Text(InCardTemplate.I18N))
    self.FashionName:SetText(Text(InSkinTemplate.I18N))
    self.Describe:SetText(Text(InSkinTemplate.I18N.."_des"))
    SetTexture(self.Logo, InCardTemplate.Icon)
    SetTexture(self.Logo_1, InCardTemplate.Icon)
end

function tbClass:RefreshCameraType(InPreviewType)
    Preview.PlayCameraAnimByCfgByID(0, InPreviewType)
end

--旋转
function tbClass:OnRotate(Value)
    if self.Actor then
        local NowRot = self.Actor:K2_GetActorRotation()
        local NewRot = NowRot + UE4.FRotator(0, 1, 0) * Value * 0.5
        self.Actor:K2_SetActorRotation(NewRot, false)
    end
end

function tbClass:OnClose()
    self.tbMallConfig = nil
    self.tbTemplate = nil
    if self.Effect then
        self.Effect:K2_DestroyActor()
    end
end

--购买
function tbClass:DoPurchase()
    if not self.tbMallConfig then --是否商城跳转的界面
        --跳转 皮肤商店
        if IBLogic.GotoMall(IBLogic.Tab_IBSkin) then
            UI.Close(self)
        end
        return
    end

    local tbSkinItem = nil
    local tbItemList = IBLogic.GetSkinItem(self.tbMallConfig)
    if tbItemList and #tbItemList > 0 then 
        tbSkinItem = tbItemList[1]
        if not tbSkinItem or tbSkinItem[1] ~= Item.TYPE_CARD_SKIN then 
            tbSkinItem = nil
        end
    end

    if not tbSkinItem then 
        UI.ShowTip("error.BadIBGoodId")
        return
    end

    --已购买
    if Fashion.CheckSkinItem(tbSkinItem) then 
        UI.ShowTip("ui.Mall_Limit_Buy")
        return
    end

    local bUnlock, tbDes = Condition.Check(self.tbMallConfig.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    local nStartTime = self.tbMallConfig.nStartTime
    local nEndTime = self.tbMallConfig.nEndTime

    if not IsInTime(nStartTime, nEndTime) then
        UI.ShowTip("tip.ItemExpirated")
        return
    end

    local isok, id, num = self:CheckPrice()
    if isok then
        if self.tbMallConfig.nAddiction > 0 then
            UI.Open("MessageBox", Text("ui.WarningTips"),
                function()
                    self:DoRealBuy()
                end
            )
        else
            self:DoRealBuy()
        end
        return
    end

    if id == Cash.MoneyType_Gold then   --兑换
        UI.Open("MessageBox", string.format(Text("tip.exchange_jump_mall"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Gold).sName)),
                function() --跳转数据金商店
                    CashExchange.ShowUIExchange(Cash.MoneyType_Gold)
                end
            )
    elseif id == Cash.MoneyType_Money then   --前往商店比特金购买界面
        UI.Open("MessageBox", string.format(Text("tip.exchange_jump_shop"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Money).sName)),
            function() --跳转比特金商店
                CashExchange.ShowUIExchange(Cash.MoneyType_Money)
            end
        )
    else
        UI.ShowMessage("tip.gold_not_enough")
    end
end

--根据
function tbClass:DoRealBuy()
    if IBLogic.CheckProductSellOut(self.tbMallConfig.nGoodsId) then 
        UI.ShowTip("tip.Mall_Limit_Buy")
        return 
    end

    IBLogic.DoBuyProduct(self.tbMallConfig.nType, self.tbMallConfig.nGoodsId)
end

---价格检查
function tbClass:CheckPrice()
    local priceInfo = IBLogic.GetRealPrice(self.tbMallConfig)
    if priceInfo then
        priceInfo = {priceInfo}
    end

    if not priceInfo then return true end

    for _, v in pairs(priceInfo) do
        local havenum = 0
        local disPrice = v[#v]
        if #v >= 5 then
            havenum = me:GetItemCount(v[1], v[2], v[3], v[4])
        else
            if v[1] == Cash.MoneyType_RMB then
                return true
            end

            havenum = Cash.GetMoneyCount(v[1])
        end
        if havenum < disPrice then
            Audio.PlayVoices("NoMoney")
            return false, v[1], v[2]
        end
    end
    return true
end

return tbClass 