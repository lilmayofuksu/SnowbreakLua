-- ========================================================
-- @File    : uw_widgets_rotate.lua
-- @Brief   : 模型旋转
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.bCacheFlag = false;
end

function tbClass:SetModel(pModel)
    self.pModel = pModel
end

function tbClass:OnRotate(Value)
    if IsValid(self.pModel) then
        self.pModel:AddInput(Value)
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if self.bDown ~= self.bCacheFlag then
        self.bCacheFlag = self.bDown
        if IsValid(self.pModel) then
            self.pModel:SetInputFlag(self.bCacheFlag)
        end
    end
end

return tbClass