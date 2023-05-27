local uw_develop_item = Class("UMG.SubWidget")

uw_develop_item.EventHandel = nil
uw_develop_item.Obj = nil

function uw_develop_item:OnListItemObjectSet(InObj)
    self.Obj = InObj
    if not InObj then
        return
    end

    self.Name:SetText(InObj.Args.Text)

    self.Btn.OnClicked:Add(
        self,
        function()
            if self.Obj.ChangeHandel then
                self.Obj.ChangeHandel(self.Obj)
            end
        end
    )

    self.EventHandel =
        EventSystem.OnTarget(
        InObj,
        InObj.ChangeEvent,
        function()
            self:Change()
        end
    )
    self:Change()
end

function uw_develop_item:Change()
    if self.Obj.bSelect then
        WidgetUtils.Collapsed(self.Select)
        WidgetUtils.SelfHitTestInvisible(self.Select_in)
    else
        WidgetUtils.SelfHitTestInvisible(self.Select)
        WidgetUtils.Collapsed(self.Select_in)
    end
    self:OnSelect(self.Obj.bSelect)
end

function uw_develop_item:OnDestruct()
    if self.EventHandel then
        EventSystem.Remove(self.EventHandel)
    end
end

return uw_develop_item
