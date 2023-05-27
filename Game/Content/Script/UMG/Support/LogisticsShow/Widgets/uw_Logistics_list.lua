-- ========================================================
-- @File    : uw_Logistics_list.lua
-- @Brief   : 后勤卡展示条目
-- @Author  :
-- @Date    :
-- ========================================================


local  tbLogistics = Class("UMG.SubWidget")
tbLogistics.ItemPath = "UMG/Support/LogisticsShow/Widgets/uw_Logistics_item_data"

function tbLogistics:Construct()
    self.pItem = Model.Use(self,self.ItemPath)
    self:DoClearListItems(self.TileView)
    self.tbSopportSortType = {
        { Option = Text('ui.item_level')     },
        { Option = Text('ui.TxtRareSort')   },
        { Option = Text('ui.TxtScreen14')}
    }

    self.tbSupportType = {
        {Type = Text("ui.technology")},
        {Type = Text("ui.medicalcare")},
        {Type = Text("ui.equip")},
    }

    self.tbSupporListtPage = {
        {Click = self.BtnType1,Page = self.PanelSkill,OnTag = self.ImgType1On,OffTag = self.ImgType1Off},
        {Click = self.BtnType2,Page = self.PanelSuit,OnTag = self.ImgType2On,OffTag = self.ImgType2Off},
        {Click = self.BtnType3,Page = self.PanelAffix,OnTag = self.ImgType3On,OffTag = self.ImgType3Off},
    }

    for index, value in ipairs(self.tbSupporListtPage) do
        value.Click.OnCheckStateChanged:Add(
            self,
            function()
                self:OnPage(index, true)
            end
        )
        WidgetUtils.Collapsed(value.OnTag)
        WidgetUtils.SelfHitTestInvisible(value.OffTag)
    end

    self.allSupportCards = Logistics.GetAllSupportCards()
    local tbSortParam = {}
    tbSortParam.tbSortInfos = {}
     tbSortParam.tbSortInfos[1] = {
         {
             tbSorts = ItemSort.SupportSelectLevelSort,
             sName =  self.tbSopportSortType[1].Option
         },
         {
             tbSorts = ItemSort.SupportSelectColorSort,
             sName =  self.tbSopportSortType[2].Option
         },
     }
     self.tbCurSort = {nIdx = 1, bReverse = false}
     tbSortParam.fSort = function(nIdx, bReverse)
        local itemlist = self:GetSlotSupport(self.page)
         local tbItems = self:SortSupports(nIdx, itemlist, bReverse)
         self:ShowItemList(tbItems)
         self.tbCurSort.nIdx = nIdx
         self.tbCurSort.bReverse = bReverse
     end

    self.Screen:Init(tbSortParam)
    self.tbSortInfo = tbSortParam.tbSortInfos
end

--- 插槽后勤卡，点击事件
---@param  InCharacter UE4.UCharacter 角色卡
---@param  InSlot Interge 插槽位
---@param  pFunc func 点击时间接口
function tbLogistics:OnOpen(InCharacter, InSlot, pFunc, SelectCard)
    self.pClickFun = pFunc
    self.tbSkillTemplateId = {}
    self.Character = InCharacter
    --- 初始化角色插槽上三个技能的信息
    if InCharacter then
        for i = 1, 3 do
            if i ~= InSlot then
                local SCard = InCharacter:GetSupporterCardForIndex(i)
                if SCard then
                    self.tbSkillTemplateId[i] = Logistics.GetSkillSuitId(SCard)
                end
            end
        end
    end
    --- 后勤卡展示列表
    if self.page and self.page == InSlot then
        self:OnPage(InSlot)
    else
        if Logistics.CurCard then 
            self:OnPage(InSlot, false, SelectCard)
        else
            self:OnPage(InSlot, true)
        end
    end
end

--- 获取对应插槽位的后勤卡
---@param InSlot Interge 插槽 1,2,3
---@return table insot 类后勤卡
function tbLogistics:GetSlotSupport(InSlot)
    if self.Character:IsTrial() then
        local tbSupportCard = {}
        table.insert(tbSupportCard, self.Character:GetSupporterCard(InSlot))
        return tbSupportCard
    else
        local SupportCards = Logistics.GetSlotSupportCards(InSlot)
        if SupportCards  then
            return SupportCards
        else
            UI.ShowMessage('tip.Current slot with no card')
        end
    end
end

function tbLogistics:ShowItemList(InCards, SelectItem)
    local tbEquipInfo = Logistics.GetEquipInfo()
    self:DoClearListItems(self.TileViewList)
    self.TileViewList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    if #InCards == 0 then
        WidgetUtils.Collapsed(self.Screen)
        WidgetUtils.SelfHitTestInvisible(self.PanelEmpty)
        return
    end
    for key, value in pairs(InCards) do
        local function beEquipId(tbInfo,InSupportCard)
            for _supportcard, _charactercard in pairs(tbInfo) do
                if _supportcard:Id() == InSupportCard:Id() then
                   return _charactercard
                end
            end
        end
        local tbParam = {
            SupportCard = value,
            funClick = self.pClickFun,
            BeEquipCard = beEquipId(tbEquipInfo,value) or nil,
            tbSkillTemplateId = self.tbSkillTemplateId,
            SelectItem = SelectItem,
            ShowPanelteam = true,
        }
        -- Dump(tbParam)
        local NewItem = self.pItem:Create(tbParam)
        self.TileViewList:AddItem(NewItem)
    end

    if #InCards < 12 then
        for i = #InCards + 1, 12 do
            local tbParam = {
                SupportCard = nil
            }
            local NewItem = self.pItem:Create(tbParam)
            self.TileViewList:AddItem(NewItem)
        end
    end
    WidgetUtils.Collapsed(self.PanelEmpty)
end

--- 后勤排序
function tbLogistics:SortSupports(nIdx, tbItems, bReverse)
    local tbSortInfo = self.tbSortInfo[1][nIdx]
    local tbRes = ItemSort:SupportSort(tbItems, tbSortInfo.tbSorts, self.tbSkillTemplateId)
    if bReverse and #tbRes > 1 then
        local nLeft = 1
        local nRight = #tbRes
        while (nLeft < nRight) do
            tbRes[nLeft], tbRes[nRight] = tbRes[nRight], tbRes[nLeft]
            nLeft = nLeft + 1
            nRight = nRight - 1
        end
    end
    return tbRes
end

--- 后勤列表切换Slot页签
---@param InPage Interge slot :1,2,3
function tbLogistics:OnPage(InPage, ChangePage, InSupportCard)
    self.page = InPage

    --- 初始化角色插槽上三个技能的信息
    if self.Character then
        for i = 1, 3 do
            if i ~= InPage then
                local SCard = self.Character:GetSupporterCardForIndex(i)
                if SCard then
                    self.tbSkillTemplateId[i] = Logistics.GetSkillSuitId(SCard)
                else
                    self.tbSkillTemplateId[i] = nil
                end
            else
                self.tbSkillTemplateId[i] = nil
            end
        end
    end

    --- 排序
    local itemlist = self:GetSlotSupport(self.page)
    local tbItems = self:SortSupports(self.tbCurSort.nIdx, itemlist, self.tbCurSort.bReverse)
    local SelectCard
    if Logistics.CurCard and not ChangePage then
        SelectCard = Logistics.CurCard
    else
        SelectCard = self.Character ~= nil and self.Character:GetSupporterCard(InPage) or tbItems[1]
    end
    self:ShowItemList(tbItems, InSupportCard or SelectCard)

    for index, value in ipairs(self.tbSupporListtPage) do
        WidgetUtils.Collapsed(value.Page)
        value.Click:SetIsChecked(false)
        WidgetUtils.Collapsed(value.OnTag)
        WidgetUtils.SelfHitTestInvisible(value.OffTag)

        if self.page == index then
            -- WidgetUtils.SelfHitTestInvisible(value.Page)
            value.Click:SetIsChecked(true)
            WidgetUtils.Collapsed(value.OffTag)
            WidgetUtils.SelfHitTestInvisible(value.OnTag)
            Logistics.SelectType = index
        end
    end
    if ChangePage then
        EventSystem.TriggerTarget(Logistics, Logistics.ChangePage, SelectCard)
    end
end

function tbLogistics:AfterEquipUpdate(InSupportCard)
    if not InSupportCard then
        return
    end
    local itemlist = self:GetSlotSupport(self.page)
    local tbItems = self:SortSupports(self.tbCurSort.nIdx, itemlist, self.tbCurSort.bReverse)
    self:ShowItemList(tbItems, InSupportCard)
end
return tbLogistics