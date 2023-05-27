-- ========================================================
-- @File    : umg_common_systemunlock.lua
-- @Brief   : 系统解锁提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.nShowIndex = 1
    self.bPlaying = false
    BtnAddEvent(self.BtnClose, function()
        if self.bPlaying then
            return
        end
        self.nShowCount = self.nShowCount or 0 
        if self.nShowIndex > self.nShowCount then
            UI.Close(self)
        else
            self:StopAllAnimations()
            self:PlayAnimationForward(self.CloseAnim)
            self.bPlaying = true
        end
    end)

    self:BindToAnimationFinished(self.CloseAnim, {self, function()
        self.bPlaying = false
        if self.tbNewOpen and self.nShowIndex then
            self:ShowOne(self.tbNewOpen[self.nShowIndex])
        end     
    end})
end

---打开时的回调
---@param tbNewOpen table 新功能开放列表
function tbClass:OnOpen(tbNewOpen)
    if (not tbNewOpen) or (#tbNewOpen == 0) then
        return UI.Close(self)
    end
    self.nShowCount = #tbNewOpen
    self.tbNewOpen = tbNewOpen
    self:ShowOne(tbNewOpen[self.nShowIndex])
end


function tbClass:ShowOne(nType)
    self.nShowIndex = self.nShowIndex + 1
    if not nType then return end
    local cfg = FunctionRouter.Get(nType)
    if not cfg then 
        return
    end
    SetTexture(self.Icon, cfg.nUnlockpic)
    self.Tip:SetText(Text(cfg.sUnlocktip or ''))
    self:PlayAnimationForward(self.OpenAnim)
end

function tbClass:OnClose()
end

return tbClass;
