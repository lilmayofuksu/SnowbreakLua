-- ========================================================
-- @File    : umg_customize.lua
-- @Brief   : 自定义界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

local SID = PlayerSetting.SSID_OPERATION
local MAX_SIZE = 150
local MIN_SIZE = 50

local MAX_ALAPHA = 100
local MIN_ALAPHA = 10

function tbClass:OnInit()
	self.tbCustomize = {
		self.Aim,
		self.Aimfire,
		self.BossHp,
		self.Cancel,
		self.Fire,
		self.Hp,
		self.InteractList,
		self.Pause,
		self.LeftFireBtn,
		self.PlayerSelect,
		self.Time,
		self.Reload,
		self.Teammate,
		self.Skill1,
		self.Skill3,
		self.Skill5,
		self.JoyStick,
		self.CheckKeepRun,
		self.LevelTask,
		self.Jump
	}

	self.tbVisibleType = {}
	self.JoyStick:SetContactWidget(self.CheckKeepRun);
	MAX_SIZE = GlobalConfig.CustomUI.MaxSize
	MIN_SIZE = GlobalConfig.CustomUI.MinSize
	MAX_ALAPHA = GlobalConfig.CustomUI.MaxAlapha
	MIN_ALAPHA = GlobalConfig.CustomUI.MinAlapha
	self.nNormalSize = 100
	self.nNormalAlpha = 90
    BtnAddEvent(self.BtnClose, function() 
    	local sCfg = PlayerSetting.GetCurrentCustomizeCfg()
    	local sCur = self:GetCurCfg() or "";
    	if sCfg == sCur then UI.Close(self) return end
    	UI.Open("MessageBox",Text("tip.arrangement_exit"),function ()
			UI.Close(self) 
		end)
	end)
    BtnAddEvent(self.BtnPut, function()
    	self:PlayAnimation(self.Put, 0, 1 , self.bCollapsed and UE4.EUMGSequencePlayMode.Reverse or UE4.EUMGSequencePlayMode.Forward, 1, false)
    	self.bCollapsed = not self.bCollapsed;
	end)
	BtnAddEvent(self.BtnSave, function()
		local sCur, sTemp = self:GetCurCfg();
		PlayerSetting.CoverCurrentCustomizeCfg(sCur, sTemp)
		UI.ShowTip(Text("tip.arrangement_save"))
	end)
	BtnAddEvent(self.BtnReset, function()
		UI.Open("MessageBox",Text("tip.arrangement_reset"),function ()
			self:ResetWidget()
			self:UpdateCustomizePanel()
			UI.ShowTip(Text("tip.arrangement_reset_success"))
		end)
	end)

	BtnAddEvent(self.BtnSwitch, function ()
		UI.Open("CustomizeSwitch")
	end)

	BtnAddEvent(self.BtnHidden, function ()
		local bChecked = not self.tbVisibleType[self.nSelected]
		self:UpdataWidgetVisible(self.CurWidget, self.nSelected, bChecked)
	end)

	self.BtnUp.OnPressed:Add(self, function()
		self.Dir = UE4.FVector2D(0,-1)
	end)

	self.BtnDown.OnPressed:Add(self, function()
		self.Dir = UE4.FVector2D(0,1)
	end)

	self.BtnLeft.OnPressed:Add(self, function()
		self.Dir = UE4.FVector2D(-1, 0)
	end)

	self.BtnRight.OnPressed:Add(self, function()
		self.Dir = UE4.FVector2D(1,0)
	end)

    self.BtnUp.OnReleased:Add(self, function()
		self.Dir = nil
	end)

	self.BtnDown.OnReleased:Add(self, function()
		self.Dir = nil
	end)

	self.BtnLeft.OnReleased:Add(self, function()
		self.Dir = nil
	end)

	self.BtnRight.OnReleased:Add(self, function()
		self.Dir = nil
	end)

	self.SliderSize.OnValueChanged:Add(self, function(InTarget, Value)
        self.nSizeValue = math.ceil(Value)
        self:UpdateScale()
    end)

    self.SliderAlpha.OnValueChanged:Add(self, function(InTarget, Value)
    	self.nAlphaValue = math.ceil(Value)
        self:UpdateAlpha()
    end)

	self.CheckBoxNotSee.OnCheckStateChanged:Add(self, function(_ , bChecked)
		self:UpdataWidgetVisible(self.CurWidget, self.nSelected, bChecked)
	end
	)

	BtnAddEvent(self.BtnMinus, function ()
        --- reduce
        if not self.CurWidget or self.nSizeValue == MIN_SIZE then return end
        self.nSizeValue = math.ceil(math.max(MIN_SIZE, self.nSizeValue - 1))
		self.SliderSize:SetValue(self.nSizeValue) 
        self:UpdateScale()
    end)

    BtnAddEvent(self.BtnPlus, function ()
        --- add
        if not self.CurWidget or self.nSizeValue == MAX_SIZE then return end
        self.nSizeValue = math.ceil(math.min(MAX_SIZE, self.nSizeValue + 1))
		self.SliderSize:SetValue(self.nSizeValue) 
        self:UpdateScale()
    end)

	BtnAddEvent(self.BtnMinus1, function ()
        --- reduce
        if not self.CurWidget or self.nAlphaValue == MIN_ALAPHA then return end
        self.nAlphaValue = math.ceil(math.max(MIN_ALAPHA, self.nAlphaValue - 1))
		self.SliderAlpha:SetValue(self.nAlphaValue)
        self:UpdateAlpha()
    end)

    BtnAddEvent(self.BtnPlus1, function ()
        --- add
        if not self.CurWidget or self.nAlphaValue == MAX_ALAPHA then return end
        self.nAlphaValue = math.ceil(math.min(MAX_ALAPHA, self.nAlphaValue + 1))
		self.SliderAlpha:SetValue(self.nAlphaValue)
        self:UpdateAlpha()
    end)
end

function tbClass:UpdateScale()
	self.TxtSizeNum:SetText(self.nSizeValue .. '%')
	self.BarSize:SetPercent((self.nSizeValue - MIN_SIZE) / (MAX_SIZE - MIN_SIZE))
	local scale = self.nSizeValue / 100
	self.CurWidget:SetScaleAndUpdatePosition(UE4.FVector2D(scale, scale))
end

function tbClass:UpdateAlpha()
	self.TxtAlphaNum:SetText(self.nAlphaValue .. '%')
	self.BarAlpha:SetPercent((self.nAlphaValue - MIN_ALAPHA) / (MAX_ALAPHA - MIN_ALAPHA))
	local opacity = self.nAlphaValue / 100
	self.CurWidget:SetRenderOpacity(opacity)
end

function tbClass:GetCurCfg()
	local tbSave = {};
	local tbTemp = {};
	local template = PlayerSetting.GetCurrentTemplateCfg() and json.decode(PlayerSetting.GetCurrentTemplateCfg()) or self.tbCfg
	for i,v in ipairs(self.tbCustomize) do
		local scale = v.RenderTransform.Scale
		local opacity = v:GetRenderOpacity()
		local translation = v.RenderTransform.Translation
		local hide = nil
		if self.tbVisibleType[i] == true then
			hide = 0
		elseif self.tbVisibleType[i] == false then
			hide = 1
		end
		local bCanHide = (template[i] ~= nil and template[i][5] ~= nil) and template[i][5] or 1
		local bCanSetSize = (template[i] ~= nil and template[i][7] ~= nil) and template[i][7] or 1
		local bCanSetX = (template[i] ~= nil and template[i][8] ~= nil) and template[i][8] or 1
		local bCanSetY = (template[i] ~= nil and template[i][9] ~= nil) and template[i][9] or 1
		hide = hide ~= nil and hide or (template[i] ~= nil and template[i][6] ~= nil) and template[i][6] or 1
		tbSave[i] =  {
			translation.X,translation.Y,
			scale.X,opacity,bCanHide,
			hide,bCanSetSize,
			bCanSetX,bCanSetY,
		}
		tbTemp[i] = {
			math.floor(tonumber(translation.X)),
			math.floor(tonumber(translation.Y)),
			math.floor(tonumber(scale.X)),
			math.floor(tonumber(opacity)),
			math.floor(tonumber(bCanHide)),
			math.floor(tonumber(hide)),
			math.floor(tonumber(bCanSetSize)),
			math.floor(tonumber(bCanSetX)),
			math.floor(tonumber(bCanSetY)),
		}
	end
	return tbSave and json.encode(tbSave), json.encode(tbTemp) or nil, json.encode(tbTemp)
end

function tbClass:OnOpen()
	self:ResetWidget()
	self:LoadCustomizeCfg()
	self.SelectWidget(17)
	self:UpdateTimer()
	self:UpdateCustomizePanel()
    --WidgetUtils.ShowMouseCursor(self, true);
    --UE4.UGameplayStatics.SetGamePaused(self, true)
    self:UpdateUI()
end

function tbClass:UpdateTimer()
	if self.CurWidget and self.Dir then
		self.CurWidget:Move(self.Dir)
	end
	self.TimerHandle = UE4.Timer.Add(0.05, function ()
        self.TimerHandle = nil
		self:UpdateTimer()
	end)
end

function tbClass:UpdateUI()
	local nActionMode = math.max(PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACTION_MODE), 1)
	local nSelect = math.max(UE4.UUserSetting.GetInt(PlayerSetting.GetCustomizeSelectKey(nActionMode)), 1)
	local sName = PlayerSetting.GetCustomizeCfgNameByIndex(nSelect)
	self.TxtCustomizeSize_1:SetText('ui.TxtSetAction'..nActionMode)
	print("caib aaaaa ", nSelect, sName)
	self.RedirectTextBlock_42:SetText(sName == "" and Text('ui.DefaultName' .. nSelect) or sName)
end

function tbClass:OnClose()
	UE4.Timer.Cancel(self.TimerHandle or 0)
	UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    --WidgetUtils.ShowMouseCursor(self, false);
    --UE4.UGameplayStatics.SetGamePaused(self, false)
end

function tbClass:LoadCustomizeCfg()
	local sCfg = PlayerSetting.GetCurrentCustomizeCfg()
	self.tbCfg = json.decode(sCfg) or {}

	for k,v in pairs(self.tbCfg) do
		local widget = self.tbCustomize[k]
		if widget then 
			widget:SetRenderScale(UE4.FVector2D(v[3], v[3]))
			widget:SetRenderOpacity(v[4])
			widget:SetRenderTranslation(UE4.FVector2D(v[1], v[2]))
			self:UpdataWidgetVisible(widget, k, v[6] == 0 and true or false)
		end
	end
end

function tbClass:UpdataWidgetVisible(widget, index, bHidden)
	self.tbVisibleType[index] = bHidden
	self.CheckBoxNotSee:SetIsChecked(bHidden and true or false)
	if widget.PanleHidden ~= nil then
		widget.PanleHidden:SetVisibility(bHidden and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
	end
end

function tbClass:UpdateCustomizePanel()
	local scale = self.CurWidget.RenderTransform.Scale
	local opacity = self.CurWidget:GetRenderOpacity()

	self.CheckBoxNotSee:SetIsChecked(self.tbVisibleType[self.nSelected] and true or false)

	self.SliderSize:SetLocked(not self.CurWidget.CanDrag)
	self.nSizeValue = math.floor(scale.X * 100 + 0.5)
	self.TxtSizeNum:SetText(self.nSizeValue .. '%')
	self.BarSize:SetPercent((self.nSizeValue - MIN_SIZE) / (MAX_SIZE - MIN_SIZE))
	self.SliderSize:SetValue(self.nSizeValue) 

	self.nAlphaValue = math.floor(opacity * 100 + 0.5)
	self.TxtAlphaNum:SetText(self.nAlphaValue .. '%')
	self.BarAlpha:SetPercent((self.nAlphaValue - MIN_ALAPHA) / (MAX_ALAPHA - MIN_ALAPHA))
	self.SliderAlpha:SetValue(self.nAlphaValue)

	print("wifi =====> 当前选中按钮的序号为: ", self.nSelected)
	if self.tbCfg[self.nSelected] == nil then
		print("wifi =====> 当前选中按钮的配置为空！！！")
	else
		print("wifi =====> 当前选中按钮的配置为: ", json.encode(self.tbCfg[self.nSelected]))
	end
	if self.tbCfg[self.nSelected] ~= nil then
		self.PanelHidden:SetVisibility(self.tbCfg[self.nSelected][5] == 1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
		self.BtnHidden:SetVisibility(self.tbCfg[self.nSelected][5] == 1 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
		self.PanelSize:SetVisibility(self.tbCfg[self.nSelected][7] == 1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
		self.BtnLeft:SetVisibility(self.tbCfg[self.nSelected][8] == 1 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
		self.BtnRight:SetVisibility(self.tbCfg[self.nSelected][8] == 1 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
		self.BtnUp:SetVisibility(self.tbCfg[self.nSelected][9] == 1 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
		self.BtnDown:SetVisibility(self.tbCfg[self.nSelected][9] == 1 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
	else
		self.PanelHidden:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
		self.BtnHidden:SetVisibility(UE4.ESlateVisibility.Visible)
		self.PanelSize:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
		self.BtnUp:SetVisibility(UE4.ESlateVisibility.Visible)
		self.BtnDown:SetVisibility(UE4.ESlateVisibility.Visible)
		self.BtnLeft:SetVisibility(UE4.ESlateVisibility.Visible)
		self.BtnRight:SetVisibility(UE4.ESlateVisibility.Visible)
	end
end

function tbClass:ResetWidget()
	local template = PlayerSetting.GetCurrentTemplateCfg()
	self.tbCfg = template and json.decode(template) or {}
	self.tbVisibleType = {}
	for i,v in ipairs(self.tbCustomize) do
		local cfg = self.tbCfg[i]
		if cfg then
			v:SetRenderScale(UE4.FVector2D(cfg[3], cfg[3]))
			v:SetRenderOpacity(cfg[4])
			v:SetRenderTranslation(UE4.FVector2D(cfg[1], cfg[2]))
			local bHorizontalDrag
			local bVerticalDrag
			if cfg[8] == 1 then
				bHorizontalDrag = false
			else
				bHorizontalDrag = true
			end
			if cfg[9] == 1 then
				bVerticalDrag = false
			else
				bVerticalDrag = true
			end
			v:InitConfigData(bHorizontalDrag, bVerticalDrag)
			self:UpdataWidgetVisible(v, i, cfg[6] == 0 and true or false)
		else
			v:SetRenderScale(UE4.FVector2D(1, 1))
			v:SetRenderOpacity(1)
			v:SetRenderTranslation(UE4.FVector2D(0, 0))
			v:InitConfigData(false, false)
			self:UpdataWidgetVisible(v, i, false)
		end
	end
end

function tbClass.SelectWidget(nIndex)
	local self = UI.GetUI("Customize")
	if self.nSelected == nIndex then return end

	self.nSelected = nIndex
	self.CurWidget = self.tbCustomize[nIndex]
	for i,v in ipairs(self.tbCustomize) do
		v:SetSelected(i == self.nSelected)
	end
	self:UpdateCustomizePanel()
end

return tbClass