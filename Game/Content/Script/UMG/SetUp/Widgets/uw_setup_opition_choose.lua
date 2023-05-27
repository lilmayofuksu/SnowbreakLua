-- ========================================================
-- @File    : uw_setup_opition_choose.lua
-- @Brief   : 设置
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListBtn)
    WidgetUtils.Collapsed(self.PanelList)
    BtnAddEvent(self.BtnSelect,function ()
        if WidgetUtils.IsVisible(self.PanelList) or self.disable then
            WidgetUtils.Collapsed(self.PanelList)
        else
            local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
            if Controller then
                local _, x, y = UE4.UWidgetLayoutLibrary.GetMousePositionScaledByDPI(Controller)
                self:OnForcus(UE4.FVector2D(x, y))
            end
        end
    end)
    BtnAddEvent(self.BtnPrompt, function ()
        if self.TipsVisible then
            WidgetUtils.Collapsed(self.PanelDetail)
        else
            WidgetUtils.Visible(self.PanelDetail)
        end
    end)
    
    self.CanvasPanel_90:SetRenderOpacity(1)
    self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))

    self:RegisterEvent(Event.MouseButtonUp, function() 
        self.TipsVisible = WidgetUtils.IsVisible(self.PanelDetail)
        WidgetUtils.Collapsed(self.PanelDetail)
    end)
end

function tbClass:OnDestruct()
    self:RemoveRegisterEvent()
    BtnClearEvent(self.BtnSelect)
    BtnClearEvent(self.BtnPrompt)
end

function tbClass:OnForcus(InPosition)
    WidgetUtils.SelfHitTestInvisible(self.PanelList)
    local Border = self:FindWidget("OuterScrollBox")
    if Border then
        local Geometry = Border:GetCachedGeometry()
        local Size = UE4.USlateBlueprintLibrary.GetLocalSize(Geometry)
        local viewSacle = UE4.UWidgetLayoutLibrary.GetViewportScale(self)

        local Height = #self.tbSub * 56 + math.max(0, (#self.tbSub - 1) * 10)
        local Pos = UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, Geometry, InPosition * viewSacle)
        --local Pos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Geometry, InPosition)
        local bUp = (Pos.Y + Height > Size.Y) and (Pos.Y > Height)
        self.PanelList:SetRenderTranslation(UE4.FVector2D(0, bUp and -(Height + 50) or 0))
        print('uw_setup_opition_choose PanelListHeight', Height, 'CurPos', Pos.X, Pos.Y, 'ScreenPox', InPosition.X, InPosition.Y, 'BoxSizeHeight', Size.Y, 'IsUp', bUp)
    end
end

function tbClass:OnBlur(InPosition)
    WidgetUtils.Collapsed(self.PanelList)
end

function tbClass:OnListItemObjectSet(InObj)
    self:Set(InObj.Data)
end

function tbClass:Set(Data)
    self.Multi = Data.bMulti
    self.nCheckIndex = Data.nCheckIndex + 1
    self.fOnChange = Data.fOnChange
    local tbCfg = Data.tbData
    self.TxtSliderName:SetText(Text(string.format('setting.%s', tbCfg[2])))
    self.tbSub = tbCfg[3]
    self.IsImg = Data.bImg
    self.DisabelVal = Data.disableVal
    local nSum = #self.tbSub

    if not self.Factory then
        self.Factory = Model.Use(self)
    end

    if self.Multi then
        self:MultiRead(Data.nCheckIndex)
    end

    self:DoClearListItems(self.ListBtn)
    self.tbChoose = {}
    for index, value in ipairs(self.tbSub) do
        local tb = {Index = index, Value = value, IsImg = self.IsImg, Cur = self:GetCurrentIndex(index), pSelect = function ()
            if self.nCheckIndex == index and not self.Multi then 
                WidgetUtils.Collapsed(self.PanelList)
                return 
            end
            self:Select(index)
        end}
        local NewItem = self.Factory:Create(tb)
        self.ListBtn:AddItem(NewItem)
        table.insert(self.tbChoose, tb)
    end

    self:Select()
    WidgetUtils.Visible(self.ListBtn)
    self.Tip = Data.tip
    if self.TxtDetail then
        self.TxtDetail:SetText(Text(self.Tip))
    end
    if self.Tip then
        WidgetUtils.SelfHitTestInvisible(self.PanelPrompt)
        WidgetUtils.Visible(self.BtnPrompt)
    else
        WidgetUtils.Collapsed(self.BtnPrompt)
    end
end

function tbClass:GetCurrentIndex(index)
    if self.Multi then
        return self.MultiData[index] and index or 0
    end
    return self.nCheckIndex
end

function tbClass:Select(index)
    if self.Multi then
        if index then
            self.MultiData[index] = not self.MultiData[index]
        end
        
        local temp = 0
        local count = 0
        for i,v in ipairs(self.MultiData) do
            if v then
                count = count + 1
                temp = temp + 10^(i-1)
            end

            local item = self.tbChoose[i]
            if item and item.Check then
                item.Check(i, v and i or 0)
            end
        end

        local key = 'setting.selectpart'
        if count == 0 then
            key = 'setting.selectnone'
        elseif count == #self.tbSub then
            key = 'setting.selectall'
        end

        self.TxtSl:SetText(Text(key))
        WidgetUtils.Collapsed(self.ImgLanguage)
        --WidgetUtils.Collapsed(self.PanelList)
        self.nCheckIndex = temp
        if self.fOnChange and index then
            self.fOnChange(self.nCheckIndex)
        end
        return
    end

    self.nCheckIndex = index or self.nCheckIndex
    if self.IsImg then
        SetTexture(self.ImgLanguage, tonumber(self.tbSub[self.nCheckIndex]))
        WidgetUtils.SelfHitTestInvisible(self.ImgLanguage)
        WidgetUtils.Collapsed(self.TxtSl)
    else
        self.TxtSl:SetText(Text('setting.' .. self.tbSub[self.nCheckIndex]))
        WidgetUtils.SelfHitTestInvisible(self.TxtSl)
        WidgetUtils.Collapsed(self.ImgLanguage)
    end

    
    WidgetUtils.Collapsed(self.PanelList)
    for i,v in ipairs(self.tbChoose) do
        if v.Check then v.Check(i, self.nCheckIndex) end
    end
    if self.fOnChange and index then
        self.fOnChange(self.nCheckIndex - 1)
    end
end

function tbClass:MultiRead(data)
    self.MultiData = {}
    for i=1,#self.tbSub do
       local bSelect = math.floor((data % 10^i) / 10^(i-1)) > 0
       self.MultiData[i] = bSelect
    end
end

function tbClass:Disable(bVal)
    if bVal then
        if self.DisabelVal then
            self.TxtSl:SetText(Text(self.DisabelVal))
        end
        WidgetUtils.HitTestInvisible(self.CanvasPanel_90)
        self.CanvasPanel_90:SetRenderOpacity(0.4)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 0.4))
    else
        if self.DisabelVal then
            self:Select()
        end
        self.CanvasPanel_90:SetRenderOpacity(1)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_90)
    end
    self.disable = bVal
end

return tbClass
