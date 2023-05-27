-- ========================================================
-- @File    : uw_achievement_listt_item.lua
-- @Brief   : 左边分类按钮 (任务界面、bp界面)
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListSecondary)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data

    WidgetUtils.Visible(self.FirstTab)
    WidgetUtils.Collapsed(self.SecondTab)

    function self.tbParam.SetSelect(_, bSelect)
        if bSelect then
            WidgetUtils.Visible(self.CheckFirst)
            WidgetUtils.Hidden(self.BgFirst)
            self.p1:ActivateSystem()
        else
            WidgetUtils.Visible(self.BgFirst)
            WidgetUtils.Hidden(self.CheckFirst)
            self.p1:DeactivateSystem()
        end
    end

    function self.tbParam.UpdateFlagShow()
        if self.tbParam.GetNewFlag and self.tbParam.GetNewFlag() then
            WidgetUtils.Visible(self.ImgNew)
        else
            WidgetUtils.Hidden(self.ImgNew)
        end
    end
    self.tbParam.UpdateFlagShow()

    if self.tbParam.isOpen then
        WidgetUtils.Hidden(self.Lock)
    else
        WidgetUtils.Visible(self.Lock)
    end

    if self.tbParam.showType and self.tbParam.showType == self.tbParam.type then
        WidgetUtils.Visible(self.CheckFirst)
        WidgetUtils.Hidden(self.BgFirst)
    else
        WidgetUtils.Visible(self.BgFirst)
        WidgetUtils.Hidden(self.CheckFirst)
    end

    self.TxtBgFirst:SetText(self.tbParam.sNameText)
    self.TxtBgFirst_1:SetText(self.tbParam.sNameText)

    if self.tbParam.sIcon then
        SetTexture(self.IconBgFirst, self.tbParam.sIcon)
        SetTexture(self.IconBgFirst_1, self.tbParam.sIcon)
    end

    self.BtnSelect.OnClicked:Clear()
    self.BtnSelect.OnClicked:Add(self, function()
        if not self.tbParam.isOpen then
            UI.ShowMessage(Text(self.tbParam.sLockText));
            return
        end
        self.tbParam.UpdateSelect()
    end)
end

return tbClass