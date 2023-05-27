-- ========================================================
-- @File    : uw_setup_user_item.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")
local SID = PlayerSetting.SSID_OTHER

function tbClass:Construct()
    BtnClearEvent(self.BtnClick.BtnUser)
	BtnAddEvent(self.BtnClick.BtnUser, function ()
        if self.disable then return end
        if self.ClickFunc and self.tbCfg then
            self.ClickFunc(self.tbCfg)
        end
    end)
end

function tbClass:OnDestruct()
    BtnClearEvent(self.BtnClick.BtnUser)
end

function tbClass:Set(tbData)
    self.tbCfg = tbData.Cfg;
    self.ClickFunc = tbData.pFunc

    local label = Text('setting.'..self.tbCfg.sName)
    local text = Text('setting.'..self.tbCfg.sText)

    
	self.TxtSliderName:SetText(label)
    self.BtnClick.TxtUserName:SetText(text)
end

function tbClass:Disable(bVal)
    if bVal then
        WidgetUtils.HitTestInvisible(self.CanvasPanel_90)
        self.BtnClick:SetRenderOpacity(0.4)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 0.4))
    else
        self.BtnClick:SetRenderOpacity(1)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_90)
    end
    self.disable = bVal
end

return tbClass