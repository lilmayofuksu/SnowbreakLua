-- ========================================================
-- @File    : uw_activity_template08.lua
-- @Brief   : 活动模板7  体力补给
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.tbShowType = {}
    self.SupplyNum = 5
    local receiveBack = function()
        self:UpdatePanel()
        self:PlaySpineAnimation(2)
    end
    for i = 1, self.SupplyNum do
        if self["BtnGet"..i] then
            BtnAddEvent(self["BtnGet"..i], function()
                local Cfg = VigourSupply.GetVigourSupplyCfg(i)
                if not Cfg then
                    return UI.ShowMessage("error.BadParam")
                end
                if not IsInTime(ParseBriefTime(Cfg.sTimeStart), ParseBriefTime(Cfg.sTimeEnd)) then
                    return UI.ShowMessage("ui.TxtLockTime")
                end
                if VigourSupply.IsReceive(Cfg.nId) then
                    self:PlaySpineAnimation(1)
                    return UI.ShowMessage("ui.TxtReceived")
                end
                VigourSupply.ReceiveVigour(Cfg.nId, receiveBack)
            end)
        else
            break
        end
    end

    ---各状态动画名
    self.tbSpineAnimName = {"sp_npc002_fouren", "sp_npc002_rentong", "sp_npc002_stand", "sp_npc002_huanying"}

    ---先播1次sp_npc002_huanying；再播3次sp_npc002_stand
    self.tbStep4Name = {self.tbSpineAnimName[4], self.tbSpineAnimName[3], self.tbSpineAnimName[3], self.tbSpineAnimName[3]}
end

function tbClass:OnOpen(tbParam)
    self:PlayAnimation(self.AllEnter)
    self.nActivityId = tbParam.nActivityId
    if Login.IsOversea() then
        WidgetUtils.HitTestInvisible(self.Oversea)
        WidgetUtils.HitTestInvisible(self.Oversea_1)
    else
        WidgetUtils.Collapsed(self.Oversea)
        WidgetUtils.Collapsed(self.Oversea_1)
    end
    VigourSupply.CheckRefresh(function()
        self.NextRefreshTime = VigourSupply.GetNextRefreshTime()
        self:UpdatePanel()
        self:PlaySpineAnimation()
    end)
end

function tbClass:UpdatePanel()
    --1已领取 2可领取 3不可领取
    self.tbShowType = {}
    for i = 1, self.SupplyNum do
        if self["Supply"..i] then
            local cfg = VigourSupply.GetVigourSupplyCfg(i)
            if cfg then
                -- if cfg.sTitle then
                --     self["TxtName"..i]:SetText(Text(cfg.sTitle))
                -- end
                local startTime = ParseBriefTime(cfg.sTimeStart)
                local endTime = ParseBriefTime(cfg.sTimeEnd)
                self["TextTime"..i]:SetText(os.date("%H:%M", startTime) .. "-" .. os.date("%H:%M", endTime))
                if VigourSupply.IsReceive(cfg.nId) then
                    WidgetUtils.Collapsed(self["Normal"..i])
                    WidgetUtils.Collapsed(self["PanelNo"..i])
                    WidgetUtils.HitTestInvisible(self["PanelGet"..i])
                    self.tbShowType[cfg.nId] = 1
                elseif IsInTime(startTime, endTime) then
                    WidgetUtils.Collapsed(self["PanelGet"..i])
                    WidgetUtils.Collapsed(self["PanelNo"..i])
                    WidgetUtils.HitTestInvisible(self["Normal"..i])
                    self.tbShowType[cfg.nId] = 2
                else
                    WidgetUtils.Collapsed(self["Normal"..i])
                    WidgetUtils.Collapsed(self["PanelGet"..i])
                    WidgetUtils.HitTestInvisible(self["PanelNo"..i])
                    self.tbShowType[cfg.nId] = 3
                end
            end
        else
            break
        end
    end
end

---获取改播放哪个状态的动画
function tbClass:GetSpineIndex()
    for _, value in pairs(self.tbShowType) do
        if value == 2 or value == 3 then
            return 4
        end
    end
    return 3
end

---播放Spine动画
---@param index integer 1 当玩家已领取体力后，玩家再次误触体力道具时播放（不循环）
--- 2 玩家成功领取道具后播放（不会循环）
--- 3 当桌上没有任何颜色的管子时，只播放stand动画（循环）
--- 4 当桌面上有道具（无论是有蓝色管还是红色管）时，与sp_npc002_stand这段动画交替播放（循环）,先播1次sp_npc002_huanying；再播3次sp_npc002_stand
function tbClass:PlaySpineAnimation(index)
    index = index or self:GetSpineIndex()
    self.SpineWidget.AnimationComplete:Clear()
    if index == 1 or index == 2 then
        self.SpineWidget.AnimationComplete:Add(self, function()
            self:PlaySpineAnimation()
        end)
        self.SpineWidget:SetAnimation(0, self.tbSpineAnimName[index], false)
    elseif index == 3 then
        self.SpineWidget:SetAnimation(0, self.tbSpineAnimName[3], true)
    elseif index == 4 then
        self.SpineAnimStep = 1
        self.SpineWidget.AnimationComplete:Add(self, function()
            self:PlaySpineAnimType4()
        end)
        self:PlaySpineAnimType4()
    end
end

---播放状态4交替循环的动画
function tbClass:PlaySpineAnimType4()
    self.SpineWidget:SetAnimation(0, self.tbStep4Name[self.SpineAnimStep], false)

    if self.SpineAnimStep < #self.tbStep4Name then
        self.SpineAnimStep = self.SpineAnimStep + 1
    else
        self.SpineAnimStep = 1
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    self.SpineWidget:Tick(InDeltaTime)
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    local time = GetTime()
    if self.NextRefreshTime and time > self.NextRefreshTime then
        self.NextRefreshTime = nil
        VigourSupply.CheckRefresh(function()
            self.NextRefreshTime = VigourSupply.GetNextRefreshTime()
            self:UpdatePanel()
        end)
    end

    for i = 1, self.SupplyNum do
        local cfg = VigourSupply.GetVigourSupplyCfg(i)
        if cfg then
            if self.tbShowType[cfg.nId] == 1 then
                if not IsInTime(ParseBriefTime(cfg.sTimeStart), ParseBriefTime(cfg.sTimeEnd), time) then
                    WidgetUtils.Collapsed(self["Normal"..i])
                    WidgetUtils.Collapsed(self["PanelGet"..i])
                    WidgetUtils.HitTestInvisible(self["PanelNo"..i])
                    self["RedO"..i]:ActivateSystem(true)
                    self.tbShowType[cfg.nId] = 3
                end
            elseif self.tbShowType[cfg.nId] == 2 then
                if not VigourSupply.IsReceive(cfg.nId) and not IsInTime(ParseBriefTime(cfg.sTimeStart), ParseBriefTime(cfg.sTimeEnd), time) then
                    WidgetUtils.Collapsed(self["Normal"..i])
                    WidgetUtils.Collapsed(self["PanelGet"..i])
                    WidgetUtils.HitTestInvisible(self["PanelNo"..i])
                    self["RedO"..i]:ActivateSystem(true)
                    self.tbShowType[cfg.nId] = 3
                end
            elseif self.tbShowType[cfg.nId] == 3 then
                if not VigourSupply.IsReceive(cfg.nId) and IsInTime(ParseBriefTime(cfg.sTimeStart), ParseBriefTime(cfg.sTimeEnd), time) then
                    WidgetUtils.Collapsed(self["PanelGet"..i])
                    WidgetUtils.Collapsed(self["PanelNo"..i])
                    WidgetUtils.HitTestInvisible(self["Normal"..i])
                    self["BlueO"..i]:ActivateSystem(true)
                    self.tbShowType[cfg.nId] = 2
                end
            end
        else
            break
        end
    end
end

return tbClass
