-- ========================================================
-- @File    : uw_dialogue_branch_item.lua
-- @Brief   : 剧情分支
-- @Author  :
-- @Date    :
-- ========================================================

local uw_dialogue_branch_item = Class("UMG.SubWidget")

local BranchItem = uw_dialogue_branch_item

BranchItem.DialogueActor = nil

function BranchItem:Construct()
    self.DialogueActor = UE4.UDialogueBlueprintLibrary.GetCurrentDialogueActor(self)
    self.ClickBtn.OnClicked:Add(
        self,
        function()
            if self.DialogueActor and self.Obj then
                self.DialogueActor.CurrentSelectBranch = self.Obj.Str
                self.DialogueActor.bSelect = true
                self.Obj.UI:HideBranch()
            end
        end
    )
end
function BranchItem:OnDestruct()
    self.DialogueActor = nil
end

function BranchItem:OnListItemObjectSet(InObj)
    if not InObj then
        return
    end
    self.Obj = InObj
    self.BranchText:SetText(DialogueMgr.GetStr(self.DialogueActor.DialogueConfig, InObj.Str))
end

return BranchItem
