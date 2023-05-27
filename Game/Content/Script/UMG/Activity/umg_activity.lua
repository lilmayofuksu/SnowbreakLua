-- ========================================================
-- @File    : umg_activity.lua
-- @Brief   : 活动界面 显示左边主标签组
-- ========================================================
local tbActivity = Class("UMG.BaseWidget")

--构建对应关系
function tbActivity:CheckWidgetList()
    if self.tbPathIndex then return end

    self.tbPathIndex = {}
    local tbPathAry = UE4.TArray(UE4.FString)
    self.Switcher:GetPathArray(tbPathAry)
    if tbPathAry:Length() == 0 then return end

    for i = 1, tbPathAry:Length() do
        local tbInfo = Split(tbPathAry:Get(i), ".uw_")
        if tbInfo and #tbInfo >= 2 and tbInfo[2] then
            local sPath = "uw_" .. tbInfo[2]
            self.tbPathIndex[sPath] = i - 1
        end
    end
end

--构造
function tbActivity:Construct()
    self.Factory = Model.Use(self)

    self.ListActivity:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:CheckWidgetList()
end

---- 进入活动界面
function tbActivity:OnOpen(InParam)
    self:CheckWidgetList()

    self.bOpen = true
    local nGetId = self:DoOpenId(InParam)

    self.nSelectGroup = nil
    local nPos =self:ShowGroups(nGetId)

    self:OnServerRefresh(nPos)

    self.Return:SetCustomEvent(function() self:ClearSelectInfo() UI.CloseTop() end, function() self:ClearSelectInfo() UI.OpenMainUI() end)
    self:PlayAnimation(self.AllEnter)
    self.bOpen = false
end

--清理选择 标签
function tbActivity:ClearSelectInfo()
    Activity.OpenUI_Id = nil
end

--关闭
function tbActivity:OnClose()
    self.nSelectGroup = nil
    self:ClearCaseItem()
    self:ClearCachClick()
end

--- 显示标签组
function tbActivity:ShowGroups(nGetId)
    local tbGroup = Activity.GetSortAllGroup()

    WidgetUtils.Visible(self.ListActivity)
    WidgetUtils.Collapsed(self.Group)
    WidgetUtils.Collapsed(self.ShopTips)

    self:DoClearListItems(self.ListActivity)

    self.tbGroupClassList = {}
    local nGroupPos = 1
    local bHaveShow = false
    local nSubPos = nil
    for key, v in ipairs(tbGroup) do
        local nGroupId = 0
        if v and #v > 0 then
            nGroupId = v[1]
        end
        local tbConfigList = Activity.GetCaseByGroup(nGroupId) or {}
        local  tbParam = {
            tbCaseList  = tbConfigList,
            nGroupPos  = nGroupPos,  --标签里的位置
            bShow = false,
        }

        if nGetId and nGetId > 0 and not nSubPos then
            for j,v in ipairs(tbConfigList) do
                if v.nId == nGetId then
                    tbParam.bShow = true
                    nSubPos = j
                    self.nSelectGroup = nGroupPos
                    break
                end
            end
        else
             tbParam.bShow = (self.nSelectGroup and self.nSelectGroup or 1) == nGroupPos
        end

        local pObj = self.Factory:Create(tbParam)
        self.ListActivity:AddItem(pObj)

        nGroupPos = nGroupPos + 1

        table.insert(self.tbGroupClassList, pObj.Data)
    end

    self.nSelectGroup = self.nSelectGroup or 1
    return nSubPos
end

--- 清理子标签  清理主标签的选中状态
function tbActivity:ClearCaseItem()
    if not self.tbGroupClassList then return end

    for i,v in ipairs(self.tbGroupClassList) do
        if v and v.ClearAllState then
            v:ClearAllState()
        end
    end
end

--点击标签
-----@param tbConfig table 当前活动配置
-----@param nGroupPos integer 主标签位置
-----@param nTagPos integer 子标签位置
-----@param bRefresh bool 服务器返回刷新
function tbActivity:OnClickItem(tbConfig, nGroupPos, nTagPos, bRefresh)
    nGroupPos = nGroupPos or 1

    if nGroupPos < 0 or nGroupPos > self.ListActivity:GetNumItems() then
        return
    end 

    --清理前一个主标签选中状态 以及子标签选中状态
    if self.nSelectGroup ~= nGroupPos then
        if self.tbGroupClassList[self.nSelectGroup].ClearAllState then
            self.tbGroupClassList[self.nSelectGroup]:ClearAllState()
        end

        self.nSelectGroup = nGroupPos
    end

    --选中新的主标签
    if self.tbGroupClassList[self.nSelectGroup].DoShowClick then
        self.tbGroupClassList[self.nSelectGroup]:DoShowClick(nTagPos)
    end

    self:ShowRightInfo(tbConfig, bRefresh)
end

--- 隐藏活动界面 常规只有一个
function tbActivity:ClearCachClick()
    for _, info in pairs(Activity.tbTemplate) do
        if info.sPath and self[info.sPath] then
            local widget = self["Scale_" .. info.sPath] or self[info.sPath]
            if widget and widget.OnClose then widget:OnClose() end
            WidgetUtils.Collapsed(widget)
        end
    end
end

--显示右边的具体活动界面
function tbActivity:ShowRightInfo(tbConfig, bRefresh)
    if not tbConfig then return end

    WidgetUtils.Collapsed(self.ShopTips)
    if Activity.OpenUI_Id == tbConfig.nId and not self.bOpen and not bRefresh then
        return
    end

    self:ClearCachClick()

    --是被锁住的也不显示 防止
    if not Activity.IsOpen(tbConfig.nId) then return end

    local tbTemplate, ModeId = Activity.GetTemplate(tbConfig.nModeId)
    if not tbTemplate then return end
    local sPath = tbTemplate.sPath
    if not sPath then return end

    if not self.tbPathIndex then
        self:CheckWidgetList()
    end

    local nIndex = self.tbPathIndex[sPath]
    if not nIndex then return end

    self.Switcher:SetActiveWidgetIndex(nIndex)

    local Widget = self.Switcher:GetActiveWidget()
    if not Widget then return end

    self[sPath] = Widget

    local tbShowInfo = {
        nActivityId = tbConfig.nId,
        bRefresh = bRefresh,
        fRefreshFun =  function(tbConfig) self:UpdateMoney(tbConfig) end,
    }

    Activity.OpenUI_Id = tbConfig.nId
    if tbConfig.nBg then
        self:ChangeBG(tbConfig.nBg)
    elseif tbTemplate.nBg then
        self:ChangeBG(tbTemplate.nBg)
    end

    Widget:OnOpen(tbShowInfo)
    if Widget.AllEnter then
        Widget:PlayAnimation(Widget.AllEnter)
    end
    WidgetUtils.SelfHitTestInvisible(self["Scale_" .. sPath] or Widget)
end

--修改背景
function tbActivity:ChangeBG(nBG)
    if not nBG then return end
    WidgetUtils.SelfHitTestInvisible(self.ImgBg)
    AsynSetTexture(self.ImgBg, nBG)
end

-- 显示/隐藏背景
function tbActivity:SetBgActive(bActive)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgBg, bActive)
end

-----外部调用 服务器回调等
--获取奖励刷新
function tbActivity:OnReceiveUpdate(tbParam)
    if tbParam and tbParam.tbRewards and #tbParam.tbRewards > 0 then
        Item.Gain(tbParam.tbRewards)
    end

    --选中新的主标签
    self:OnServerRefresh(nil, true)
end

---打开商品详情页
function tbActivity:OpenShopTips(cfg)
    if self.ShopTips == nil then
        self.ShopTips = WidgetUtils.AddChildToPanel(self.ContentNode, '/Game/UI/UMG/Shop/Widgets/uw_shop_tips.uw_shop_tips_C', 1)
    end

    if not self.ShopTips then return end

    WidgetUtils.SelfHitTestInvisible(self.ShopTips)
    self.ShopTips:Init(cfg)
end

---购买商品后刷新页面
function tbActivity:OnByGoodsUpdate()
    WidgetUtils.Collapsed(self.ShopTips)

    --选中新的主标签
    self:OnServerRefresh(nil, true)
end

---刷新显示代币信息
function tbActivity:UpdateMoney(tbConfig)
    if not tbConfig or tbConfig.nModeId ~= 1005 then
        self.Money:ClearAll()
        return
    end

    local info = ShopLogic.GetShopInfo(tbConfig.tbCustomData[1] or 0)
    if info and info.tbShopMoneyType then
        self.Money:Init(info.tbShopMoneyType)
    end
end

--服务器返回刷新从这里开始
function tbActivity:OnServerRefresh(nPos, bRefresh)
    local tbGroup = self.tbGroupClassList[self.nSelectGroup]
    if not tbGroup then return end

    local nCurIdx = nPos and nPos or (tbGroup.nSelectTag or 1)
    local tbConfig = tbGroup.tbCaseList[nCurIdx]
    if not tbConfig then
        return
    end

    self:OnClickItem(tbConfig, self.nSelectGroup, nCurIdx, bRefresh)
end

--处理有打开值的情况
function tbActivity:DoOpenId(nId)
    if nId then
        Activity.OpenUI_Id = tonumber(nId)
    end

    if not Activity.OpenUI_Id then return end
    if not Activity.IsOpen(Activity.OpenUI_Id) then return end

    return Activity.OpenUI_Id
end

return tbActivity
