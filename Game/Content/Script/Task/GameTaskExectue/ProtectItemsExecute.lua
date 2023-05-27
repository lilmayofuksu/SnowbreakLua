-- ========================================================
-- @File    : ProtectItemsExecute.lua
-- @Brief   :
-- @Author  : cms
-- @Date    : 2021/6/23
-- ========================================================

---@class  ProtectItemsExecute: GameTask_Execute
local ProtectItems = Class()

function ProtectItems:OnActive()
    local FindItem = UE4.ULevelLibrary.GetActorByName(self, UE4.AGameCharacter.StaticClass(), self.ItemName)
    if not IsValid(FindItem) then
        print("ProtectItem is not valid!")
        self:Finish()
        return
    end
    self.Item = FindItem:Cast(UE4.AGameCharacter)
    if not IsValid(self.Item) then
        print("ProtectItem must be GameCharacter!")
        self:Finish()
        return
    end
    self.Item.Ability.OnCharacterDie:Add(
        self,
        function(ThisPtr, DeadCharacter, Killer,Params)
            self:Fail()
        end
    )
end

function ProtectItems:CountDownFinish()
    self:Finish()
end

function ProtectItems:GetFormatTitle()
    return self:GetUIDescription()
end

return ProtectItems
