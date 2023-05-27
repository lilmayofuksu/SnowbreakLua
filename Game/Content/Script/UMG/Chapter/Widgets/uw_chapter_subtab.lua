-- ========================================================
-- @File    : uw_chapter_subtab.lua
-- @Brief   : 主线支线切换控件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSwitch, function()
        if self.nType == 1 then
            FunctionRouter.CheckEx(FunctionType.RoleLevel, function()
                Role.GetOPenTime()
            end)
        else
            local ui = UI.GetUI("DungeonsRole")
            if ui then UI.Close(ui, nil, true) end
            UI.Open('Chapter')
        end
    end)
end

function tbClass:Init(nType)
    self.nType = nType
    if nType == 1 then
        self:PlayAnimation(self.SwtichMain)
    elseif nType == 2 then
        self:PlayAnimation(self.SwtichRole)
    end
end

return tbClass