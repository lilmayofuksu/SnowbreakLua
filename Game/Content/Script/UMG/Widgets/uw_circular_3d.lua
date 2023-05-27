-- ========================================================
-- @File    : uw_circular.lua
-- @Brief   : 经验进度显示
-- ========================================================

local ExpWidget = Class("UMG.SubWidget")

ExpWidget.fPercent = 0.0
ExpWidget.CanAdd = false
ExpWidget.CurLv = 0
ExpWidget.TarLv = 1
ExpWidget.nDeltaLv = 0

function ExpWidget:Construct()
    -- print("ExpWidget:Construct")
end

---@param InLv number 当前等级
---@param InExp number 当前经验
---@param InAddExp number 添加的经验
---@param InMaxExp number 当前最大经验值
---@param InModel ExpState 动态经验变化模式：1：增加，2：减少
function ExpWidget:Set(InLv, InExp, InAddExp, InMaxExp,InModel)
    self.TarLv = InLv
    if not InModel then
        self.RankNum:SetText(InLv)
        self.CurLv = InLv
    end
    if self.ShowRate then
        self.ShowRate:SetText(InExp .. "/" .. InMaxExp)
    end

    if self.StepPower then
        self.StepPower:SetText("+" .. InAddExp)
    end

    self.fTarget = (InExp) / InMaxExp

    if self.fTarget>0.98 and self.fTarget<1.02 then
        self.fTarget = 0.98
    end
    
    
    if not InModel then
        self:SetPercent(self.fTarget)
        self.fPercent = self.fTarget
        self.ExpModel = nil
        return
    end
    --- abs 表示当前经验值循环次数在大于或者等于3时，只刷新当前和最后一圈
    self.ExpModel = InModel
    if InModel == 1 then
        if self.TarLv ~= self.CurLv then
            local abs = math.abs(self.CurLv-self.TarLv)
            if abs>=3 then abs = 2 end
            self.fTarget = abs + self.fTarget
        end
    end

    if InModel == 2 then
        local abs = math.abs(self.CurLv-self.TarLv)
        if abs>=3 then abs = 2 end
        if self.TarLv ~= self.CurLv then
            self.fTarget = -(abs - self.fTarget)
        end
    end
end

--- 刷新经验值
function ExpWidget:Tick(MyGeometry, InDeltaTime)
    --- 等级动态刷新
    -- self.LvInfo:Tick(MyGeometry, InDeltaTime)
    if self.ExpModel and self.ExpModel >=1 then
        self:ShowTextLvByDynamic(InDeltaTime)
    end

    if self.ExpModel == 1 then
        while self.fTarget < self.fPercent do
            self.fPercent = 0.0
            self:SetPercent(self.fPercent)
            return
        end

        if self.fTarget > 1 then
            self.fTarget = self.fTarget - 1
            self.fPercent = 0
        end

        if self.fTarget == 1 and self.fTarget - self.fPercent <=0.05 then
            self.fPercent = 0
            self:SetPercent(self.fPercent)
            self.ExpModel = nil
            return
        end

        if self.fPercent >= 1 then
            self.fPercent = 0
        end

        self.fPercent = Lerp(self.fPercent, self.fTarget, 0.1)
    end

    if self.ExpModel == 2 then
        while self.fPercent <= 0 and self.fTarget < 0 do
            self.fPercent = 1.0
            self.fTarget = self.fTarget +1
        end
        self.fPercent = Lerp(self.fPercent,self.fTarget, 0.1)
    end
    
    self:SetPercent(self.fPercent)
end

ExpWidget.nFps = 5
function ExpWidget:ShowTextLvByDynamic(InDeltatime)
    self.nFps = self.nFps - 1
    while self.nFps <=0 do
        self.nFps = 5
        if self.TarLv ~= self.CurLv then
            if self.TarLv > self.CurLv then
                self.CurLv  = self.CurLv + 1
                if self.ExpModel and self.ExpModel>=1 then
                    self.nDeltaLv = self.nDeltaLv + 1
                end
            end
            if self.TarLv < self.CurLv then
                self.CurLv  = self.CurLv - 1
                if self.ExpModel and self.ExpModel>=1 then
                    self.nDeltaLv = self.nDeltaLv + 1
                end
            end
            self.RankNum:SetText(self.CurLv)
        end
    end
    
end

function ExpWidget:ShowIcon(InIconId)
    SetTexture(self.Girl,InIconId)
end
return ExpWidget
