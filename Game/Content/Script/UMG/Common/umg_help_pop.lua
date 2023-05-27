-- ========================================================
-- @File    : umg_help_pop.lua
-- @Brief   : 图片提示指引界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function()
        if self.bCanClose == false then return end

        if self.funClose then
            self.funClose()
        end
    end)
end

function tbClass:OnDestruct()
    if self.nTimer then
        UE4.Timer.Cancel(self.self.nTimer)
    end
end

function tbClass:Display(imgPath, funClose)
    self.bCanClose = false
    local nDelayClose = 3
    if self.nTimer then
        UE4.Timer.Cancel(self.self.nTimer)
    end

    self.nTimer = UE4.Timer.Add(nDelayClose, function()
        self.nTimer = nil
        self.bCanClose = true
    end)

    SetTexture(self.ImgAD, imgPath)
    self.funClose = funClose
    self.Tips:SetText(Text('ui.TxtFightHelp', nDelayClose))
end


function tbClass:SetTexture(imgPath)
    SetTexture(self.ImgAD, imgPath)
end

return tbClass