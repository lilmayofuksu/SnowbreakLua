-- ========================================================
-- @File    : uw_fight_gainlist.lua
-- @Brief   : 战斗提示最小单元列表
-- ========================================================

local GainList = Class("UMG.SubWidget")

function GainList:Construct()
    self:DoClearListItems(self.ListGainItems)
    self.Factory = Model.Use(self)

    self.PreAddItemHandleList = {}
    self.AnimTime = GlobalConfig.FightUI.AnimTime
    self.MaxGainItemNum = GlobalConfig.FightUI.MaxGainItemNum
    self.bCanAddNewItem = true
    self.IntervalTimerHandle = nil

    self:RegisterEvent(Event.OnGainItemShow, function(textType, itemName)   -- itemName 暂时没传, 是为了开放世界拾取掉落物时候做的预处理
        self:AddNewGainItem(textType, itemName)
    end)
end

function GainList:OnDestruct()
    self:DoClearListItems(self.ListGainItems)
    if self.IntervalTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.IntervalTimerHandle)
        self.IntervalTimerHandle = nil
    end
end

function GainList:AddNewGainItem(textType, itemName)
    local itemNums = self.ListGainItems:GetNumItems()
    if (itemNums == self.MaxGainItemNum) then
        for i = 1, itemNums do
            local item = self.ListGainItems:GetItemAt(i - 1)
            if item.Data.tbData.bRemoveing == false and item.Data.tbData.bIniting == false and self.bCanAddNewItem == true then
                item.Data.pRefresh(item)
                local preAddItemHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
                    self,
                    function()
                        self:CreateNewItem(textType, itemName)
                    end
                    },
                    self.AnimTime,
                    false
                )
                table.insert(self.PreAddItemHandleList, preAddItemHandle)
                break
            end
        end
        return
    end
    self:CreateNewItem(textType, itemName)
end

function GainList:CreateNewItem(textType, itemName)
    if (self.bCanAddNewItem == false or self.IntervalTimerHandle ~= nil) then
        return
    end

    local params = {
        ListGainItems = self.ListGainItems,
        TextType = textType,
        ItemName = nil,
        tbData = {
            bIniting = false,
            bRemoveing = false,
        },
        pRefresh = nil,
    }

    local pObj = self.Factory:Create(params)
    self.ListGainItems:AddItem(pObj)
    self:IntervalTimer()
end

function GainList:IntervalTimer()
    self.bCanAddNewItem = false
    self.IntervalTimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
            self,
            function()
                self.bCanAddNewItem = true
                self.IntervalTimerHandle = nil
            end
        },
        GlobalConfig.FightUI.IntervalTime,
        false
    )
end

return GainList