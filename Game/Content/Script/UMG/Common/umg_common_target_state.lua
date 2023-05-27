-- ========================================================
-- @File    : umg_common_target_state.lua
-- @Brief  : 打靶-信息显示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
end

function tbClass:OnInit()

    BtnAddEvent(
        self.BtnOK,
        function()
            UI.Close(self)
        end
    )

    for i = 1, 5 do
        if self["Item"..i] then
            local Item = self["Item"..i]
            local ResId = TargetShootLogic.tbInfo[i].nPicId
            local Name = TargetShootLogic.tbInfo[i].nName
            local Desc = TargetShootLogic.tbInfo[i].nDesc
            print("umg_common_target_state - Init ", ResId, Name, Desc)
            SetTexture(Item.Icon, ResId)
            Item.TxtTitle:SetText(Text(string.format("targetdes.%s", Name)))
            Item.TxtContent:SetText(Text(string.format("targetdes.%s", Desc)))
        end
    end
end

function tbClass:OnOpen()
end

function tbClass:OnClose()
    if self.RoundTimerExecute then
        --记录已读
        local tbParam = {
            FuncName = "RecordFirstEnter",
        }
        TargetShootMsgHandle.TargetShootMsgSender(tbParam)

        self.RoundTimerExecute:LockPlayer(false)
        self.RoundTimerExecute:InitTargetShootUI()
    end
    -- print("umg_common_target_state - Close ")
    -- print(debug.traceback())
end

function tbClass:SetNode(RoundTimerExecuteNode)
    if RoundTimerExecuteNode and not self.RoundTimerExecute then
        self.RoundTimerExecute = RoundTimerExecuteNode
    end
end

return tbClass