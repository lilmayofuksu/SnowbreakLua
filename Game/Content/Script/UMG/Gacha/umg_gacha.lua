-- ========================================================
-- @File    : umg_gacha.lua
-- @Brief   : 扭蛋界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field GachaID UEditableText
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.ListTab:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

---PC
function tbClass:CanEsc()
    return self:CanInput()
end

---输入判定
function tbClass:CanInput()
    return not Gacha.bDisableInput
end

function tbClass:OnClose()
    EventSystem.Remove(self.nAttChangeHandle)
    self.nAttChangeHandle = nil
    Gacha.CleanCacheExists()
end

function tbClass:OnDisable()
    if self.pCurrentRes then self.pCurrentRes:OnHide() end
end

function tbClass:OnInit()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnOne, function()  self:DoLaunch(1)  end )
    BtnAddEvent(self.BtnTen, function() self:DoLaunch(10) end  )
    BtnAddEvent( self.BtnInfo, function() UI.Open("GachaInfo", self.nId) end )
    BtnAddEvent( self.BtnShop,  function()   UI.Open("Shop", 22) end)
    self.nAttChangeHandle = EventSystem.On(Event.CustomAttr, function(gid, sid, value)
        if gid == Gacha.GID and sid == Gacha.SID_DAILY_TOTAL_TIME then
            self:UpdateDailyTime()
        end
    end)
    self.tbCacheRes = {}
    BtnAddEvent(self.BtnChoose, function() UI.Open('UpSelect', self.nId) end)

    self:StreamingScene(PreviewType.gacha)

    self.bUpdateTime = false
    self.DisTime = 0
end

---打开UI
---@param nId number 蛋池ID
function tbClass:OnOpen(nId)
    self.nCacheID = nId
    Adjust.GachaMainRecord()
    Audio.PlaySounds(3016)
    self.Title:SetCustomEvent(function()
        if not self:CanInput() then  return end
        UI.Close(self)
    end, function()
        if not self:CanInput() then return end
        UI.OpenMainUI()
    end)
    self:ResetVariable()
    Gacha.bDisableInput = true
    self:OnRspOpenTime()
    PreviewScene.Enter(PreviewType.main, function() Gacha.bDisableInput = false end)
end

function tbClass:OnRspOpenTime()
    print('OnRspOpenTime :', self.nCacheID)
    self:CheckInit()
    self:InternalDisplay(self.nCacheID)
end

function tbClass:CheckInit()
    if self.bCheckInit then return end
    self.bCheckInit = true
    self.tbOpenPool = {}
    for id, cfg in pairs(Gacha.tbGacha or {}) do
        if cfg:IsInTime() then
            if cfg:IsNewPool() then
                local nTotalTime= cfg:GetTotalTime()
                if nTotalTime < cfg.nFreshmanTime then
                    local nTriggerTime = cfg:GetSureTriggerNum()
                    local nTotalTime = cfg:GetTotalTime()
  
                    if nTotalTime >= nTriggerTime then
                        table.insert(self.tbOpenPool, {id = id, order = -1})
                    else
                        table.insert(self.tbOpenPool, {id = id, order = cfg.nIndex})
                    end
                end
            else
                table.insert(self.tbOpenPool, {id = id, order = cfg.nIndex})
            end
        end
    end
end

---内部展示处理
function tbClass:InternalDisplay(nId)
    local tbOpenPool = self.tbOpenPool or {}

    if #tbOpenPool > 0 then
        WidgetUtils.Visible(self.BtnInfo)
        WidgetUtils.Visible(self.BtnShop)
        WidgetUtils.Visible(self.BtnOne)
        WidgetUtils.Visible(self.BtnTen)
    else
        WidgetUtils.Collapsed(self.BtnInfo)
        WidgetUtils.Collapsed(self.BtnShop)
        WidgetUtils.Collapsed(self.BtnOne)
        WidgetUtils.Collapsed(self.BtnTen)

        UI.Close(self)
        return
    end

    table.sort(tbOpenPool, function(a, b)
        return a.order > b.order
    end)

    self.nId = nId or self.nId
    self.nId = self.nId or tbOpenPool[1].id

    if not self.nId then return end

    self:DoClearListItems(self.ListTab)

    self.tbCache = {}
    self.currentParam = nil

    if not self.Factory then return end

    for _, pool in ipairs(tbOpenPool) do
        local bSelect = (pool.id == self.nId)
        local tbParam = {
            nId = pool.id,
            bSelect = bSelect,
            OnTouch = function(data)
                self:OnSelectChange(data)
            end,
            SetSelected = function(tbSelf)
                EventSystem.TriggerTarget(tbSelf, "SET_SELECTED")
            end
        }
        local pObj = self.Factory:Create(tbParam)
        self.ListTab:AddItem(pObj)
        self.tbCache[pool.id] = tbParam
    end

    self:OnSelectChange(self.tbCache[self.nId])
  
    Gacha.DoCacheExists()
    Online.CheckAndShowInviteUI(true)
end

---重置变量
function tbClass:ResetVariable()
    Gacha.bDisableInput = false
    self.tbCache = {}
end

---执行抽卡请求
---@param nTime Integer 抽卡次数
function tbClass:DoLaunch(nTime)
    if not self:CanInput() then return end
    if not self.nId or not nTime  then return end

    local cfg = Gacha.GetCfg(self.nId)
    if not cfg then return end

    ---独立新手池
    if cfg:IsNewPool() then
        if nTime == 1 then
            print('do launch err', nTime, cfg.nType)
            return
        else
            local nTotalTime= cfg:GetTotalTime()
            if nTotalTime >= cfg.nFreshmanTime then
                UI.ShowTip(Text('tip.FreshmanTime'))
                return
            end
        end
    end

    

    if cfg:IsOpenUpSelect() then
        if cfg:GetSelectUp() == nil then
            UI.Open('UpSelect', self.nId)
            return
        end
    end

    ---检查每日次数
    if Gacha.Check_GetDailyLeftTime() < nTime then
        local sTip = nTime == 10 and Text('tip.GachaLeftTimeLess10') or Text("tip.GachaLeftTime")
        UI.ShowTip(sTip)
        return
    end

    self.nSendTime = nTime
    local fDo = function()  Gacha.Req_Launch(self.nId, nTime) end

    --- 先检查消耗
    local bCan, _ = self.tbCfg:CheckCost(nTime)
    if not bCan then
        UI.Open("GachaExchange", self.nId, nTime, fDo)
    else
        local bTip = Gacha.GetIsTip()
        if bTip then
            UI.Open("GachaTip", self.nId, nTime, fDo)
        else
            fDo()
        end
    end
end

---抽卡回调
---@param tbAwards table 奖励类容
function tbClass:LaunchRsp(tbAwards)
    if self:IsOpen() == false then return end

    Adjust.GachaRecord(self.nId, self.nSendTime)
    Gacha.tbResult = tbAwards
    local exchangeUI = UI.GetUI('GachaExchange')
    if exchangeUI then
        UI.Close(exchangeUI)
    end
    
    Gacha.bDisableInput = true
    local pTap = UI.Open("GachaTap")
    WidgetUtils.HitTestInvisible(pTap)
    PreviewScene.Enter(PreviewType.gacha, function()
        Gacha.bDisableInput = false
        WidgetUtils.SelfHitTestInvisible(pTap)
    end)
end

---刷新剩余时间
function tbClass:UpdateDailyTime()
    self.TxtName:SetText(Text("ui.TxtGachaAllLeftTime", Gacha.Check_GetDailyLeftTime()))
end

---蛋池选择改变
---@param tbData table
function tbClass:OnSelectChange(param)
    if not param then return end

    if self.currentParam == param then
        return
    end

    if self.currentParam then
        self.currentParam.bSelect = false
        self.currentParam:SetSelected()
    end
    self.currentParam = param
    if self.currentParam then
        self.currentParam.bSelect = true
        self.currentParam:SetSelected()
        self:ShowDetail(param.nId)
    end
end

---显示蛋池信息
function tbClass:ShowDetail(nId)
    if not nId then return  end

    self.nId = nId
    self.tbCfg = Gacha.GetCfg(nId)
    if not self.tbCfg then return end

    self:UpdateDailyTime()

    if self.pCurrentRes then
        self.pCurrentRes:OnHide()
        WidgetUtils.Collapsed(self.pCurrentRes)
    end

    self.pCurrentRes = self:FindOrAddResWidget(self.tbCfg)
    if self.pCurrentRes then
        self.pCurrentRes:OnShow(self.tbCfg)
        WidgetUtils.SelfHitTestInvisible(self.pCurrentRes)
    end

    local pOneTemplate = UE4.UItem.FindTemplate(table.unpack(self.tbCfg.tbCastOne[1]))
    SetTexture(self.ImgIconOne, pOneTemplate.Icon)
    self.NumOne:SetText(tostring(self.tbCfg.tbCastOne[1][5]))

    local pTenTemplate = UE4.UItem.FindTemplate(table.unpack(self.tbCfg.tbCastTen[1]))
    SetTexture(self.ImgIconTen, pTenTemplate.Icon)
    self.NumTen:SetText(tostring(self.tbCfg.tbCastTen[1][5]))

    if self.tbCfg.nTimeBan == 1 then
        WidgetUtils.Collapsed(self.PanelTime)
        self.bUpdateTime = false
    else
        if self.tbCfg.tbPoolTime then
            WidgetUtils.Visible(self.PanelTime)
            self.bUpdateTime = true
            self.DisTime = ParseTime(self.tbCfg.tbPoolTime[2] or 0) or 0
            --self.TxtTime:SetText(self.tbCfg:GetOpenTimeStr())
        else
            self.bUpdateTime = false
            WidgetUtils.Collapsed(self.PanelTime)
        end

    end

    self.Money:Init({self.tbCfg.tbCastOne[1],Cash.MoneyType_Gold})

    ---独立新手池
    if self.tbCfg:IsNewPool() then
        WidgetUtils.HitTestInvisible(self.RookieTip)
        WidgetUtils.Collapsed(self.NormalTip)
        self.TxtTipNumRookie:SetText(Text('ui.TxtGachaTotalnum', self.tbCfg.nFreshmanTime - self.tbCfg:GetTotalTime(), self.tbCfg.nFreshmanTime))
        self.TxtTipRookie:SetContent(Text('gacha.SpecialProtect_detaildes', self.tbCfg.nFreshmanTime))
        WidgetUtils.HitTestInvisible(self.Rookie)
        WidgetUtils.Collapsed(self.BtnOne)
        WidgetUtils.HitTestInvisible(self.Discount)
        self.PreNum1_1:SetText(10)
        WidgetUtils.HitTestInvisible(self.DiscountNum)
    else
        WidgetUtils.Collapsed(self.DiscountNum)
        WidgetUtils.Visible(self.BtnOne)
        WidgetUtils.Collapsed(self.Discount)
        WidgetUtils.Collapsed(self.Rookie)
        WidgetUtils.Collapsed(self.RookieTip)
        WidgetUtils.HitTestInvisible(self.NormalTip)
        if self.tbCfg.sDes then
            self.TxtTip:SetContent(Text(string.format("gacha.%s_protect", self.tbCfg.sDes), self.tbCfg:GetProtectNum()))
        end
        self.TxtTipNum:SetText(Text('ui.TxtGachaTotalnum', self.tbCfg:GetTime(), self.tbCfg:GetSureTriggerNum()))
    end

    ---Select UP
    if self.tbCfg:IsOpenUpSelect() then
        WidgetUtils.Visible(self.BtnChoose)
        self:RefreshSelectUP()
    else
        WidgetUtils.Collapsed(self.BtnChoose)
    end
end

function tbClass:RefreshSelectUP()
    if self.tbCfg == nil then return end
    local tbSelectUP = self.tbCfg:GetSelectUp()
    if tbSelectUP then
        self.Item:Display({G = tbSelectUP[1], D = tbSelectUP[2], P = tbSelectUP[3], L = tbSelectUP[4]})
    else
        local tbUp = Gacha.GetUps(self.tbCfg) or {}
        if tbUp[1] then
            self.Item:Display({G = tbUp[1][1], D = tbUp[1][2], P = tbUp[1][3], L = tbUp[1][4]})
        end
        if UI.IsOpen('UpSelect') == false then
            UI.Open('UpSelect', self.tbCfg.nId)
        end
    end
end

function tbClass:FindOrAddResWidget(cfg)
    if not cfg or cfg.tbResourceInfo == nil then 
        return 
    end
    local sResourcePath = cfg.tbResourceInfo[1]
    if not sResourcePath or sResourcePath == '' then return end

    local pResWidget = self.tbCacheRes[sResourcePath]
    if pResWidget == nil then
        pResWidget = LoadWidget(string.format('/Game/UI/UMG/Gacha/Widgets/%s.%s_C', sResourcePath, sResourcePath))
        self.ResContent:AddChild(pResWidget)

        local pSlot = UE4.UWidgetLayoutLibrary.SlotAsOverlaySlot(pResWidget)
        if pSlot then
            pSlot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Fill)
            pSlot:SetVerticalAlignment(UE4.EVerticalAlignment.VAlign_Fill)
        end
        self.tbCacheRes[sResourcePath] = pResWidget
    end
   return pResWidget
end

function tbClass:Tick()
    if not self.bUpdateTime then return end

    if self.DisTime > GetTime() then
        local nDay, nHour, nMin, nSec = TimeDiff(self.DisTime, GetTime())
        if nDay > 0 then
            local strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
            WidgetUtils.SelfHitTestInvisible(self.TxtDay)
            WidgetUtils.Collapsed(self.TxtTime)
            self.TxtDay:SetText(strTime)
        else
            local strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
            WidgetUtils.SelfHitTestInvisible(self.TxtTime)
            WidgetUtils.Collapsed(self.TxtDay)
            self.TxtTime:SetText(strTime)
        end
    else
        WidgetUtils.Collapsed(self.TxtDay)
        WidgetUtils.Collapsed(self.TxtTime)
    end
end

return tbClass
