-- ========================================================
-- @File    : umg_help_images.lua
-- @Brief   : 图片轮播介绍界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.PointPath = "/Game/UI/UMG/HelpImages/Widgets/uw_help_page_point.uw_help_page_point_C"
    BtnAddEvent(self.Larrow, function()
        local index = self.AttrPage:GetCenterIndex()
        self.AttrPage:SetCurrentIndex(index-1)
    end)

    BtnAddEvent(self.Rarrow, function()
        local index = self.AttrPage:GetCenterIndex()
        self.AttrPage:SetCurrentIndex(index+1)
    end)

    self.Padding = UE4.FMargin()
    self.Padding.Left = 0
end

---打开界面
---@param id integer 活动ID
function tbClass:OnOpen(id)
    BtnClearEvent(self.BtnClose)
    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
    end)
    BtnClearEvent(self.BtnClose_1)
    BtnAddEvent(self.BtnClose_1, function()
        UI.Close(self)
    end)
    self.AttrPage.OnCenterIndexChange:Clear()
    if id then self:UpdateImages(id) end
end

---显示界面
---@param id integer 活动ID
function tbClass:Display(id)
    self.AttrPage.OnCenterIndexChange:Clear()
    if id then self:UpdateImages(id) end
end

function tbClass:UpdateImages(id)
    local tbcfg = Activity.tbHelpImages[id]
    if not tbcfg or not tbcfg.tbPage then return end

    self.tbPageInfo = {}
    for _, Page in pairs(tbcfg.tbPage) do
        if Condition.Check(Page.tbCondition) then
            table.insert(self.tbPageInfo, Page)
        end
    end

    if tbcfg.nChangeMode == 1 then  --仅可滑动
        WidgetUtils.Collapsed(self.Larrow)
        WidgetUtils.Collapsed(self.Rarrow)
    else
        WidgetUtils.Visible(self.Larrow)
        WidgetUtils.Visible(self.Rarrow)
    end

    if tbcfg.bLoop then  --是否循环
        self.AttrPage.bLoop = true
    else
        self.AttrPage.bLoop = false
    end

    self.nowPage = self.AttrPage:GetCenterIndex() + 1
    if tbcfg.bShowPage then
        self.tbPointWidget = {}
        self.PointBox:ClearChildren()
        for i = 1, #self.tbPageInfo do
            local point = Activity.LoadCaseItem(self.PointPath)
            if point then
                self.PointBox:AddChild(point)
                self.tbPointWidget[i] = point
                point:SetChecked(self.nowPage == i)
                if i > 1 then
                    point:SetPadding(self.Padding)
                end
            end
        end

        if #self.tbPageInfo > 1 then
            WidgetUtils.Visible(self.PointBox)
        else
            WidgetUtils.Collapsed(self.PointBox)
        end

    else
        WidgetUtils.Collapsed(self.PointBox)
    end
    self:UpdatePageCaption(self.nowPage)

    self.AttrPage.OnCenterIndexChange:Add(self, function()
        local page = self.AttrPage:GetCenterIndex() + 1
        if self.nowPage == page then return end
        self:UpdatePageCaption(page)
        if tbcfg.bShowPage then
            self:UpdatePagePoint(page)
        end
        self.nowPage = page
    end)

    self.AttrPage:ClearChildren()
    for _, v in ipairs(self.tbPageInfo) do
        local Widget = LoadWidget("/Game/UI/UMG/HelpImages/Widgets/uw_help_page_img.uw_help_page_img_C")
        if Widget then
            self.AttrPage:AddChild(Widget)
            Widget:Init(v)
        end
    end

    local nPages = #self.tbPageInfo
    if nPages <= 1 then
        WidgetUtils.Collapsed(self.Larrow)
        WidgetUtils.Collapsed(self.Rarrow)
    end
end

function tbClass:UpdatePagePoint(page)
    if self.nowPage and self.tbPointWidget[self.nowPage] then
        self.tbPointWidget[self.nowPage]:SetChecked(false)
    end
    if page and self.tbPointWidget[page] then
        self.tbPointWidget[page]:SetChecked(true)
    end
end

function tbClass:UpdatePageCaption(page)
    self.TxtPage:SetText(page)
    local pageInfo = self.tbPageInfo[page] or {}
    if pageInfo.Title and self.TxtTitle then
        WidgetUtils.SelfHitTestInvisible(self.TxtTitle)
        self.TxtTitle:SetText(Text(pageInfo.Title))
    else
        WidgetUtils.Collapsed(self.TxtTitle)
    end
    if pageInfo.Caption and self.TxtTips then
        WidgetUtils.SelfHitTestInvisible(self.TxtTips)
        self.TxtTips:SetText(Text(pageInfo.Caption))
    else
        WidgetUtils.Collapsed(self.TxtTips)
    end
end

return tbClass
