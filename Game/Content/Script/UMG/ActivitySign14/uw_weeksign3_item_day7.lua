-- ========================================================
-- @File    : uw_sign14_item.lua
-- @Brief   : 短签Task
-- ========================================================

local tbShortTask=Class("UMG.SubWidget")
tbShortTask.bShowAmi = false

function tbShortTask:Construct()
    self.BtnCheck.OnClicked:Add(self,
        function()
            local data = self.tbParam.tbReward[1]
            UI.Open("ItemInfo", data[1], data[2], data[3], data[4], data[5])
        end
    )
end

--- 奖励条目
function tbShortTask:OnListItemObjectSet(InParam)
    WidgetUtils.Collapsed(self.Select)

    if not InParam then
        WidgetUtils.Collapsed(self.PanelMain)
        return
    end
    self.tbParam = InParam.Data

    WidgetUtils.Visible(self.PanelMain)
    self:OnAddRewardItem()
    self:CheckFinished(self.tbParam.bFinished, self.tbParam.bChannel)
end

function tbShortTask:Init(InParam)
    self:OnListItemObjectSet(InParam)
end

--- 签到奖励
function tbShortTask:OnAddRewardItem()
    if not self.tbParam.tbReward or not self.tbParam.tbReward[1] then return end
    local data = self.tbParam.tbReward[1]
    local tbParam = {
        G = data[1],
        D = data[2],
        P = data[3],
        L = data[4],
        N = data[5],
        bGeted = false,
        bSign = true
    }
    
    -- 日期
    self.TxtName:SetText(self.tbParam.nDayId)
    -- 道具名字
    local pTemplate = UE4.UItem.FindTemplate(data[1], data[2], data[3], data[4])
    if self.Name then
        if self.tbParam.Tips then
            self.Name:SetText(Text(self.tbParam.Tips))
        else
            self.Name:SetText(Text(pTemplate.I18N))
        end
    end

    --图标
    if self.tbParam.icon then
        SetTexture(self.Icon, self.tbParam.icon)
    end


    --选中状态
    if self.tbParam.bNext then
        WidgetUtils.Visible(self.Select)
    else
        WidgetUtils.Collapsed(self.Select)
    end

    --数量
    if data and data[5] then
        self.Num:SetText(data[5])
    else
        WidgetUtils.Collapsed(self.Num)
    end
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


function tbShortTask:OnDestruct()
    EventSystem.Remove(self.ClickHandle)
end

function tbShortTask:PlayFinish(InBegin)
    if not self:IsAnimationPlaying(self.SelectAnim) then
        WidgetUtils.Visible(self.Select)
        self:PlayAnimation(self.SelectAnim, InBegin, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

function tbShortTask:SetAWardPanel(InState)
    if InState then
        WidgetUtils.SelfHitTestInvisible(self.PanelGet)
        WidgetUtils.Collapsed(self.Select)
    else
        WidgetUtils.Collapsed(self.PanelGet)
    end
end

return tbShortTask