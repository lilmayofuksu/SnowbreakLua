-- ========================================================
-- @File    : umg_common_itemselect.lua
-- @Brief   : 道具选择箱弹窗
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Factory = Model.Use(self)

    BtnAddEvent(
        self.BtnReduce,
        function()
            self:DecCount()
        end
    )
    self.BtnReduce.OnLongPressed:Add(
        self,
        function()
            self:DecCount()
        end
    )
    BtnAddEvent(
        self.BtnAdd,
        function()
            self:AddCount()
        end
    )
    self.BtnAdd.OnLongPressed:Add(
        self,
        function()
            self:AddCount()
        end
    )
    BtnAddEvent(
        self.BtnMax,
        function()
            self.nCount = self.pItem:Count()
            self.TextNum:SetText(tostring(self.nCount))
            EventSystem.Trigger(Event.ShowItemNumChange,self.nCount)
            self:UpdateList()
        end
    )
    BtnAddEvent(
        self.BtnNo,
        function()
            UI.Close(self)
        end
    )
    BtnAddEvent(
        self.BtnOK,
        function()
            local cmd = {
                Id = self.pItem:Id(),
                Count = self.nCount,
                tbSelect = {}
            }

            local selectOne = {
                    nGroup = self.tbSelected.nGroup,
                    tbGDPLN = self.tbSelected.tbGDPLN
                }
                table.insert(cmd.tbSelect,selectOne)
            me:CallGS("Item_OpenBox", json.encode(cmd))
            UI.ShowConnection()
            self:UseItemCallBack(self.pItem,self.nCount)
            
            -- UI.CloseConnection()
            -- UI.Close(self)
            -- 
            -- self.nGetBoxItemEvent = 
            --     EventSystem.On(
            --     Event.GetBoxItem,
            --     function(InItem)
            --         -- print("GetBoxItem")
            --         UI.CloseConnection()
            --         UI.Close(self)
            --         EventSystem.Remove(self.nServerErrorEvent)
            --         EventSystem.Remove(self.nGetBoxItemEvent)
            --         Item.Gain(InItem.tbAward)
            --         local BagUI = UI.GetUI("Bag")
            --         if BagUI then
            --             -- BagUI:UpdatePage()
            --             BagUI:OnRecycleEnd()
            --         end
            --     end,
            --     true
            -- )
            self.nServerErrorEvent =
                EventSystem.On(
                Event.ShowPlayerMessage,
                function()
                    UI.CloseConnection()
                    UI.Close(self)
                end,
                true
            )
        end
    )
end

function tbClass:PreOpen()

    return true
end

---@param pItem  
function tbClass:OnOpen(pItem)
    self:DoClearListItems(self.ListItem)
    -- print("pItem:",pItem,self.pItem)
    if pItem then 
        self.pItem = pItem
    end
    if self.pItem == nil then return end
    local bFst = true
    local info = UE4.UItem.FindTemplate(self.pItem:Genre(),self.pItem:Detail(),self.pItem:Particular(),self.pItem:Level())
    local sTip =
        string.format(
        -- Text("ui.openbox"),
        Text(info.I18N)
    )

    self.nCount = 1
    self.tbSelected = {}

    self.TextTop:SetText(sTip)
    self.TextNum:SetText(1)
    local tbConfig = Item.tbBox[info.Param1]
    for _,group in pairs(tbConfig["Select"] or {}) do
        for k,chooseItem in pairs(group or {}) do
            local tbBox = {
                tbGDPLN = chooseItem.tbGDPLN,
                nCount = chooseItem.tbGDPLN[5],
                nGroup = chooseItem.nGroup
            }
            local tbData = {
                G = chooseItem.tbGDPLN[1],
                D = chooseItem.tbGDPLN[2],
                P = chooseItem.tbGDPLN[3],
                L = chooseItem.tbGDPLN[4],
                N = chooseItem.tbGDPLN[5],
                Count = chooseItem.tbGDPLN[5],
                pUI = self,
                bSelected = false,
                bInfoSP = true,
                fCustomEvent = function()
                    if self.tbSelected then
                        self.tbSelected.tbSubUI.bSelected = false
                        self.tbSelected.tbSubUI:SetSelected()
                    end
                    self.tbSelected = tbBox
                    self.tbSelected.tbSubUI.bSelected = true
                    self.tbSelected.tbSubUI:SetSelected()
                end
            }
            tbData.SetSelected = function(self)
                EventSystem.TriggerTarget(self, "SET_SELECTED")
            end
            if bFst then
                self.tbSelected = tbBox
                tbData.bSelected = true
                bFst = false

            end
            tbBox.tbSubUI = tbData
            self.ListItem:AddItem(self.Factory:Create(tbData))
        end
    end
end

function tbClass:OnClose()
    EventSystem.Remove(self.nGetBoxItemEvent)
    EventSystem.Remove(self.nServerErrorEvent)
    print("itemselect Onclose")
end

function tbClass:UpdateList()
    local tbList = self.ListItem:GetListItems()
    local nLength = tbList:Length()
    for i=1,nLength do
        local tbData = tbList:Get(i)
        tbData.Data.N = tbData.Data.Count * self.nCount
    end
end


function tbClass:AddCount()
    if self.nCount < self.pItem:Count() then
        self.nCount = self.nCount + 1
        self.TextNum:SetText(tostring(self.nCount))
        EventSystem.Trigger(Event.ShowItemNumChange,self.nCount)
        self:UpdateList()
    else
        return UI.ShowTip("tip.shop_max")
    end
end

function tbClass:DecCount()
    if self.nCount > 1 then
        self.nCount = self.nCount - 1
        self.TextNum:SetText(tostring(self.nCount))
        EventSystem.Trigger(Event.ShowItemNumChange,self.nCount)
        self:UpdateList()
    else
        return UI.ShowTip("tip.shop_min")
    end
end

--服务器 Item::Use 中先使用道具（调用Lua的onUse）再扣减数量
--客户端收到onUse中的回包时还没同步到最新数据
function tbClass:UseItemCallBack(pItem,nUseCount)
    if pItem:Count() > nUseCount then
        self.nGetBoxItemEvent = 
            EventSystem.On(
            Event.GetBoxItem,
            function(InItem)
                UI.CloseConnection()
                UI.Close(self)
                EventSystem.Remove(self.nServerErrorEvent)
                EventSystem.Remove(self.nGetBoxItemEvent)

                local BagUI = UI.GetUI("Bag")
                if BagUI then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        BagUI,
                        function()
                            local BagUI = UI.GetUI("Bag")
                            if BagUI then
                                BagUI:UpdatePage()
                            end
                        end
                    },
                    0.05,
                    false
                    )
                end
            end,
            true
        )
    else
        self.nGetBoxItemEvent = 
            EventSystem.On(
            Event.GetBoxItem,
            function(InItem)
                UI.CloseConnection()
                UI.Close(self)
                EventSystem.Remove(self.nServerErrorEvent)
                EventSystem.Remove(self.nGetBoxItemEvent)

                local BagUI = UI.GetUI("Bag")
                if BagUI then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        BagUI,
                        function()
                            local BagUI = UI.GetUI("Bag")
                            if BagUI then
                                BagUI:OnRecycleEnd()
                            end
                        end
                    },
                    0.05,
                    false
                    )
                end
            end,
            true
        )
    end
end

return tbClass
