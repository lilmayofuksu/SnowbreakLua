-- ========================================================
-- @File    : uw_sign14_item.lua
-- @Brief   : 短签Task
-- ========================================================

local tbShortTask=Class("UMG.SubWidget")
tbShortTask.bShowAmi = false
tbShortTask.tbTypeIcon = 
{
    --武器
    {1400000, 1400001, 1400002, 1400003, 1400004},
    --皮肤
    {1400210}
}

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
    
    --特殊背景
    if self.tbParam.Special then
        WidgetUtils.SelfHitTestInvisible(self.Sp)
    else
        WidgetUtils.Collapsed(self.Sp)
    end

    --图标
    SetTexture(self.Icon, pTemplate.Icon)


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

    --道具类型图标
    if self.ImgType then
        if data[1] == Item.TYPE_CARD_SKIN then
            SetTexture(self.ImgType, self.tbTypeIcon[2][1])
        elseif data[1] == Item.TYPE_WEAPON then
            SetTexture(self.ImgType, self.tbTypeIcon[1][data[2]]) 
        else
            WidgetUtils.Collapsed(self.ImgType)
        end
    end

    if self.tbParam.bFinished then
        WidgetUtils.Collapsed(self.ImgBG)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG_1)
    else
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.Collapsed(self.ImgBG_1)
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
    if not self:IsAnimationPlaying(self.Get) then
        WidgetUtils.Visible(self.Select)
        self:PlayAnimation(self.Get, InBegin, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
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