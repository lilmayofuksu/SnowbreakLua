
-- ========================================================
-- @File    : uw_logistics_affix.lua
-- @Brief   : 洗练界面
-- ========================================================


local  tbAffixClass = Class("UMG.BaseWidget")
tbAffixClass.AffixPath = "UMG.Support.LogiAffix.Widgets.uw_logistics_affix_info_data"


function tbAffixClass:Construct()

    BtnAddEvent(
        self.BtnClear, 
        function()
            if self.nNeedNum > self.nHaveNum then
                UI.ShowTip("tip.not_material_for_break")
                return
            end
            Logistics.Req_ResetAffix(self.pSupportCard, self.affixCostCfg, function()
                self:UpdateAffixCost()
                self:UpdatePanelClear()
            end)
        end 
    )

    BtnAddEvent(
        self.BtnAffixOld, 
        function()
            Logistics.Req_SelectAffix(self.pSupportCard, false, function()
                self:UpdatePanelClear()
                self:SelectItemIcon()
                self:OptionSelect(2)
                UI.ShowTip(Text('tip.refineFinish'))
            end)
        end 
    )
    
    BtnAddEvent(
        self.BtnAffixNew, 
        function()
            Logistics.Req_SelectAffix(self.pSupportCard, true, function()
                self:UpdatePanelClear()
                self:SelectItemIcon()
                self:OptionSelect(2)
                UI.ShowTip(Text('tip.refineFinish'))
            end)
        end 
    )

    self:OnInit()
end

function tbAffixClass:OnInit()
    self:OptionSelect(1)
    WidgetUtils.Collapsed(self.TxtOldName)
    WidgetUtils.Collapsed(self.HorizontalBox_142)
end


function tbAffixClass:OnActive(InParam,CallFunc,TabCallFun)
    --- 播放All Enter动画
    self:PlayAnimation(self.AllEnter, 0, 1 ,UE4.EUMGSequencePlayMode.Forward, 1, false)

    self.callfunc = CallFunc
    self.TabFun = TabCallFun
    self.pSupportCard = InParam
    Logistics.CulCard = InParam
    self:ShowBg(self.pSupportCard)
    --- 洗练词缀描述
    self:UpdatePanelClear()
    self:ShowAffixItem()
    self:UpdateAffixCost()
end

--- 操作界面的多态
--- @param InState number  Instate:1 -> 词缀显示, 2 -> 洗练词缀界面, 3 -> 新旧词缀选择界面
function tbAffixClass:OptionSelect(InState)
    WidgetUtils.Collapsed(self.PanelClear)
    WidgetUtils.Collapsed(self.PanelAffix)
    WidgetUtils.Collapsed(self.TxtPreview)
    WidgetUtils.Collapsed(self.TxtNewIntro)
    WidgetUtils.Collapsed(self.BtnClear)
    WidgetUtils.Collapsed(self.BtnAffixNew)
    WidgetUtils.Collapsed(self.BtnAffixOld)
    WidgetUtils.Collapsed(self.PanelItem)

    if InState == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelAffix)
    elseif InState == 2 then
        self.callfunc(true)
        -- self.TabFun(true)
        WidgetUtils.SelfHitTestInvisible(self.PanelClear)
        WidgetUtils.SelfHitTestInvisible(self.TxtPreview)
        WidgetUtils.Visible(self.BtnClear)
        WidgetUtils.SelfHitTestInvisible(self.PanelItem)
    elseif InState == 3 then
        self.callfunc(true)
        -- self.TabFun(true)
        WidgetUtils.SelfHitTestInvisible(self.PanelClear)
        WidgetUtils.SelfHitTestInvisible(self.TxtNewIntro)
        WidgetUtils.Visible(self.BtnAffixNew)
        WidgetUtils.Visible(self.BtnAffixOld)
    else
        -- body
    end
end

--- 初始化词缀的显示界面
function tbAffixClass:ShowAffixItem()
    self.affix1Value = self.pSupportCard:GetAffix(1)
    self.affix2Value = self.pSupportCard:GetAffix(2)
    local tbAffix = {1,2,3} 
    local  tbParam = {
        AffixIdx = 0,
        TxtTitle = '',
        TxtValue = '',
        SupportCard = self.pSupportCard,
        OnClick = function()
            self:OptionSelect(2)
            -- self.TabFun(true)
        end,
    }
    for i = 1, 3 do
        tbParam.AffixIdx = i
        local affix = self["affix"..i.."Value"]
        if affix:Length() > 0 then
            local key = affix:Get(1)
            local value = affix:Get(2)
            if key > 0 and value > 0 then
                local affixValue = Logistics.tbAffixValue[key]
                tbParam.TxtTitle = affixValue.key
                tbParam.TxtCont = affixValue.value[value][1]
                tbParam.nIndex = i
                tbParam.TxtDes = 'Affix'..i..'th'
            end
        end
        self["Affix"..i]:OnOpen(tbParam)
    end
end


--- 判断是否有未保存的洗练词缀
--- 如果有的话，强制选择界面
--- 同时刷新一下洗练词缀的界面
function tbAffixClass:UpdatePanelClear()
    self.affix3Value = self.pSupportCard:GetAffix(3)
    self.affix4Value = self.pSupportCard:GetAffix(4)
    if self.affix3Value:Length() <= 0 then
        return
    end
    self.TxtOldIntro:SetText(Logistics.GetAffixShowNameByTarray(self.affix3Value))
    if self.affix4Value and self.affix4Value:Length() > 0 then
        local key = self.affix4Value:Get(1)
        local value = self.affix3Value:Get(2)
        if key ~= 0 and value ~= 0 then
            self:OptionSelect(3)
            self.TxtNewIntro:SetText(Logistics.GetAffixShowNameByTarray(self.affix4Value))
        end
    end
end

function tbAffixClass:UpdateAffixCost()
    local sGDPL = string.format("%s-%s-%s-%s", self.pSupportCard:Genre(), self.pSupportCard:Detail(), self.pSupportCard:Particular(), self.pSupportCard:Level())
    local cfg = Logistics.tbLogiData[sGDPL].AffixCost
    self.affixCostCfg = cfg
    self.nNeedNum = cfg[5]
    self.nHaveNum = me:GetItemCount(cfg[1], cfg[2], cfg[3], cfg[4])
    self.Item:Display({ G = cfg[1], D = cfg[2], P = cfg[3], L = cfg[4], N = {nNeedNum = self.nNeedNum, nHaveNum = self.nHaveNum}})
end

function tbAffixClass:ChangeDes(InWidget,InOn)
    if InWidget then
        if InOn then
            WidgetUtils.SelfHitTestInvisible(InWidget)
        else 
            WidgetUtils.Collapsed(InWidget)
        end
    end
end


function tbAffixClass:SelectItemIcon(InItem)
    self:ChangeDes(self.ImgIcon,false)
    self:ChangeDes(self.NumBox,false)
    self:ChangeDes(self.ImgQuality,false)
    if InItem then
        self:ChangeDes(self.ImgIcon,true)
        self:ChangeDes(self.NumBox,true)
        self:ChangeDes(self.ImgQuality,true)
        self:SelectItemDes()
    end
    -- SetTexture(self.ImgIcon,)
end

function tbAffixClass:SelectItemDes()
    local sNum = string.format('%d/%d',100,1)
    self.TxtDesNum:SetText(sNum)
end

function tbAffixClass:ShowBg(InCard)
    local ResId = InCard:Icon()
    local IconId
    if Logistics.CheckUnlockBreakImg(InCard) then
        IconId = ResId
    else
        IconId = ResId
    end
    SetTexture(self.ImgSerPoseA,IconId,true)
end

return tbAffixClass
