-- ========================================================
-- @File    : uw_widgets_function_content.lua
-- @Brief   : 功能容器
-- ========================================================

---@class tbClass
---@field Content UVerticalBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Init(tbFunction, fClickEvent)
    self.Content:ClearChildren()
    self.tbPage = {}
    for nIdx, tbInfo in ipairs(tbFunction) do
        local pCreate = LoadWidget("/Game/UI/UMG/Role/Widgets/uw_role_rightlist.uw_role_rightlist_C")
        if pCreate then
            self.Content:AddChild(pCreate)
            local tbParam = {
                sName = tbInfo.sName,
                Index = nIdx - 1,
                Click = fClickEvent,
                SelectChange = "SELECT_CHANGE",
                bSelect = false,
                bLock = tbInfo.bLock,
    
            }
            tbParam.SetSelect = function(_, InSelect)
                if tbParam.bSelect ~= InSelect then
                    tbParam.bSelect = InSelect
                    EventSystem.TriggerTarget(tbParam, tbParam.SelectChange)
                end
            end,
            pCreate:Init(tbParam)
            self.tbPage[nIdx - 1] = pCreate
        end
    end
end

function tbClass:SelectPage(nPage)
    -- if self.CurrentSelect == nPage then
    --     return
    -- end
    for _, pWidget in pairs(self.tbPage) do
        if pWidget.Obj.Index == nPage then
            pWidget.Obj:SetSelect(true)
        elseif self.CurrentSelect == pWidget.Obj.Index then
            pWidget.Obj:SetSelect(false)
        end
    end

    self.CurrentSelect = nPage
end

return tbClass
