-- ========================================================
-- @File    : uw_dorm_room.lua
-- @Brief   : 宿舍门卡入住界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

--- 用于存储角色到房间号的对应关系
tbClass.GirlListItem = {}


function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListGirl)

    BtnAddEvent(self.Button, function()
        if not self.NowSelect then
            UI.ShowMessage("error.BadParam")
            return
        end
        HouseBedroom.GirlRegister(self.NowSelect.Data.GirlId, function()
            UI.ShowTip(Text("house.RoomCheckin", Text(self.NowSelect.Data.Template.I18N)))
            self:Update(self.NowSelect.Data.GirlId)
            WidgetUtils.Collapsed(self.Button)
        end)
    end)

    self.EventHandel = EventSystem.OnTarget(HouseBedroom, "UpdateAll", function()
        self:Update()
    end)

    self.Title:SetCustomEvent(
        function()
            -- if self.PlayerController then
            --     RuntimeState.ChangeInputMode(false)
            --     self.PlayerController:TryInteract()
            -- end
            UI.CloseTop()
        end
    )

    self.Title:SetShowExitBtn(false)
end

tbClass.SortHandle = function(l, r)
    local IsNullOrZero = function(Num)
        if Num and Num ~= 0 then
            return true
        end
        return false
    end
    if IsNullOrZero(r.RoomId) and not IsNullOrZero(l.RoomId) then
        return true
    elseif not IsNullOrZero(r.RoomId) and IsNullOrZero(l.RoomId) then
        return false
    else
        if IsNullOrZero(l.IsRegistered) and not IsNullOrZero(r.IsRegistered) then
            return true
        else
            return false
        end
    end
end

function tbClass:OnOpen(PlayerController)
    self.Title:SetCustomEvent(nil,function ()
        GoToMainLevel()
    end)
    
    self.PlayerController = PlayerController
    -- if self.PlayerController then
    --     WidgetUtils.ShowMouseCursor(self, true)
    --     UE4.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self.PlayerController)
    -- end
    self:Update()
end

function tbClass:Update(InGirlId)
    self:UpdateRoomList()
    self:UpdateGirlList(InGirlId)
    if self.NowSelect and self.NowSelect.OnSelect then
        self.NowSelect:OnSelect(true)
    end
end

function tbClass:UpdateRoomList()
    local tbRoomData = {}
    for i = 1, HouseBedroom.GetOpenCount() do
        local RoomData = {}
        local GirlId = HouseBedroom.GetBedroomGirlId(i)
        if not GirlId or GirlId == 0 then
            RoomData = {
                RoomId = i,
                IsUnlock = false,
            }
        else
            local GirlFavor = HouseGirlLove:GetGirlLoveLevel(GirlId)
            local Template =  UE4.UItem.FindTemplate(1, GirlId, 1, 1)
            RoomData = {
                RoomId = i,
                IsUnlock = true,
                GirlId = GirlId,
                Favor = GirlFavor,
                Template = Template,
                OnTorch = function(GirlId)
                    EventSystem.TriggerTarget(self, GirlId)
                end
            }
        end
        table.insert(tbRoomData, RoomData)
    end
    self.GridPanel:RoomDisplay(tbRoomData)
end

function tbClass:UpdateGirlList(InGirlId)
    local tbGirl = self:GetAllDormGirl()
    local tbRoleData = {}
    for _, GirlId in pairs(tbGirl) do
        local Template = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
        local RoomId = HouseStorage.GetCharacterAttr(GirlId, HouseStorage.EGirlAttr.RoomNum)
        local tbParam = {
            GirlId = GirlId,
            RoomId = RoomId,
            IsRegistered = RoomId > 0,
            Favor = HouseGirlLove:GetGirlLoveLevel(GirlId),
            Template = Template,
            parent = self,
        }
        table.insert(tbRoleData, tbParam)
    end


    table.sort(tbRoleData, self.SortHandle)

    self:DoClearListItems(self.ListGirl)
    EventSystem.RemoveAllByTarget(self)
    if #tbRoleData == 0 then
        WidgetUtils.Collapsed(self.Info)
    end
    for _, Data in pairs(tbRoleData) do
        Data.OnTorch = function(item)
            self:OnCharacterSelected(item)
        end
        Data.bRoomWiget = true
        if InGirlId and InGirlId == Data.GirlId then
            Data.bInitSelect = true
        end
        if not InGirlId and not self.bInitSelect then
            Data.bInitSelect = true
            self.bInitSelect = true
        end
        local pItem = self.Factory:Create(Data)
        self.ListGirl:AddItem(pItem)
    end
end

--- 剔除非原皮角色和未开放角色
function tbClass:GetAllDormGirl()
    local AllCharacter = RoleCard.GetAllCharacter(2)
    local tbGirls = {}
    local GrilIsExist = {}
    for _, Character in pairs(AllCharacter) do
        local GirlId = Character.Detail
        if HouseBedroom.CheckGirlAviliable(GirlId) and not GrilIsExist[GirlId] then
            table.insert(tbGirls, GirlId)
            GrilIsExist[GirlId] = true
        end
    end
    return tbGirls
end


function tbClass:OnCharacterSelected(InData)
    if not InData or self.NowSelect == InData then
        return
    end
    if self.NowSelect and self.NowSelect.OnSelect then
        self.NowSelect:OnSelect(false)
    end

    self.NowSelect = InData
    self.GridPanel:OnSelect(InData.Data.GirlId)
    if self.NowSelect.OnSelect then
        self.NowSelect:OnSelect(true)
    end

    --- 更新右侧列表
    self:UpdateRightPanel(InData)
end

function tbClass:UpdateRightPanel(InData)
    if not InData or not InData.Data then
        WidgetUtils.Collapsed(self.Info)
        return
    else
        WidgetUtils.SelfHitTestInvisible(self.Info)
    end
    local NowGotNum, AllCanGotNum = HouseGiftLogic:GetGiftGotInfo(InData.Data.GirlId)
    local Template =  InData.Data.Template
    SetTexture(self.ImgGirl, Template.Icon)
    self.Heart:Display(InData.Data.Favor)
    self.TxtName:SetText(Text(Template.I18N))
    self.TxtDesc:SetText(Text(Template.I18N.."_des"))
    self.TxtProgressNum1:SetText(NowGotNum)
    self.TxtProgressNum2:SetText(AllCanGotNum)
    if InData.Data.RoomId and InData.Data.RoomId ~= 0 then
        local floor = math.floor((InData.Data.RoomId - 1) / 8) + 2
        local room = (InData.Data.RoomId - 1) % 8 + 1
        WidgetUtils.SelfHitTestInvisible(self.TxtRoomNum)
        self.TxtRoom:SetText("TxtDormRoomNum")
        self.TxtRoomNum:SetText(string.format("%02d%02d", floor, room))
    else
        WidgetUtils.Collapsed(self.TxtRoomNum)
        self.TxtRoom:SetText("TxtDormRoomNotLived")
    end

    if InData.Data.IsRegistered == nil or InData.Data.IsRegistered == true then
        WidgetUtils.Collapsed(self.Button)
    else
        WidgetUtils.Visible(self.Button)
    end
end

return tbClass