-- ========================================================
-- @File    : umg_general_fight_exit.lua
-- @Brief   : 通用提示界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

---打开提示界面
---@param textMessage string 提示文字
---@param textSure string 确定按钮提示文字
---@param textBack string 取消按钮提示文字
---@param funSure function 确定按钮点击事件
---@param funBack function 取消按钮点击事件
---@param isPause boolean 是否暂停游戏
function tbClass:OnOpen(textMessage, textSure, textBack, funSure, funBack, isPause)
    if textMessage then
        self.Message:SetText(textMessage)
    end
    if textSure then
        self.Text_Sure:SetText(textSure)
    end
    if textBack then
        self.Text_Back:SetText(textBack)
    end

    if isPause then
        UE4.UGameplayStatics.SetGamePaused(self, true)
    end

    self.ButSure.OnClicked:Clear()
    self.ButSure.OnClicked:Add(self, function()
        if isPause then
            UE4.UGameplayStatics.SetGamePaused(self, false)
        end
        if funSure then
            funSure()
        end
        UI.Close(self)
    end)
    self.ButBack.OnClicked:Clear()
    self.ButBack.OnClicked:Add(self, function()
        if isPause then
            UE4.UGameplayStatics.SetGamePaused(self, false)
        end
        if funBack then
            funBack()
        end
        UI.Close(self)
    end)
end

return tbClass;
