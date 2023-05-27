
-- ========================================================
-- @File    : uw_activitylittle_list.lua
-- @Brief   : 活动子标签列表  具体每个小标签
-- ========================================================
local tbCase=Class("UMG.SubWidget")
--构造
function tbCase:Construct()
    --当前显示的TagPos
    self.nTagPos = nil
end

--- 界面入口
function tbCase:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data
    local tbConfig = tbParam.tbConfig  --活动配置表
    local nGroupPos = tbParam.nGroupPos --主标签里的位置
    local nTagPos = tbParam.nTagPos --子标签里的位置
    local bShow = tbParam.bShow --初始默认显示

    self.nTagPos = nTagPos

    --注册函数 给上层主标签调用 防止界面和数据不统一
    --选项选中状态
    pObj.Data.ChangeState = function(tbInfo, bState)
            tbInfo.bShow = bState;
        if self.nTagPos == tbInfo.nTagPos then
            self:ChangeState(tbInfo.tbConfig, tbInfo.bShow)
        end
    end

    --点击后显示
    pObj.Data.DoShowClick = function(tbInfo)
            tbInfo.bShow = true; 
        if self.nTagPos == tbInfo.nTagPos then
            self:DoShowClick(tbInfo.tbConfig)
        end
    end

    self:ShowCaseItem(tbConfig, bShow)

    self.BtnSelect.OnClicked:Clear()
        self.BtnSelect.OnClicked:Add(self, function()
            self:OnClickTag(tbConfig, nGroupPos, nTagPos)
        end)
end

--显示当前界面
function tbCase:ShowCaseItem(tbConfig, bState)
    if not tbConfig then return end

    self.TxtName:SetText(Text(tbConfig.sTitleDes))

    --锁定
    local bLock = not Activity.IsOpen(tbConfig.nId)

    --背景
    if tbConfig.nBg then
        SetTexture(self.ImgBg, tbConfig.nBg)
    else
        WidgetUtils.Collapsed(self.ImgBg)
    end

    --选中状态
    self:ChangeState(tbConfig, bState)

    --锁定状态
    if bLock then
        WidgetUtils.SelfHitTestInvisible(self.Image_120)
    else
        WidgetUtils.Collapsed(self.Image_120)
    end

    --红点
    local bShowRed = Activity.CheckActivityRed(tbConfig)
    if bShowRed then
        WidgetUtils.Visible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

--切换当前选中状态 外部会调用
function tbCase:ChangeState(tbConfig, bState)
    if not tbConfig then return end

    if bState then
        WidgetUtils.SelfHitTestInvisible(self.PanelSelect)
        self.TxtSelectName:SetText(Text(tbConfig.sTitleDes))
        WidgetUtils.Collapsed(self.TxtName)
        WidgetUtils.Collapsed(self.ImgPic)
    else
        WidgetUtils.Collapsed(self.PanelSelect)

        WidgetUtils.SelfHitTestInvisible(self.TxtName)
        WidgetUtils.SelfHitTestInvisible(self.ImgPic)
    end
end

--点击标签
function tbCase:OnClickTag(tbConfig, nGroupPos, nTagPos)
    if not tbConfig then return end

    if not Activity.IsOpen(tbConfig.nId) then
        Activity.ClickLockTip(tbConfig)
        return
    end

    --红点
    if Activity.IsRedFlag(tbConfig.nId) then
        Activity.Quest_Flag(tbConfig.nId)
    end

    --调用活动主界面的点击函数 从头开始
    local sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OnClickItem(tbConfig, nGroupPos, nTagPos)
    end
end

--执行点击函数 本界面和上级界面调用
function tbCase:DoShowClick(tbConfig)
    self:ShowCaseItem(tbConfig, true)
end

return tbCase