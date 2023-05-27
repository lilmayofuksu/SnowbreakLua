-- ========================================================
-- @File    : umg_develop.lua
-- @Brief   : 开发调试界面
-- ========================================================

local Develop = Class("UMG.BaseWidget")

Develop.Chapters = nil
Develop.CurrentChapter = nil
Develop.CurrentLevel = nil
Develop.CurrentRole = nil

function Develop:OnInit()
    self.EnterBtn.OnClicked:Add(
        self,
        function()
            if not self.CurrentChapter then
                return
            end
            local G = self.CurrentRole.Args.Config.Genre
            local D = self.CurrentRole.Args.Config.Detail
            local P = self.CurrentRole.Args.Config.Particular
            local L = self.CurrentRole.Args.Config.Level

            local Index = me:AddCustomTeam(string.format("%d-%d-%d-%d", G, D, P, L))
            UE4.UUMGLibrary.SetTeamLineupIndex(Index)
        end
    )

    self.CloseBtn.OnClicked:Add(
        self,
        function()
            UI.Close(self)
        end
    )
    self.ChangePanelBtn.OnClicked:Add(
        self,
        function()
            if self.PanelIndex == 1 then               
                self.LevelPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
                self.WeaponParts:SetVisibility(UE4.ESlateVisibility.Visible)
                
                self.PanelIndex = 2
            else
                self.PanelIndex = 1
                self.LevelPanel:SetVisibility(UE4.ESlateVisibility.Visible)
                self.WeaponParts:SetVisibility(UE4.ESlateVisibility.Collapsed)
            end
        end
    )

    self.PIDBtn.OnClicked:Add(
        self,
        function()
            UE4.UGMLibrary.ClipboardCopy(tostring(me:ID()))
        end
    )

    self.EquipBtn.OnClicked:Add(
        self,
        function()
            self:EquipWeaponParts()
        end
    )
end

function Develop:OnOpen(...)
    self.PID:SetText(me:ID())
    self:ShowChapters()
    self:ShowLevel()
    self:ShowRole()
    self.PanelIndex = 1
    self.LevelPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    self.WeaponParts:SetVisibility(UE4.ESlateVisibility.Collapsed)    

    self:ShowCards()
    self:ShowAllParts()
end

function Develop:ShowChapters()
    self.CurrentChapter = nil
    self.Chapters = Chapter.GetChapterCfgs(true, 1)
    local ItemDataClass = LoadClass("/Game/UI/UMG/Develop/Widgets/uw_develop_item_data")
    self:DoClearListItems(self.ChapterList)
    ---Chapter
    for i = 1, #self.Chapters do
        local NewObj = NewObject(ItemDataClass, self, nil)
        NewObj.Args = {
            Config = self.Chapters[i],
            Text = Text(self.Chapters[i].sName)
        }
        NewObj.ChangeEvent = "Chapter_Change_Event"
        NewObj.bSelect = false
        NewObj.ChangeHandel = function(InChapter)
            self:ChapterChange(InChapter)
        end
        if self.CurrentChapter == nil then
            self.CurrentChapter = NewObj
            NewObj.bSelect = true
        end
        self.ChapterList:AddItem(NewObj)
    end
end

function Develop:ChapterChange(InChapter)
    if self.CurrentChapter then
        self.CurrentChapter:Change(false)
    end
    self.CurrentChapter = InChapter
    self.CurrentChapter:Change(true)

    self:ShowLevel()
end

function Develop:ShowLevel()
    if not self.CurrentChapter then
        return
    end
    self.CurrentLevel = nil
    self:DoClearListItems(self.LevelList)
    local Levels = self.CurrentChapter.Args.Config.tbLevel
    local Path = "/Game/UI/UMG/Develop/Widgets/uw_develop_item_data"
    local ItemDataClass = UE4.UClass.Load(Path)
    for i = 1, #Levels do
        local NewObj = NewObject(ItemDataClass, self, nil)
        local tbLvCfg = ChapterLevel.Get(Levels[i])
        NewObj.Args = {
            Config = tbLvCfg,
            Text = Text(tbLvCfg.sName)
        }
        NewObj.ChangeEvent = "Level_Change_Event"
        NewObj.bSelect = false
        NewObj.ChangeHandel = function(InLevel)
            self:LevelChange(InLevel)
        end

        if self.CurrentLevel == nil then
            self.CurrentLevel = NewObj
            NewObj.bSelect = true
        end

        self.LevelList:AddItem(NewObj)
    end
end

function Develop:LevelChange(InLevel)
    if self.CurrentLevel then
        self.CurrentLevel:Change(false)
    end
    self.CurrentLevel = InLevel
    self.CurrentLevel:Change(true)
end

function Develop:ShowRole()
    local RoleList = UE4.TArray(UE4.FItemTemplate)
    UE4.UItemLibrary.GetCharacterTemplates(RoleList)

    local ItemDataClass = LoadClass("/Game/UI/UMG/Develop/Widgets/uw_develop_item_data")
    self:DoClearListItems(self.RoleList)
    for i = 1, RoleList:Length() do
        local NewObj = NewObject(ItemDataClass, self, nil)
        NewObj.Args = {
            Config = RoleList:Get(i),
            Text = Text(RoleList:Get(i).I18N)
        }
        NewObj.ChangeEvent = "Role_Change_Event"
        NewObj.bSelect = false
        NewObj.ChangeHandel = function(InRole)
            self:RoleChange(InRole)
        end

        if self.CurrentRole == nil then
            self.CurrentRole = NewObj
            NewObj.bSelect = true
        end
        self.RoleList:AddItem(NewObj)
    end
end

function Develop:RoleChange(InRole)
    if self.CurrentRole then
        self.CurrentRole:Change(false)
    end
    self.CurrentRole = InRole
    self.CurrentRole:Change(true)
end


function Develop:ShowCards()
    local cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(cards)

    local ItemDataClass = LoadClass("/Game/UI/UMG/Develop/Widgets/uw_develop_item_data")
    self:DoClearListItems(self.CardsList)
    for i = 1, cards:Length() do
        local NewObj = NewObject(ItemDataClass, self, nil)
        NewObj.Args = {
            Config = cards:Get(i),
            Text = Text(cards:Get(i):I18N())
        }
        NewObj.ChangeEvent = "Card_Change_Event"
        NewObj.bSelect = false
        NewObj.ChangeHandel = function(InCard)
            self:CardChange(InCard)
        end

        if self.CurrentCard == nil then
            self.CurrentCard = NewObj
            NewObj.bSelect = true
            self:ShowWeaponParts(self.CurrentCard.Args.Config)
        end
        self.CardsList:AddItem(NewObj)
    end
end
function Develop:CardChange(InCard)
    if self.CurrentCard then
        self.CurrentCard:Change(false)
    end
    self.CurrentCard = InCard
    self.CurrentCard:Change(true)
    self:ShowWeaponParts(InCard.Args.Config)
end
function Develop:ShowWeaponParts(InCard)
    local pWeapon = InCard:GetSlotWeapon()
    local parts = UE4.TArray(UE4.UItem)
    pWeapon:GetWeaponSlots(parts)

    local ItemDataClass = LoadClass("/Game/UI/UMG/Develop/Widgets/uw_develop_item_data")
    self:DoClearListItems(self.WeaponEquipParts)
    for i = 1, parts:Length() do
        local partsTemplate = UE4.UItemLibrary.GetWeaponPartsTemplate(parts:Get(i):TemplateId())
        if partsTemplate then
            local NewObj = NewObject(ItemDataClass, self, nil)
            NewObj.Args = {
                Config = parts:Get(i),
                Text = partsTemplate.WeaponPartsName
            }      
            self.WeaponEquipParts:AddItem(NewObj)
        end
    end
end

function Develop:ShowAllParts()
    local AllParts = UE4.TArray(UE4.FItemTemplate)
    UE4.UItemLibrary.GetWeaponPartsTemplates(AllParts)

    local ItemDataClass = LoadClass("/Game/UI/UMG/Develop/Widgets/uw_develop_item_data")  
    self:DoClearListItems(self.WeaponPartsList)
    for i = 1, AllParts:Length() do
        local partsTemplate = UE4.UItemLibrary.GetWeaponPartsTemplateForAppearID(AllParts:Get(i).AppearID)
        if partsTemplate then
            local NewObj = NewObject(ItemDataClass, self, nil)
            NewObj.Args = {
                Config = AllParts:Get(i),
                Text = partsTemplate.WeaponPartsName
            }
            NewObj.ChangeEvent = "Parts_Change_Event"
            NewObj.bSelect = false
            NewObj.ChangeHandel = function(InParts)
                self:PartsChange(InParts)
            end

            if self.CurrentParts == nil then
                self.CurrentParts = NewObj
                NewObj.bSelect = true
            end
            self.WeaponPartsList:AddItem(NewObj)
        end
    end
end
function Develop:PartsChange(InParts)
    if self.CurrentParts then
        self.CurrentParts:Change(false)
    end
    self.CurrentParts = InParts
    self.CurrentParts:Change(true)
end
function Develop:EquipWeaponParts()
    if self.CurrentCard == nil then return end
    if self.CurrentCard.Args.Config == nil then return end
    if self.CurrentParts == nil then return end
    if self.CurrentParts.Args.Config == nil then return end
    local pWeapon = self.CurrentCard.Args.Config:GetSlotWeapon() 
    local newPartsItem = me:DebugCreateItem(self.CurrentParts.Args.Config);
    if pWeapon ~= nil and newPartsItem ~= nil then
        pWeapon:AddSlotItem(newPartsItem:Detail(),newPartsItem )
        self:ShowWeaponParts(self.CurrentCard.Args.Config)
    end
end

return Develop
