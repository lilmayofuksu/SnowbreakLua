-- ========================================================
-- @File    : umg_common_warntips.lua
-- @Brief  : 联机 重连 游戏结束 提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Bg.BtnClose.OnClicked:Clear()
    self.Bg.BtnClose.OnClicked:Add(self, function()
        UI.Close(self)
    end)
end

---打开时的回调
function tbClass:OnOpen(sInfo, funcEnd)
    if sInfo then
        self.TxtWarn:SetText(Text(sInfo))
    else
        self.TxtWarn:SetText(Text("ui.TxtGameOver"))
    end

    self.OnEnd = funcEnd
end

function tbClass:OnClose()
    if self.OnEnd then
        self.OnEnd()
    end
end

return tbClass
