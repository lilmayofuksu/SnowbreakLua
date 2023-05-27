-- ========================================================
-- @File    : uw_dungeonsonline_rewarditem.lua
-- @Brief   : 联机周积分奖励条目界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

--显示主要界面
function tbClass:OnListItemObjectSet(pObj)
    local Factory = Model.Use(self)
    local tbParam = pObj.Data
    local tbConfig = tbParam.tbConfig  --活动配置信息

    self.TxtScore:SetText(tbConfig.nPoint)
   -- self.TxtScore_1:SetText(tbConfig.nPoint)

    self:DoClearListItems(self.ListItem)
    if tbConfig.tbRewards then
        for _, item in ipairs(tbConfig.tbRewards) do
            local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5], bGeted = state == 2}
            local pObj = Factory:Create(cfg)
            self.ListItem:AddItem(pObj)
        end
    end

    self:ShowState(tbConfig, tbParam.tbGetAllFunc)
end

--显示获取状态
function tbClass:ShowState(tbConfig, tbFunc)
    if not tbConfig then return end

    if Online.GetWeeklyAward(tbConfig.nId) then
        WidgetUtils.SelfHitTestInvisible(self.PanelCompleted)
        WidgetUtils.SelfHitTestInvisible(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelGain)
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Collapsed(self.ImgFrame)
        WidgetUtils.Collapsed(self.ImgBG)

        self.Text:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFF66'))
        self.Image_653:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFF19'))
        self.ImgIcon:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFF66'))
        self.TxtScore:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFF66'))
        self.Image_227:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFF33'))
        self.TxtRewardList:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#FFFFFF66'))
    
    elseif Online.GetWeeklyPoint() >= tbConfig.nPoint then
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.ImgFrame)
        WidgetUtils.SelfHitTestInvisible(self.PanelGain)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.SelfHitTestInvisible(self.ImgFrame)

        self.Text:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0B0B10FF'))
        self.Image_653:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0E0A8A19'))
        self.ImgIcon:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0E0A8ACC'))
        self.TxtScore:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0E0A8ACC'))
        self.Image_227:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#01010433'))
        self.TxtRewardList:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0B0B10CC'))

        self.BtnGot.OnClicked:Clear()
        self.BtnGot.OnClicked:Add(self, function()
            if tbFunc then
                tbFunc()
            end
        end)
    else
        WidgetUtils.Collapsed(self.PanelGain)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.SelfHitTestInvisible(self.ImgFrame)

        self.Text:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0B0B10FF'))
        self.Image_653:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0E0A8A19'))
        self.ImgIcon:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0E0A8ACC'))
        self.TxtScore:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0E0A8ACC'))
        self.Image_227:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#01010433'))
        self.TxtRewardList:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#0B0B10CC'))
    end
end


return tbClass
