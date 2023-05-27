-- ========================================================
-- @File    : uw_activityweek_list.lua
-- @Brief   : 短签Task
-- ========================================================

local tbShortTask=Class("UMG.SubWidget")
tbShortTask.bShowAmi = false

function tbShortTask:Construct()
    self.BtnGet.OnClicked:Add(
        self,
        function()
            if Activity.IsOpen(self.tbParam.nId) then
                return UI.ShowTip(Text('ui.TxtSignNot'))
            end

            if self.tbParam.bFinished then
                return UI.ShowTip(Text('ui.TxtFinishSign'))
            end

            return UI.ShowTip(Text('ui.TxtSignNot'))
        end
    )
end

--- 奖励条目
function tbShortTask:OnListItemObjectSet(InParam)
    self.tbParam = InParam.Data
    self:OnAddRewardItem(self.tbParam.tbReward)
    self:SetNumTxt(self.tbParam.nDayId)
    self:IsSpecial(self.tbParam, self.tbParam.bFinished)
    self:CheckFinished(self.tbParam.bFinished, self.tbParam.bChannel)
end

--- 签到奖励
function tbShortTask:OnAddRewardItem(InData)
    if not InData then return end

    self.pRewardItem = Model.Use(self)
    self:DoClearListItems(self.ListItem)
    for index, value in ipairs(InData) do
        local tbParam = {
            G = value[1],
            D = value[2],
            P = value[3],
            L = value[4],
            N = value[5],
            pItem = nil,
            Total = value[5],
            Name = "",
        }
        local Reward =self.pRewardItem:Create(tbParam)
        self.ListItem:AddItem(Reward)
    end
end

--- 奖励描述
---@param string Instr 文本内容，当前为条目Index 
function tbShortTask:SetNumTxt(InStr)
    self.TxtNormalNum:SetText(InStr)
    self.TxtSpecialNum:SetText(InStr)
end

---@param InState boolean 是否完成 
---@param InChannel boolean true 默认完成，false 首次完成
function tbShortTask:CheckFinished(InState,InChannel)
    if InChannel == true and not tbShortTask.bShowAmi then
        self:PlayFinish(0)
        tbShortTask.bShowAmi = true
    end

    self:SetAWardPanel(InState)
end


--- 标记重点
function tbShortTask:IsSpecial(InParam, InState)
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelSpecial)
    if InParam.Special == 2 and not InState then
        WidgetUtils.SelfHitTestInvisible(self.PanelSpecial)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelNormal)
    end

    if InParam.Color and not self.tbParam.bFinished then
        local hexColor = UE4.UUMGLibrary.GetSlateColorFromHex(InParam.Color)
        self.bg2:SetColorAndOpacity(hexColor)
    end
end

function tbShortTask:OnDestruct()
    EventSystem.Remove(self.ClickHandle)
end

function tbShortTask:PlayFinish(InBegin)
    if not self:IsAnimationPlaying(self.AniGet) then
        self:PlayAnimation(self.AniGet, InBegin, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

function tbShortTask:SetAWardPanel(InState)
    if InState then
        WidgetUtils.SelfHitTestInvisible(self.PanelGet)
    else
        WidgetUtils.Collapsed(self.PanelGet)
    end
end

return tbShortTask