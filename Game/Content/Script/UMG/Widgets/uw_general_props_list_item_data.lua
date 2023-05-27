-- ========================================================
-- @File    : uw_general_props_list_item_data.lua
-- @Brief   : 通用材料显示
-- ========================================================
---@class tbClass
---@field Item UItem
local tbClass = Class("UMG.SubWidget")
tbClass.Item = nil
tbClass.CurrentNum = 0

tbClass.__AddHandle = nil
tbClass.__SubHandle = nil
tbClass.__CheckHandle = nil
tbClass.DataChangeEvent = "DATA_CHANGE_EVENT"
tbClass.bPlaying = true

function tbClass:Init(InItem, AddFun, SubFun, CheckFun,DlTime)
    self.Item = InItem
    self.CurrentNum = 0
    self.__AddHandle = AddFun
    self.__SubHandle = SubFun
    self.__CheckHandle = CheckFun
    self.bPlaying = false
    self.delayTime = DlTime

    self.FunChange = function ()
        self.CurrentNum = 0
        EventSystem.TriggerTarget(self, self.DataChangeEvent)
    end

    if self.Item.Type then
        self.Item.OnDataChange:Remove(self, self.FunChange)
        self.Item.OnDataChange:Add(self, self.FunChange)
    end
end

function tbClass:Change()
    self.CurrentNum = 0
    EventSystem.TriggerTarget(self, self.DataChangeEvent)
end

---指定数量
function tbClass:AppointNum(num)
    self.CurrentNum = num
    EventSystem.TriggerTarget(self, self.DataChangeEvent)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.__AddHandle)
    EventSystem.Remove(self.__SubHandle)
    EventSystem.Remove(self.__CheckHandle)
    if IsValid(self.Item) and self.Item.Type then
        self.Item.OnDataChange:Clear()
    end
end

function tbClass:Add(bTip)
    if self.CurrentNum >= self:GetItemNum() then
        UI.ShowTip("tip.girlcard_cmd_err")
        return false
    end
    if self.__CheckHandle and self.__CheckHandle(self.Item, self.CurrentNum, bTip) and self.__AddHandle then
        self.CurrentNum = self.CurrentNum + 1
        self.__AddHandle(self.Item)
        EventSystem.TriggerTarget(self, self.DataChangeEvent)
        return true
    end
    return false
end

function tbClass:Sub()
    if self.CurrentNum <= 0 then
        return false
    end
    if self.__SubHandle then
        self.CurrentNum = self.CurrentNum - 1
        self.__SubHandle(self.Item)
        EventSystem.TriggerTarget(self, self.DataChangeEvent)
        return true
    end
    return false
end

function tbClass:GetItemNum()
    if self.Item.Type then
        return self.Item:Count()
    end
    return 0
end

function tbClass:GetCurrentNum()
    return self.CurrentNum
end

return tbClass
