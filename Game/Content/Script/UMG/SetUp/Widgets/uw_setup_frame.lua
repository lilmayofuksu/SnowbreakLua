-- ========================================================
-- @File    : uw_setup_frame.lua
-- @Brief   : 设置
-- ========================================================

---@class tbClass : UUserWidget
---@field List UListView
local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_FRAME

local ContentType = {
    Frame         = 20
}

function tbClass:Construct()

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

   self:Update()
    ---选择变化
   self.GropType.OnStateChangedEvent:Add(self, function(_, nIndex)
        local nLevel = nIndex + 1
        local nCurLevel = PlayerSetting.GetOne(SID, FrameType.LEVEL) or 1
        if nLevel ~= nCurLevel then
            self:LoadStandard(FrameType.LEVEL, nLevel)
            self:ShowOption()
        end
   end)
   --self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
   --self.ListFactory = Model.Use(self)

   self.GropType.TxtCheck6:SetText(Text('setting.custom'))
   self.GropType.TxtCheck6_1:SetText(Text('setting.custom'))

   self.nSelectIndex = 0
   self.nSelectLevel = nil
   self.nSelectType = nil
   --self:DoClearListItems(self.List)

   self.tbWidgets = {}

   self.tbFunc = {
    [FrameType.FPS] = function (tbCfg, nIndex, pCallBack)
        local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
        if not IsPc then
            local nLastIndex = math.min((tonumber(PlayerSetting.GetFrameCheckIndex(tbCfg.Type)) or 0), #tbCfg.Items - 1)
            local nLastLevel = string.gsub(tbCfg.Items[nLastIndex  + 1], 'fps', '')

            local nLevel = string.gsub(tbCfg.Items[nIndex  + 1], 'fps', '')
            if (tonumber(nLevel) or 1) >= 2 and (tonumber(nLastLevel) or 1) < 2 then
                UI.Open("MessageBox", Text("ui.HighFpsTip"), function ()
                    pCallBack()
                end, function ()
                    self:OnActive()
                end)
                return true
            end
        end
    end
   }

    self.FrameSet:Set({sName = "ui.TxtOperationSet.Frame", pFunc = function ()
        UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text("ui.TxtOperationSet.Frame")) , function ()
            PlayerSetting.Set(SID, FrameType.LEVEL, {PlayerSetting.GetDefaultLevel()})
            self:OnActive()
        end)
    end})
end

function tbClass:Update()
    if not IsMobile() then
        local GraphicsSetting = UE4.UGraphicsSettingManager.GetGraphicsSettingManager(GetGameIns())
        -- local nCheckIndex = GraphicsSetting:GetFullScreen()
        -- self.WindowSize:Set({ tbData = {0, 'window_size', {'windowed', 'full_screen'}}, nCheckIndex = nCheckIndex, fOnChange = function(nIndex)
        --     PlayerSetting.SetDisplayCheck(FrameDisplayType.DISPLAY_MODE, nIndex)
        -- end})
        
        local rIndex = 0
        local nDisplayMode = GraphicsSetting:GetFullScreen()
        local rid = PlayerSetting.GetDisplayCheckIndex(FrameDisplayType.RESOLUTION_SIZE)
        local vScreenSize = GraphicsSetting:GetMaxWindowSize()
        local tb = PlayerSetting.GetAdapterResolution(vScreenSize)
        local tbDesc = {}

        for i,v in ipairs(tb) do
            if v.id == rid then rIndex = i - 1 end
            table.insert(tbDesc, v.width .. 'x' .. v.height)
        end

        self.Resolution:Set({ tbData = {0, 'resolution', tbDesc}, nCheckIndex = rIndex, disableVal = vScreenSize.X .. 'x' ..vScreenSize.Y, fOnChange = function(nIndex)
            PlayerSetting.SetDisplayCheck(FrameDisplayType.RESOLUTION_SIZE, tb[nIndex + 1].id)
        end})

        self.Screen:Set({tbData = {0, 'window_size', { 'full_screen', 'no_border_full_screen', 'windowed'}}, nCheckIndex = nDisplayMode, fOnChange = function(nIndex)
            PlayerSetting.SetDisplayCheck(FrameDisplayType.DISPLAY_MODE, nIndex)
            self.Resolution:Disable(nIndex == FrameDisplayModeType.NO_BORDER)
        end})

        self.Resolution:Disable(nDisplayMode == FrameDisplayModeType.NO_BORDER)
    else
        WidgetUtils.Collapsed(self.WindowSize)
        WidgetUtils.Collapsed(self.Resolution)
        WidgetUtils.Collapsed(self.Screen)
    end
end


function tbClass:OnActive()
    local nLevel = PlayerSetting.GetOne(SID, FrameType.LEVEL) or 1
    self.GropType:Select(nLevel - 1)
    self:LoadStandard(FrameType.LEVEL, nLevel)
end

function tbClass:OnReset()
    PlayerSetting.ResetBySID(SID)
    self:OnActive()
end

function tbClass:CheckLevelUpdata(nType, nValue)
    self.GropType:Select(5) --Custom
end

function tbClass:GetWidget(tbCfg)
    local pWidget = self.tbWidgets[tbCfg.Type]
    if tbCfg then
        if not pWidget then
            pWidget = LoadWidget(PlayerSetting.tbClassType[tbCfg.ClassType])
            if pWidget then
                self.tbWidgets[tbCfg.Type] = pWidget
            end
        end
    end
    return pWidget
end

function tbClass:InitWidget(SID, Widget, tbCfg, tbFunc, tbWidgets)
    if tbCfg.ClassType < 2 then
        local tb = tbCfg.Items or {'close', 'open'}
        local nValue = tonumber(PlayerSetting.GetFrameCheckIndex(tbCfg.Type)) or 0
        local check = tbCfg.Multi and nValue or math.min(nValue, #tb - 1)
        Widget:Set({ tbData = {0, tbCfg.Name, tb}, nCheckIndex = check, fOnChange = function(nIndex)
            if tbCfg.Connect then
                for k,tb in pairs(tbCfg.Connect) do
                    if tbWidgets[k] then
                        local bDisable = false
                        for _,v in ipairs(tb) do
                            bDisable = bDisable or (v == nIndex)
                        end
                        tbWidgets[k]:Disable(bDisable)
                    end
                end
            end
            
            local block = nil
            local pFunc = function ()
                PlayerSetting.SetFrameCheck(tbCfg.Type, nIndex)
                self:CheckLevelUpdata(tbCfg.Type, nIndex)
            end

            if tbFunc and tbFunc[tbCfg.Type] then
                block = tbFunc[tbCfg.Type](tbCfg, nIndex, pFunc)
            end

            if not block then pFunc() end
        end, bMulti = tbCfg.Multi, tip = tbCfg.BanTip})
    elseif tbCfg.ClassType == 2 then
        local nMin, nMax = PlayerSetting.GetSliderRange(SID, tbCfg.Type)
        Widget:Init(SID, tbCfg.Type, nMin, nMax, tbCfg.BanTip, function (val)
            self:CheckLevelUpdata(tbCfg.Type, val)
        end)
    elseif (tbCfg.ClassType == 3 or tbCfg.ClassType == 5) and tbFunc then
        local text = tbCfg.Items and tbCfg.Items[1] or tbCfg.Name
        local icon = tbCfg.Items and tbCfg.Items[2] or nil
        local platform = tbCfg.Items and tbCfg.Items[3] or nil

        Widget:Set({Cfg = {sName = tbCfg.Name, sText = text, sUrl = tbCfg.Url, bExternal = tbCfg.External, nIconId = icon, sPlatform = platform}, pFunc = tbFunc[tbCfg.Type]})
    elseif tbCfg.ClassType == 4 then
        Widget:OnActive()
    end
end

function tbClass:LoadStandard(nType, nIndex)
    -- for _,v in ipairs(PlayerSetting.tbFrameSort) do
    --     PlayerSetting.SetFrameCheck(v.Type, PlayerSetting.GetFrameCheckIndexByLevel(nIndex, v.Type))
    --     PlayerSetting.Set(SID, v.Type, {})
    -- end
    local pFunc = function ()
        PlayerSetting.Set(SID, FrameType.LEVEL, {nIndex})
        for _,v in ipairs(PlayerSetting.tbFrameSort) do
            if v.Reference and v.Standard and v.Reference == nType and nIndex <= #v.Standard then
                PlayerSetting.SetFrameCheck(v.Type, v.Standard[nIndex])
            end
        end
        self:ShowOption()
    end

    local block = nil
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    if not IsPc then
        local fpsCfg = PlayerSetting.tbFrameCfg[FrameType.FPS]
        if fpsCfg.Reference and fpsCfg.Standard and fpsCfg.Reference == nType and nIndex <= #fpsCfg.Standard then
            block = self.tbFunc[FrameType.FPS](fpsCfg, fpsCfg.Standard[nIndex], pFunc)
        end
    end
    
    if not block then pFunc() end
end

function tbClass:Align(Widget)
    local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
    slot:SetPadding(self.Padding)
    slot:SetFillEmptySpace(true)
end

function tbClass:ShowOption()
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbFrameSort) do
        if PlayerSetting.IsPageContent(v, IsPc, ContentType) then
            local Widget = self:GetWidget(v)
            self.Content:AddChildToWrapBox(Widget)
            self:Align(Widget)
            self:InitWidget(SID, Widget, v, self.tbFunc, self.tbWidgets)
        end
    end
    self:CheckConnect(SID, self.tbWidgets)
end

function tbClass:CheckConnect()
    for _,v in ipairs(PlayerSetting.tbFrameSort) do
        if v.Connect then
            local nValue = PlayerSetting.GetFrameCheckIndex(v.Type) or 0
            for k,tb in pairs(v.Connect) do
                if self.tbWidgets[k] then
                    local bDisable = false
                    for _,v in ipairs(tb) do
                        bDisable = bDisable or (v == nValue)
                    end
                    self.tbWidgets[k]:Disable(bDisable)
                    WidgetUtils.SelfHitTestInvisible(self.tbWidgets[k].ImgItem)
                end
            end
        end
    end
end

return tbClass