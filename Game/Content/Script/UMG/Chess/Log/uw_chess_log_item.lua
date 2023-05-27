local view = Class("UMG.SubWidget")

function view:SetData(tbTask)
    local bComplete = ChessData:GetMapTaskIsComplete(tbTask.tbArg.id)
    if bComplete then
       WidgetUtils.SelfHitTestInvisible(self.Over) 
    else
        WidgetUtils.Collapsed(self.Over)
    end

    if tbTask.tbArg.main or tbTask.bCurTask then
        self.Des:SetText(Text(tbTask.tbArg.name))
    else
        self.Des:SetText(Text("ui.TxtChessTips9"))
    end

    self.CanvasPanel_0:SetRenderOpacity(bComplete and 0.6 or 1)
    self.TxtTarget:SetText(string.format("%d / %d", bComplete and 1 or 0, 1))  -- 这里能显示状态么：已完成，未开启，进行中
end

return view