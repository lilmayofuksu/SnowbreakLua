-- ========================================================
-- @File    : uw_setup_option_item.lua
-- @Brief   : 设置
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.OnStateChangedEvent:Add(self,
        function(_, nIndex)
           if self.nCheckIndex == nIndex then return end
           Audio.PlaySounds(3005)
           if self.fOnChange then
                self.nCheckIndex = nIndex
                self.fOnChange(nIndex)
           end
        end
    )
    
    BtnAddEvent(self.BtnPrompt, function ()
        if self.TipsVisible then
            WidgetUtils.Collapsed(self.PanelDetail)
        else
            WidgetUtils.Visible(self.PanelDetail)
        end
    end)

    self.CanvasPanel_62:SetRenderOpacity(1)
    self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))

    self:RegisterEvent(Event.MouseButtonUp, function() 
        WidgetUtils.Collapsed(self.PanelDetail)
    end)

    self:RegisterEvent(Event.MouseButtonUp, function() 
        self.TipsVisible = WidgetUtils.IsVisible(self.PanelDetail)
        WidgetUtils.Collapsed(self.PanelDetail)
    end)
end

function tbClass:OnDestruct()
    self:RemoveRegisterEvent()
    self.OnStateChangedEvent:Clear()
    BtnClearEvent(self.BtnPrompt)
end


function tbClass:OnListItemObjectSet(InObj)
    self:Set(InObj.Data)
end

function tbClass:Set(Data)
    self.nCheckIndex = Data.nCheckIndex
    self.fOnChange = Data.fOnChange
    local tbCfg = Data.tbData
    self.TxtSliderName:SetText(Text(string.format('setting.%s', tbCfg[2])))
    local tbSub = tbCfg[3]
    local nSum = #tbSub
    for index, value in ipairs(tbSub) do
        self['TxtCheck'..index]:SetText(Text(string.format('setting.%s', value)))
        --self['TxtCheck'..index..'_1']:SetText(Text(string.format('setting.%s', value)))
        local pBox = self.Content:GetChildAt(index - 1)
        if pBox then
            WidgetUtils.SelfHitTestInvisible(pBox)
        end
    end
    for i = nSum, self.Content:GetChildrenCount() do
        local pBox = self.Content:GetChildAt(i)
        if pBox then
            WidgetUtils.Collapsed(pBox)
        end
    end

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
    self:Select(Data.nCheckIndex)
end

function tbClass:OnDisableChange(InDisable)
    if InDisable then
        WidgetUtils.HitTestInvisible(self.CanvasPanel_62)
        self.CanvasPanel_62:SetRenderOpacity(0.4)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 0.4))
    else
        self.CanvasPanel_62:SetRenderOpacity(1)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_62)
    end
end

return tbClass
