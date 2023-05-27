-- ========================================================
-- @File    : uw_energy_list.lua
-- @Brief   : 筛选框
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnDestruct()
end

function tbClass:Display(data)
    self.Data = data
    self.untext:SetText(Text(self.Data.sDesc))
    self.text:SetText(Text(self.Data.sDesc))
    self.text_1:SetText(Text(self.Data.sDesc))

    --排序规则
    if not self.Data.rule then
        WidgetUtils.Visible(self.Up)
        WidgetUtils.Visible(self.Down)
    else --筛选规则
        WidgetUtils.Collapsed(self.Up)
        WidgetUtils.Collapsed(self.Down)
    end

    BtnAddEvent(
        self.unchecked,
        function()
            self.Data.ParentUI:OnChildClick(0, self.Data)
        end
    )

    BtnAddEvent(
        self.checked1,
        function()
            self.Data.ParentUI:OnChildClick(1, self.Data)
        end
    )

    BtnAddEvent(
        self.checked2,
        function()
            self.Data.ParentUI:OnChildClick(2, self.Data)
        end
    )

    self:SetState(self.Data.state)
end

function tbClass:SetState(nState)
    self.Switcher:SetActiveWidgetIndex(nState or 0)
end


return tbClass
