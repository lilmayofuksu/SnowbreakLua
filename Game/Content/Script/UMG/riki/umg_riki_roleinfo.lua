-- ========================================================
-- @File    : umg_riki_roleinfo.lua
-- @Brief   : 图鉴角色详情
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

tbClass.BasicListItem = "/Game/UI/UMG/Riki/Widgets/uw_riki_rolelist.uw_riki_rolelist_C"
tbClass.VoiceListItem = "/Game/UI/UMG/Riki/Widgets/uw_riki_rolelist3.uw_riki_rolelist3_C"
tbClass.StoryListItem = "/Game/UI/UMG/Riki/Widgets/uw_riki_rolelist2.uw_riki_rolelist2_C"
function tbClass:Construct()
    -- self.Title:SetCustomEvent(function() UI.Open('RikiList',RikiLogic.tbType.Role) end, nil)
    self.Title:SetCustomEvent(
        function() 
            UI.Close(self);
            -- EventSystem.TriggerTarget(RikiLogic.tbType.Role, "EndRikiVoice")
        end, 
        function() 
            UI.Close(self);
            UI.OpenMainUI()
            UI.GC()
            -- EventSystem.TriggerTarget(RikiLogic.tbType.Role, "EndRikiVoice")
        end)

end

function tbClass:OnInit()
    self:DoClearListItems(self.List2)
    self:DoClearListItems(self.List3)

    BtnAddEvent(self.BtnFashion,function()
        local pItem = self.tbRoleData.pItem
        local tbCardTemplate = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
        local tbParam = {
            CharacterTemplate = tbCardTemplate,
            SkinIndex = 1,
        }
        UI.Open("RoleFashion", tbParam);
    end)

    BtnAddEvent(self.BtnLeft, function()
        local tbData = RikiLogic:GetLeftRole(self.tbRoleData.Id)--self.tbRoleData.OnLeft(self.tbRoleData.Id)
        
        self:Update(tbData)
    end)

    BtnAddEvent(self.BtnRight, function()
        local tbData = RikiLogic:GetRightRole(self.tbRoleData.Id)--self.tbRoleData.OnRight(self.tbRoleData.Id)
        self:Update(tbData)
    end)

    self:InitSkillInfo()
end

function tbClass:Update(tbData)
    EventSystem.TriggerTarget(RikiLogic.tbType.Role, "EndRikiVoice")
    self:DoClearListItems(self.List2)
    -- self:DoClearListItems(self.List3)
    self.tbRoleData = tbData or RikiLogic:GetNowRoleData()
    local pItem = self.tbRoleData.pItem
    
    self.Content:Init({
        {sName = Text('ui.TxtHandbook15'), nIcon = 1701020,bLock = false },  -- 队员信息
        {sName = Text('ui.TxtRolePiece'), nIcon = 1701021,bLock = self.tbRoleData.nGet==0},  --个人故事
        {sName = Text('ui.TxtHandbook7'), nIcon = 1701022,bLock = self.tbRoleData.nGet==0}   --角色语音
        }, 
        function(_, nPage)
            if self.nPage ~= nPage then
                EventSystem.TriggerTarget(RikiLogic.tbType.Role, "EndRikiVoice")
                Audio.PlaySounds(3005)
                self:OpenPage(nPage)
            end
        end
    )

    WidgetUtils.Visible(self.Content)
    if self.nPage == nil and self.tbRoleData.nPage ~= nil then 
        self.nPage = self.tbRoleData.nPage
    end

    self:UpdateRoleInfo()

    if self.nPage ~= 0 and self.tbRoleData.nGet == 1 then
        self:OpenPage(self.nPage)
    else
        self:OpenPage(0)
    end
    RikiLogic:SetNowRoleData(self.tbRoleData)
end

function tbClass:OnOpen(tbData)
    self.tbRoleData = tbData or RikiLogic:GetNowRoleData()
	local pItem = self.tbRoleData.pItem
	
    self.Content:Init({
        {sName = Text('ui.TxtHandbook15'), nIcon = 1701020,bLock = false },  -- 队员信息
        {sName = Text('ui.TxtRolePiece'), nIcon = 1701021,bLock = self.tbRoleData.nGet==0},  --个人故事
        {sName = Text('ui.TxtHandbook7'), nIcon = 1701022,bLock = self.tbRoleData.nGet==0}   --角色语音
        }, 
        function(_, nPage)
            if self.nPage ~= nPage then
                EventSystem.TriggerTarget(RikiLogic.tbType.Role, "EndRikiVoice")
                Audio.PlaySounds(3005)
                self:OpenPage(nPage)
            end
        end
    )

    WidgetUtils.Collapsed(self.BtnLeft)
    WidgetUtils.Collapsed(self.BtnRight)

    if self.tbRoleData.nTotal > 1 then
        WidgetUtils.Visible(self.BtnLeft)
        WidgetUtils.Visible(self.BtnRight)
    end

	WidgetUtils.Visible(self.Content)

    if self.nPage == nil and self.tbRoleData.nPage ~= nil then 
        self.nPage = self.tbRoleData.nPage
    end

	self:UpdateRoleInfo()
    -- self:UpdateSkillInfo()
    if self.nPage then
        self:OpenPage(self.nPage)
    else
        self:OpenPage(0)
    end
    RikiLogic:SetNowRoleData(self.tbRoleData)

end

function tbClass:OnClose()
    Preview.Destroy()
    EventSystem.TriggerTarget(RikiLogic.tbType.Role, "EndRikiVoice")
end

function tbClass:UpdateRoleInfo()
    self:DoClearListItems(self.List2)
    -- self:DoClearListItems(self.List3)
	local pItem = self.tbRoleData.pItem

	-- SetTexture(self.Girl, pItem:Icon(), true)
	self.TxtName:SetText(Text(pItem:I18N()))
    self.TxtTitle:SetText(Text(pItem:I18N()..'_title'))
    --print("pItem:Color():",pItem:Color())
    SetTexture(self.ImgQuality, Item.RoleColor_short[pItem:Color()])
    SetTexture(self.ImgQuality2, Item.RoleColorWeapon[pItem:Color()])
    self.Quality:Set(pItem:Color())

    -- SetTexture(self.ImgQuality, Item.RoleColor_short[InCard:Color()])
    -- SetTexture(self.ImgQuality2, Item.RoleColorWeapon[InCard:Color()])
    WidgetUtils.Collapsed(self.PanelInfo)
	WidgetUtils.Collapsed(self.PanelStory)
	WidgetUtils.Collapsed(self.PanelVoice)

	if self.tbRoleData.nGet == 1 then
		WidgetUtils.Collapsed(self.PanelLock)
	else
		WidgetUtils.Visible(self.PanelLock)
	end
    Preview.Destroy()
    -- PreviewScene.Reset()
    PreviewScene.Enter(PreviewType.role_lvup)

    Preview.PreviewByGDPL(UE4.EItemType.CharacterCard,pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level(),PreviewType.role_riki)
    Preview.PlayCameraAnimByCfgByID(0, PreviewType.role_riki)
    
    self:UpdateBasicInfo()
    
    self:UpdateStoryInfo()
    self:UpdateVoiceInfo()

    local tbWeapon = pItem:DefaultWeaponGPDL()
    if pItem.DefaultWeaponGPDL then
        local tbWeapon = pItem:DefaultWeaponGPDL()
        print(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level(),"/",tbWeapon[1], tbWeapon[2], tbWeapon[3], tbWeapon[4])
        SetTexture(self.TypeGun, Item.WeaponTypeIcon[tbWeapon.Detail] )
    end
    SetTexture(self.RoleIcon, pItem:Icon())
end

function tbClass:UpdateBasicInfo()
    self.ScrollBox_114:ClearChildren()

    local pWidget1 = LoadWidget(self.BasicListItem)
    local cfg = RikiLogic.tbCfg[self.tbRoleData.Id]
    if pWidget1 and cfg then
        local tbParam = {
            Title = Text(cfg.Extension1),
            Content = Text(cfg.Extension2)
        }
        local child = self.ScrollBox_114:AddChild(pWidget1)
        child:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Right)
        pWidget1:Display(tbParam)
    end

    local pWidget2 = LoadWidget(self.BasicListItem)

    if pWidget2 and cfg then
        local tbParam = {
            Title = Text(cfg.Extension3),
            Content = Text(cfg.Extension4)
        }
        local child = self.ScrollBox_114:AddChild(pWidget2)
        child:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Right)
        pWidget2:Display(tbParam)
    end

    self.CustomTextBlock_263:SetText(Text("TxtHandbook15"))
end

function tbClass:UpdateStoryInfo()
    local ChapterCfg = self.tbRoleData.tbChapterCfg
    local count = 0
    if ChapterCfg then
        count = #ChapterCfg.tbLevel
    end
    for i=1,count do
        local levelCfg = RoleLevel.Get(ChapterCfg.tbLevel[i])
        if levelCfg and levelCfg.nType == RoleLevelType.PLOT then
            local pWidget = LoadWidget(self.StoryListItem)
            if pWidget == nil then
                break
            end
            pWidget.tbData = {}
            pWidget.tbData.ClickFun = function(cfg) 
                self:UpdateChange(cfg.nID)
                self:ShowDetail(cfg, self.ChapterCfg)
            end
            pWidget.tbData.CheckFun = function(cfg,sLockDes)
                -- if bUnLock == false then
                UI.ShowTip(sLockDes[1])
                return
                -- end
            end
            pWidget.tbData.tbCfg = RoleLevel.Get(levelCfg.nID)-- ChapterLevel.Get(levelCfg.nID)
            pWidget.tbData.tbChapterCfg = self.tbRoleData.tbChapterCfg
            local tbCond = {}
            table.insert(tbCond,{Condition.PRE_LEVEL,levelCfg.nID})
            local bUnLock, sLockDes = Condition.Check(tbCond)

            pWidget.tbData.bUnlocked = bUnLock == true
            if i==1 or pWidget.tbData.bUnlocked == true then
                pWidget.tbData.bExpand = true
            else
                pWidget.tbData.bExpand = false
            end

            self.List2:AddItem(pWidget)
        end
    end

end

function tbClass:UpdateVoiceInfo()
	-- self:DoClearListItems(self.List3)
    self.List3:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    local tbVoiceCfgs = RikiLogic.tbVoiceCfg[self.tbRoleData.Id]
    -- self.List3:ScrollToStart()
    -- self.List3:NavigateToIndex(1)
    self.List3:ScrollIndexIntoView(1)
    local tbList = self.List3:GetListItems()
    local nLength = tbList:Length()
    -- for i=1,nLength do
    -- print("nLength:",nLength)

    if tbVoiceCfgs then
        for index,cfg in pairs(tbVoiceCfgs) do
            if nLength >= index then 
                local tbData = tbList:Get(index)
            -- tbData.Data.N = tbData.Data.Count * self.nCount
                tbData.Data.VoiceID = cfg.VoiceID
                tbData.Data.pCard = self.tbRoleData.pItem
                tbData.Data.TxtKey = cfg.TxtKey
            else
                local pWidget = LoadWidget(self.VoiceListItem)
                if pWidget then
                    pWidget.Data = {}
                    pWidget.Data.VoiceID = cfg.VoiceID
                    pWidget.Data.pCard = self.tbRoleData.pItem
                    pWidget.Data.TxtKey = cfg.TxtKey
                    -- print("cfg.TxtKey:",Text(cfg.TxtKey))
                    self.List3:AddItem(pWidget)
                end
            end
        end
    end
    EventSystem.TriggerTarget(RikiLogic.tbType.Role, "ChangeRikiVoice")
end

function tbClass:InitSkillInfo()
    self.BtnSkill:SetClickMethod(UE4.EButtonClickMethod.MouseDown)
    self.BtnSkill:SetTouchMethod(UE4.EButtonTouchMethod.Down)
    -- self.BtnSkill.OnCheckStateChanged:RemoveAll()
    self.BtnSkill.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            Audio.PlaySounds(3005)
            local pItem = self.tbRoleData.pItem
            local tbCardTemplate = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
            -- Dump(tbCardTemplate)
            local Skills, SkillTags = RoleCard.GetItemShowSkills(tbCardTemplate)
            -- Dump(Skills)
            UI.Open("SkillTip",tbCardTemplate, Skills[2],2,RoleCard.SkillType.NormalSkill,false,true,true)
        end
    )


    
end

function tbClass:OpenPage(nPage)
	if nPage ~= 0 and self.tbRoleData.nGet ~= 1 then
        UI.ShowTip("ui.RikiRoleUnlock1")
		return
	end

	WidgetUtils.Collapsed(self.PanelInfo)
	WidgetUtils.Collapsed(self.PanelStory)
	WidgetUtils.Collapsed(self.PanelVoice)
	if nPage == 0 then
		WidgetUtils.Visible(self.PanelInfo)
        self.ScrollBox_114:ScrollToStart()
	elseif nPage == 1 then
		WidgetUtils.Visible(self.PanelStory)
	elseif nPage == 2 then
		WidgetUtils.Visible(self.PanelVoice)
	end

	self.Content:SelectPage(nPage)
	self.nPage = nPage
    self.tbRoleData.nPage = self.nPage
end

---刷新选中状态
function tbClass:UpdateChange(selectid)
    -- if not selectid or not self.tbLevelItem[selectid] then
    --     selectid = Role.GetChapterProgres()
    -- end
    -- for id, level in pairs(self.tbLevelItem) do
    --     level:SelectChange(id == selectid)
    -- end
end

---显示关卡细节
function tbClass:ShowDetail(tbLevelCfg, ChapterCfg)
    Role.SetLevelID(tbLevelCfg.nID)
    if Role.IsPlot(tbLevelCfg.nID) then
        -- UI.Open('StoryInfo', tbLevelCfg.nID)
        Chapter.SetLevelID(tbLevelCfg.nID)
        Launch.Start()

    end
end

return tbClass