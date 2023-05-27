-- @DESCRIPTION OccupyUI 左侧上飘信息的单个实体
-- @AUTHOR zhangguangyu
-- @DATE 2022/06/29


local tbClass = Class()

function tbClass:Construct()
    self.bIsShown = nil
    self.bIsPlayerInstigate = nil
    self.OccupyState = 0 -- 1:占领中 2:占领完成
    self.ListIndex = 0
end

function tbClass:OnListItemObjectSet(obj)
    print("occupy info item OnListItemObjectSet: ListIndex:", obj.Data.ListId, "TriggerId:", obj.Data.TriggerIndex, " InstigatorFlag=", obj.Data.InstigatorFlag, "OccupyState:", obj.Data.OccupyState, " Obj=", obj, " self=", self)
    self.OccupyInfoItem:OnListItemObjectSet(obj)--这玩意是个Occupy_list 就是一个盾牌那玩意
    if obj and obj.Data then
        self.bIsPlayerInstigate = obj.Data.InstigatorFlag
        self.OccupyState = obj.Data.OccupyState
        self.bIsShown = true
        self.ListIndex = obj.Data.ListId
    end
    self:PlayAnimInto()
    -- if self.OccupyState ~= nil then
        if self.OccupyState == 1 then --占领中
            if self.bIsPlayerInstigate then
                self:SetTxtInfo(Text("ui.TxtOccupyOur"))
            else
                self:SetTxtInfo(Text("ui.TxtOccupyNPC"))
            end
        elseif self.OccupyState == 2 then
            --占领完成
            if self.bIsPlayerInstigate then
                self:SetTxtInfo(Text("ui.TXTOccupyOverOur"))
                self.OccupyInfoItem.BarBlue:SetPercent(100)
                self.OccupyInfoItem:SetBarIndicatorPos(100)
            else
                self:SetTxtInfo(Text("ui.TxtOccupyOverNPC"))
                self.OccupyInfoItem.BarRed:SetPercent(100)
                self.OccupyInfoItem:SetBarIndicatorPos(100)
            end
        end
    -- end
end

function tbClass:CollapseInfo()
    self:PlayAnimDisappear()
    UE4.Timer.Add(1, function()
        WidgetUtils.Collapsed(self.OccupyRoot)
    end)
end

function tbClass:SetTxtInfo(info)
    self.Txt1:SetText(info)
end

function tbClass:PlayAnimDisappear()
    self:PlayAnimation(self.Disappear)
end

function tbClass:PlayAnimInto()
    self:PlayAnimation(self.Into)
end

return tbClass
