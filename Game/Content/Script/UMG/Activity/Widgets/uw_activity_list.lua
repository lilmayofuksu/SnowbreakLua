-- ========================================================
-- @File    : uw_activity_list.lua
-- @Brief   : 活动标签列表  具体每个大标签和子标签组
-- ========================================================
local tbActiveList = Class("UMG.SubWidget")

--构造
function tbActiveList:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListSecondary)
    --当前显示的group
    self.ShowGroup = nil
end

function tbActiveList:OnDestruct()
    if self.ReceiveVigourEventID then
        EventSystem.Remove(self.ReceiveVigourEventID)
    end
end

--- 界面入口
function tbActiveList:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data
    local tbCaseList = tbParam.tbCaseList or {} --活动配置列表
    local nGroupPos = tbParam.nGroupPos --主标签里的位置
    local bShow = tbParam.bShow --初始默认显示

    self:ClearList(Condition)
    self.ShowGroup = nGroupPos
    tbParam.nSelectTag = nil --当前选中子标签
    --注册给上层使用 上层回调回来，防止self和数据不是同一个
    --tbInfo = tbParam
    tbParam.DoShowClick = function(tbInfo, nTagPos)  self:DoShowClick(tbInfo, nTagPos)  end
    tbParam.ClearAllState = function(tbInfo) self:ClearAllState(tbInfo) end

    self:ShowGroupPanel(tbCaseList, bShow)

    self.BtnSelect.OnClicked:Clear()
    self.BtnSelect.OnClicked:Add(self, function()
        self:OnClickGroup(tbCaseList, nGroupPos, tbParam.nSelectTag)
    end)

    if self.ReceiveVigourEventID then
        EventSystem.Remove(self.ReceiveVigourEventID)
    end
    for _, tbConf in pairs(tbCaseList) do
        if tbConf.sClass == "vigour_supply" then
            self.ReceiveVigourEventID = EventSystem.OnTarget(VigourSupply, VigourSupply.EventReceiveVigour, function()
                if Activity.CheckAllCaseRed(tbCaseList) then
                    WidgetUtils.Visible(self.New)
                else
                    WidgetUtils.Collapsed(self.New)
                end
            end)
            break
        end
    end
end

--当前主标签显示
function tbActiveList:ShowGroupPanel(tbCaseList, bSelect)
    if not tbCaseList then return end

    --更新锁定状态
   local bLock = self:CheckAllCaseLock(tbCaseList)
   self:ShowGroupLock(bLock)

    --显示红点
    if Activity.CheckAllCaseRed(tbCaseList) then
        WidgetUtils.Visible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end

    --默认状态
    self:ChangeState(bSelect)

    --默认显示第一个子标签的图片
    local cfg = tbCaseList[1]
    if cfg and cfg.sTitleDes then
        self.TxtCheckedName:SetText(Text(cfg.sTitleDes))
        self.TxtUncheckedName:SetText(Text(cfg.sTitleDes))
    else
         self.TxtCheckedName:SetText("")
         self.TxtUncheckedName:SetText("")
    end

    if cfg and cfg.nTitleIcon then
        SetTexture(self.IconUnchecked, cfg.nTitleIcon)
        SetTexture(self.IconOnChecked, cfg.nTitleIcon)
    end
end

--切换当前选中状态
function tbActiveList:ChangeState(bSelect)
    if bSelect then
        if not WidgetUtils.IsVisible(self.OnChecked) then
            self.p1:ActivateSystem()
        end
        
        WidgetUtils.SelfHitTestInvisible(self.OnChecked)
        WidgetUtils.Collapsed(self.Unchecked)
    else
        if WidgetUtils.IsVisible(self.OnChecked) then
            self.p1:DeactivateSystem()
        end

        WidgetUtils.SelfHitTestInvisible(self.Unchecked)
        WidgetUtils.Collapsed(self.OnChecked)
    end
end

--- 点击主标签
function tbActiveList:OnClickGroup(tbCaseList, nGroupPos, nSelectTag)
    local nCurIdx = nSelectTag or 1
    local tbConfig = tbCaseList and tbCaseList[nCurIdx]
    if not tbConfig then
        UI.ShowTip('tip.congif_err')
        return
    end

    --更新锁定状态
    local bLock = self:CheckAllCaseLock(tbCaseList)
    self:ShowGroupLock(bLock)
    if bLock then
        Activity.ClickLockTip(tbConfig)
        return
    end

    if #tbCaseList == 1 and Activity.IsRedFlag(tbConfig.nId) then
        Activity.Quest_Flag(tbConfig.nId)
    end

    --调用活动主界面的点击函数 从头开始
    local sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OnClickItem(tbConfig, nGroupPos)
    end
end

--- 动态清空子标签列表
function tbActiveList:ClearList(tbInfo)
    self:DoClearListItems(self.ListSecondary)

    if tbInfo then
        tbInfo.tbTagClassList = {}  --子标签管理
    end
end

--- 添加子标签
function tbActiveList:ShowChilds(tbInfo)
    if not tbInfo or not tbInfo.tbCaseList then
        return
    end

    --清空 子标签列表
    self:ClearList(tbInfo)

    WidgetUtils.SelfHitTestInvisible(self.ListSecondary)
    WidgetUtils.Collapsed(self.CaseItem)

    --如果需要排序 先排序再添加
    
    for index, tbConfig in ipairs(tbInfo.tbCaseList) do
        local tbParam ={
            tbConfig = tbConfig,
            nTagPos = index,  --子标签table里的位置
            nGroupPos  = tbInfo.nGroupPos,  --主标签里的位置
            bShow =  (tbInfo.nSelectTag and tbInfo.nSelectTag or 1) == index
        }
        local pObj = self.Factory:Create(tbParam)
        self.ListSecondary:AddItem(pObj)

        table.insert(tbInfo.tbTagClassList, pObj.Data)
    end
end


--检测所有小标签 锁定状态
function tbActiveList:CheckAllCaseLock(tbCaseList)
    if not tbCaseList or #tbCaseList == 0 then
        return false
    elseif #tbCaseList == 1 then
        return not Activity.IsOpen(tbCaseList[1].nId)
    end

    for i,v in ipairs(tbCaseList) do
        bLock = not Activity.IsOpen(v.nId)
        if not bLock then
            return false
        end
    end

    return true
end

--显示锁定状态
function tbActiveList:ShowGroupLock(bLock)
    if bLock then
        WidgetUtils.SelfHitTestInvisible(self.Lock)
    else
        WidgetUtils.Collapsed(self.Lock)
    end
end

--执行点击显示 本界面和上级界面调用
-----@param tbInfo table 当前活动数据
-----@param nTagPos integer 子标签位置
function tbActiveList:DoShowClick(tbInfo, nTagPos)
    if self.ShowGroup ~= tbInfo.nGroupPos then return end

    if tbInfo.nSelectTag ~= nil and nTagPos == nil then --折叠子标签
        if self.ListSecondary:GetNumItems() > 0 then
            --清空子标签
            self:ClearList(tbInfo)
            return
        end
    end

    nTagPos = nTagPos or 1
    local nCaseNum = #tbInfo.tbCaseList
    if self.ListSecondary:GetNumItems() == 0 then
        --刷新主标签选中状态
        self:ChangeState(true)
        --子标签
        if nCaseNum > 1 then
            self:ShowChilds(tbInfo) --默认子标签
            nTagPos = tbInfo.nSelectTag or 1 --默认子标签
        end
    end

    if nCaseNum > 1 then
        if nTagPos < 0 or nTagPos > nCaseNum then
            nTagPos = 1
        end

        --清空上次选中的子标签
        if tbInfo.nSelectTag and tbInfo.nSelectTag ~= nTagPos
            and tbInfo.tbTagClassList[tbInfo.nSelectTag]
            and tbInfo.tbTagClassList[tbInfo.nSelectTag].ChangeState then
            tbInfo.tbTagClassList[tbInfo.nSelectTag]:ChangeState(false)
        end

        tbInfo.nSelectTag = nTagPos
    end

    self:ShowGroupPanel(tbInfo.tbCaseList, true)

    --选中子标签
    if tbInfo.nSelectTag and tbInfo.tbTagClassList[tbInfo.nSelectTag] and tbInfo.tbTagClassList[tbInfo.nSelectTag].DoShowClick then
       tbInfo.tbTagClassList[tbInfo.nSelectTag]:DoShowClick()
    end
end

--- 清空标签一些状态
function tbActiveList:ClearAllState(tbInfo)
    tbInfo.nSelectTag = nil
    tbInfo.bShow = false
    --清空子标签
    self:ClearList(tbInfo)

    if self.ShowGroup ~= tbInfo.nGroupPos then return end

    --清空当前选中状态
    self:ChangeState(false)
end

return tbActiveList
