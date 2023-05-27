-- ========================================================
-- @File    : umg_dungeons_smap.lua
-- @Brief   : 出击主界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field LevelScrollBox UScrollBox
---@field ListSmap UListView
local tbClass = Class("UMG.BaseWidget")

local Type2WidgetPath = {
    [1] = '/Game/UI/UMG/DungeonsSmap/Widgets/uw_dungeons_resourse_common.uw_dungeons_resourse_common_C',
    [2] = '/Game/UI/UMG/DungeonsSmap/Widgets/uw_dungeons_resourse_elite.uw_dungeons_resourse_elite_C',
    [3] = '/Game/UI/UMG/DungeonsSmap/Widgets/uw_dungeons_resourse_boss.uw_dungeons_resourse_boss_C',
}


function tbClass:OnInit()
    self.ListFactory = Model.Use(self)
    BtnAddEvent(self.ClickBtn, function()
        local popEvent = self.Return:Pop()
        if popEvent then popEvent() end
        self.HasPushToReturn = false
    end)

    BtnAddEvent(self.BtnGo, function()
        if UI.IsOpen("DungeonsSupportGroup") then
            return
        end
        UI.Open("DungeonsSupportGroup", self.nSuit, function(InSuitId)
            self:SelectSuit(InSuitId)
        end)
    end)

    BtnAddEvent(self.Info.BtnInfo, function()
        UI.Open("HelpImages", 16)
    end)
    self.ScrollText_118:SetText(Text('ui.TxtSmapTip3'))
end
---打开UI
---@param nID number 章节ID
function tbClass:OnOpen(nID)
    Launch.SetType(LaunchType.DAILY)
    WidgetUtils.Collapsed(self.ClickBtn)
    WidgetUtils.Visible(self.LevelScrollBox)
    WidgetUtils.Visible(self.Return)
    self.CloseInfoTimer = nil

    self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Silver, Cash.MoneyType_Vigour})
    WidgetUtils.Collapsed(self.Money)

    if nID and self.nID ~= nID then
        self.nID = nID or Daily.GetID()
        self.nChapterID = nil
        self.nLevelID = nil
    else
        self.nID = nID or Daily.GetID()
        self.nChapterID = self.nChapterID or Daily.GetChapterID()
        self.nLevelID = self.nLevelID or Daily.GetLevelID()
    end
    local nextLevelId = Daily.GetNextLevelID()
    local tbNextCfg = Daily.GetCfgByID(nextLevelId)
    if tbNextCfg and tbNextCfg:IsOpen() then
        self.nNextLevelID = nextLevelId;
    end
    Daily.SetID(self.nID)
    Daily.Clear()


    ---获取配置
    local tbCfg = Daily.GetCfgByID(self.nID)
    if not tbCfg then return end

    if not tbCfg:IsOpen() then
        UI.Close(self)
        return
    end

    local tbChapterCfg = Daily.GetChapterByID(self.nID)
    if tbChapterCfg.Guarantee ~= 0 then
        self.MaxGuarantee = tbChapterCfg.Guarantee
        WidgetUtils.Visible(self.Support)
        BtnClearEvent(self.BtnGot)
        BtnAddEvent(self.BtnGot, function()
            Daily.GetGuaranteeReward(self.nSuit, tbCfg.nID, function(InParam)
                if not InParam then
                    return
                end
                self:ShowGuaranteeInfo(tbChapterCfg, tbCfg)
                if self.LevelInfo then
                    if self.MaxGuarantee and self.nGuarantee and self.nGuarantee >= self.MaxGuarantee then
                        self.LevelInfo:SetbMaxGuarantee(true)
                    else
                        self.LevelInfo:SetbMaxGuarantee(false)
                    end
                end
                self.Logistics:InitSuitPanel(InParam.SuitId)
                UI.Open("GainItem", InParam.tbItem)
            end)
        end)
        self:ShowGuaranteeInfo(tbChapterCfg, tbCfg)
        self.Logistics:Display(self.nSuit, function(InSuitId)
            self:SelectSuit(InSuitId)
        end)
    end
    ---设置背景图
    SetTexture(self.Bg, tbCfg.nBg)
    
    ---关卡名字
    self.LevelName:SetText(Text('ui.'..tbCfg.I18N))

    self.tbListItem = {}
    ---显示章节列表
    self:DoClearListItems(self.ListSmap)
    self.ListSmap:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    local selectObj = nil

    for nIdx, nChapterID in ipairs(tbCfg.tbChapter or {}) do
        local tbParam = {nID = nChapterID, fClick = function(o) self:OnSelect(o) end, bSelect = false}
        local pObj = self.ListFactory:Create(tbParam)
        self.ListSmap:AddItem(pObj)
        local cfg = DailyChapter.Get(1, nChapterID)
        if cfg:IsOpen() then
            self.nChapterID = self.nChapterID or nChapterID
        end

        if self.nChapterID == nChapterID then
            tbParam.bSelect = true
            selectObj = pObj
        end
        self.tbListItem[nChapterID] = pObj  
    end

    if selectObj then
        self:OnSelect(selectObj)
    end
    if #tbCfg.tbChapter <= 1 then
        WidgetUtils.Collapsed(self.ListSmap)
    else
        WidgetUtils.Visible(self.ListSmap)
    end

    if Daily.bShowLevelInfo then
        local tbLevelCfg = DailyLevel.Get(self.nLevelID)
        if tbLevelCfg and tbLevelCfg:CheckCondition() then
            self:ShowLevelInfo()
        end
        Daily.bShowLevelInfo = false
    end

    --- 跳转回来的时候LevelInfo打开的话 强制刷新一次
    if self.LevelInfo and self.LevelInfo:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        Daily.SetChapterID(self.nChapterID)
        Daily.SetLevelID(self.nLevelID)
        self:ShowLevelInfo()
    end
end

---章节选择改变
---@param pObj UObject 选择对象
function tbClass:OnSelect(pObj)
    if not pObj then return end


    if self.currentObj == pObj then return end

   local nChapterID = pObj.Data.nID
    local tbCfg = Daily.GetChapterByID(nChapterID)

    if not tbCfg then return end

    if not tbCfg:IsOpen() then
        UI.ShowTip(tbCfg:GetOpenDayStr())
        return
    end

    if self.currentObj then
       EventSystem.TriggerTarget(self.currentObj, 'SELECT_CHANGE', false)
    end
   
    self.nLevelID = self.nLevelID or nil
    self.LevelScrollBox:SetScrollOffset(0)
 
    EventSystem.TriggerTarget(pObj, 'SELECT_CHANGE', true)
    self.currentObj = pObj
    self.nChapterID = nChapterID
    ---保存章节ID
    Daily.SetChapterID(self.nChapterID)
    WidgetUtils.Collapsed(self.PanelNotOpen)
    WidgetUtils.Visible(self.LevelScrollBox)
    self:ShowLevels(tbCfg)
end

---显示关卡列表
function tbClass:ShowLevels(tbCfg)
    for _, pWidget in pairs(self.tbWidget or {}) do
        pWidget:RemoveFromViewport()
    end

    self.tbWidget = {}
    local nNum = #tbCfg.tbLevel
    for nIdx, nLevelID in ipairs(tbCfg.tbLevel or {}) do
        self.nLevelID = self.nLevelID or nLevelID
        local bSelect = self.nLevelID == nLevelID
        if bSelect and not self.nNextLevelID then
            Daily.SetLevelID(self.nLevelID)
        end
        local pNode = self['Level0' .. nIdx]
        if pNode then
            WidgetUtils.SelfHitTestInvisible(pNode)
            local pCreate = LoadWidget(Type2WidgetPath[1])
            if pCreate then
                pNode:AddChild(pCreate)
                self.tbWidget[nLevelID] = pCreate

                pCreate:Set(nLevelID, bSelect, function(n)
                        self:OnSelectLevel(n)
                    end)
            end
        end

        WidgetUtils.HitTestInvisible(self['Line' .. nIdx])
    end
    if self.nNextLevelID then
        Daily.SetLevelID(self.nNextLevelID)
    end
    ---隐藏多余的
    for i = nNum , 7 do
        WidgetUtils.Collapsed(self['Line' .. i])
    end

    for i = nNum + 1 , 8 do
        WidgetUtils.Collapsed(self['Level0' .. i])
    end
end

---关卡选择
---@param nLevelID number 关卡ID
function tbClass:OnSelectLevel(nLevelID)
    local cfg = DailyLevel.Get(nLevelID)
    local bPass, tbTip = cfg:CheckCondition()
    if not bPass then
        UI.ShowTip(string.gsub(tbTip[1], "_", "-"))
        return
    end

    if self.tbWidget[self.nLevelID] then
        self.tbWidget[self.nLevelID]:OnSelectChange(false)
    end
    ---设置当前关卡
    self.nLevelID = nLevelID
    if self.tbWidget[self.nLevelID] then
        self.tbWidget[self.nLevelID]:OnSelectChange(true)
    end
    Daily.SetLevelID(nLevelID)

    self:ShowLevelInfo()
    DailyLevel.SetFirstCheck(cfg)
    if self.tbWidget[self.nLevelID] then
        self.tbWidget[self.nLevelID]:UpdateRed(cfg)
    end
end

---显示关卡详细信息
function tbClass:ShowLevelInfo()
    if not self.LevelInfo then
        self.LevelInfo = WidgetUtils.AddChildToPanel(self.CanvasPanel_0, '/Game/UI/UMG/DungeonsSmap/Widgets/uw_dungeons_smap_level_info.uw_dungeons_smap_level_info_C', 1)
    end
    self.LevelInfo:PlayAnimation(self.LevelInfo.AllEnter)
    if self.MaxGuarantee and self.nGuarantee and self.nGuarantee >= self.MaxGuarantee then
        self.LevelInfo:Show(DailyLevel.Get(self.nLevelID), true)
    else
        self.LevelInfo:Show(DailyLevel.Get(self.nLevelID), false)
    end
    WidgetUtils.Visible(self.ClickBtn)
    WidgetUtils.SelfHitTestInvisible(self.LevelScrollBox)
    WidgetUtils.SelfHitTestInvisible(self.Money)

    if not self.HasPushToReturn then
        self.HasPushToReturn = true
        self.Return:Push(function()
            WidgetUtils.Collapsed(self.ClickBtn)
            if self.CloseInfoTimer then return end
            self.LevelInfo:PlayAnimation(self.LevelInfo.AllEnter, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
            self.CloseInfoTimer = UE4.Timer.Add(0.5, function()
                WidgetUtils.Collapsed(self.LevelInfo)
                WidgetUtils.Collapsed(self.Money)
                WidgetUtils.Visible(self.LevelScrollBox)
                self.CloseInfoTimer = nil
                self.HasPushToReturn = false
            end)
        end)
    end
end

---显示保底值相关信息
function tbClass:ShowGuaranteeInfo(tbChapterCfg, tbCfg)
    local value = me:GetAttribute(102, tbCfg.nID)
    self.nSuit = GetBits(value, 16, 31)
    if (self.nSuit == 0 or not Daily.tbSupportDrop[self.nSuit]) and Daily.DefaultSuit ~= 0 then
        Daily.SetSelectSuit(Daily.DefaultSuit, tbCfg.nID)
        self.nSuit = Daily.DefaultSuit
    end
    self.nGuarantee = GetBits(value, 0, 15)
    self.ExpBar:SetPercent(math.min(self.nGuarantee/tbChapterCfg.Guarantee, 1))
    self.Num1:SetText(self.nGuarantee)
    self.Num2:SetText(tbChapterCfg.Guarantee)
    if self.nGuarantee >= tbChapterCfg.Guarantee then
        WidgetUtils.Collapsed(self.PanelNo)
        WidgetUtils.SelfHitTestInvisible(self.PanelGot)
    else
        WidgetUtils.Collapsed(self.PanelGot)
        WidgetUtils.SelfHitTestInvisible(self.PanelNo)
    end
end

function tbClass:SelectSuit(InSuitId)
    if InSuitId and InSuitId ~= self.nSuit then
        self.nSuit = InSuitId
        Daily.SetSelectSuit(self.nSuit, self.nID, function(InParam)
            if not InParam or not InParam.SuitId then
                return
            end
            self.Logistics:InitSuitPanel(InParam.SuitId)
        end)
    end
end

function tbClass:OnDisable()
    self.Return:Pop()
    self.HasPushToReturn = false
end

return tbClass